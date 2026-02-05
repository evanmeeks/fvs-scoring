"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "~/components/Icon";
import { useUI, useTarget } from "~/context/AppContext";
import { normalizeTarget, type NormalizedTarget } from "~/utils/targets";
import { getOriginLabel } from "~/data/originTypes";
import { getContextLabel } from "~/data/contextTypes";
import { createClient } from "~/lib/supabase/client";
import type { DbTarget } from "~/types/database";

export const TargetSelectionModal = () => {
  const { targetSelectionModalOpen, setTargetSelectionModalOpen } = useUI();
  const { activeTarget, setActiveTarget } = useTarget();
  const router = useRouter();
  const supabase = createClient();

  const [selectedTarget, setSelectedTarget] =
    useState<NormalizedTarget | null>(null);
  const [rawTargets, setRawTargets] = useState<DbTarget[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!targetSelectionModalOpen) return;
    setIsLoading(true);
    const fetch = async () => {
      const { data, error: err } = await supabase
        .from("targets")
        .select("*")
        .order("created_at", { ascending: false });
      if (err) setError(err as unknown as Error);
      else setRawTargets((data ?? []) as DbTarget[]);
      setIsLoading(false);
    };
    fetch();
  }, [targetSelectionModalOpen, supabase]);

  const availableTargets = useMemo(() => {
    if (!Array.isArray(rawTargets)) return [];
    return rawTargets
      .map(normalizeTarget)
      .filter(Boolean) as NormalizedTarget[];
  }, [rawTargets]);

  // Sync selection with current active target when modal opens
  useEffect(() => {
    if (targetSelectionModalOpen && activeTarget) {
      setSelectedTarget(activeTarget);
    }
  }, [targetSelectionModalOpen, activeTarget]);

  // Default to first target if none selected
  useEffect(() => {
    if (
      targetSelectionModalOpen &&
      !selectedTarget &&
      !activeTarget &&
      availableTargets.length > 0
    ) {
      setSelectedTarget(availableTargets[0]!);
    }
  }, [targetSelectionModalOpen, selectedTarget, activeTarget, availableTargets]);

  if (!targetSelectionModalOpen) return null;

  const handleClose = () => setTargetSelectionModalOpen(false);

  const handleConfirm = () => {
    if (!selectedTarget) return;
    setActiveTarget(selectedTarget);

    // Navigate to the audit page for the selected target
    const slug =
      selectedTarget.slug ??
      `${selectedTarget.caseId}-${selectedTarget.name
        .trim()
        .replace(/\s+/g, "_")
        .replace(/[^a-zA-Z0-9_-]/g, "")
        .replace(/^[_-]+|[_-]+$/g, "")}`;

    router.push(`/audit-target/${slug}`);
    handleClose();
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-ops-panel w-full max-w-3xl border border-ops-border rounded-lg shadow-2xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="p-4 border-b border-ops-border flex justify-between items-center bg-ops-black/50 rounded-t-lg">
          <div className="flex items-center gap-2 text-white">
            <Icon name="target" className="text-primary" />
            <h3 className="font-bold text-lg font-mono">
              Select Active Target
            </h3>
          </div>
          <button
            className="text-ops-text-dim hover:text-white"
            onClick={handleClose}
          >
            <Icon name="close" />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto space-y-4">
          <div className="text-xs text-ops-text-dim mb-4">
            Choose a forecast or claim to analyze using the FVS Protocol
            metrics. The active target determines which case you&apos;re
            currently scoring.
          </div>

          {isLoading && (
            <div className="text-xs text-ops-text-dim font-mono animate-pulse">
              Loading targets...
            </div>
          )}
          {error && (
            <div className="text-xs text-red-400 font-mono">
              Unable to load targets.
            </div>
          )}
          {!isLoading && !error && availableTargets.length === 0 && (
            <div className="text-xs text-ops-text-dim font-mono">
              No approved targets yet.
            </div>
          )}

          {availableTargets.map((target) => (
            <div
              key={target.id}
              role="button"
              tabIndex={0}
              onClick={() => setSelectedTarget(target)}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault();
                  setSelectedTarget(target);
                }
              }}
              aria-pressed={selectedTarget?.id === target.id}
              className={`border rounded-lg p-4 cursor-pointer transition-all ${
                selectedTarget?.id === target.id
                  ? "border-primary bg-primary/10"
                  : "border-ops-border bg-ops-black hover:border-primary/50 hover:bg-ops-panel"
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-1">
                    <h4 className="font-bold text-white font-mono">
                      {target.name}
                    </h4>
                    {target.verified && (
                      <span className="text-primary text-xs">
                        <Icon name="verified" className="text-sm" />
                      </span>
                    )}
                  </div>
                  <div className="text-[10px] text-ops-text-dim font-mono">
                    Case ID: {target.caseId}
                  </div>
                </div>
                <div
                  className={`w-5 h-5 rounded-full border-2 flex items-center justify-center ${
                    selectedTarget?.id === target.id
                      ? "border-primary"
                      : "border-ops-border"
                  }`}
                >
                  {selectedTarget?.id === target.id && (
                    <div className="w-3 h-3 rounded-full bg-primary" />
                  )}
                </div>
              </div>

              <p className="text-xs text-ops-text-dim mb-3">
                {target.description}
              </p>

              <div className="flex gap-4 text-[10px]">
                <div>
                  <span className="text-ops-text-dim">Origin: </span>
                  <span className="text-white font-mono">
                    {getOriginLabel(target.origin)}
                  </span>
                </div>
                <div>
                  <span className="text-ops-text-dim">Context: </span>
                  <span className="text-white font-mono">
                    {getContextLabel(target.context)}
                  </span>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-ops-border bg-ops-black/50 rounded-b-lg flex justify-end gap-3">
          <button
            className="px-5 py-2.5 rounded border border-ops-border text-ops-text-dim hover:text-white text-xs font-bold uppercase tracking-wide transition-colors"
            onClick={handleClose}
          >
            Cancel
          </button>
          <button
            className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20"
            onClick={handleConfirm}
            disabled={!selectedTarget}
          >
            Set Active Target
          </button>
        </div>
      </div>
    </div>
  );
};

export default TargetSelectionModal;
