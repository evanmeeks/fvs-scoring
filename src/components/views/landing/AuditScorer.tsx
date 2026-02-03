"use client";

import { useState, useEffect } from "react";
import { useMetrics, useTarget, useScoring, useUI, type Metric } from "~/context/AppContext";
import { getOriginLabel } from "~/data/originTypes";
import { getContextLabel } from "~/data/contextTypes";
import AuthTeaser from "~/components/shared/AuthTeaser";
import { useRouter } from "next/navigation";
import ShareButton from "~/components/shared/ShareButton";
import { generateGlobalConsensusOgImageUrl } from "~/utils/seo";
import { createClient } from "~/lib/supabase/client";

/* eslint-disable @typescript-eslint/no-explicit-any */

export const AuditScorer = () => {
  const { FVS_METRICS } = useMetrics();
  const { activeTarget } = useTarget();
  const { scores, handleScoreChange, totalScore } = useScoring();
  const { setTargetSelectionModalOpen, setAuthModalOpen } = useUI();

  const supabase = createClient();
  const [user, setUser] = useState<any>(null);
  const [isSubmittingVote, setIsSubmittingVote] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<
    "idle" | "success" | "error"
  >("idle");
  const [hasAdjustedScore, setHasAdjustedScore] = useState(false);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  const maxPossible = FVS_METRICS.length * 5;
  const normalizedScore =
    maxPossible > 0 ? Math.round((totalScore / maxPossible) * 100) : 0;

  const getClassification = () => {
    if (normalizedScore === 0) {
      return {
        label: "Awaiting Data",
        color: "text-ops-text-dim",
        barColor: "bg-ops-text-dim",
        icon: "hourglass_empty",
      };
    }
    if (normalizedScore <= 25) {
      return {
        label: "Low Confidence",
        color: "text-red-500",
        barColor: "bg-red-500",
        iconBg: "bg-red-600",
        icon: "block",
      };
    }
    if (normalizedScore <= 50) {
      return {
        label: "Speculative",
        color: "text-orange-500",
        barColor: "bg-orange-500",
        iconBg: "bg-orange-500",
        icon: "warning",
      };
    }
    if (normalizedScore <= 75) {
      return {
        label: "Credible Forecast",
        color: "text-yellow-400",
        barColor: "bg-yellow-400",
        iconBg: "bg-yellow-400",
        icon: "check_circle",
      };
    }
    if (normalizedScore <= 90) {
      return {
        label: "High-Confidence Forecast",
        color: "text-cyan-400",
        barColor: "bg-cyan-400",
        iconBg: "bg-cyan-500",
        icon: "verified",
      };
    }
    return {
      label: "Consensus Forecast",
      color: "text-white",
      barColor: "bg-white",
      iconBg: "bg-white",
      iconTextColor: "text-black",
      icon: "stars",
    };
  };

  const classification = getClassification();
  const router = useRouter();

  const handleSubmit = async () => {
    if (!user) {
      setAuthModalOpen(true);
      return;
    }

    if (!activeTarget) return;

    try {
      setSubmitStatus("idle");
      setIsSubmittingVote(true);
      const promises = FVS_METRICS.map((metric) => {
        const val = scores[metric.id] || 0;
        if (val === 0) return Promise.resolve();

        return (supabase.rpc as any)("upsert_community_vote", {
          p_target_id: activeTarget.id,
          p_metric_id: Number(metric.id),
          p_vote_value: Number(val),
          p_confidence_level: "medium",
          p_rationale: "",
        });
      });

      await Promise.all(promises);
      setSubmitStatus("success");

      setTimeout(() => {
        router.push(`/share/scorecard/${activeTarget.id}/${user.id}`);
      }, 1000);
    } catch (err) {
      console.error(err);
      setSubmitStatus("error");
    } finally {
      setIsSubmittingVote(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#050505] relative w-full">
      <div className="scanlines"></div>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in relative">
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 relative z-10">
          {/* Input Column */}
          <div className="lg:col-span-7 space-y-6">
            {/* Target Dossier Panel */}
            <div className="bg-ops-panel border border-ops-border rounded-lg backdrop-blur-sm overflow-hidden relative group">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <p className="block text-[10px] font-mono uppercase text-ops-accent mb-1 tracking-widest">
                      Target Designation // ACTIVE FEED
                    </p>
                    <h1 className="text-2xl md:text-3xl font-bold text-white tracking-tight flex items-center gap-3">
                      {activeTarget ? activeTarget.name : "NO TARGET ACTIVE"}
                      {activeTarget?.verified && (
                        <span className="bg-cyan-500/20 text-cyan-400 text-[10px] px-2 py-0.5 rounded border border-cyan-500/30 uppercase tracking-widest font-mono">
                          Verified
                        </span>
                      )}
                    </h1>
                  </div>
                  <button
                    onClick={() => setTargetSelectionModalOpen(true)}
                    className="px-3 py-1.5 bg-ops-black border border-ops-border text-ops-text-dim hover:text-white hover:border-ops-accent text-xs font-mono uppercase transition-all flex items-center gap-2"
                  >
                    <span className="material-symbols-outlined text-sm">
                      swap_horiz
                    </span>
                    Switch Target
                  </button>
                </div>

                {activeTarget ? (
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4 border-t border-b border-white/5 py-4 bg-black/20">
                    <div>
                      <span className="block text-[10px] font-mono text-gray-500 uppercase">
                        Case ID
                      </span>
                      <span className="block text-sm font-mono text-cyan-400/90">
                        {activeTarget.caseId || "N/A"}
                      </span>
                    </div>
                    <div>
                      <span className="block text-[10px] font-mono text-gray-500 uppercase">
                        Origin
                      </span>
                      <span className="block text-sm font-mono text-white">
                        {getOriginLabel(activeTarget.origin) || "Unknown"}
                      </span>
                    </div>
                    <div>
                      <span className="block text-[10px] font-mono text-gray-500 uppercase">
                        Context
                      </span>
                      <span className="block text-sm font-mono text-white">
                        {getContextLabel(activeTarget.context) || "Unknown"}
                      </span>
                    </div>
                    <div>
                      <span className="block text-[10px] font-mono text-gray-500 uppercase">
                        Claim Date
                      </span>
                      <span className="block text-sm font-mono text-white">
                        {typeof activeTarget.claim_date === "string"
                          ? new Date(
                              activeTarget.claim_date,
                            ).toLocaleDateString()
                          : "Unknown"}
                      </span>
                    </div>
                  </div>
                ) : (
                  <div className="py-8 text-center text-ops-text-dim border-t border-b border-white/5 bg-black/20 italic text-sm">
                    System Offline. Please select a target to initialize
                    scoring.
                  </div>
                )}

                {activeTarget && (
                  <div className="relative">
                    <div className="absolute left-0 top-0 bottom-0 w-1 bg-ops-accent/30"></div>
                    <p className="pl-4 text-sm text-gray-300 leading-relaxed font-mono">
                      <span className="text-ops-accent text-xs uppercase mr-2">
                        [BRIEF]
                      </span>
                      {activeTarget.description}
                    </p>
                  </div>
                )}
              </div>

              <div className="h-1 w-full bg-gradient-to-r from-ops-accent/0 via-ops-accent/50 to-ops-accent/0"></div>
            </div>

            <div className="bg-ops-panel border border-ops-border rounded-lg overflow-hidden backdrop-blur-sm">
              <div className="px-6 py-4 border-b border-ops-border bg-ops-black/50 flex justify-between items-center">
                <h3 className="text-sm font-mono uppercase text-white">
                  Assessment Matrix
                </h3>
                <span className="text-xs text-ops-text-dim">
                  Scale: 1 (Absent) - 5 (Strong)
                </span>
              </div>

              <div className="divide-y divide-ops-border">
                {FVS_METRICS.map((metric: Metric) => {
                  const criteria = metric.scoringCriteria || [];
                  const lowCriteria = criteria?.[0];
                  const highCriteria = criteria?.[4];

                  const scoreVal = parseInt(
                    String(scores[metric.id] || "0"),
                    10,
                  );
                  const getScoreColor = (val: number) => {
                    if (val === 1) return "text-red-500";
                    if (val === 2) return "text-white";
                    if (val === 3) return "text-amber-500";
                    if (val === 4) return "text-white";
                    if (val === 5) return "text-cyan-400";
                    return "text-white";
                  };

                  return (
                    <div
                      key={metric.id}
                      className="p-6 hover:bg-white/5 transition-colors group"
                    >
                      <div className="flex justify-between items-center mb-3">
                        <div>
                          <span className="text-xs font-mono text-ops-accent block mb-1">
                            METRIC {String(metric.id).padStart(2, "0")}
                          </span>
                          <h4 className="text-white font-bold text-lg">
                            {metric.name}
                          </h4>
                        </div>
                        <span
                          className={`text-2xl font-black ${getScoreColor(scoreVal)}`}
                        >
                          {scores[metric.id] || 0}
                        </span>
                      </div>
                      <p className="text-gray-400 text-sm mb-4 italic pl-3 border-l-2 border-gray-700 group-hover:border-ops-accent transition-colors">
                        &quot;
                        {metric.question || lowCriteria?.description}
                        &quot;
                      </p>
                      <div className="flex items-center gap-4">
                        <div className="hidden sm:block w-32 text-right">
                          <span className="block text-[10px] font-mono text-gray-500 uppercase font-bold">
                            {lowCriteria?.label || "Absent"}
                          </span>
                          <span className="block text-[9px] text-gray-600 leading-tight mt-0.5">
                            {lowCriteria?.description?.split(",")[0]}
                          </span>
                        </div>
                        <input
                          type="range"
                          min="0"
                          max="5"
                          step="1"
                          value={scores[metric.id] || 0}
                          onChange={(e) => {
                            const newValue = parseInt(e.target.value);
                            handleScoreChange(metric.id, e.target.value);

                            if (!hasAdjustedScore && newValue > 0) {
                              setHasAdjustedScore(true);
                            }
                            const allScores = FVS_METRICS.map((m) =>
                              m.id === metric.id
                                ? newValue
                                : scores[m.id] || 0,
                            );
                            if (allScores.every((s) => s === 0)) {
                              setHasAdjustedScore(false);
                            }
                          }}
                          className="flex-grow h-1 bg-gray-700 rounded-lg appearance-none cursor-pointer range-slider accent-ops-accent"
                        />
                        <div className="hidden sm:block w-32 text-left">
                          <span className="block text-[10px] font-mono text-ops-accent uppercase font-bold">
                            {highCriteria?.label || "Strong"}
                          </span>
                          <span className="block text-[9px] text-ops-accent/70 leading-tight mt-0.5">
                            {highCriteria?.description?.split(",")[0]}
                          </span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Results Column */}
          <div className="lg:col-span-5">
            <div className="sticky top-8 space-y-6">
              <div className="bg-ops-panel border border-ops-border p-6 rounded-lg shadow-2xl relative overflow-hidden backdrop-blur-sm">
                <div className="absolute top-0 right-0 p-4 opacity-10">
                  <span className="material-symbols-outlined text-9xl text-white">
                    analytics
                  </span>
                </div>
                <div className="flex justify-between items-start mb-1">
                  <h2 className="text-xs font-mono uppercase text-ops-text-dim tracking-widest">
                    Assessment
                  </h2>
                  {activeTarget && normalizedScore > 0 && (
                    <ShareButton
                      title={`My Audit: ${activeTarget.name}`}
                      description={`Individual FVS audit for ${activeTarget.name}. My assessment score: ${normalizedScore}/100 - ${classification.label}`}
                      image={generateGlobalConsensusOgImageUrl({
                        targetName: activeTarget.name,
                        score: normalizedScore,
                        totalVotes: 1,
                      })}
                      variant="icon"
                      className="text-ops-text-dim hover:text-ops-accent"
                    />
                  )}
                </div>
                <div className="flex items-baseline gap-2 mb-4">
                  <span
                    className={`text-6xl font-black tracking-tighter ${classification.color}`}
                  >
                    {normalizedScore}
                  </span>
                  <span className="text-xl text-ops-text-dim font-mono">
                    / 100
                  </span>
                </div>
                <div className="h-2 w-full bg-ops-black rounded-full mb-2 overflow-hidden border border-ops-border">
                  <div
                    className={`h-full transition-all duration-500 ease-out rounded-full ${classification.barColor || "bg-ops-text-dim"}`}
                    style={{ width: `${normalizedScore}%` }}
                  ></div>
                </div>
                <div className="flex justify-between items-center border-t border-ops-border pt-4 mt-4">
                  <div>
                    <p className="text-[10px] font-mono uppercase text-ops-text-dim tracking-widest">
                      Classification
                    </p>
                    <p
                      className={`text-lg font-bold mt-1 ${classification.color}`}
                    >
                      {classification.label}
                    </p>
                  </div>
                  <div
                    className={`h-10 w-10 rounded flex items-center justify-center ${(classification as any).iconBg || "bg-ops-text-dim"}`}
                  >
                    <span
                      className={`material-symbols-outlined ${(classification as any).iconTextColor || "text-white"}`}
                    >
                      {classification.icon}
                    </span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="grid grid-cols-2 gap-3">
                <button
                  onClick={() => {
                    FVS_METRICS.forEach((m) => handleScoreChange(m.id, "0"));
                    setHasAdjustedScore(false);
                  }}
                  className="px-4 py-3 bg-ops-panel border border-ops-border text-ops-text hover:border-ops-accent hover:text-white font-mono text-sm uppercase transition-all rounded flex items-center justify-center gap-2"
                >
                  Reset Data
                </button>
                <button
                  onClick={handleSubmit}
                  disabled={isSubmittingVote || !activeTarget || !user}
                  className={`px-4 py-3 border font-mono text-sm uppercase transition-all rounded flex items-center justify-center gap-2 relative overflow-hidden group
                    ${
                      submitStatus === "success"
                        ? "bg-green-600 border-green-500 text-white"
                        : submitStatus === "error"
                          ? "bg-red-600 border-red-500 text-white"
                          : !user
                            ? "bg-ops-panel border-ops-border text-ops-text-dim cursor-not-allowed"
                            : "bg-ops-accent text-ops-black border-ops-accent hover:bg-cyan-400"
                    }`}
                >
                  {isSubmittingVote ? (
                    <>
                      <span className="material-symbols-outlined animate-spin text-sm">
                        sync
                      </span>
                      Submitting...
                    </>
                  ) : submitStatus === "success" ? (
                    <>
                      <span className="material-symbols-outlined text-sm">
                        check_circle
                      </span>
                      Submitted
                    </>
                  ) : (
                    <>
                      <span className="material-symbols-outlined text-sm">
                        save
                      </span>
                      {user ? "Submit Scores" : "Login to Submit"}
                    </>
                  )}
                </button>
              </div>

              {!user && hasAdjustedScore && (
                <AuthTeaser
                  action="Log In to Submit Score"
                  description="Save your assessment and contribute to community consensus."
                  icon="shield_person"
                  variant="banner"
                  onLogin={() => setAuthModalOpen(true)}
                  className="animate-fade-in"
                />
              )}

              {/* Classification Legend */}
              <div className="bg-ops-panel border border-ops-border rounded-lg p-4">
                <div className="space-y-2 text-xs font-mono">
                  <div className="flex justify-between items-center">
                    <span className="text-red-500">00-25</span>
                    <span className="text-ops-text-dim">
                      Low Confidence
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-orange-500">26-50</span>
                    <span className="text-ops-text-dim">
                      Speculative
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-yellow-400">51-75</span>
                    <span className="text-ops-text-dim">
                      Credible Forecast
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-cyan-400">76-90</span>
                    <span className="text-ops-text-dim">
                      High-Confidence Forecast
                    </span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-white">91-100</span>
                    <span className="text-ops-text-dim">Consensus Forecast</span>
                  </div>
                </div>
              </div>

              <div className="text-center">
                <p className="text-[10px] text-gray-500 font-mono">
                  {!user
                    ? "AUTHENTICATION REQUIRED FOR LEDGER ENTRY"
                    : "SECURE LEDGER LINK ESTABLISHED"}
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
