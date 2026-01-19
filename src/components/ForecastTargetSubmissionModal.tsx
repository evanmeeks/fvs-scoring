
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState } from "react";
import { getOriginAbbreviation, SORTED_ORIGIN_TYPES } from "../data/originTypes";
import { SORTED_CONTEXT_TYPES } from "../data/contextTypes";
import { useOriginTypes, useContextTypes } from "../hooks/useSupabase";
import Icon from "./Icon";

type ForecastTargetSubmissionModalProps = {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (formData: typeof initialFormState) => void;
  user: any;
  onRequireAuth?: () => void;
};

const initialFormState = {
  targetName: "",
  caseId: "",
  origin: "",
  context: "",
  description: "",
  sourceUrl: "",
  claimDate: "",
  primarySource: "",
  additionalNotes: "",
};

const ForecastTargetSubmissionModal = ({
  isOpen,
  onClose,
  onSubmit,
  user,
  onRequireAuth,
}: ForecastTargetSubmissionModalProps) => {
  // Fetch from Supabase with local fallback
  const { data: originTypes } = useOriginTypes();
  const { data: contextTypes } = useContextTypes();
  const originOptions = originTypes && originTypes.length > 0 ? originTypes : SORTED_ORIGIN_TYPES;
  const contextOptions = contextTypes && contextTypes.length > 0 ? contextTypes : SORTED_CONTEXT_TYPES;

  const [formData, setFormData] = useState(initialFormState);

  const generateCaseIdPreview = (origin: string) => {
    if (!origin) return "Select Origin";
    const originAbbr = getOriginAbbreviation(origin) || "UNK";
    const protocolNumber = "001";
    return `FVS-${protocolNumber}-${originAbbr}-####`;
  };

  if (!isOpen) return null;

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = () => {
    if (!user) {
      if (onRequireAuth) onRequireAuth();
      return;
    }
    if (!formData.targetName || !formData.description || !formData.claimDate || !formData.sourceUrl) {
      alert("Please fill in all required fields");
      return;
    }
    if (!formData.origin) {
      alert("Please select Origin for Case ID generation");
      return;
    }

    onSubmit(formData);
    onClose();
    setFormData(initialFormState);
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-panel w-full max-w-3xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh] scale-100 animate-slide-up">
        <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
          <div className="flex items-center gap-2 text-white">
            <Icon name="add_box" className="text-primary" />
            <h3 className="font-bold text-lg font-mono">New Forecast Target Entry</h3>
          </div>
          <button className="text-text-muted hover:text-white" onClick={onClose}>
            <Icon name="close" />
          </button>
        </div>

        <div className="p-6 overflow-y-auto space-y-5">
          <div className="text-xs text-text-muted mb-4">
            Propose a new forecast or claim for community analysis using the FVS Protocol. All submissions are reviewed before being added to the active targets list.
          </div>

          <div>
            <label htmlFor="targetName" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
              Target Name <span className="text-red-500">*</span>
            </label>
            <input
              id="targetName"
              type="text"
              name="targetName"
              value={formData.targetName}
              onChange={handleChange}
              className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all font-mono"
              placeholder="e.g., Grusch_T_2024"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <div id="case-id-label" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                Case ID (Auto-Generated)
              </div>
              <div
                className="w-full bg-surface border border-border text-primary p-2.5 rounded text-sm font-mono flex items-center gap-2"
                role="status"
                aria-labelledby="case-id-label"
                aria-live="polite"
              >
                <Icon name="tag" className="text-xs" aria-hidden="true" />
                <span>{generateCaseIdPreview(formData.origin)}</span>
              </div>
              <div className="text-[9px] text-text-muted mt-1 font-mono">
                Format: FVS-PROTOCOL#-ORIGIN-REF
              </div>
            </div>

            <div>
              <label htmlFor="claimDate" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                Claim Date <span className="text-red-500">*</span>
              </label>
              <input
                id="claimDate"
                type="date"
                name="claimDate"
                value={formData.claimDate}
                onChange={handleChange}
                className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label htmlFor="origin" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                Origin
              </label>
              <select
                id="origin"
                name="origin"
                value={formData.origin}
                onChange={handleChange}
                className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
              >
                <option value="">Select origin...</option>
                {originOptions.map((origin) => (
                  <option key={origin.slug} value={origin.slug}>
                    {origin.label} ({origin.abbreviation})
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label htmlFor="context" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
                Context
              </label>
              <select
                id="context"
                name="context"
                value={formData.context}
                onChange={handleChange}
                className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
              >
                <option value="">Select context...</option>
                {contextOptions.map((context) => (
                  <option key={context.slug} value={context.slug}>
                    {context.label}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label htmlFor="primarySource" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
              Primary Source Name
            </label>
            <input
              id="primarySource"
              type="text"
              name="primarySource"
              value={formData.primarySource}
              onChange={handleChange}
              className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
              placeholder="e.g., David Grusch, Eric Davis, etc."
            />
          </div>

          <div>
            <label htmlFor="description" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
              Description <span className="text-red-500">*</span>
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleChange}
              className="w-full h-24 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary leading-relaxed transition-all resize-none"
              placeholder="Brief description of the disclosure event..."
            ></textarea>
          </div>

          <div>
            <label htmlFor="sourceUrl" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
              Source URL / Reference <span className="text-red-500">*</span>
            </label>
            <input
              id="sourceUrl"
              type="url"
              name="sourceUrl"
              value={formData.sourceUrl}
              onChange={handleChange}
              className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all"
              placeholder="https://..."
            />
          </div>

          <div>
            <label htmlFor="additionalNotes" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">
              Additional Notes
            </label>
            <textarea
              id="additionalNotes"
              name="additionalNotes"
              value={formData.additionalNotes}
              onChange={handleChange}
              className="w-full h-20 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary leading-relaxed transition-all resize-none"
              placeholder="Any additional context or notes for reviewers..."
            ></textarea>
          </div>
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
            onClick={handleSubmit}
          >
            New Target Entry
          </button>
        </div>
      </div>
    </div>
  );
};

export default ForecastTargetSubmissionModal;
