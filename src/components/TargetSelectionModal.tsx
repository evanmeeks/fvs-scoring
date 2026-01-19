import { useEffect, useMemo, useState } from "react";
import Icon from "./Icon";
import { useTargets } from "../hooks/useSupabase";
import { normalizeTarget } from "../utils/targets";
import { getOriginLabel } from "../data/originTypes";
import { getContextLabel } from "../data/contextTypes";

type Target = NonNullable<ReturnType<typeof normalizeTarget>>;

type TargetSelectionModalProps = {
    isOpen: boolean;
    onClose: () => void;
    currentTarget?: Target | null;
    onSelectTarget: (target: Target | null) => void;
};

const TargetSelectionModal = ({ isOpen, onClose, currentTarget, onSelectTarget }: TargetSelectionModalProps) => {
    const [selectedTarget, setSelectedTarget] = useState<Target | null | undefined>(currentTarget || null);
    const { data: targets, loading, error, refetch } = useTargets();

    const availableTargets = useMemo(() => {
        if (!Array.isArray(targets)) return [];
        return targets.map(normalizeTarget).filter(Boolean) as Target[];
    }, [targets]);

    useEffect(() => {
        if (isOpen) {
            refetch();
        }
    }, [isOpen, refetch]);

    // Sync with currentTarget prop when it changes
    useEffect(() => {
        if (currentTarget) {
            // eslint-disable-next-line react-hooks/set-state-in-effect
            setSelectedTarget(currentTarget);
        }
    }, [currentTarget]);

    // Default selection if none selected and modal is open
    useEffect(() => {
        if (!isOpen) return;

        if (!selectedTarget && !currentTarget && availableTargets.length > 0) {
            // eslint-disable-next-line react-hooks/set-state-in-effect
            setSelectedTarget(availableTargets[0]);
        }
    }, [isOpen, selectedTarget, currentTarget, availableTargets]);

    if (!isOpen) return null;

    const handleConfirm = () => {
        onSelectTarget(selectedTarget ?? null);
        onClose();
    };

    return (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
            <div className="bg-panel w-full max-w-3xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh] scale-100 animate-slide-up">
                <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
                    <div className="flex items-center gap-2 text-white">
                        <Icon name="target" className="text-primary" />
                        <h3 className="font-bold text-lg font-mono">Select Active Target</h3>
                    </div>
                    <button className="text-text-muted hover:text-white" onClick={onClose}>
                        <Icon name="close" />
                    </button>
                </div>

                <div className="p-6 overflow-y-auto space-y-4">
                    <div className="text-xs text-text-muted mb-4">
                        Choose a forecast or claim to analyze using the FVS Protocol metrics. The active target determines which case you're currently scoring.
                    </div>

                    {loading ? (
                        <div className="text-xs text-text-muted font-mono animate-pulse">
                            Loading targets...
                        </div>
                    ) : null}
                    {error ? (
                        <div className="text-xs text-red-400 font-mono">
                            Unable to load targets.
                        </div>
                    ) : null}
                    {!loading && !error && availableTargets.length === 0 ? (
                        <div className="text-xs text-text-muted font-mono">
                            No approved targets yet.
                        </div>
                    ) : null}
                    {availableTargets.map((target) => (
                        <div
                            key={target.id}
                            role="button"
                            tabIndex={0}
                            onClick={() => setSelectedTarget(target)}
                            onKeyDown={(e) => {
                                if (e.key === 'Enter' || e.key === ' ') {
                                    e.preventDefault();
                                    setSelectedTarget(target);
                                }
                            }}
                            aria-pressed={selectedTarget?.id === target.id}
                            className={`
                                border rounded-lg p-4 cursor-pointer transition-all
                                ${selectedTarget?.id === target.id
                                    ? 'border-primary bg-primary/10'
                                    : 'border-border bg-background hover:border-primary/50 hover:bg-surface'
                                }
                            `}
                        >
                            <div className="flex items-start justify-between mb-2">
                                <div className="flex-1">
                                    <div className="flex items-center gap-2 mb-1">
                                        <h4 className="font-bold text-white font-mono">{target.name}</h4>
                                        {target.verified && (
                                            <span className="text-primary text-xs">
                                                <Icon name="verified" className="text-sm" />
                                            </span>
                                        )}
                                    </div>
                                    <div className="text-[10px] text-text-muted mono">
                                        Case ID: {target.caseId}
                                    </div>
                                </div>
                                <div className={`
                                    w-5 h-5 rounded-full border-2 flex items-center justify-center
                                    ${selectedTarget?.id === target.id
                                        ? 'border-primary'
                                        : 'border-border'
                                    }
                                `}>
                                    {selectedTarget?.id === target.id && (
                                        <div className="w-3 h-3 rounded-full bg-primary"></div>
                                    )}
                                </div>
                            </div>

                            <p className="text-xs text-text-muted mb-3">{target.description}</p>

                            <div className="flex gap-4 text-[10px]">
                                <div>
                                    <span className="text-text-muted">Origin: </span>
                                    <span className="text-white font-mono">{getOriginLabel(target.origin)}</span>
                                </div>
                                <div>
                                    <span className="text-text-muted">Context: </span>
                                    <span className="text-white font-mono">{getContextLabel(target.context)}</span>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                <div className="p-4 border-t border-border bg-surface rounded-b-lg flex justify-end gap-3">
                    <button
                        className="px-5 py-2.5 rounded border border-border text-text-muted hover:text-white text-xs font-bold uppercase tracking-wide transition-colors"
                        onClick={onClose}
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
