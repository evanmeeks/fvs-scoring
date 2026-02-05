"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect, useCallback } from "react";
import { createClient } from "~/lib/supabase/client";
import Icon from "~/components/Icon";
import { getOriginLabel } from "~/data/originTypes";
import { getContextLabel } from "~/data/contextTypes";

type AdminReviewPanelProps = {
  isOpen: boolean;
  onClose: () => void;
  onStatsChange?: () => void;
};

interface Submission {
  id: string;
  type: "target" | "rfc";
  status: string;
  target_name: string;
  submitted_at: string;
  created_at: string;
  description?: string;
  rationale?: string;
  case_id?: string;
  origin?: string;
  primary_source?: string;
  source_url?: string;
  context?: string;
  claim_date?: string;
  additional_notes?: string;
  reviewed_at?: string | null;
  review_notes?: string | null;
  proposal_type?: string;
  proposed_name?: string;
  metrics?: { id: number; name: string };
  metric_id?: number | null;
  proposed_question?: string;
  proposed_min_criteria?: string;
  proposed_max_criteria?: string;
  [key: string]: any;
}

const AdminReviewPanel = ({
  isOpen,
  onClose,
  onStatsChange,
}: AdminReviewPanelProps) => {
  const supabase = createClient();
  const [submissions, setSubmissions] = useState<Submission[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedSubmission, setSelectedSubmission] =
    useState<Submission | null>(null);
  const [reviewNotes, setReviewNotes] = useState("");
  const [targetId, setTargetId] = useState("");
  const [filter, setFilter] = useState("pending");
  const [counts, setCounts] = useState({
    pending: 0,
    approved: 0,
    rejected: 0,
    all: 0,
  });
  const [revokeLoading, setRevokeLoading] = useState(false);

  const generateTargetSlug = (submission: Submission) => {
    const caseId = submission.case_id || "FVS-000";
    const targetName = submission.target_name
      .trim()
      .replace(/\s+/g, "_")
      .replace(/[^a-zA-Z0-9_-]/g, "")
      .replace(/^[_-]+|[_-]+$/g, "");
    return `${caseId}-${targetName}`;
  };

  const loadSubmissions = useCallback(async () => {
    setLoading(true);
    try {
      const { data: targetData, error: targetError } = await supabase
        .from("target_submissions")
        .select("*")
        .order("submitted_at", { ascending: false });

      if (targetError) throw targetError;

      const { data: rfcData, error: rfcError } = await supabase
        .from("rfc_proposals")
        .select("*, metrics(*)")
        .order("created_at", { ascending: false });

      if (rfcError) throw rfcError;

      const targets = (targetData || []).map((t: any) => ({
        ...t,
        type: "target" as const,
      }));
      const rfcs = (rfcData || []).map((r: any) => ({
        ...r,
        type: "rfc" as const,
        target_name:
          r.proposal_type === "new_metric"
            ? r.proposed_name
            : r.metrics?.name || `Metric #${r.metric_id}`,
        submitted_at: r.created_at,
        description: r.rationale,
      }));

      const allSubmissions: Submission[] = [...targets, ...rfcs].sort(
        (a, b) =>
          new Date(b.submitted_at).getTime() -
          new Date(a.submitted_at).getTime(),
      );

      const newCounts = {
        pending: allSubmissions.filter((s) => s.status === "pending").length,
        approved: allSubmissions.filter((s) => s.status === "approved").length,
        rejected: allSubmissions.filter((s) => s.status === "rejected").length,
        all: allSubmissions.length,
      };
      setCounts(newCounts);

      const filteredSubmissions =
        filter === "all"
          ? allSubmissions
          : allSubmissions.filter((s) => s.status === filter);

      setSubmissions(filteredSubmissions);
    } catch (error) {
      console.error("Error loading submissions:", error);
    } finally {
      setLoading(false);
    }
  }, [filter, supabase]);

  useEffect(() => {
    if (isOpen) {
      loadSubmissions();
    }
  }, [isOpen, filter, loadSubmissions]);

  const handleSelectSubmission = (submission: Submission) => {
    setSelectedSubmission(submission);
    if (
      submission &&
      submission.type === "target" &&
      submission.status === "pending"
    ) {
      setTargetId(generateTargetSlug(submission));
    } else {
      setTargetId("");
    }
    setReviewNotes("");
  };

  const handleApprove = async () => {
    if (!selectedSubmission) return;

    if (selectedSubmission.type === "target" && !targetId) {
      alert("Please enter a target ID");
      return;
    }

    try {
      if (selectedSubmission.type === "target") {
        const { error } = await (supabase.rpc as any)("approve_target_submission", {
          submission_id_param: selectedSubmission.id,
          target_id_param: targetId,
        });
        if (error) throw error;
      } else {
        const { error } = await (supabase
          .from("rfc_proposals") as any)
          .update({
            status: "approved",
            review_notes: reviewNotes,
            reviewed_at: new Date().toISOString(),
          })
          .eq("id", selectedSubmission.id);

        if (error) throw error;
      }

      alert(
        `${selectedSubmission.type === "target" ? "Target" : "Proposal"} approved successfully!`,
      );
      setSelectedSubmission(null);
      setTargetId("");
      setReviewNotes("");
      loadSubmissions();
      onStatsChange?.();
    } catch (error: any) {
      console.error("Error approving submission:", error);
      alert("Failed to approve submission: " + error.message);
    }
  };

  const handleReject = async () => {
    if (!selectedSubmission) return;

    try {
      const table =
        selectedSubmission.type === "target"
          ? "target_submissions"
          : "rfc_proposals";

      const updatePayload: any = {
        status: "rejected",
        review_notes: reviewNotes,
        reviewed_at: new Date().toISOString(),
      };

      const { error } = await (supabase
        .from(table) as any)
        .update(updatePayload)
        .eq("id", selectedSubmission.id);

      if (error) throw error;

      alert("Submission rejected");
      setSelectedSubmission(null);
      setReviewNotes("");
      loadSubmissions();
      onStatsChange?.();
    } catch (error) {
      console.error("Error rejecting submission:", error);
      alert("Failed to reject submission");
    }
  };

  const handleRevoke = async () => {
    if (!selectedSubmission) return;

    if (
      selectedSubmission.status !== "approved" &&
      selectedSubmission.status !== "rejected"
    )
      return;

    const actionLabel =
      selectedSubmission.status === "approved"
        ? "Revoke this approval"
        : "Revert this rejection";

    const confirmRevoke = window.confirm(
      `${actionLabel} and return the submission to Pending review?`,
    );
    if (!confirmRevoke) return;

    try {
      setRevokeLoading(true);

      if (selectedSubmission.type === "target") {
        const { error } = await (supabase.rpc as any)("revoke_target_submission", {
          submission_id_param: selectedSubmission.id,
          review_notes_param: reviewNotes || "",
        });
        if (error) throw error;
      } else {
        const { error } = await (supabase
          .from("rfc_proposals") as any)
          .update({
            status: "pending",
            review_notes: null,
            reviewed_at: null,
            reviewed_by: null,
          })
          .eq("id", selectedSubmission.id);
        if (error) throw error;
      }

      alert("Submission returned to Pending.");
      setSelectedSubmission(null);
      setReviewNotes("");
      setTargetId("");
      loadSubmissions();
      onStatsChange?.();
    } catch (error) {
      console.error("Error resetting submission:", error);
      alert("Failed to reset submission");
    } finally {
      setRevokeLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-panel w-full max-w-6xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
          <div className="flex items-center gap-2 text-white">
            <Icon name="admin_panel_settings" className="text-primary" />
            <h3 className="font-bold text-lg font-mono">
              Admin Review Panel
            </h3>
          </div>
          <button
            className="text-text-muted hover:text-white"
            onClick={onClose}
          >
            <Icon name="close" />
          </button>
        </div>

        {/* Filter Tabs */}
        <div className="flex gap-2 p-4 border-b border-border bg-background">
          {(
            [
              { key: "pending", label: "Pending", count: counts.pending },
              { key: "approved", label: "Approved", count: counts.approved },
              { key: "rejected", label: "Rejected", count: counts.rejected },
              { key: "all", label: "All", count: counts.all },
            ] as const
          ).map((tab) => (
            <button
              key={tab.key}
              onClick={() => setFilter(tab.key)}
              className={`px-4 py-2 rounded text-xs font-bold uppercase transition-all ${
                filter === tab.key
                  ? "bg-primary text-black"
                  : "bg-panel border border-border text-text-muted hover:text-white"
              }`}
            >
              {tab.label} ({tab.count})
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="flex-1 overflow-hidden flex">
          {/* Submissions List */}
          <div className="w-1/2 border-r border-border overflow-y-auto p-4 space-y-3">
            {loading ? (
              <div className="text-center text-text-muted py-8">
                Loading...
              </div>
            ) : submissions.length === 0 ? (
              <div className="text-center text-text-muted py-8">
                No submissions found
              </div>
            ) : (
              submissions.map((submission) => (
                <div
                  key={submission.id}
                  role="button"
                  tabIndex={0}
                  onClick={() => handleSelectSubmission(submission)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") {
                      e.preventDefault();
                      handleSelectSubmission(submission);
                    }
                  }}
                  aria-pressed={selectedSubmission?.id === submission.id}
                  className={`p-4 rounded-lg border cursor-pointer transition-all ${
                    selectedSubmission?.id === submission.id
                      ? "border-primary bg-primary/10"
                      : "border-border bg-background hover:border-primary/50"
                  }`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex items-center gap-2">
                      {submission.type === "rfc" && (
                        <span className="text-[9px] bg-purple-500/20 text-purple-400 px-1.5 py-0.5 rounded font-bold uppercase">
                          RFC
                        </span>
                      )}
                      <h4 className="font-bold text-white font-mono break-all line-clamp-1">
                        {submission.target_name}
                      </h4>
                    </div>
                    <span
                      className={`text-[10px] px-2 py-1 rounded uppercase font-bold whitespace-nowrap ${
                        submission.status === "pending"
                          ? "bg-amber-500/20 text-amber-500"
                          : submission.status === "approved"
                            ? "bg-primary/20 text-primary"
                            : "bg-red-500/20 text-red-500"
                      }`}
                    >
                      {submission.status}
                    </span>
                  </div>
                  <p className="text-xs text-text-muted mb-2 line-clamp-2">
                    {submission.description}
                  </p>
                  <div className="flex items-center gap-4 text-[10px] text-text-muted">
                    <div>
                      <Icon
                        name="calendar_today"
                        className="text-[10px] mr-1"
                      />
                      {new Date(
                        (submission.type === "target"
                          ? submission.claim_date
                          : submission.created_at) || "",
                      ).toLocaleDateString()}
                    </div>
                    <div>
                      <Icon name="schedule" className="text-[10px] mr-1" />
                      {new Date(submission.submitted_at).toLocaleDateString()}
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Detail Panel */}
          <div className="w-1/2 overflow-y-auto p-6">
            {!selectedSubmission ? (
              <div className="text-center text-text-muted py-8">
                Select a submission to review
              </div>
            ) : (
              <div className="space-y-6">
                <div>
                  <div className="flex items-center gap-2 mb-2">
                    {selectedSubmission.type === "rfc" && (
                      <span className="text-xs bg-purple-500/20 text-purple-400 px-2 py-1 rounded font-bold uppercase border border-purple-500/30">
                        Metric Proposal
                      </span>
                    )}
                    <h3 className="text-xl font-bold text-white">
                      {selectedSubmission.target_name}
                    </h3>
                  </div>
                  <div className="text-[10px] text-text-muted font-mono">
                    ID: {selectedSubmission.id.slice(0, 8)}...
                  </div>
                </div>

                {/* Fields */}
                <div className="grid grid-cols-2 gap-4 text-sm">
                  {selectedSubmission.type === "target" && (
                    <>
                      <div>
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Case ID
                        </div>
                        <div className="text-white font-mono">
                          {selectedSubmission.case_id || "N/A"}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Date of Claim
                        </div>
                        <div className="text-white">
                          {new Date(
                            selectedSubmission.claim_date || "",
                          ).toLocaleDateString()}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Origin
                        </div>
                        <div className="text-white">
                          {getOriginLabel(selectedSubmission.origin) || "N/A"}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Context
                        </div>
                        <div className="text-white">
                          {getContextLabel(selectedSubmission.context) || "N/A"}
                        </div>
                      </div>
                    </>
                  )}

                  {selectedSubmission.type === "rfc" && (
                    <>
                      <div>
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Proposal Type
                        </div>
                        <div className="text-white font-mono">
                          {selectedSubmission.proposal_type === "new_metric"
                            ? "New Metric"
                            : "Modification"}
                        </div>
                      </div>
                      {selectedSubmission.metrics && (
                        <div>
                          <div className="text-[10px] text-text-muted uppercase mb-1">
                            Existing Metric
                          </div>
                          <div className="text-white">
                            {selectedSubmission.metrics.name} (ID:{" "}
                            {selectedSubmission.metrics.id})
                          </div>
                        </div>
                      )}
                    </>
                  )}
                </div>

                {/* Description */}
                <div>
                  <div className="text-[10px] text-text-muted uppercase mb-2">
                    {selectedSubmission.type === "rfc"
                      ? "Rationale"
                      : "Description"}
                  </div>
                  <p className="text-sm text-white leading-relaxed">
                    {selectedSubmission.type === "rfc"
                      ? selectedSubmission.rationale
                      : selectedSubmission.description}
                  </p>
                </div>

                {selectedSubmission.type === "rfc" &&
                  selectedSubmission.proposed_question && (
                    <div>
                      <div className="text-[10px] text-text-muted uppercase mb-2">
                        Proposed Question
                      </div>
                      <p className="text-sm text-white italic leading-relaxed">
                        &quot;{selectedSubmission.proposed_question}&quot;
                      </p>
                    </div>
                  )}

                {selectedSubmission.type === "rfc" &&
                  (selectedSubmission.proposed_min_criteria ||
                    selectedSubmission.proposed_max_criteria) && (
                    <div className="grid grid-cols-2 gap-4">
                      {selectedSubmission.proposed_min_criteria && (
                        <div>
                          <div className="text-[10px] text-text-muted uppercase mb-2">
                            Min Criteria (1)
                          </div>
                          <p className="text-xs text-red-400">
                            {selectedSubmission.proposed_min_criteria}
                          </p>
                        </div>
                      )}
                      {selectedSubmission.proposed_max_criteria && (
                        <div>
                          <div className="text-[10px] text-text-muted uppercase mb-2">
                            Max Criteria (5)
                          </div>
                          <p className="text-xs text-primary">
                            {selectedSubmission.proposed_max_criteria}
                          </p>
                        </div>
                      )}
                    </div>
                  )}

                {selectedSubmission.type === "target" &&
                  selectedSubmission.primary_source && (
                    <div>
                      <div className="text-[10px] text-text-muted uppercase mb-1">
                        Primary Source
                      </div>
                      <div className="text-sm text-white">
                        {selectedSubmission.primary_source}
                      </div>
                    </div>
                  )}

                {selectedSubmission.type === "target" &&
                  selectedSubmission.source_url && (
                    <div>
                      <div className="text-[10px] text-text-muted uppercase mb-1">
                        Source URL
                      </div>
                      <a
                        href={selectedSubmission.source_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-sm text-primary hover:underline break-all"
                      >
                        {selectedSubmission.source_url}
                      </a>
                    </div>
                  )}

                {selectedSubmission.additional_notes && (
                  <div>
                    <div className="text-[10px] text-text-muted uppercase mb-2">
                      Additional Notes
                    </div>
                    <p className="text-sm text-white leading-relaxed">
                      {selectedSubmission.additional_notes}
                    </p>
                  </div>
                )}

                {/* Actions for Pending */}
                {selectedSubmission.status === "pending" && (
                  <div className="space-y-4 pt-4 border-t border-border">
                    {selectedSubmission.type === "target" && (
                      <div>
                        <label
                          htmlFor="target-id-approval"
                          className="block text-[10px] font-bold text-text-muted uppercase mb-2"
                        >
                          Target ID (for approval){" "}
                          <span className="text-red-500">*</span>
                        </label>
                        <input
                          id="target-id-approval"
                          type="text"
                          value={targetId}
                          onChange={(e) => setTargetId(e.target.value)}
                          className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all font-mono"
                          placeholder="e.g., grusch-2024"
                        />
                      </div>
                    )}

                    <div>
                      <label
                        htmlFor="review-notes"
                        className="block text-[10px] font-bold text-text-muted uppercase mb-2"
                      >
                        Review Notes
                      </label>
                      <textarea
                        id="review-notes"
                        value={reviewNotes}
                        onChange={(e) => setReviewNotes(e.target.value)}
                        className="w-full h-24 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary leading-relaxed transition-all resize-none"
                        placeholder="Optional notes about this review..."
                      ></textarea>
                    </div>

                    <div className="flex gap-3">
                      <button
                        onClick={handleApprove}
                        className="flex-1 px-4 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20 flex items-center justify-center gap-2"
                      >
                        <Icon name="check_circle" />
                        Approve
                      </button>
                      <button
                        onClick={handleReject}
                        className="flex-1 px-4 py-2.5 rounded border border-red-500 text-red-500 hover:bg-red-500/20 font-bold text-xs uppercase tracking-wide transition-colors flex items-center justify-center gap-2"
                      >
                        <Icon name="cancel" />
                        Reject
                      </button>
                    </div>
                  </div>
                )}

                {/* Status for reviewed items */}
                {selectedSubmission.status !== "pending" && (
                  <div className="pt-4 border-t border-border">
                    <div className="text-[10px] text-text-muted uppercase mb-2">
                      Review Status
                    </div>
                    <div
                      className={`text-sm font-bold ${
                        selectedSubmission.status === "approved"
                          ? "text-primary"
                          : "text-red-500"
                      }`}
                    >
                      {selectedSubmission.status.toUpperCase()}
                    </div>
                    {selectedSubmission.reviewed_at && (
                      <div className="text-xs text-text-muted mt-1">
                        Reviewed:{" "}
                        {new Date(
                          selectedSubmission.reviewed_at,
                        ).toLocaleString()}
                      </div>
                    )}
                    {selectedSubmission.review_notes && (
                      <div className="mt-3">
                        <div className="text-[10px] text-text-muted uppercase mb-1">
                          Review Notes
                        </div>
                        <p className="text-sm text-white">
                          {selectedSubmission.review_notes}
                        </p>
                      </div>
                    )}
                    {(selectedSubmission.status === "approved" ||
                      selectedSubmission.status === "rejected") && (
                      <div className="mt-4">
                        <button
                          onClick={handleRevoke}
                          disabled={revokeLoading}
                          className={`px-4 py-2.5 rounded border border-amber-500 text-amber-400 hover:bg-amber-500/10 font-bold text-xs uppercase tracking-wide transition-colors flex items-center gap-2 ${
                            revokeLoading
                              ? "opacity-60 cursor-not-allowed"
                              : ""
                          }`}
                        >
                          <Icon name="undo" />
                          {revokeLoading
                            ? "Processing..."
                            : selectedSubmission.status === "approved"
                              ? "Revoke Approval"
                              : "Revert Rejection"}
                        </button>
                      </div>
                    )}
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminReviewPanel;
