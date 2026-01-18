import { useSupabaseQuery } from "./useSupabase";
import { supabase } from "../utils/supabase";
import type { DbTarget } from "../types/database";

/**
 * Type for target with aggregate score data
 */
export type TargetWithScore = DbTarget & {
  totalScore: number;
  maxScore: number;
  scoreCount: number;
  averageScore: number;
  classification:
    | "STRATEGIC"
    | "HIGH-VALUE"
    | "LEGITIMATE"
    | "AMBIGUOUS"
    | "OCCUPATION"
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
      classification: "STRATEGIC",
      classificationLabel: "STRATEGIC",
      statusLabel: "AUDITED",
      colorClass: "text-white",
      borderClass: "border-white/50",
    };
  } else if (totalScore >= 76) {
    return {
      classification: "HIGH-VALUE",
      classificationLabel: "HIGH-VALUE",
      statusLabel: "AUDITED",
      colorClass: "text-cyan-400",
      borderClass: "border-cyan-500/50",
    };
  } else if (totalScore >= 51) {
    return {
      classification: "LEGITIMATE",
      classificationLabel: "LEGITIMATE",
      statusLabel: "AUDITED",
      colorClass: "text-yellow-400",
      borderClass: "border-yellow-500/50",
    };
  } else if (totalScore >= 26) {
    return {
      classification: "AMBIGUOUS",
      classificationLabel: "AMBIGUOUS",
      statusLabel: "MIXED/AMBIGUOUS",
      colorClass: "text-orange-500",
      borderClass: "border-orange-500/50",
    };
  } else {
    return {
      classification: "OCCUPATION",
      classificationLabel: "OCCUPATION",
      statusLabel: "OCCUPATION",
      colorClass: "text-red-500",
      borderClass: "border-red-500/50",
    };
  }
}

/**
 * Hook: useTargetsWithScores
 * Fetches all targets with their aggregate community scores
 */
export function useTargetsWithScores() {
  return useSupabaseQuery<TargetWithScore[]>(async () => {
    // 1. Fetch all targets
    const { data: targets, error: targetsError } = await supabase
      .from("targets")
      .select("*")
      .order("created_at", { ascending: false });

    // If error or no data, use fallback targets for local development
    let targetsList = targets;
    if (targetsError || !targets || targets.length === 0) {
      const { FALLBACK_TARGETS } = await import('../data/targets');
      targetsList = FALLBACK_TARGETS;
    }

    // 2. Fetch aggregate scores for each target
    // We'll calculate the consensus score by averaging votes per metric, then normalizing
    const targetIds = targetsList.map((t) => t.id);

    const { data: votes, error: votesError } = await supabase
      .from("community_votes")
      .select("target_id, metric_id, vote_value")
      .in("target_id", targetIds);

    if (votesError) {
      console.warn(
        "Failed to fetch community votes, returning targets without scores",
        votesError,
      );
    }

    // 3. Calculate consensus scores per target
    // Group votes by target and metric to calculate per-metric averages
    const targetMetricVotes: Record<string, Record<number, number[]>> = {};

    (votes || []).forEach((vote) => {
      if (!vote.target_id || vote.metric_id == null || vote.vote_value == null)
        return;

      if (!targetMetricVotes[vote.target_id]) {
        targetMetricVotes[vote.target_id] = {};
      }
      if (!targetMetricVotes[vote.target_id][vote.metric_id]) {
        targetMetricVotes[vote.target_id][vote.metric_id] = [];
      }
      targetMetricVotes[vote.target_id][vote.metric_id].push(vote.vote_value);
    });

    // 4. Map targets to TargetWithScore
    const targetsWithScores: TargetWithScore[] = targetsList.map((target) => {
      const metricVotes = targetMetricVotes[target.id];

      if (!metricVotes || Object.keys(metricVotes).length === 0) {
        // No votes for this target
        return {
          ...target,
          totalScore: 0,
          maxScore: 100,
          scoreCount: 0,
          averageScore: 0,
          ...classifyTarget(0, 0),
        };
      }

      // Calculate average vote per metric
      const metricAverages: number[] = [];
      let totalVoteCount = 0;

      Object.values(metricVotes).forEach((voteValues) => {
        const metricAvg =
          voteValues.reduce((sum, v) => sum + v, 0) / voteValues.length;
        metricAverages.push(metricAvg);
        totalVoteCount += voteValues.length;
      });

      // Sum all metric averages (each metric is 1-5 scale)
      const sumOfAverages = metricAverages.reduce((sum, avg) => sum + avg, 0);

      // Calculate average score across metrics that have been scored
      const averageScore = sumOfAverages / metricAverages.length;

      // Normalize to 0-100 scale based on average of scored metrics
      // This approach shows the quality of what HAS been scored, not penalizing
      // targets for incomplete coverage
      // Example: 14 metrics averaging 3.79/5 = 76/100 (not 53/100)
      const totalScore = Math.round((averageScore / 5) * 100);

      const classification = classifyTarget(totalScore, totalVoteCount);

      return {
        ...target,
        totalScore,
        maxScore: 100,
        scoreCount: totalVoteCount,
        averageScore,
        ...classification,
      };
    });

    return targetsWithScores;
  });
}
