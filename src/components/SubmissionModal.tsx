
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from "react";
import Icon from "./Icon";
import { useApp } from "../context/AppContext";
import type { User } from "../types";

interface SubmissionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: any, mode: string) => void;
  metricId?: string;
  user?: User | null;
  onRequireAuth?: () => void;
  initialMode?: "rfc" | "new-metric";
}

const SubmissionModal = ({
  isOpen,
  onClose,
  onSubmit,
  metricId,
  user,
  onRequireAuth,
  initialMode = "rfc", // "rfc" or "new-metric"
}: SubmissionModalProps) => {
  const { FVS_METRICS } = useApp();
  const [mode, setMode] = useState(initialMode);

  // Helper to get min/max criteria from metric
  const getMetricCriteria = (metric: any) => {
    if (!metric) return { minCriteria: "", maxCriteria: "" };

    // Check if metric has rich scoring_criteria (metrics 1-10)
    if (metric.scoringCriteria && Array.isArray(metric.scoringCriteria)) {
      const minScore = metric.scoringCriteria.find((c: any) => c.score === 1);
      const maxScore = metric.scoringCriteria.find((c: any) => c.score === 5);
      return {
        minCriteria: minScore ? `${minScore.label}: ${minScore.description}` : metric.lowDescription || "",
        maxCriteria: maxScore ? `${maxScore.label}: ${maxScore.description}` : metric.highDescription || "",
      };
    }

    // Fallback to low/high descriptions (metrics 11-20)
    return {
      minCriteria: metric.lowDescription || metric.low || "",
      maxCriteria: metric.highDescription || metric.high || "",
    };
  };

  const [rfcForm, setRfcForm] = useState(() => {
    const initialId = metricId || "1";
    const metric = FVS_METRICS.find((m) => String(m.id) === String(initialId));
    const criteria = getMetricCriteria(metric);
    return {
      targetMetric: String(initialId),
      contributionType: "RFC (Request for Comment)",
      rationale: "",
      metricName: metric?.name || "",
      metricQuestion: metric?.question || "",
      minCriteria: criteria.minCriteria,
      maxCriteria: criteria.maxCriteria,
      richEntries: "",
    };
  });
  const [newMetricForm, setNewMetricForm] = useState(() => ({
    metricName: "",
    metricQuestion: "",
    minCriteria: "",
    maxCriteria: "",
    richEntries: "",
    rationale: "",
  }));
  const [selectedCopyMetric, setSelectedCopyMetric] = useState("");

  useEffect(() => {
    if (isOpen) {
      const initialId = metricId || "1";
      const metric = FVS_METRICS.find((m) => String(m.id) === String(initialId));
      const criteria = getMetricCriteria(metric);

      // Reset form only when opening or metricId changes
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setRfcForm({
        targetMetric: String(initialId),
        contributionType: "RFC (Request for Comment)",
        rationale: "",
        metricName: metric?.name || "",
        metricQuestion: metric?.question || "",
        minCriteria: criteria.minCriteria,
        maxCriteria: criteria.maxCriteria,
        richEntries: "",
      });
      setMode(initialMode);
    }
  }, [isOpen, metricId, initialMode, FVS_METRICS]);

  if (!isOpen) return null;

  const handleInputChange = (setter: React.Dispatch<React.SetStateAction<any>>, field: string, value: any) => {
    setter((prev: any) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = () => {
    if (!user) {
      if (onRequireAuth) onRequireAuth();
      return;
    }
    const payload = mode === "rfc" ? rfcForm : newMetricForm;
    if (onSubmit) onSubmit(payload, mode);
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-panel w-full max-w-2xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh] scale-100 animate-slide-up">
        {/* Header */}
        <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
          <div className="flex items-center gap-2 text-white">
            <Icon name="add_comment" className="text-primary" />
            <h3 className="font-bold text-lg font-mono">
              {mode === "rfc" ? "Submit RFC Proposal" : "Propose New Metric"}
            </h3>
          </div>
          <button
            className="text-text-muted hover:text-white"
            onClick={onClose}
          >
            <Icon name="close" />
          </button>
        </div>

        {/* Mode Toggle */}
        <div className="p-4 border-b border-border bg-background">
          <div className="flex gap-2">
            <button
              onClick={() => setMode("rfc")}
              className={`flex-1 py-2 px-4 rounded text-xs font-bold uppercase tracking-wide transition-all ${mode === "rfc"
                ? "bg-primary text-black"
                : "bg-surface text-text-muted hover:text-white border border-border"
                }`}
            >
              <Icon name="edit_square" className="inline mr-2 text-sm" />
              RFC on Existing Metric
            </button>
            <button
              onClick={() => setMode("new-metric")}
              className={`flex-1 py-2 px-4 rounded text-xs font-bold uppercase tracking-wide transition-all ${mode === "new-metric"
                ? "bg-primary text-black"
                : "bg-surface text-text-muted hover:text-white border border-border"
                }`}
            >
              <Icon name="add_box" className="inline mr-2 text-sm" />
              Propose New Metric
            </button>
          </div>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto space-y-5">
          {!user && (
            <div className="bg-primary/10 border border-primary/30 rounded-lg p-4 text-center">
              <p className="text-sm text-primary font-medium">
                You must be logged in to submit a proposal
              </p>
              <button
                onClick={() => {
                  if (onRequireAuth) onRequireAuth();
                }}
                className="mt-2 text-xs text-primary hover:underline font-bold"
              >
                Click here to log in
              </button>
            </div>
          )}

          {mode === "rfc" ? (
            <>
              {/* RFC Mode - Existing fields */}
              <div className="grid grid-cols-2 gap-4">
                {/* Target Metric ID */}
                <div>
                  <label htmlFor="target-metric" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Target Metric
                  </label>
                  <select
                    id="target-metric"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    value={rfcForm.targetMetric}
                    onChange={(e) => {
                      const val = e.target.value;
                      const metric = FVS_METRICS.find(m => String(m.id) === val);
                      const criteria = getMetricCriteria(metric);
                      setRfcForm(prev => ({
                        ...prev,
                        targetMetric: val,
                        metricName: metric?.name || "",
                        metricQuestion: metric?.question || "",
                        minCriteria: criteria.minCriteria,
                        maxCriteria: criteria.maxCriteria,
                      }));
                    }}
                  >
                    {FVS_METRICS.map((metric) => (
                      <option key={metric.id} value={String(metric.id)}>
                        {metric.id} - {metric.name}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Contribution Type */}
                <div>
                  <label htmlFor="contribution-type" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Contribution Type
                  </label>
                  <select
                    id="contribution-type"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    value={rfcForm.contributionType}
                    onChange={(e) =>
                      handleInputChange(setRfcForm, "contributionType", e.target.value)
                    }
                  >
                    <option>RFC (Request for Comment)</option>
                    <option>Score Verification</option>
                    <option>Context Addendum</option>
                  </select>
                </div>
              </div>

              {/* Attribution Integrity / Proposed Adjustments */}
              <div className="space-y-4 border-t border-border/50 pt-4">
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="tune" className="text-primary text-sm" />
                  <span className="text-[10px] font-bold text-text-muted uppercase tracking-wider">
                    Proposed Metric Adjustments
                  </span>
                </div>

                {/* Metric Name */}
                <div>
                  <label htmlFor="rfc-metric-name" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Attribution Integrity (Metric Name)
                  </label>
                  <input
                    id="rfc-metric-name"
                    type="text"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    value={rfcForm.metricName}
                    onChange={(e) => handleInputChange(setRfcForm, "metricName", e.target.value)}
                  />
                </div>

                {/* Metric Question */}
                <div>
                  <label htmlFor="rfc-metric-question" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Metric Question
                  </label>
                  <input
                    id="rfc-metric-question"
                    type="text"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    value={rfcForm.metricQuestion}
                    onChange={(e) => handleInputChange(setRfcForm, "metricQuestion", e.target.value)}
                  />
                </div>

                {/* Criteria */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="rfc-min-criteria" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                      Low Score Criteria (Min)
                    </label>
                    <input
                      id="rfc-min-criteria"
                      type="text"
                      className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                      value={rfcForm.minCriteria}
                      onChange={(e) => handleInputChange(setRfcForm, "minCriteria", e.target.value)}
                    />
                  </div>
                  <div>
                    <label htmlFor="rfc-max-criteria" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                      High Score Criteria (Max)
                    </label>
                    <input
                      id="rfc-max-criteria"
                      type="text"
                      className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                      value={rfcForm.maxCriteria}
                      onChange={(e) => handleInputChange(setRfcForm, "maxCriteria", e.target.value)}
                    />
                  </div>
                </div>

                {/* Rich Entries */}
                <div>
                  <label htmlFor="rfc-rich-entries" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Rich Entries / Examples
                  </label>
                  <textarea
                    id="rfc-rich-entries"
                    className="w-full h-24 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary font-mono leading-relaxed transition-all resize-none"
                    placeholder="Provide rich examples or detailed entries..."
                    value={rfcForm.richEntries}
                    onChange={(e) => handleInputChange(setRfcForm, "richEntries", e.target.value)}
                  ></textarea>
                </div>
              </div>

              {/* Argument / Data */}
              <div>
                <label htmlFor="rationale" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                  Rationale / Data
                </label>
                <textarea
                  id="rationale"
                  className="w-full h-40 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary font-mono leading-relaxed transition-all resize-none"
                  placeholder="Enter your analysis, citing specific timestamps or documents where applicable..."
                  value={rfcForm.rationale}
                  onChange={(e) =>
                    handleInputChange(setRfcForm, "rationale", e.target.value)
                  }
                ></textarea>
              </div>
            </>
          ) : (
            <>
              {/* New Metric Mode */}
              {/* Copy from Existing Metric */}
              <div className="bg-background border border-border rounded-lg p-4">
                <div className="flex items-center gap-2 mb-3">
                  <Icon name="content_copy" className="text-primary text-sm" />
                  <label htmlFor="copy-metric" className="text-[10px] font-bold text-text-muted uppercase">
                    Copy from Existing Metric (Optional)
                  </label>
                </div>
                <p className="text-xs text-text-muted mb-3">
                  Select an existing metric to instantly copy its structure. The form will auto-populate and you can modify the fields below.
                </p>
                <div className="relative">
                  <select
                    id="copy-metric"
                    className="w-full bg-panel border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all appearance-none pr-10"
                    value={selectedCopyMetric}
                    onChange={(e) => {
                      setSelectedCopyMetric(e.target.value);
                      if (e.target.value) {
                        // Auto-copy on selection
                        const metric = FVS_METRICS.find(m => String(m.id) === e.target.value);
                        if (metric) {
                          const criteria = getMetricCriteria(metric);
                          setNewMetricForm(prev => ({
                            ...prev,
                            metricName: metric.name || "",
                            metricQuestion: metric.question || "",
                            minCriteria: criteria.minCriteria,
                            maxCriteria: criteria.maxCriteria,
                          }));
                          // Reset dropdown after copying
                          setTimeout(() => setSelectedCopyMetric(""), 100);
                        }
                      }
                    }}
                  >
                    <option value="">-- Select a metric to copy --</option>
                    {FVS_METRICS.map((metric) => (
                      <option key={metric.id} value={String(metric.id)}>
                        {metric.id} - {metric.name}
                      </option>
                    ))}
                  </select>
                  <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-3 text-text-muted">
                    <Icon name="content_copy" className="text-sm" />
                  </div>
                </div>
              </div>

              <div>
                <label htmlFor="metric-name" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                  Metric Name
                </label>
                <input
                  id="metric-name"
                  type="text"
                  className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                  placeholder="e.g., Source Attribution Quality"
                  value={newMetricForm.metricName}
                  onChange={(e) =>
                    handleInputChange(setNewMetricForm, "metricName", e.target.value)
                  }
                />
              </div>

              <div>
                <label htmlFor="metric-question" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                  Metric Question
                </label>
                <input
                  id="metric-question"
                  type="text"
                  className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                  placeholder="e.g., How well are sources cited and attributed?"
                  value={newMetricForm.metricQuestion}
                  onChange={(e) =>
                    handleInputChange(setNewMetricForm, "metricQuestion", e.target.value)
                  }
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label htmlFor="min-criteria" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    Low Score Criteria (Min)
                  </label>
                  <input
                    id="min-criteria"
                    type="text"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    placeholder="e.g., Vague or unsourced"
                    value={newMetricForm.minCriteria}
                    onChange={(e) =>
                      handleInputChange(setNewMetricForm, "minCriteria", e.target.value)
                    }
                  />
                </div>
                <div>
                  <label htmlFor="max-criteria" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                    High Score Criteria (Max)
                  </label>
                  <input
                    id="max-criteria"
                    type="text"
                    className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
                    placeholder="e.g., Fully verified with documentation"
                    value={newMetricForm.maxCriteria}
                    onChange={(e) =>
                      handleInputChange(setNewMetricForm, "maxCriteria", e.target.value)
                    }
                  />
                </div>
              </div>

              <div>
                <label htmlFor="rationale-new-metric" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                  Rationale for New Metric
                </label>
                <textarea
                  id="rationale-new-metric"
                  className="w-full h-32 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary font-mono leading-relaxed transition-all resize-none"
                  placeholder="Explain why this metric is needed and how it improves the FVS framework..."
                  value={newMetricForm.rationale}
                  onChange={(e) =>
                    handleInputChange(setNewMetricForm, "rationale", e.target.value)
                  }
                ></textarea>
              </div>
            </>
          )}
        </div>

        {/* Footer */}
        <div className="p-4 border-t border-border bg-surface rounded-b-lg flex justify-end gap-3">
          <button
            className="px-5 py-2.5 rounded border border-border text-text-muted hover:text-white text-xs font-bold uppercase tracking-wide transition-colors"
            onClick={onClose}
          >
            Cancel
          </button>
          <button
            className={`px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20 ${!user ? "opacity-60 cursor-not-allowed" : ""
              }`}
            onClick={handleSubmit}
            disabled={!user}
          >
            {user ? "Submit to Ledger" : "Login to Submit"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default SubmissionModal;
