"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useMemo, useState, useEffect, useCallback } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  createColumnHelper,
} from "@tanstack/react-table";
import { createClient } from "~/lib/supabase/client";
import type { DbMetric } from "~/types/database";

type RFCWithMetric = {
  id: string;
  metric_id: number | null;
  proposal_type: string;
  proposed_name: string | null;
  proposed_question: string | null;
  proposed_min_criteria: string | null;
  proposed_max_criteria: string | null;
  rationale: string;
  status: string | null;
  created_at: string;
  version?: string | null;
  metrics: DbMetric | null;
};

type DbRFCVote = {
  id: string;
  rfc_id: string | null;
  user_id: string;
  vote: string | null;
  confidence_level: string | null;
  notes: string | null;
};

const columnHelper = createColumnHelper<RFCWithMetric>();

const NoteCell = ({
  rfcId,
  initialNotes,
  onUpdateNote,
}: {
  rfcId: string;
  initialNotes: string;
  onUpdateNote: (id: string, notes: string) => void;
}) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [noteText, setNoteText] = useState(initialNotes || "");

  return (
    <div className="flex items-center gap-2">
      {!isExpanded && !initialNotes ? (
        <button
          onClick={(e) => {
            e.stopPropagation();
            setIsExpanded(true);
          }}
          className="text-[10px] text-text-muted hover:text-primary transition-colors uppercase tracking-wide"
        >
          + Add note
        </button>
      ) : (
        <input
          type="text"
          placeholder="Optional feedback..."
          className="w-full bg-transparent border-b border-border focus:border-primary text-white text-xs py-1 focus:outline-none transition-colors"
          value={noteText}
          onChange={(e) => setNoteText(e.target.value)}
          onBlur={() => {
            if (noteText !== (initialNotes || "")) {
              onUpdateNote(rfcId, noteText);
            }
            if (!noteText) setIsExpanded(false);
          }}
          onKeyDown={(e) => {
            if (e.key === "Enter") {
              onUpdateNote(rfcId, noteText);
              e.currentTarget.blur();
            }
          }}
          onClick={(e) => e.stopPropagation()}
        />
      )}
    </div>
  );
};

const RFCProposalList = () => {
  const supabase = createClient();
  const [user, setUser] = useState<any>(null);
  const [proposals, setProposals] = useState<RFCWithMetric[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [userVotes, setUserVotes] = useState<Record<string, DbRFCVote>>({});

  // Fetch user
  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  // Fetch proposals
  const fetchProposals = useCallback(async () => {
    setLoading(true);
    try {
      const { data, error: fetchError } = await supabase
        .from("rfc_proposals")
        .select("*, metrics(*)")
        .order("created_at", { ascending: false });

      if (fetchError) throw fetchError;
      setProposals((data as RFCWithMetric[]) || []);
    } catch (err) {
      console.error("Error fetching proposals:", err);
      setError("Failed to load proposals");
    } finally {
      setLoading(false);
    }
  }, [supabase]);

  // Fetch user votes
  const fetchVotes = useCallback(async () => {
    if (!user) return;
    try {
      const { data, error: fetchError } = await supabase
        .from("rfc_votes")
        .select("*")
        .eq("user_id", user.id);

      if (fetchError) throw fetchError;

      const votesMap = (data || []).reduce(
        (acc: Record<string, DbRFCVote>, vote: any) => {
          if (vote.rfc_id) {
            acc[vote.rfc_id] = vote;
          }
          return acc;
        },
        {} as Record<string, DbRFCVote>,
      );
      setUserVotes(votesMap);
    } catch (err) {
      console.error("Error fetching votes:", err);
    }
  }, [user, supabase]);

  useEffect(() => {
    fetchProposals();
  }, [fetchProposals]);

  useEffect(() => {
    if (user) fetchVotes();
  }, [user, fetchVotes]);

  const upsertVote = async (
    rfcId: string,
    vote: string,
    confidence: string,
    notes: string,
  ) => {
    if (!user) return;
    try {
      const { error: upsertError } = await (supabase.from("rfc_votes") as any).upsert(
        {
          rfc_id: rfcId,
          user_id: user.id,
          vote,
          confidence_level: confidence,
          notes,
        },
        { onConflict: "rfc_id,user_id" },
      );
      if (upsertError) throw upsertError;
    } catch (err) {
      console.error("Error upserting vote:", err);
    }
  };

  const handleVote = async (rfcId: string, vote: string) => {
    if (!user) return;
    const existingVote = userVotes?.[rfcId];
    await upsertVote(
      rfcId,
      vote,
      existingVote?.confidence_level || "medium",
      existingVote?.notes || "",
    );
    fetchVotes();
  };

  const handleConfidence = async (rfcId: string, confidence: string) => {
    if (!user) return;
    const existingVote = userVotes?.[rfcId];
    await upsertVote(
      rfcId,
      existingVote?.vote || "approve",
      confidence,
      existingVote?.notes || "",
    );
    fetchVotes();
  };

  const handleNote = async (rfcId: string, notes: string) => {
    if (!user) return;
    const existingVote = userVotes?.[rfcId];
    await upsertVote(
      rfcId,
      existingVote?.vote || "approve",
      existingVote?.confidence_level || "medium",
      notes,
    );
    fetchVotes();
  };

  const columns = useMemo(
    () => [
      columnHelper.accessor((row) => row.version, {
        header: "Ver",
        cell: (info) => (
          <span className="text-[10px] mono text-ops-text-dim">
            v{info.getValue() || "1.1"}
          </span>
        ),
        meta: {
          className: "p-4 w-12 text-center text-ops-text-dim font-mono",
        } as any,
      }),
      columnHelper.accessor((row) => row.metric_id, {
        header: "Metric Proposal",
        cell: (info) => {
          const row = info.row.original;
          return (
            <div className="flex flex-col gap-1">
              <div className="flex items-center gap-2">
                <span
                  className={`
                  text-[9px] uppercase font-bold px-1.5 py-0.5 rounded leading-none
                  ${row.status === "approved" ? "bg-green-500/20 text-green-400" : ""}
                  ${row.status === "pending" ? "bg-yellow-500/20 text-yellow-400" : ""}
                  ${row.status === "rejected" ? "bg-red-500/20 text-red-400" : ""}
                  ${row.status === "under_review" ? "bg-blue-500/20 text-blue-400" : ""}
                  ${row.status === "implemented" ? "bg-purple-500/20 text-purple-400" : ""}
                `}
                >
                  {row.status || "Pending"}
                </span>
                <span className="font-bold text-white text-sm">
                  {row.proposal_type === "new_metric"
                    ? row.proposed_name
                    : row.metrics?.name || `Metric #${row.metric_id}`}
                </span>
              </div>
              <div className="flex items-center gap-2 mt-1">
                <span className="text-[9px] text-text-muted uppercase border border-border px-1 rounded bg-black/50">
                  {row.proposal_type === "new_metric"
                    ? "New Metric"
                    : "Modification"}
                </span>
                {row.proposal_type === "modify_existing" &&
                  row.proposed_name && (
                    <span className="text-xs text-primary">
                      &rarr; Rename to: {row.proposed_name}
                    </span>
                  )}
              </div>
              <div className="text-[10px] text-text-muted mt-1 max-w-lg leading-relaxed">
                <span className="text-ops-accent">Rationale:</span>{" "}
                {row.rationale}
              </div>
            </div>
          );
        },
        meta: { className: "p-4 w-1/4" } as any,
      }),
      columnHelper.accessor((row) => row.proposed_question, {
        header: "Proposed Definition",
        cell: (info) => {
          const row = info.row.original;
          return (
            <div className="text-xs text-gray-400">
              {row.proposed_question ? (
                <div className="mb-1 text-white italic">
                  &quot;{row.proposed_question}&quot;
                </div>
              ) : (
                <div className="mb-1 text-text-muted italic opacity-50">
                  No change to question
                </div>
              )}
              {(row.proposed_min_criteria || row.proposed_max_criteria) && (
                <div className="grid grid-cols-2 gap-2 mt-2 opacity-80">
                  {row.proposed_min_criteria && (
                    <span className="text-red-400">
                      1: {row.proposed_min_criteria}
                    </span>
                  )}
                  {row.proposed_max_criteria && (
                    <span className="text-ops-accent">
                      5: {row.proposed_max_criteria}
                    </span>
                  )}
                </div>
              )}
            </div>
          );
        },
        meta: { className: "p-4 w-1/3" } as any,
      }),
      columnHelper.display({
        id: "vote",
        header: "Your Vote",
        cell: ({ row }) => {
          const rfcId = row.original.id;
          const userVote = userVotes?.[rfcId];
          const currentVote = userVote?.vote;

          const voteOptions = [
            { value: "approve", label: "Approve", color: "text-green-400" },
            { value: "reject", label: "Reject", color: "text-red-400" },
            { value: "abstain", label: "Abstain", color: "text-yellow-400" },
          ];

          return (
            <div className="flex gap-1">
              {voteOptions.map((option) => (
                <button
                  key={option.value}
                  onClick={(e) => {
                    e.stopPropagation();
                    handleVote(rfcId, option.value);
                  }}
                  className={`
                    px-3 py-1.5 text-xs font-bold rounded transition-all
                    ${
                      currentVote === option.value
                        ? `${option.color} bg-surface border-2 border-current`
                        : "bg-panel border border-border text-text-muted hover:border-primary hover:text-white"
                    }
                  `}
                >
                  {option.label}
                </button>
              ))}
            </div>
          );
        },
        meta: { className: "p-4 w-72" } as any,
      }),
      columnHelper.display({
        id: "confidence",
        header: "Confidence",
        cell: ({ row }) => {
          const rfcId = row.original.id;
          const vote = userVotes?.[rfcId];
          const confidence = vote?.confidence_level;

          const levels = [
            { value: "low", label: "Low" },
            { value: "medium", label: "Med" },
            { value: "high", label: "High" },
          ];

          return (
            <div className="flex gap-1">
              {levels.map((level) => (
                <button
                  key={level.value}
                  onClick={(e) => {
                    e.stopPropagation();
                    handleConfidence(rfcId, level.value);
                  }}
                  className={`
                    px-2 py-1.5 text-xs font-bold rounded transition-all
                    ${
                      confidence === level.value
                        ? "bg-primary text-black"
                        : "bg-panel border border-border text-text-muted hover:border-primary hover:text-white"
                    }
                  `}
                >
                  {level.label}
                </button>
              ))}
            </div>
          );
        },
        meta: { className: "p-4 w-48" } as any,
      }),
      columnHelper.display({
        id: "notes",
        header: "Notes (Optional)",
        cell: ({ row }) => {
          const rfcId = row.original.id;
          const vote = userVotes?.[rfcId];
          return (
            <NoteCell
              rfcId={rfcId}
              initialNotes={vote?.notes || ""}
              onUpdateNote={handleNote}
            />
          );
        },
        meta: { className: "p-4" } as any,
      }),
      columnHelper.accessor((row) => row.created_at, {
        header: "Submitted",
        cell: (info) => (
          <span className="text-xs text-text-muted mono">
            {new Date(info.getValue()).toLocaleDateString()}
          </span>
        ),
        meta: { className: "p-4 w-24 text-right" } as any,
      }),
      // eslint-disable-next-line react-hooks/exhaustive-deps
    ],
    [userVotes],
  );

  const table = useReactTable({
    data: proposals,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  if (loading) {
    return (
      <div className="p-8 text-center text-text-muted animate-pulse font-mono text-xs">
        LOADING PROPOSALS...
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-8 text-center text-red-400 font-mono text-xs">
        ERROR LOADING PROPOSALS
      </div>
    );
  }

  if (!proposals || proposals.length === 0) {
    return (
      <div className="space-y-4">
        <h3 className="text-lg font-bold text-primary flex items-center gap-2 font-mono uppercase tracking-wider">
          <span className="material-symbols-outlined text-sm">forum</span>
          RFC Proposals
        </h3>
        <div className="p-8 text-center text-text-muted border border-dashed border-ops-border rounded-lg bg-black/20 text-xs font-mono uppercase">
          No active RFC proposals found.
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-bold text-primary flex items-center gap-2 font-mono uppercase tracking-wider">
          <span className="material-symbols-outlined text-sm">forum</span>
          RFC Proposals
        </h3>
      </div>

      <div className="bg-ops-panel border border-ops-border rounded-lg overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            {table.getHeaderGroups().map((headerGroup) => (
              <tr
                key={headerGroup.id}
                className="bg-black border-b border-ops-border text-xs font-mono uppercase text-ops-text-dim"
              >
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className={
                      (header.column.columnDef.meta as any)?.className
                    }
                  >
                    {flexRender(
                      header.column.columnDef.header,
                      header.getContext(),
                    )}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="divide-y divide-ops-border text-sm text-gray-300">
            {table.getRowModel().rows.map((row) => (
              <tr
                key={row.id}
                className="hover:bg-white/5 transition-colors group border-b border-ops-border"
              >
                {row.getVisibleCells().map((cell) => (
                  <td
                    key={cell.id}
                    className={
                      (cell.column.columnDef.meta as any)?.className
                    }
                  >
                    {flexRender(
                      cell.column.columnDef.cell,
                      cell.getContext(),
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default RFCProposalList;
