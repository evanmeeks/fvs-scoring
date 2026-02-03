"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from "react";
import { createClient } from "~/lib/supabase/client";
import { useUI } from "~/context/AppContext";
import Icon from "~/components/Icon";

export function Inspector() {
  const supabase = createClient();
  const {
    selectedMetric: metric,
    isInspectorOpen,
    setIsInspectorOpen,
    setSubmissionModalOpen,
    setDiscussionModalOpen,
  } = useUI();

  const [discussionCount, setDiscussionCount] = useState(0);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  useEffect(() => {
    if (!metric) return;

    const fetchDiscussionCount = async () => {
      const { count, error } = await supabase
        .from("metric_discussions")
        .select("*", { count: "exact", head: true })
        .eq("metric_id", Number(metric.id));

      if (!error && count !== null) {
        setDiscussionCount(count);
      }
    };

    fetchDiscussionCount();
  }, [metric, supabase]);

  if (!isInspectorOpen && !metric) {
    return null;
  }

  if (!metric) {
    return (
      <aside className="w-80 bg-panel border-l border-border hidden xl:flex flex-col shrink-0 items-center justify-center text-text-muted text-center p-8">
        <div className="w-16 h-16 rounded-full bg-border/50 flex items-center justify-center mb-4 border border-border">
          <Icon name="ads_click" className="text-3xl opacity-50" />
        </div>
        <h3 className="font-bold text-white mb-2">Detailed Inspection</h3>
        <p className="text-xs leading-relaxed max-w-[200px]">
          Select any metric row from the matrix to view definitions, scoring
          criteria, and community consensus data.
        </p>
      </aside>
    );
  }

  // Extract criteria from new structure or fallback
  let criteriaLow = {
    label: "Low Confidence",
    description:
      "Information is abstract, lacks referential stability, and cannot be acted upon.",
  };
  let criteriaHigh = {
    label: "High Confidence",
    description:
      "Concrete details provided. Identifies specific actors, programs, or mechanisms.",
  };

  if (metric.scoringCriteria && metric.scoringCriteria.length >= 2) {
    const low = metric.scoringCriteria.find((c) => c.score === 1);
    const high = metric.scoringCriteria.find((c) => c.score === 5);
    if (low) criteriaLow = { label: low.label, description: low.description };
    if (high)
      criteriaHigh = { label: high.label, description: high.description };
  } else if (metric.criteria) {
    criteriaLow.label =
      metric.criteria.split(", ")[0]?.split("=")[1] || "Low Confidence";
    criteriaHigh.label =
      metric.criteria.split(", ")[1]?.split("=")[1] || "High Confidence";
  }

  const communityScore = metric.communityScore || 0;

  return (
    <aside className="w-80 bg-panel border-l border-border hidden xl:flex flex-col shrink-0">
      <div className="p-6 border-b border-border flex justify-between items-center">
        <span className="text-[10px] text-primary mono font-bold uppercase tracking-wider">
          INSPECTOR
        </span>
        <button
          onClick={() => setIsInspectorOpen(false)}
          className="text-text-muted hover:text-white transition-colors"
        >
          <Icon name="close" className="text-sm" />
        </button>
      </div>

      <div className="p-6 space-y-8 overflow-y-auto">
        <div className="space-y-2">
          <h3 className="text-xl font-bold text-white">{metric.name}</h3>
          <p className="text-sm text-text-muted">{metric.question}</p>
        </div>

        <div className="space-y-4">
          <div className="text-[10px] text-text-muted mono uppercase">
            Scale Calibration
          </div>
          <div className="space-y-3">
            <div className="p-3 bg-background border-l-2 border-red-600 rounded">
              <div className="text-[10px] text-red-600 font-bold mb-1">
                SCORE 1: {criteriaLow.label}
              </div>
              <div className="text-xs text-text-muted">
                {criteriaLow.description}
              </div>
            </div>
            <div className="p-3 bg-background border-l-2 border-primary rounded">
              <div className="text-[10px] text-primary font-bold mb-1">
                SCORE 5: {criteriaHigh.label}
              </div>
              <div className="text-xs text-text-muted">
                {criteriaHigh.description}
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <div className="text-[10px] text-text-muted mono uppercase">
            Analyst Consensus
          </div>
          <div className="p-4 rounded bg-background border border-border">
            <div className="flex justify-between items-center mb-2">
              <div className="text-[10px] text-text-muted uppercase">
                Community Score
              </div>
              <div className="text-sm font-mono text-white font-bold">
                {communityScore.toFixed(1)}
              </div>
            </div>
            <div className="h-2 bg-border rounded-full overflow-hidden mb-2">
              <div
                className="h-full bg-gradient-to-r from-primary to-emerald-400"
                style={{ width: `${(communityScore / 5) * 100}%` }}
              ></div>
            </div>
            <p className="text-[10px] text-text-muted">
              n=1,240 verified inputs
            </p>
          </div>
        </div>

        <div className="border-t border-border pt-6">
          <button
            onClick={() => {
              if (!user) return;
              setSubmissionModalOpen(true);
            }}
            className={`w-full py-2 ${!user ? "opacity-60 cursor-not-allowed" : "bg-border hover:bg-white hover:text-black"} text-white font-bold text-xs uppercase tracking-wider rounded transition-colors mb-3 flex items-center justify-center gap-2`}
            disabled={!user}
          >
            <Icon name="edit_square" className="text-sm" />
            Submit RFC Proposal
          </button>
          <button
            onClick={() => setDiscussionModalOpen(true)}
            className="w-full py-2 border border-border hover:border-primary text-text-muted hover:text-primary font-bold text-xs uppercase tracking-wider rounded transition-colors flex items-center justify-center gap-2"
          >
            <Icon name="forum" className="text-sm" />
            View Discussion {discussionCount > 0 && `(${discussionCount})`}
          </button>
        </div>
      </div>
    </aside>
  );
}

export default Inspector;
