"use client";

import { useState } from "react";
import Link from "next/link";
import {
  useTargetsWithScores,
  type TargetWithScore,
} from "~/hooks/useTargetsWithScores";
import { generateTargetSlug } from "~/utils/urlSlug";

export const CurrentTargetsView = () => {
  const { data: targets, loading, error } = useTargetsWithScores();
  const [searchQuery, setSearchQuery] = useState("");

  const filteredTargets =
    targets?.filter(
      (target) =>
        target.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        target.description
          ?.toLowerCase()
          .includes(searchQuery.toLowerCase()) ||
        target.context?.toLowerCase().includes(searchQuery.toLowerCase()) ||
        target.origin?.toLowerCase().includes(searchQuery.toLowerCase()),
    ) || [];

  const getTargetHref = (target: TargetWithScore) => {
    const slug = generateTargetSlug(target);
    return `/global-consensus/${slug}`;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - date.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

    if (diffDays < 30) {
      return `${diffDays} days ago`;
    } else if (diffDays < 365) {
      const months = Math.floor(diffDays / 30);
      return `${months} month${months > 1 ? "s" : ""} ago`;
    } else {
      return date.toLocaleDateString("en-US", {
        month: "short",
        year: "numeric",
      });
    }
  };

  const getStatusIcon = (statusLabel: string) => {
    if (statusLabel === "SCORED") return "check_circle";
    if (statusLabel.includes("LOW CONFIDENCE")) return "block";
    return "pending";
  };

  return (
    <div
      id="view-targets"
      className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in"
    >
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-2xl font-bold text-white font-mono">
            Active Forecast Targets
          </h2>
          <p className="text-ops-text-dim text-sm mt-1">
            Select a target to view consensus data, execute audit, or explore
            intelligence.
          </p>
        </div>
        <div className="flex gap-2">
          <div className="relative flex items-center bg-ops-panel border border-ops-border rounded px-3 py-2">
            <span className="material-symbols-outlined text-gray-500 text-sm mr-2">
              search
            </span>
            <input
              type="text"
              placeholder="Search Targets..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-transparent border-none outline-none text-white text-xs font-mono w-48"
            />
          </div>
        </div>
      </div>

      {loading && (
        <div className="text-center py-12">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-ops-accent"></div>
          <p className="text-ops-text-dim text-sm mt-4 font-mono">
            Loading targets...
          </p>
        </div>
      )}

      {error && (
        <div className="text-center py-12">
          <div className="text-red-500 font-mono text-sm">
            Error loading targets: {error.message}
          </div>
        </div>
      )}

      {!loading && !error && filteredTargets.length === 0 && searchQuery && (
        <div className="text-center py-12">
          <p className="text-ops-text-dim text-sm font-mono">
            No targets found matching &quot;{searchQuery}&quot;
          </p>
        </div>
      )}

      {!loading && !error && filteredTargets.length === 0 && !searchQuery && (
        <div className="text-center py-12">
          <p className="text-ops-text-dim text-sm font-mono">
            No targets available
          </p>
        </div>
      )}

      <div
        id="targets-grid"
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        {filteredTargets.map((target) => (
          <Link
            key={target.id}
            href={getTargetHref(target)}
            className={`bg-ops-panel border ${target.borderClass} p-5 rounded-lg hover:bg-white/5 transition-all group flex flex-col justify-between h-full cursor-pointer no-underline`}
          >
            <div>
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] font-mono uppercase bg-black px-2 py-0.5 rounded border border-ops-border text-gray-400">
                  {target.context}
                </span>
                <span className="text-[10px] font-mono text-gray-500">
                  {formatDate(target.created_at)}
                </span>
              </div>
              <h3 className="text-white font-bold text-lg leading-tight mb-2">
                {target.name}
              </h3>
              <div className="flex items-center gap-2 mb-4">
                <span
                  className={`material-symbols-outlined text-sm ${target.colorClass}`}
                >
                  {getStatusIcon(target.statusLabel)}
                </span>
                <span className={`text-xs font-mono ${target.colorClass}`}>
                  {target.statusLabel} {"//"} {target.classificationLabel}
                </span>
              </div>
            </div>

            <div className="border-t border-ops-border pt-4 flex justify-between items-center mt-auto">
              <div className={`text-2xl font-black ${target.colorClass}`}>
                {target.scoreCount > 0
                  ? `${target.totalScore}/100`
                  : "--/100"}
              </div>
              <span
                className="bg-ops-border group-hover:bg-ops-accent group-hover:text-black text-white text-xs font-mono uppercase px-3 py-2 rounded transition-colors flex items-center gap-1"
              >
                View Target
                <span className="material-symbols-outlined text-sm">
                  arrow_forward
                </span>
              </span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
};
