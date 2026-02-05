"use client";

import React, { useState, useEffect, useCallback } from "react";
import { useUI } from "~/context/AppContext";
import { createClient } from "~/lib/supabase/client";
import Icon from "~/components/Icon";

/* eslint-disable @typescript-eslint/no-explicit-any */

type Discussion = {
  id: string;
  metric_id: number;
  user_id: string | null;
  parent_id: string | null;
  comment: string;
  upvotes: number | null;
  downvotes: number | null;
  created_at: string | null;
  user_profiles?: {
    full_name: string | null;
    pseudonym: string | null;
    role: string;
  } | null;
};

export function DiscussionModal() {
  const { selectedMetric: metric, setDiscussionModalOpen, setAuthModalOpen } =
    useUI();
  const supabase = createClient();
  const [user, setUser] = useState<any>(null);
  const [newComment, setNewComment] = useState("");
  const [replyTo, setReplyTo] = useState<string | null>(null);
  const [discussions, setDiscussions] = useState<Discussion[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  const metricId = metric ? Number(metric.id) : 0;

  const fetchDiscussions = useCallback(async () => {
    if (metricId <= 0) return;
    setIsLoading(true);
    const { data, error } = await supabase
      .from("metric_discussions")
      .select(
        "*, user_profiles!metric_discussions_user_id_fkey(full_name, pseudonym, role)",
      )
      .eq("metric_id", metricId)
      .order("created_at", { ascending: true });

    if (error) {
      const { data: fallback } = await supabase
        .from("metric_discussions")
        .select("*")
        .eq("metric_id", metricId)
        .order("created_at", { ascending: true });
      setDiscussions((fallback ?? []) as Discussion[]);
    } else {
      setDiscussions((data ?? []) as Discussion[]);
    }
    setIsLoading(false);
  }, [metricId, supabase]);

  useEffect(() => {
    fetchDiscussions();
  }, [fetchDiscussions]);

  if (!metric) return null;

  const typedDiscussions = discussions;
  const topLevel = typedDiscussions.filter((d) => !d.parent_id);

  const handleCommentSubmit = async (
    comment: string,
    parentId: string | null,
  ) => {
    if (!user || isSubmitting) return;
    setIsSubmitting(true);
    const { error } = await (supabase.from("metric_discussions") as any)
      .insert({
        metric_id: metricId,
        user_id: user.id,
        comment,
        parent_id: parentId,
      })
      .select()
      .single();
    if (!error) {
      await fetchDiscussions();
      setNewComment("");
      setReplyTo(null);
    }
    setIsSubmitting(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newComment.trim() || !user || isSubmitting) return;
    handleCommentSubmit(newComment.trim(), replyTo);
  };

  const handleClose = () => setDiscussionModalOpen(false);

  const getDisplayName = (d: Discussion) =>
    d.user_profiles?.pseudonym ?? d.user_profiles?.full_name ?? "Anonymous";

  const renderDiscussion = (discussion: Discussion, isReply = false) => {
    const replies = typedDiscussions.filter(
      (d) => d.parent_id === discussion.id,
    );
    const netVotes = (discussion.upvotes ?? 0) - (discussion.downvotes ?? 0);
    const isAdmin = discussion.user_profiles?.role === "admin";

    return (
      <div
        key={discussion.id}
        className={isReply ? "ml-8 mt-2" : "mb-4"}
      >
        <div className="bg-ops-black border border-ops-border rounded-lg p-4">
          <div className="flex gap-3">
            {/* Voting */}
            <div className="flex flex-col items-center gap-1">
              <button
                disabled={!user}
                className={`transition-colors ${!user ? "text-ops-text-dim/50 cursor-not-allowed" : "text-ops-text-dim hover:text-primary"}`}
                title={!user ? "Log in to vote" : "Upvote"}
              >
                <Icon name="arrow_upward" className="text-sm" />
              </button>
              <span
                className={`text-xs font-bold ${netVotes > 0 ? "text-primary" : netVotes < 0 ? "text-red-500" : "text-ops-text-dim"}`}
              >
                {netVotes}
              </span>
              <button
                disabled={!user}
                className={`transition-colors ${!user ? "text-ops-text-dim/50 cursor-not-allowed" : "text-ops-text-dim hover:text-red-500"}`}
                title={!user ? "Log in to vote" : "Downvote"}
              >
                <Icon name="arrow_downward" className="text-sm" />
              </button>
            </div>

            {/* Content */}
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-2">
                <div
                  className={`w-6 h-6 rounded-full border text-[10px] flex items-center justify-center font-bold ${
                    isAdmin
                      ? "bg-primary text-black border-primary"
                      : "bg-ops-panel border-ops-border text-ops-text-dim"
                  }`}
                >
                  {getDisplayName(discussion)[0]?.toUpperCase() ?? "?"}
                </div>
                <div className="flex items-baseline gap-2">
                  <span
                    className={`text-xs font-bold ${isAdmin ? "text-primary" : "text-white"}`}
                  >
                    {getDisplayName(discussion)}
                  </span>
                  {isAdmin && (
                    <span className="text-[9px] bg-primary/10 text-primary px-1 rounded border border-primary/20">
                      MOD
                    </span>
                  )}
                  <span className="text-[10px] text-ops-text-dim">
                    {discussion.created_at
                      ? new Date(discussion.created_at).toLocaleDateString()
                      : ""}
                  </span>
                </div>
              </div>
              <p className="text-sm text-white mb-2">{discussion.comment}</p>
              <button
                onClick={() => {
                  if (!user) {
                    setAuthModalOpen(true);
                    return;
                  }
                  setReplyTo(discussion.id);
                }}
                className={`text-xs ${!user ? "text-ops-text-dim cursor-not-allowed" : "text-primary hover:underline"}`}
              >
                Reply
              </button>

              {replyTo === discussion.id && (
                <form onSubmit={handleSubmit} className="mt-3">
                  <textarea
                    value={newComment}
                    onChange={(e) => setNewComment(e.target.value)}
                    className="w-full h-20 bg-ops-panel border border-ops-border text-white p-2 rounded text-sm focus:border-primary focus:outline-none resize-none"
                    placeholder="Write your reply..."
                  />
                  <div className="flex gap-2 mt-2">
                    <button
                      type="submit"
                      disabled={isSubmitting}
                      className="px-3 py-1.5 bg-primary text-black text-xs font-bold rounded hover:bg-white transition-colors"
                    >
                      {isSubmitting ? "Posting..." : "Post Reply"}
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setReplyTo(null);
                        setNewComment("");
                      }}
                      className="px-3 py-1.5 border border-ops-border text-ops-text-dim text-xs rounded hover:text-white transition-colors"
                    >
                      Cancel
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>
        </div>

        {replies.length > 0 && (
          <div className="mt-2">
            {replies.map((reply) => renderDiscussion(reply, true))}
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-ops-panel w-full max-w-3xl border border-ops-border rounded-lg shadow-2xl flex flex-col max-h-[90vh]">
        {/* Header */}
        <div className="p-4 border-b border-ops-border flex justify-between items-center bg-ops-black/50 rounded-t-lg">
          <div className="flex items-center gap-2 text-white">
            <Icon name="forum" className="text-primary" />
            <div>
              <h3 className="font-bold text-lg font-mono">Discussion</h3>
              <p className="text-xs text-ops-text-dim">{metric.name}</p>
            </div>
          </div>
          <button
            className="text-ops-text-dim hover:text-white"
            onClick={handleClose}
          >
            <Icon name="close" />
          </button>
        </div>

        {/* Discussion Thread */}
        <div className="flex-1 overflow-y-auto p-6">
          {isLoading ? (
            <div className="text-center text-ops-text-dim py-8">
              Loading discussions...
            </div>
          ) : topLevel.length === 0 ? (
            <div className="text-center text-ops-text-dim py-8">
              No discussions yet. Be the first to comment!
            </div>
          ) : (
            topLevel.map((discussion) => renderDiscussion(discussion))
          )}
        </div>

        {/* New Comment Form */}
        {user ? (
          <div className="p-4 border-t border-ops-border bg-ops-black/50">
            <form
              onSubmit={(e) => {
                e.preventDefault();
                if (!newComment.trim() || isSubmitting) return;
                handleCommentSubmit(newComment.trim(), null);
              }}
            >
              <textarea
                value={replyTo ? "" : newComment}
                onChange={(e) => {
                  if (!replyTo) setNewComment(e.target.value);
                }}
                className="w-full h-24 bg-ops-black border border-ops-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none resize-none"
                placeholder={
                  replyTo
                    ? "Use the reply form above..."
                    : "Share your thoughts on this metric..."
                }
                disabled={!!replyTo}
              />
              <div className="flex justify-end mt-3">
                <button
                  type="submit"
                  disabled={!newComment.trim() || !!replyTo || isSubmitting}
                  className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isSubmitting ? "Posting..." : "Post Comment"}
                </button>
              </div>
            </form>
          </div>
        ) : (
          <div className="p-4 border-t border-ops-border bg-ops-black/50 text-center">
            <p className="text-sm text-ops-text-dim mb-3">
              Please log in to participate in discussions
            </p>
            <button
              onClick={() => setAuthModalOpen(true)}
              className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20"
            >
              <Icon name="login" className="inline mr-2 text-sm" />
              Connect to Comment
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

export default DiscussionModal;
