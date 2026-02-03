"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import React, { useMemo } from "react";
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  type ColumnDef,
} from "@tanstack/react-table";
import type { Metric } from "~/context/AppContext";

interface MetricTableProps {
  data: Metric[];
  scores?: Record<string, number>;
  votes?: Record<string, any>;
  onScoreChange?: (id: number | string, score: number) => void;
  onVoteChange?: (
    id: number | string,
    field: "confidence" | "notes",
    value: string | null,
  ) => void | Promise<void>;
  onSelect?: (metric: Metric) => void;
  isSelected?: number | string | null;
  mode?: "scoring" | "review" | "governance";
  saveStatus?: Record<string, string>;
}

const MetricTable = React.memo(({
  data,
  scores = {},
  votes,
  onScoreChange = () => {},
  onVoteChange = () => {},
  onSelect,
  isSelected,
  mode = "scoring",
  saveStatus = {},
}: MetricTableProps) => {
  const columns = useMemo<ColumnDef<Metric>[]>(() => {
    const baseCols: ColumnDef<Metric>[] = [
      {
        header: mode === "governance" ? "Ver" : "#",
        accessorKey: "id",
        cell: (info) => (
          <span className="text-[10px] mono text-ops-text-dim">
            {mode === "governance"
              ? "v1.0"
              : (info.getValue() as number).toString().padStart(2, "0")}
          </span>
        ),
        meta: {
          className: "p-4 w-12 text-center text-ops-text-dim font-mono",
        },
      },
      {
        header: "Metric Name",
        accessorKey: "name",
        cell: (info) => (
          <div className="font-bold text-white">{info.getValue() as string}</div>
        ),
        meta: { className: "p-4 w-1/4" },
      },
      {
        header:
          mode === "governance"
            ? "Current Definition (Standard)"
            : "Assessment Criteria",
        accessorKey: "question",
        cell: ({ row, table }) => {
          const metric = row.original;
          const meta = table.options.meta as any;
          const {
            mode: tableMode,
            scores: tableScores,
            onScoreChange: tableOnScoreChange,
          } = meta;

          const question = metric.question;
          let minLabel = "Low";
          let maxLabel = "High";
          let minDesc = metric.lowDescription || "";
          let maxDesc = metric.highDescription || "";

          const criteria = metric.scoringCriteria || [];
          const lowCriteria = criteria.find((c: any) => c.score === 1);
          const highCriteria = criteria.find((c: any) => c.score === 5);

          if (lowCriteria) {
            minLabel = lowCriteria.label;
            minDesc = lowCriteria.description;
          } else if (metric.lowDescription) {
            minDesc = metric.lowDescription;
            minLabel = "Low";
          }

          if (highCriteria) {
            maxLabel = highCriteria.label;
            maxDesc = highCriteria.description;
          } else if (metric.highDescription) {
            maxDesc = metric.highDescription;
            maxLabel = "High";
          }

          const score = tableScores?.[metric.id];

          if (tableMode === "governance") {
            return (
              <div className="text-xs text-gray-400">
                <div className="mb-1 text-white italic">&quot;{question}&quot;</div>
                <div className="grid grid-cols-2 gap-2 mt-2 opacity-60">
                  <span className="text-red-400">
                    1: {minLabel}
                    {minDesc ? `: ${minDesc}` : ""}
                  </span>
                  <span className="text-ops-accent">
                    5: {maxLabel}
                    {maxDesc ? `: ${maxDesc}` : ""}
                  </span>
                </div>
              </div>
            );
          }

          return (
            <div className="pr-4">
              <div className="text-xs text-text-muted mb-2">{question}</div>
              {tableMode === "scoring" ? (
                <div className="flex items-center gap-4">
                  <span className="text-[9px] mono text-text-muted w-20 truncate">
                    {minLabel}
                  </span>
                  <input
                    type="range"
                    min="0"
                    max="5"
                    step="1"
                    value={score || 0}
                    className="custom-range flex-1"
                    onChange={(e) =>
                      tableOnScoreChange?.(metric.id, parseInt(e.target.value))
                    }
                    onClick={(e) => e.stopPropagation()}
                  />
                  <span className="text-[9px] mono text-text-muted w-20 truncate text-right">
                    {maxLabel}
                  </span>
                </div>
              ) : (
                <div className="text-[10px] mono text-primary">
                  CRITERIA: 1 (Absent) to 5 (High Utility)
                </div>
              )}
            </div>
          );
        },
        meta: { className: "p-4 w-1/3" },
      },
    ];

    if (mode === "governance") {
      baseCols.push({
        header: "Confidence",
        id: "vote_confidence",
        cell: ({ row, table }) => {
          const metric = row.original;
          const meta = table.options.meta as any;
          const {
            votes: tableVotes,
            onVoteChange: tableOnVoteChange,
            saveStatus: tableSaveStatus,
          } = meta;
          const vote = tableVotes ? tableVotes[metric.id] : {};
          const confidence = vote?.confidence || null;
          const status = tableSaveStatus?.[metric.id];

          const confidenceLevels = [
            { value: "low", label: "Low", emoji: "⚠️" },
            { value: "medium", label: "Medium", emoji: "✓" },
            { value: "high", label: "High", emoji: "✓✓" },
          ];

          return (
            <div className="flex items-center gap-2">
              <div className="flex gap-1">
                {confidenceLevels.map((level) => (
                  <button
                    key={level.value}
                    onClick={(e) => {
                      e.stopPropagation();
                      tableOnVoteChange?.(metric.id, "confidence", level.value);
                    }}
                    className={`
                      px-3 py-1.5 text-xs font-bold rounded transition-all
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
              {status && (
                <span className="text-[10px] text-text-muted ml-2">
                  {status === "saving" && "💾"}
                  {status === "saved" && "✓"}
                  {status === "error" && "⚠️"}
                </span>
              )}
            </div>
          );
        },
        meta: { className: "p-4 w-64" },
      });

      const MetricNoteCell = ({
        notes,
        onUpdate,
      }: {
        notes: string;
        onUpdate?: (notes: string) => void;
      }) => {
        const [isExpanded, setIsExpanded] = React.useState(false);

        return (
          <div className="flex items-center gap-2">
            {!isExpanded && !notes ? (
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
                placeholder="Optional feedback or suggestions..."
                className="w-full bg-transparent border-b border-border focus:border-primary text-white text-xs py-1 focus:outline-none transition-colors"
                value={notes || ""}
                onChange={(e) => onUpdate?.(e.target.value)}
                onClick={(e) => e.stopPropagation()}
                onKeyDown={(e) => e.stopPropagation()}
                onBlur={() => {
                  if (!notes) setIsExpanded(false);
                }}
              />
            )}
          </div>
        );
      };

      baseCols.push({
        header: "Notes (Optional)",
        id: "vote_notes",
        cell: ({ row, table }) => {
          const metric = row.original;
          const meta = table.options.meta as any;
          const { votes: tableVotes, onVoteChange: tableOnVoteChange } = meta;
          const vote = tableVotes ? tableVotes[metric.id] : {};

          return (
            <MetricNoteCell
              notes={vote?.notes}
              onUpdate={(val) =>
                tableOnVoteChange?.(metric.id, "notes", val)
              }
            />
          );
        },
        meta: { className: "p-4" },
      });
    } else {
      baseCols.push({
        header: mode === "review" ? "Community Score" : "Your Score",
        id: "score_display",
        cell: ({ row, table }) => {
          const metric = row.original;
          const meta = table.options.meta as any;
          const { mode: tableMode, scores: tableScores } = meta;
          const score = tableScores?.[metric.id];

          return (
            <div className="text-center">
              {tableMode === "review" ? (
                <div className="flex flex-col items-center">
                  <span className="text-sm mono font-bold text-white">
                    {metric.communityScore
                      ? metric.communityScore.toFixed(1)
                      : "-"}
                  </span>
                  <div className="w-16 h-1 bg-border mt-1 rounded-full overflow-hidden">
                    <div
                      className="h-full bg-primary"
                      style={{
                        width: `${((metric.communityScore || 0) / 5) * 100}%`,
                      }}
                    ></div>
                  </div>
                </div>
              ) : (
                <span
                  className={`text-lg mono font-bold ${
                    score && score > 0 ? "text-primary" : "text-text-muted"
                  }`}
                >
                  {score && score > 0 ? score : "-"}
                </span>
              )}
            </div>
          );
        },
        meta: { className: "p-4 w-24" },
      });
      baseCols.push({
        header: "Inspect",
        id: "inspect",
        cell: () => (
          <div className="text-right flex justify-end">
            <span className="material-symbols-outlined text-text-muted text-sm group-hover:text-white">
              visibility
            </span>
          </div>
        ),
        meta: { className: "p-4" },
      });
    }

    return baseCols;
  }, [mode]);

  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    meta: {
      mode,
      scores,
      votes,
      onScoreChange,
      onVoteChange,
      saveStatus,
    },
  });

  return (
    <div className="bg-ops-panel border border-ops-border rounded-lg overflow-x-auto h-full">
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
              onClick={() => onSelect?.(row.original)}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.preventDefault();
                  onSelect?.(row.original);
                }
              }}
              className={`
                hover:bg-white/5 transition-colors group border-b border-ops-border cursor-pointer
                ${isSelected === row.original.id ? "bg-white/10" : ""}
              `}
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
  );
});

MetricTable.displayName = "MetricTable";

export default MetricTable;
