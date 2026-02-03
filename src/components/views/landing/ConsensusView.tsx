"use client";

import { useMemo, useEffect, useState } from "react";
import {
  useTargetsWithScores,
  type TargetWithScore,
} from "~/hooks/useTargetsWithScores";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
} from "recharts";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { generateTargetSlug, findTargetBySlug } from "~/utils/urlSlug";
import { createClient } from "~/lib/supabase/client";
import { FVS_METRICS, type QddMetric } from "~/data/metrics";
import ShareButton from "~/components/shared/ShareButton";
import { generateGlobalConsensusOgImageUrl } from "~/utils/seo";

interface ConsensusViewProps {
  activeTargetSlug?: string;
}

interface MetricScore {
  metricId: number;
  metricName: string;
  averageScore: number;
  voteCount: number;
}

type TopTargetDatum = {
  name: string;
  fullName: string;
  score: number;
  classification: TargetWithScore["classification"];
  target: TargetWithScore;
};

export const ConsensusView = ({ activeTargetSlug }: ConsensusViewProps) => {
  const { data: targets, loading, error } = useTargetsWithScores();
  const router = useRouter();
  const supabase = createClient();
  const [metricScores, setMetricScores] = useState<MetricScore[]>([]);
  const [communityVotes, setCommunityVotes] = useState<any[]>([]);

  // Find the active target from slug
  const activeTarget = useMemo(() => {
    if (!activeTargetSlug || !targets || targets.length === 0) return null;
    return findTargetBySlug(targets, activeTargetSlug);
  }, [activeTargetSlug, targets]);

  // Fetch community votes for active target
  useEffect(() => {
    if (!activeTarget) return;
    const fetchVotes = async () => {
      const { data, error } = await supabase
        .from("community_votes")
        .select("*, metrics(*)")
        .eq("target_id", activeTarget.id);
      if (!error) setCommunityVotes(data ?? []);
    };
    fetchVotes();
  }, [activeTarget, supabase]);

  // Calculate metric scores from community votes
  useEffect(() => {
    if (!communityVotes || !activeTarget) return;

    const metricMap: Record<number, { total: number; count: number }> = {};
    /* eslint-disable @typescript-eslint/no-explicit-any */
    (communityVotes as any[]).forEach((vote: any) => {
      if (vote.metric_id == null || vote.vote_value == null) return;
      if (!metricMap[vote.metric_id]) {
        metricMap[vote.metric_id] = { total: 0, count: 0 };
      }
      metricMap[vote.metric_id].total += vote.vote_value;
      metricMap[vote.metric_id].count += 1;
    });

    const scores: MetricScore[] = Object.entries(metricMap).map(
      ([metricId, stats]) => {
        const metric = FVS_METRICS.find(
          (m: QddMetric) => m.id === parseInt(metricId, 10),
        );
        return {
          metricId: parseInt(metricId, 10),
          metricName: metric?.name || `Metric ${metricId}`,
          averageScore: stats.total / stats.count,
          voteCount: stats.count,
        };
      },
    );

    scores.sort((a, b) => a.metricId - b.metricId);
    setMetricScores(scores);
  }, [communityVotes, activeTarget]);

  // Calculate global stats
  const globalStats = useMemo(() => {
    if (!targets || targets.length === 0) {
      return {
        avgScore: 0,
        totalAudits: 0,
        dominantClassification: "UNSCORED",
        dominantClassificationLabel: "No Data",
        dominantClassificationColor: "text-gray-500",
        dominantPercentage: 0,
        classificationDistribution: {} as Record<string, number>,
      };
    }

    const scoredTargets = targets.filter((t) => t.scoreCount > 0);
    const totalScores = scoredTargets.reduce(
      (sum, t) => sum + t.totalScore,
      0,
    );
    const avgScore =
      scoredTargets.length > 0
        ? Math.round(totalScores / scoredTargets.length)
        : 0;
    const totalAudits = targets.reduce((sum, t) => sum + t.scoreCount, 0);

    const classificationCounts: Record<string, number> = {};
    targets.forEach((t) => {
      classificationCounts[t.classification] =
        (classificationCounts[t.classification] || 0) + 1;
    });

    let dominantClassification = "UNSCORED";
    let maxCount = 0;
    Object.entries(classificationCounts).forEach(([classification, count]) => {
      if (count > maxCount) {
        maxCount = count;
        dominantClassification = classification;
      }
    });

    const dominantTarget = targets.find(
      (t) => t.classification === dominantClassification,
    );
    const dominantPercentage =
      targets.length > 0 ? Math.round((maxCount / targets.length) * 100) : 0;

    return {
      avgScore,
      totalAudits,
      dominantClassification,
      dominantClassificationLabel:
        dominantTarget?.classificationLabel || dominantClassification,
      dominantClassificationColor:
        dominantTarget?.colorClass || "text-gray-500",
      dominantPercentage,
      classificationDistribution: classificationCounts,
    };
  }, [targets]);

  const topTargetsData: TopTargetDatum[] = useMemo(() => {
    if (!targets) return [];
    return targets
      .filter((t) => t.scoreCount > 0)
      .sort((a, b) => b.totalScore - a.totalScore)
      .slice(0, 8)
      .map((t) => ({
        name: t.name.length > 20 ? t.name.substring(0, 20) + "..." : t.name,
        fullName: t.name,
        score: t.totalScore,
        classification: t.classification,
        target: t,
      }));
  }, [targets]);

  const classificationRadarData = useMemo(() => {
    if (!targets || targets.length === 0) return [];

    const classifications = [
      "CONSENSUS",
      "HIGH-CONFIDENCE",
      "CREDIBLE",
      "SPECULATIVE",
      "LOW-CONFIDENCE",
      "UNSCORED",
    ];
    return classifications.map((classification) => {
      const count = globalStats.classificationDistribution[classification] || 0;
      return {
        classification: classification.replace("-", " "),
        count,
      };
    });
  }, [targets, globalStats]);

  const handleTargetClick = (target: TargetWithScore) => {
    const slug = generateTargetSlug(target);
    router.push(`/audit-target/${slug}`);
  };

  if (loading) {
    return (
      <div
        id="view-consensus"
        className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in"
      >
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-ops-accent"></div>
          <p className="text-ops-text-dim text-sm mt-4 font-mono">
            Loading consensus data...
          </p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div
        id="view-consensus"
        className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in"
      >
        <div className="text-center py-12">
          <div className="text-red-500 font-mono text-sm">
            Error loading consensus data: {error.message}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div
      id="view-consensus"
      className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in"
    >
      {/* Hero Section */}
      <div className="flex flex-col md:flex-row items-start md:items-center justify-between mb-8 gap-4">
        <div className="flex-1">
          <h2 className="text-3xl md:text-4xl font-black text-white font-mono tracking-tight">
            Global Consensus
          </h2>
          {activeTarget && (
            <div className="mt-2 flex items-center gap-2">
              <span className="text-ops-accent text-xl font-bold">
                {activeTarget.name}
              </span>
              <span className={`text-sm font-mono ${activeTarget.colorClass}`}>
                [{activeTarget.classificationLabel}]
              </span>
            </div>
          )}
          <p className="text-ops-text-dim text-sm md:text-base mt-2 max-w-2xl">
            Network consensus from all verified audit nodes. Aggregate
            intelligence reveals forecast patterns across{" "}
            {targets?.length || 0} targets.
          </p>
        </div>
        <div className="flex items-center gap-2 text-green-500 animate-pulse-slow">
          <span className="h-2 w-2 bg-green-500 rounded-full shadow-lg shadow-green-500/50"></span>
          <span className="font-mono text-xs uppercase tracking-widest">
            Consensus Active
          </span>
        </div>
      </div>

      <div className="flex justify-end mb-4">
        <ShareButton
          title={`Global Consensus: ${activeTarget?.name || "All Targets"}`}
          description={
            activeTarget
              ? `Network consensus reveals forecast patterns across all verified audit nodes. ${activeTarget.name} - FVS Score: ${globalStats.avgScore}/100`
              : "Network consensus reveals forecast patterns across all verified audit nodes."
          }
          image={
            activeTarget
              ? generateGlobalConsensusOgImageUrl({
                  targetName: activeTarget.name,
                  score: globalStats.avgScore,
                  totalVotes: globalStats.totalAudits,
                })
              : "/og-image.png"
          }
          variant="button"
          label="Share Consensus Data"
        />
      </div>

      {/* Top Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 mb-8">
        <div className="bg-ops-panel border border-ops-border p-6 rounded-lg relative overflow-hidden hover:border-ops-accent/50 transition-all group">
          <div className="absolute -right-4 -top-4 opacity-5 group-hover:opacity-10 transition-opacity">
            <span className="material-symbols-outlined text-9xl">public</span>
          </div>
          <h3 className="text-xs font-mono uppercase text-ops-text-dim mb-1">
            Global Avg Score
          </h3>
          <div
            className={`text-4xl font-black ${
              globalStats.avgScore >= 76
                ? "text-cyan-400"
                : globalStats.avgScore >= 51
                  ? "text-yellow-400"
                  : globalStats.avgScore >= 26
                    ? "text-orange-500"
                    : "text-red-500"
            }`}
          >
            {globalStats.avgScore}
            <span className="text-lg text-gray-600 font-normal">/100</span>
          </div>
          <div className="text-[10px] text-gray-500 mt-2 font-mono uppercase">
            Status:{" "}
            {globalStats.avgScore >= 76
              ? "High-Confidence Forecast"
              : globalStats.avgScore >= 51
                ? "Credible Forecast"
                : globalStats.avgScore >= 26
                  ? "Speculative"
                  : "Low Confidence"}
          </div>
        </div>

        <div className="bg-ops-panel border border-ops-border p-6 rounded-lg relative overflow-hidden hover:border-ops-accent/50 transition-all group">
          <div className="absolute -right-4 -top-4 opacity-5 group-hover:opacity-10 transition-opacity">
            <span className="material-symbols-outlined text-9xl">storage</span>
          </div>
          <h3 className="text-xs font-mono uppercase text-ops-text-dim mb-1">
            Total Audits Processed
          </h3>
          <div className="text-4xl font-black text-white">
            {globalStats.totalAudits.toLocaleString()}
          </div>
          <div className="text-[10px] text-ops-text-dim mt-2 font-mono uppercase flex items-center gap-1">
            <span className="material-symbols-outlined text-[10px]">
              assessment
            </span>
            Across {targets?.length || 0} targets
          </div>
        </div>

        <div className="bg-ops-panel border border-ops-border p-6 rounded-lg relative overflow-hidden hover:border-ops-accent/50 transition-all group">
          <div className="absolute -right-4 -top-4 opacity-5 group-hover:opacity-10 transition-opacity">
            <span className="material-symbols-outlined text-9xl">
              pie_chart
            </span>
          </div>
          <h3 className="text-xs font-mono uppercase text-ops-text-dim mb-1">
            Dominant Classification
          </h3>
          <div
            className={`text-xl md:text-2xl font-black ${globalStats.dominantClassificationColor} mt-1`}
          >
            {globalStats.dominantClassificationLabel}
          </div>
          <div className="text-[10px] text-gray-500 mt-2 font-mono uppercase">
            {globalStats.dominantPercentage}% of all targets
          </div>
        </div>
      </div>

      {/* Metric-Level Breakdown */}
      {activeTarget && metricScores.length > 0 && (
        <div className="mb-8 bg-ops-panel border border-ops-border rounded-lg p-6">
          <h3 className="text-lg font-bold text-white font-mono mb-4 flex items-center gap-2">
            <span className="material-symbols-outlined text-ops-accent">
              analytics
            </span>
            Metric Breakdown: {activeTarget.name}
          </h3>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart
              data={metricScores}
              layout="horizontal"
              margin={{ top: 5, right: 30, left: 20, bottom: 80 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#333" />
              <XAxis
                dataKey="metricName"
                stroke="#888"
                angle={-45}
                tick={{ fontSize: 10, fill: "#888", textAnchor: "end" }}
                height={100}
              />
              <YAxis
                type="number"
                domain={[0, 5]}
                stroke="#888"
                tick={{ fontSize: 12, fill: "#888" }}
                label={{
                  value: "Average Score (1-5)",
                  angle: -90,
                  position: "insideLeft",
                  style: { fill: "#888" },
                }}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#1a1a1a",
                  border: "1px solid #333",
                  borderRadius: "8px",
                }}
                labelStyle={{
                  color: "#fff",
                  fontFamily: "monospace",
                  fontSize: "12px",
                }}
              />
              <Bar
                dataKey="averageScore"
                fill="#ff8a00"
                radius={[4, 4, 0, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      )}

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 md:gap-8">
        <div className="lg:col-span-7 bg-ops-panel border border-ops-border rounded-lg p-6">
          <h3 className="text-lg font-bold text-white font-mono mb-4 flex items-center gap-2">
            <span className="material-symbols-outlined text-ops-accent">
              bar_chart
            </span>
            Top Scored Forecast Targets
          </h3>
          {topTargetsData.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart
                data={topTargetsData}
                layout="vertical"
                margin={{ top: 5, right: 30, left: 80, bottom: 5 }}
              >
                <CartesianGrid strokeDasharray="3 3" stroke="#333" />
                <XAxis
                  type="number"
                  domain={[0, 100]}
                  stroke="#888"
                  tick={{ fontSize: 12, fill: "#888" }}
                />
                <YAxis
                  type="category"
                  dataKey="name"
                  stroke="#888"
                  tick={{ fontSize: 11, fill: "#888" }}
                  width={80}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "#1a1a1a",
                    border: "1px solid #333",
                    borderRadius: "8px",
                  }}
                  labelStyle={{ color: "#fff", fontFamily: "monospace" }}
                  cursor={{ fill: "rgba(255, 138, 0, 0.1)" }}
                />
                <Bar
                  dataKey="score"
                  fill="#ff8a00"
                  radius={[0, 4, 4, 0]}
                  onClick={(data) => {
                    const targetData = (
                      data as { target?: TargetWithScore }
                    ).target;
                    if (targetData) {
                      handleTargetClick(targetData);
                    }
                  }}
                  cursor="pointer"
                />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[300px] flex items-center justify-center text-ops-text-dim font-mono text-sm">
              No scored targets available
            </div>
          )}
        </div>

        <div className="lg:col-span-5 bg-ops-panel border border-ops-border rounded-lg p-6">
          <h3 className="text-lg font-bold text-white font-mono mb-4 flex items-center gap-2">
            <span className="material-symbols-outlined text-ops-accent">
              radar
            </span>
            Classification Distribution
          </h3>
          {classificationRadarData.length > 0 &&
          classificationRadarData.some((d) => d.count > 0) ? (
            <ResponsiveContainer width="100%" height={300}>
              <RadarChart data={classificationRadarData}>
                <PolarGrid stroke="#333" />
                <PolarAngleAxis
                  dataKey="classification"
                  tick={{
                    fontSize: 10,
                    fill: "#888",
                    fontFamily: "monospace",
                  }}
                />
                <PolarRadiusAxis
                  angle={90}
                  domain={[0, "auto"]}
                  tick={{ fontSize: 10, fill: "#888" }}
                />
                <Radar
                  name="Target Count"
                  dataKey="count"
                  stroke="#ff8a00"
                  fill="#ff8a00"
                  fillOpacity={0.3}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "#1a1a1a",
                    border: "1px solid #333",
                    borderRadius: "8px",
                  }}
                  labelStyle={{
                    color: "#fff",
                    fontFamily: "monospace",
                    fontSize: "12px",
                  }}
                />
              </RadarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-[300px] flex items-center justify-center text-ops-text-dim font-mono text-sm">
              No classification data available
            </div>
          )}
        </div>
      </div>

      {/* Recent Targets Grid */}
      <div className="mt-8">
        <h3 className="text-lg font-bold text-white font-mono mb-4 flex items-center gap-2">
          <span className="material-symbols-outlined text-ops-accent">
            history
          </span>
          Recent Forecast Targets
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {targets?.slice(0, 6).map((target) => (
            <Link
              key={target.id}
              href={`/audit-target/${generateTargetSlug(target)}`}
              className={`w-full text-left bg-ops-panel border ${target.borderClass} p-4 rounded-lg hover:bg-white/5 transition-all cursor-pointer group no-underline`}
            >
              <div className="flex justify-between items-start mb-2">
                <span className="text-[9px] font-mono uppercase bg-black px-2 py-0.5 rounded border border-ops-border text-gray-400">
                  {target.context}
                </span>
                <span className={`text-xs font-mono ${target.colorClass}`}>
                  {target.scoreCount > 0
                    ? `${target.totalScore}/100`
                    : "UNSCORED"}
                </span>
              </div>
              <h4 className="text-white font-bold text-sm leading-tight mb-1 group-hover:text-ops-accent transition-colors">
                {target.name}
              </h4>
              <div className="flex items-center gap-1">
                <span
                  className={`text-[10px] font-mono ${target.colorClass}`}
                >
                  {target.classificationLabel}
                </span>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
};
