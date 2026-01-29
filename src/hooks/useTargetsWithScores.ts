"use client";

import { useMemo, useState, useEffect } from "react";
import { createClient } from "~/lib/supabase/client";
import type { DbTarget } from "~/types/database";

/**
 * Type for target with aggregate score data
 */
export type TargetWithScore = DbTarget & {
  totalScore: number;
  maxScore: number;
  scoreCount: number;
  averageScore: number;
  classification:
    | "CONSENSUS"
    | "HIGH-CONFIDENCE"
    | "CREDIBLE"
    | "SPECULATIVE"
    | "LOW-CONFIDENCE"
    | "UNSCORED";
  classificationLabel: string;
  statusLabel: string;
  colorClass: string;
  borderClass: string;
};

/**
 * Classifies a target based on its total score
 */
function classifyTarget(
  totalScore: number,
  scoreCount: number,
): Pick<
  TargetWithScore,
  | "classification"
  | "classificationLabel"
  | "statusLabel"
  | "colorClass"
  | "borderClass"
> {
  if (scoreCount === 0 || totalScore === 0) {
    return {
      classification: "UNSCORED",
      classificationLabel: "UNSCORED",
      statusLabel: "PENDING AUDIT",
      colorClass: "text-gray-400",
      borderClass: "border-gray-700",
    };
  }

  if (totalScore >= 91) {
    return {
      classification: "CONSENSUS",
      classificationLabel: "CONSENSUS FORECAST",
      statusLabel: "SCORED",
      colorClass: "text-white",
      borderClass: "border-white/50",
    };
  } else if (totalScore >= 76) {
    return {
      classification: "HIGH-CONFIDENCE",
      classificationLabel: "HIGH-CONFIDENCE",
      statusLabel: "SCORED",
      colorClass: "text-cyan-400",
      borderClass: "border-cyan-500/50",
    };
  } else if (totalScore >= 51) {
    return {
      classification: "CREDIBLE",
      classificationLabel: "CREDIBLE",
      statusLabel: "SCORED",
      colorClass: "text-yellow-400",
      borderClass: "border-yellow-500/50",
    };
  } else if (totalScore >= 26) {
    return {
      classification: "SPECULATIVE",
      classificationLabel: "SPECULATIVE",
      statusLabel: "SPECULATIVE",
      colorClass: "text-orange-500",
      borderClass: "border-orange-500/50",
    };
  } else {
    return {
      classification: "LOW-CONFIDENCE",
      classificationLabel: "LOW CONFIDENCE",
      statusLabel: "LOW CONFIDENCE",
      colorClass: "text-red-500",
      borderClass: "border-red-500/50",
    };
  }
}

/**
 * Hook: useTargetsWithScores
 * Fetches all targets with their aggregate community scores
 */
/* eslint-disable @typescript-eslint/no-explicit-any */
export function useTargetsWithScores() {
  const supabase = createClient();
  const [targets, setTargets] = useState<DbTarget[] | undefined>(undefined);
  const [aggregates, setAggregates] = useState<any[]>([]);
  const [targetsLoading, setTargetsLoading] = useState(true);
  const [aggregatesLoading, setAggregatesLoading] = useState(true);
  const [targetsError, setTargetsError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchTargets = async () => {
      const { data, error } = await supabase
        .from("targets")
        .select("*")
        .order("created_at", { ascending: false });
      if (error) setTargetsError(error as unknown as Error);
      else setTargets((data ?? []) as DbTarget[]);
      setTargetsLoading(false);
    };
    fetchTargets();
  }, [supabase]);

  useEffect(() => {
    const fetchAggregates = async () => {
      const { data, error } = await supabase
        .from("target_score_aggregates")
        .select("*");
      if (!error) setAggregates((data ?? []) as any[]);
      setAggregatesLoading(false);
    };
    fetchAggregates();
  }, [supabase]);

  const data = useMemo(() => {
    if (!targets) return undefined;

    return targets.map((target): TargetWithScore => {
      /* eslint-disable @typescript-eslint/no-explicit-any */
      // The view returns one row per target×metric — filter all rows for this target
      const targetAggs = (aggregates ?? []).filter(
        (a: any) => a.target_id === target.id,
      ) as any[];

      // Only consider metrics that have actual votes
      const scoredMetrics = targetAggs.filter(
        (a) => Number(a.total_votes ?? 0) > 0,
      );

      if (scoredMetrics.length === 0) {
        return {
          ...target,
          totalScore: 0,
          maxScore: 100,
          scoreCount: 0,
          averageScore: 0,
          ...classifyTarget(0, 0),
        };
      }

      // Average the per-metric averages to get an overall 1-5 score, then normalize to 0-100
      const avgAcrossMetrics =
        scoredMetrics.reduce(
          (sum, a) => sum + Number(a.average_score ?? 0),
          0,
        ) / scoredMetrics.length;
      const totalScore = Math.round((avgAcrossMetrics / 5) * 100);
      const scoreCount = scoredMetrics.reduce(
        (sum, a) => sum + Number(a.total_votes ?? 0),
        0,
      );

      return {
        ...target,
        totalScore,
        maxScore: 100,
        scoreCount,
        averageScore: avgAcrossMetrics,
        ...classifyTarget(totalScore, scoreCount),
      };
    });
  }, [targets, aggregates]);

  return {
    data,
    loading: targetsLoading || aggregatesLoading,
    error: targetsError ? targetsError : null,
  };
}
