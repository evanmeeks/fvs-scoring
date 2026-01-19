import { useMemo, useState, useEffect } from "react";
import { useSystemActivityFeed } from "../hooks/useSupabase";

type ActivityItem = {
  id: string;
  target_name?: string | null;
  metric_name?: string | null;
  description?: string | null;
  activity_type?: string | null;
  user_name?: string | null;
  created_at?: string | null;
};

const ActivityLog = () => {
  const { data, loading, error } = useSystemActivityFeed(null, 12);
  const [referenceTime, setReferenceTime] = useState(() => Date.now());

  // Update reference time every minute to keep relative times accurate
  useEffect(() => {
    const interval = setInterval(() => {
      setReferenceTime(Date.now());
    }, 60000);
    return () => clearInterval(interval);
  }, []);

   
  const formatRelativeTime = useMemo(() => (timestamp?: string | null) => {
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
  }, [referenceTime]);

  const formatAction = (value?: string | null) => {
    if (!value) return "Updated";
    const normalized = value.replace(/_/g, " ").trim();
    return normalized.charAt(0).toUpperCase() + normalized.slice(1);
  };

  const logs = useMemo(() => {
    if (!Array.isArray(data)) return [];
    return (data as ActivityItem[]).map((item) => {
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
};

export default ActivityLog;
