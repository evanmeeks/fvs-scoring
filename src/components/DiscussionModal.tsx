import React, { useState } from 'react';
import Icon from './Icon';
import { useDiscussions, useSubmitComment, useVoteOnComment } from '../hooks/useSupabase';
// import type { DbDiscussion } from '../types/database'; // Removed unused
import type { User } from '../types';

type DiscussionWithProfile = {
    id: string;
    metric_id: number;
    user_id: string | null;
    parent_id: string | null;
    comment: string;
    upvotes: number | null;
    downvotes: number | null;
    created_at: string | null;
    updated_at: string | null;
    user_profiles: {
        full_name: string | null;
        role: string;
    } | null;
};

interface DiscussionModalProps {
    isOpen: boolean;
    onClose: () => void;
    metricId: number;
    metricName: string;
    user: User | null;
    onRequireAuth?: () => void;
}

const DiscussionModal = ({ isOpen, onClose, metricId, metricName, user, onRequireAuth }: DiscussionModalProps) => {
    // Use discussion hooks
    const [refreshKey, setRefreshKey] = useState(0);
    const { data: discussionsData, loading } = useDiscussions(metricId, refreshKey);
    const { submitComment, loading: submitting } = useSubmitComment();
    const { voteOnComment } = useVoteOnComment();

    const [newComment, setNewComment] = useState('');
    const [replyTo, setReplyTo] = useState<string | null>(null);

    // Use hook data directly
    const discussions = (discussionsData || []) as DiscussionWithProfile[];

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!newComment.trim() || !user || submitting) return;

        try {
            await submitComment(metricId, newComment, replyTo);
            setNewComment('');
            setReplyTo(null);
            setRefreshKey((prev) => prev + 1);
        } catch (error) {
            console.error('Error posting comment:', error);
            alert('Failed to post comment');
        }
    };


    const handleVote = async (discussionId: string, voteType: 'upvote' | 'downvote') => {
        if (!user) {
            if (onRequireAuth) onRequireAuth();
            return;
        }

        try {
            await voteOnComment(discussionId, voteType);
            setRefreshKey((prev) => prev + 1);
        } catch (error) {
            console.error('Error voting:', error);
        }
    };

    const renderDiscussion = (discussion: DiscussionWithProfile, isReply = false) => {
        const replies = discussions.filter(d => d.parent_id === discussion.id);
        const netVotes = (discussion.upvotes || 0) - (discussion.downvotes || 0);

        return (
            <div key={discussion.id} className={`${isReply ? 'ml-8 mt-2' : 'mb-4'}`}>
                <div className="bg-background border border-border rounded-lg p-4">
                    <div className="flex gap-3">
                        {/* Voting */}
                        <div className="flex flex-col items-center gap-1">
                            <button
                                onClick={() => handleVote(discussion.id, 'upvote')}
                                disabled={!user}
                                className={`transition-colors ${!user ? 'text-text-muted/50 cursor-not-allowed' : 'text-text-muted hover:text-primary'}`}
                                title={!user ? 'Log in to vote' : 'Upvote'}
                            >
                                <Icon name="arrow_upward" className="text-sm" />
                            </button>
                            <span className={`text-xs font-bold ${netVotes > 0 ? 'text-primary' : netVotes < 0 ? 'text-red-500' : 'text-text-muted'}`}>
                                {netVotes}
                            </span>
                            <button
                                onClick={() => handleVote(discussion.id, 'downvote')}
                                disabled={!user}
                                className={`transition-colors ${!user ? 'text-text-muted/50 cursor-not-allowed' : 'text-text-muted hover:text-red-500'}`}
                                title={!user ? 'Log in to vote' : 'Downvote'}
                            >
                                <Icon name="arrow_downward" className="text-sm" />
                            </button>
                        </div>

                        {/* Content */}
                        <div className="flex-1">
                            <div className="flex items-center gap-2 mb-2">
                                <div className={`w-6 h-6 rounded-full border text-[10px] flex items-center justify-center font-bold ${discussion.user_profiles?.role === 'admin'
                                    ? 'bg-primary text-black border-primary'
                                    : 'bg-surface border-border text-text-muted'
                                    }`}>
                                    {(discussion.user_profiles?.full_name || 'A')[0].toUpperCase()}
                                </div>
                                <div className="flex items-baseline gap-2">
                                    <span className={`text-xs font-bold ${discussion.user_profiles?.role === 'admin' ? 'text-primary' : 'text-white'
                                        }`}>
                                        {discussion.user_profiles?.full_name || 'Anonymous'}
                                    </span>
                                    {discussion.user_profiles?.role === 'admin' && (
                                        <span className="text-[9px] bg-primary/10 text-primary px-1 rounded border border-primary/20">
                                            MOD
                                        </span>
                                    )}
                                    <span className="text-[10px] text-text-muted">
                                        • {discussion.created_at ? new Date(discussion.created_at).toLocaleString() : 'Unknown'}
                                    </span>
                                </div>
                            </div>
                            <p className="text-sm text-white mb-2">{discussion.comment}</p>
                            <button
                                onClick={() => {
                                    if (!user) {
                                        if (onRequireAuth) onRequireAuth();
                                        return;
                                    }
                                    setReplyTo(discussion.id);
                                }}
                                disabled={!user}
                                className={`text-xs ${!user ? 'text-text-muted cursor-not-allowed' : 'text-primary hover:underline'}`}
                            >
                                Reply
                            </button>

                            {replyTo === discussion.id && (
                                <form onSubmit={handleSubmit} className="mt-3">
                                    <textarea
                                        value={newComment}
                                        onChange={(e) => setNewComment(e.target.value)}
                                        className="w-full h-20 bg-panel border border-border text-white p-2 rounded text-sm focus:border-primary focus:outline-none resize-none"
                                        placeholder="Write your reply..."
                                    />
                                    <div className="flex gap-2 mt-2">
                                        <button
                                            type="submit"
                                            className="px-3 py-1.5 bg-primary text-black text-xs font-bold rounded hover:bg-white transition-colors"
                                        >
                                            Post Reply
                                        </button>
                                        <button
                                            type="button"
                                            onClick={() => {
                                                setReplyTo(null);
                                                setNewComment('');
                                            }}
                                            className="px-3 py-1.5 border border-border text-text-muted text-xs rounded hover:text-white transition-colors"
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </form>
                            )}
                        </div>
                    </div>
                </div>

                {/* Render replies */}
                {replies.length > 0 && (
                    <div className="mt-2">
                        {replies.map(reply => renderDiscussion(reply, true))}
                    </div>
                )}
            </div>
        );
    };

    if (!isOpen) return null;

    const topLevelDiscussions = discussions.filter(d => !d.parent_id);

    return (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
            <div className="bg-panel w-full max-w-3xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh] scale-100 animate-slide-up">
                {/* Header */}
                <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
                    <div className="flex items-center gap-2 text-white">
                        <Icon name="forum" className="text-primary" />
                        <div>
                            <h3 className="font-bold text-lg font-mono">Discussion</h3>
                            <p className="text-xs text-text-muted">{metricName}</p>
                        </div>
                    </div>
                    <button className="text-text-muted hover:text-white" onClick={onClose}>
                        <Icon name="close" />
                    </button>
                </div>

                {/* Discussions List */}
                <div className="flex-1 overflow-y-auto p-6">
                    {loading ? (
                        <div className="text-center text-text-muted py-8">Loading discussions...</div>
                    ) : topLevelDiscussions.length === 0 ? (
                        <div className="text-center text-text-muted py-8">
                            No discussions yet. Be the first to comment!
                        </div>
                    ) : (
                        topLevelDiscussions.map(discussion => renderDiscussion(discussion))
                    )}
                </div>

                {/* New Comment Form */}
                {user ? (
                    <div className="p-4 border-t border-border bg-surface">
                        <form onSubmit={handleSubmit}>
                            <textarea
                                value={newComment}
                                onChange={(e) => setNewComment(e.target.value)}
                                className="w-full h-24 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none resize-none"
                                placeholder="Share your thoughts on this metric..."
                            />
                            <div className="flex justify-end mt-3">
                                <button
                                    type="submit"
                                    disabled={!newComment.trim()}
                                    className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    Post Comment
                                </button>
                            </div>
                        </form>
                    </div>
                ) : (
                    <div className="p-4 border-t border-border bg-surface text-center">
                        <p className="text-sm text-text-muted mb-3">
                            Please log in to participate in discussions
                        </p>
                        <button
                            onClick={() => {
                                if (onRequireAuth) onRequireAuth();
                            }}
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
};

export default DiscussionModal;
