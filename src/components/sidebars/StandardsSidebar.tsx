"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect, useMemo } from "react";
import { createClient } from "~/lib/supabase/client";

type ActivityItem = {
  id: string;
  target_name?: string | null;
  metric_name?: string | null;
  description?: string | null;
  activity_type?: string | null;
  user_name?: string | null;
  created_at?: string | null;
};

function ActivityLog() {
  const supabase = createClient();
  const [data, setData] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);
  const [referenceTime, setReferenceTime] = useState(() => Date.now());

  useEffect(() => {
    const interval = setInterval(() => {
      setReferenceTime(Date.now());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const fetchActivity = async () => {
      const { data: rows, error: err } = await (supabase.from("activity_log") as any)
        .select("*")
        .order("created_at", { ascending: false })
        .limit(12);

      if (err) {
        setError(true);
      } else {
        setData(rows || []);
      }
      setLoading(false);
    };

    fetchActivity();
  }, [supabase]);

  const formatRelativeTime = useMemo(
    () => (timestamp?: string | null) => {
      if (!timestamp) return "Just now";
      const diffMs = referenceTime - new Date(timestamp).getTime();
      if (Number.isNaN(diffMs)) return "Just now";
      const diffMinutes = Math.floor(diffMs / 60000);
      if (diffMinutes < 1) return "Just now";
      if (diffMinutes < 60) return `${diffMinutes}m ago`;
      const diffHours = Math.floor(diffMinutes / 60);
      if (diffHours < 24) return `${diffHours}h ago`;
      const diffDays = Math.floor(diffHours / 24);
      return `${diffDays}d ago`;
    },
    [referenceTime],
  );

  const formatAction = (value?: string | null) => {
    if (!value) return "Updated";
    const normalized = value.replace(/_/g, " ").trim();
    return normalized.charAt(0).toUpperCase() + normalized.slice(1);
  };

  const logs = useMemo(() => {
    if (!Array.isArray(data)) return [];
    return data.map((item) => {
      const target =
        [item.target_name, item.metric_name].filter(Boolean).join(" • ") ||
        "System";
      const action = item.description || formatAction(item.activity_type);
      return {
        id: item.id,
        user: item.user_name || "System",
        action,
        target,
        time: formatRelativeTime(item.created_at),
      };
    });
  }, [data, formatRelativeTime]);

  return (
    <div className="space-y-3">
      {loading && logs.length === 0 ? (
        <div className="text-[10px] text-text-dim font-mono animate-pulse">
          Loading activity...
        </div>
      ) : null}
      {error ? (
        <div className="text-[10px] text-red-400 font-mono">
          Unable to load activity.
        </div>
      ) : null}
      {!loading && !error && logs.length === 0 ? (
        <div className="text-[10px] text-text-dim font-mono">
          No recent activity.
        </div>
      ) : null}
      {logs.map((log) => (
        <div
          key={log.id}
          className="flex gap-3 items-start p-2.5 rounded border border-transparent hover:border-border hover:bg-white/5 transition-all group animate-fade-in"
        >
          <div className="w-1.5 h-1.5 rounded-full bg-primary mt-1.5 shrink-0 opacity-50 group-hover:opacity-100 transition-opacity"></div>
          <div className="overflow-hidden">
            <div className="text-[10px] text-text-muted leading-tight">
              <span className="text-text-main font-bold hover:text-primary cursor-pointer">
                {log.user}
              </span>{" "}
              {log.action}
            </div>
            <div className="text-xs text-primary/80 truncate font-mono mt-0.5">
              {log.target}
            </div>
            <div className="text-[9px] text-text-dim font-mono mt-1">
              {log.time}
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}

export function StandardsSidebar() {
  return (
    <aside className="w-72 bg-panel border-r border-border flex flex-col shrink-0 hidden lg:flex h-full">
      <div className="p-5 border-b border-border bg-background/50">
        <h2 className="text-[10px] font-bold text-text-muted uppercase tracking-widest mb-4">
          Workspace Context
        </h2>
        <div className="space-y-5 animate-fade-in">
          <div className="bg-surface border border-border p-4 rounded shadow-sm">
            <div className="text-[10px] text-text-muted mb-1 uppercase tracking-wide">
              Standard Version
            </div>
            <div className="font-bold text-white text-sm flex items-center justify-between">
              FVS Metric Set v1.0
              <span className="w-2 h-2 rounded-full bg-green-500"></span>
            </div>
          </div>
          <div>
            <div className="text-xs text-text-muted mb-2 flex justify-between font-mono">
              <span>Consensus Progress</span>
              <span>85%</span>
            </div>
            <div className="h-1 bg-border rounded-full overflow-hidden">
              <div className="h-full bg-primary w-[85%] shadow-[0_0_10px_rgba(0,255,65,0.4)]"></div>
            </div>
          </div>
          <div className="text-xs text-text-muted leading-relaxed p-3 bg-blue-900/10 border border-blue-900/30 rounded text-blue-200/80">
            <strong className="text-blue-400 block mb-1">Objective:</strong>
            Refine metrics to distinguish high-value intelligence from narrative
            occupation.
          </div>
        </div>
      </div>
      <div className="flex-1 overflow-hidden flex flex-col">
        <div className="p-4 pb-0">
          <h3 className="text-[10px] font-bold text-text-muted uppercase tracking-widest">
            Recent Activity
          </h3>
        </div>
        <div className="flex-1 overflow-y-auto p-4 custom-scrollbar">
          <ActivityLog />
        </div>
      </div>
    </aside>
  );
}

export default StandardsSidebar;
