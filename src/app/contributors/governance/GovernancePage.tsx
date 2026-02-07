"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useState, useMemo, useEffect, useCallback } from "react";
import { useMetrics, useUI, useTarget } from "~/context/AppContext";
import MetricTable from "~/components/MetricTable";
import RFCProposalList from "~/components/RFCProposalList";
import { createClient } from "~/lib/supabase/client";
import { LandingView } from "~/components/views/LandingView";
import type { Metric } from "~/context/AppContext";

type VoteEntry = { confidence: string | null; notes: string };
type VoteState = Record<string, VoteEntry>;
type SaveStatusState = Record<string, "saving" | "saved" | "error">;
type DebounceTimers = Record<string, ReturnType<typeof setTimeout>>;

export function GovernancePage() {
  const supabase = createClient();
  const { FVS_METRICS } = useMetrics();
  const { setIsInspectorOpen, setSelectedMetric } = useUI();
  const { activeTarget } = useTarget();
  const [user, setUser] = useState<any>(null);
  const [userVotesData, setUserVotesData] = useState<any[]>([]);
  const [localVotes, setLocalVotes] = useState<VoteState>({});
  const [saveStatus, setSaveStatus] = useState<SaveStatusState>({});

  // Fetch user
  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  // Fetch user scores (governance votes)
  const fetchUserScores = useCallback(async () => {
    if (!user || !activeTarget?.id) return;
    try {
      const { data, error } = await supabase
        .from("user_scores")
        .select("*, metrics(*)")
        .eq("user_id", user.id)
        .eq("target_id", activeTarget.id);
      if (error) throw error;
      setUserVotesData(data || []);
    } catch (err) {
      console.error("Error fetching user scores:", err);
    }
  }, [user, activeTarget?.id, supabase]);

  useEffect(() => {
    if (user && activeTarget?.id) {
      fetchUserScores();
    }
  }, [user, activeTarget?.id, fetchUserScores]);

  // Merge remote votes with local votes
  const votes = useMemo(() => {
    const merged: VoteState = {};

    if (userVotesData) {
      userVotesData.forEach((v: any) => {
        if (v.metric_id == null) return;
        if (!v.action_vote && !v.action_notes) return;

        merged[String(v.metric_id)] = {
          confidence: v.action_vote || null,
          notes: v.action_notes || "",
        };
      });
    }

    Object.keys(localVotes).forEach((metricId) => {
      merged[metricId] = {
        ...merged[metricId],
        ...localVotes[metricId],
      };
    });

    return merged;
  }, [userVotesData, localVotes]);

  const debounceTimers = React.useRef<DebounceTimers>({});

  // Submit governance vote with debouncing
  const submitGovernanceVote = async (
    targetId: string,
    metricId: number,
    actionVote: string | null,
    actionNotes: string,
  ) => {
    const userData = await supabase.auth.getUser();
    if (!userData.data.user) throw new Error("User not authenticated");

    const userId = userData.data.user.id;
    const timestamp = new Date().toISOString();

    // Check if record exists
    const { data: existing, error: fetchError } = await supabase
      .from("user_scores")
      .select("score")
      .eq("user_id", userId)
      .eq("target_id", targetId)
      .eq("metric_id", metricId)
      .maybeSingle();

    if (fetchError) throw fetchError;

    if (existing) {
      const { error } = await (supabase
        .from("user_scores") as any)
        .update({
          action_vote: actionVote || null,
          action_notes: actionNotes,
          updated_at: timestamp,
        })
        .eq("user_id", userId)
        .eq("target_id", targetId)
        .eq("metric_id", metricId);

      if (error) throw error;
    } else {
      const { error } = await (supabase.from("user_scores") as any).insert({
        user_id: userId,
        target_id: targetId,
        metric_id: metricId,
        score: 0,
        action_vote: actionVote || null,
        action_notes: actionNotes,
        updated_at: timestamp,
      });

      if (error) throw error;
    }
  };

  const handleVoteChange = async (
    metricId: number | string,
    field: "confidence" | "notes",
    value: string | null,
  ) => {
    const metricKey = String(metricId);
    const currentVote = votes[metricKey] || { confidence: null, notes: "" };
    const newVote: VoteEntry = { ...currentVote, [field]: value };

    setLocalVotes((prev) => ({
      ...prev,
      [metricKey]: newVote,
    }));

    if (debounceTimers.current[metricKey]) {
      clearTimeout(debounceTimers.current[metricKey]);
    }

    setSaveStatus((prev) => ({ ...prev, [metricKey]: "saving" }));

    debounceTimers.current[metricKey] = setTimeout(async () => {
      try {
        await submitGovernanceVote(
          activeTarget.id,
          Number(metricId),
          newVote.confidence ?? "",
          newVote.notes,
        );

        setSaveStatus((prev) => ({ ...prev, [metricKey]: "saved" }));
        setTimeout(() => {
          setSaveStatus((prev) => {
            const next: SaveStatusState = { ...prev };
            delete next[metricKey];
            return next;
          });
        }, 2000);
      } catch (error) {
        console.error("Governance save failed", error);
        setSaveStatus((prev) => ({ ...prev, [metricKey]: "error" }));
      }
    }, 500);
  };

  const handleSelect = (metric: Metric) => {
    setSelectedMetric(metric);
    setIsInspectorOpen(true);
  };

  return (
    <LandingView>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in">
        <MetricTable
          data={FVS_METRICS}
          scores={{}}
          votes={votes}
          onVoteChange={handleVoteChange}
          onSelect={handleSelect}
          mode="governance"
          saveStatus={saveStatus}
        />
        <div className="mt-8">
          <RFCProposalList />
        </div>
      </div>
    </LandingView>
  );
}
