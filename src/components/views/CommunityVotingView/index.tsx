
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useMemo, useEffect, type ReactNode } from 'react';
import { Target, TrendingUp, Users, CheckCircle2 } from 'lucide-react';
import { useAuth, useCommunityVotes, useUserVotesForTarget, useSubmitCommunityVote } from '../../../hooks/useSupabase';
import ShareButton from '../../shared/ShareButton';
import Toast from '../../Toast';
import { useApp } from '../../../context/AppContext';
import type { DbVote, DbMetric } from '../../../types/database';

// Shared UI Component
interface GlassPanelProps {
    children: ReactNode;
    className?: string;
}

const GlassPanel = ({ children, className = '' }: GlassPanelProps) => (
    <div className={`bg-black/40 backdrop-blur-md border border-white/10 rounded-xl overflow-hidden ${className}`}>
        {children}
    </div>
);

interface CommunityVotingViewProps {
    activeTarget?: string;
}

interface VoteDistribution {
    [key: number]: number;
}

interface ConsensusStats {
    mean: number;
    median: number;
    totalVotes: number;
    distribution: VoteDistribution;
}

type UserVoteRpcResponse = {
    confidence_level: string;
    metric_id: number;
    metric_name: string;
    rationale: string;
    vote_value: number;
    voted_at: string;
};

type CommunityVote = DbVote & { metrics: DbMetric | null };

export const CommunityVotingView = ({ activeTarget = 'grusch-2024' }: CommunityVotingViewProps) => {
    const { user } = useAuth();
    const { FVS_METRICS } = useApp();

    // Hooks
    const { data: communityVotesData } = useCommunityVotes(activeTarget);
    const { data: userVotesData } = useUserVotesForTarget(activeTarget);
    const { submitVote } = useSubmitCommunityVote();

    // Local State
    const [selectedConfidence, setSelectedConfidence] = useState<Record<string | number, string>>({});
    const [rationales, setRationales] = useState<Record<string | number, string>>({});
    // Add local optimistic votes state to override server data temporarily
    const [localVotes, setLocalVotes] = useState<Record<string | number, number>>({});

    // Toast State
    const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' | 'warning' | 'info' } | null>(null);

    // Derived User Votes Map
    const userVotes = useMemo(() => {
        const votes: Record<string | number, number> = {};

        // 1. Start with server data
        if (userVotesData) {
            userVotesData.forEach((v: UserVoteRpcResponse) => {
                const vote = v;
                votes[vote.metric_id] = vote.vote_value;
            });
        }

        // 2. Override with local optimistic votes
        return { ...votes, ...localVotes };
    }, [userVotesData, localVotes]);

    // Derived Confidence/Rationales logic handled similarly or just kept local as they are input fields
    // We init them from server data once if needed, but for now we focus on votes.
    // Derived Confidence/Rationales logic
    // We init them from server data once if needed, but for now we focus on votes.
    useEffect(() => {
        if (!userVotesData) return;

        // eslint-disable-next-line react-hooks/set-state-in-effect
        setSelectedConfidence(prev => {
            const next = { ...prev };
            let changed = false;
            userVotesData.forEach((v: UserVoteRpcResponse) => {
                if (v.confidence_level && next[v.metric_id] !== v.confidence_level) {
                    next[v.metric_id] = v.confidence_level;
                    changed = true;
                }
            });
            return changed ? next : prev;
        });


        setRationales(prev => {
            const next = { ...prev };
            let changed = false;
            userVotesData.forEach((v: UserVoteRpcResponse) => {
                if (v.rationale && next[v.metric_id] !== v.rationale) {
                    next[v.metric_id] = v.rationale;
                    changed = true;
                }
            });
            return changed ? next : prev;
        });
    }, [userVotesData]);


    // Derived Consensus Data
    const consensusData = useMemo(() => {
        if (!communityVotesData) return {};

        const stats: Record<string | number, ConsensusStats | null> = {};

        FVS_METRICS.forEach(metric => {
            const metricVotes = (communityVotesData as CommunityVote[]).filter((v) => v.metric_id === metric.id);
            const totalVotes = metricVotes.length;

            if (totalVotes === 0) {
                stats[metric.id] = null;
                return;
            }

            const sum = metricVotes.reduce((acc: number, v) => acc + v.vote_value, 0);
            const mean = sum / totalVotes;

            // Median
            const sorted = [...metricVotes].map((v) => v.vote_value).sort((a: number, b: number) => a - b);
            const median = sorted[Math.floor(sorted.length / 2)];

            // Distribution
            const distribution: VoteDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
            metricVotes.forEach((v) => {
                if (distribution[v.vote_value] !== undefined) {
                    distribution[v.vote_value]++;
                }
            });

            stats[metric.id] = {
                mean,
                median,
                totalVotes,
                distribution
            };
        });

        return stats;
    }, [communityVotesData, FVS_METRICS]);

    const handleVoteChange = async (metricId: string | number, vote: number) => {
        if (!user) {
            // Prompt user to login
            const shouldLogin = window.confirm(
                'You must be logged in to submit votes. Would you like to login now?'
            );
            if (shouldLogin) {
                window.location.assign('/login');
            }
            return;
        }

        // Optimistic update
        setLocalVotes(prev => ({ ...prev, [metricId]: vote }));

        const confidence = selectedConfidence[metricId] || 'medium';
        const rationale = rationales[metricId] || '';

        try {
            await submitVote(activeTarget, Number(metricId), vote, confidence, rationale);
            // Optionally triggering refetch here would be good if we had access to invalidation
        } catch (e) {
            console.error("Vote failed", e);
            // Revert optimistic update on error if we wanted to be strict
        }
    };

    const getVoteCount = () => Object.keys(userVotes).length;
    const getProgressPercentage = () => (getVoteCount() / FVS_METRICS.length) * 100;

    const getScoreColor = (score: number) => {
        if (score >= 4) return 'bg-green-500';
        if (score >= 3) return 'bg-yellow-500';
        if (score >= 2) return 'bg-orange-500';
        return 'bg-red-500';
    };

    const getScoreLabel = (score: number) => {
        const labels: Record<number, string> = { 1: 'Very Low', 2: 'Low', 3: 'Medium', 4: 'High', 5: 'Very High' };
        return labels[Number(score)];
    };

    // Construct Share URL
    const shareUrl = typeof window !== 'undefined' && user
        ? `${window.location.origin}/share/scorecard/${activeTarget}/${user.id}`
        : '';

    // Check if sharing is allowed (simple for now: enabled if user is logged in)
    const isShareDisabled = !user;
    const shareDisabledReason = !user ? 'Login to create and share your scorecard' : '';

    return (
        <div className="p-4 md:p-6 pb-20 overflow-y-auto h-full">
            {toast && (
                <Toast
                    message={toast.message}
                    type={toast.type}
                    onClose={() => setToast(null)}
                />
            )}

            {/* Breadcrumbs & Share */}
            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
                <div className="flex items-center gap-2 text-xs font-mono text-gray-500">
                    <span>COMMUNITY VOTING</span>
                    <span>/</span>
                    <span className="text-white uppercase">{activeTarget}</span>
                    <span>/</span>
                    <span className="text-green-500">CONSENSUS BUILDING</span>
                </div>

                <ShareButton
                    url={shareUrl}
                    variant="button"
                    label="Share My Scorecard"
                    disabled={isShareDisabled}
                    disabledReason={shareDisabledReason}
                    onShowToast={(msg, type) => setToast({ message: msg, type })}
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 max-w-7xl mx-auto">
                {/* Left Column: Progress */}
                <div className="lg:col-span-3 space-y-4">
                    <GlassPanel className="p-6">
                        <div className="text-center">
                            <div className="text-xs font-mono text-gray-500 uppercase mb-4">
                                Your Progress
                            </div>
                            <div className="relative w-32 h-32 mx-auto mb-4">
                                <svg className="w-32 h-32 transform -rotate-90">
                                    <circle
                                        cx="64" cy="64" r="56"
                                        stroke="currentColor" strokeWidth="8" fill="none"
                                        className="text-white/10"
                                    />
                                    <circle
                                        cx="64" cy="64" r="56"
                                        stroke="currentColor" strokeWidth="8" fill="none"
                                        strokeDasharray={`${2 * Math.PI * 56}`}
                                        strokeDashoffset={`${2 * Math.PI * 56 * (1 - getProgressPercentage() / 100)}`}
                                        className="text-green-500 transition-all duration-500"
                                    />
                                </svg>
                                <div className="absolute inset-0 flex items-center justify-center">
                                    <div className="text-center">
                                        <div className="text-3xl font-bold text-white font-mono">
                                            {getVoteCount()}
                                        </div>
                                        <div className="text-xs text-gray-500">/ {FVS_METRICS.length}</div>
                                    </div>
                                </div>
                            </div>
                            <div className="text-sm text-gray-400">
                                Metrics Voted
                            </div>
                        </div>
                    </GlassPanel>

                    <GlassPanel className="p-4">
                        <div className="text-xs font-mono text-gray-500 uppercase mb-3">
                            Consensus Stats
                        </div>
                        <div className="space-y-3">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Users size={14} className="text-green-500" />
                                    <span className="text-xs text-gray-400">Total Voters</span>
                                </div>
                                {/* Placeholder for total unique voters across all metrics */}
                                <span className="text-sm font-mono text-white">
                                    {communityVotesData ? new Set(communityVotesData.map((v: any) => v.user_id)).size : 0}
                                </span>
                            </div>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <TrendingUp size={14} className="text-green-500" />
                                    <span className="text-xs text-gray-400">Avg Agreement</span>
                                </div>
                                {/* Placeholder - calculation complex */}
                                <span className="text-sm font-mono text-green-400">--%</span>
                            </div>
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <Target size={14} className="text-green-500" />
                                    <span className="text-xs text-gray-400">Convergence</span>
                                </div>
                                <span className="text-sm font-mono text-yellow-400">Tracking</span>
                            </div>
                        </div>
                    </GlassPanel>

                    {getVoteCount() === FVS_METRICS.length && (
                        <GlassPanel className="p-4 bg-green-500/10 border-green-500/30">
                            <div className="flex items-center gap-2 mb-2">
                                <CheckCircle2 size={16} className="text-green-500" />
                                <span className="text-sm font-bold text-green-500">
                                    Complete!
                                </span>
                            </div>
                            <p className="text-xs text-gray-400 mb-3">
                                You've voted on all metrics. Your contribution helps build community consensus.
                            </p>
                            <ShareButton
                                url={shareUrl}
                                variant="button"
                                label="Share Scorecard"
                                className="w-full justify-center bg-green-500 text-white hover:bg-green-600 border-none"
                                onShowToast={(msg, type) => setToast({ message: msg, type })}
                            />
                        </GlassPanel>
                    )}
                </div>

                {/* Right Column: Vote Cards */}
                <div className="lg:col-span-9">
                    <div className="grid grid-cols-1 gap-4">
                        {FVS_METRICS.map((metric) => {
                            const userVote = userVotes[metric.id];
                            const consensus = consensusData[metric.id];
                            const hasVoted = userVote !== undefined;

                            return (
                                <GlassPanel
                                    key={metric.id}
                                    className={`p-6 ${hasVoted ? 'border-green-500/30' : ''}`}
                                >
                                    <div className="flex items-start justify-between mb-4">
                                        <div className="flex-1">
                                            <div className="flex items-center gap-3 mb-2">
                                                <span className="text-xs font-mono text-gray-500">
                                                    {metric.id}
                                                </span>
                                                <h3 className="text-lg font-bold text-white">
                                                    {metric.name}
                                                </h3>
                                                {hasVoted && (
                                                    <CheckCircle2 size={16} className="text-green-500" />
                                                )}
                                            </div>
                                            <p className="text-sm text-gray-400 mb-3">
                                                {(metric.coreQuestion as string) || metric.question || ""}
                                            </p>
                                        </div>
                                    </div>

                                    {/* Voting Buttons */}
                                    <div className="mb-4">
                                        <div className="text-xs font-mono text-gray-500 uppercase mb-3">
                                            Your Vote
                                        </div>
                                        <div className="grid grid-cols-5 gap-2">
                                            {[1, 2, 3, 4, 5].map((score) => (
                                                <button
                                                    key={score}
                                                    onClick={() =>
                                                        handleVoteChange(metric.id, score)
                                                    }
                                                    className={`p-3 rounded border-2 transition-all ${userVote === score
                                                        ? 'border-green-500 bg-green-500/20'
                                                        : 'border-white/10 bg-black/40 hover:border-white/30'
                                                        }`}
                                                >
                                                    <div className="text-center">
                                                        <div
                                                            className={`text-2xl font-bold font-mono mb-1 ${userVote === score ? 'text-green-500' : 'text-white'
                                                                }`}
                                                        >
                                                            {score}
                                                        </div>
                                                        <div className="text-[10px] text-gray-500">
                                                            {getScoreLabel(score)}
                                                        </div>
                                                    </div>
                                                </button>
                                            ))}
                                        </div>
                                    </div>

                                    {/* Consensus Bar */}
                                    {consensus && (
                                        <div className="mb-4">
                                            <div className="flex items-center justify-between text-xs mb-2">
                                                <span className="font-mono text-gray-500 uppercase">
                                                    Community Consensus
                                                </span>
                                                <div className="flex items-center gap-3 font-mono">
                                                    <span className="text-gray-500">
                                                        Mean: <span className="text-white">{consensus.mean.toFixed(1)}</span>
                                                    </span>
                                                    <span className="text-gray-500">
                                                        Median: <span className="text-white">{consensus.median}</span>
                                                    </span>
                                                    <span className="text-gray-500">
                                                        Votes: <span className="text-white">{consensus.totalVotes}</span>
                                                    </span>
                                                </div>
                                            </div>
                                            <div className="flex gap-1 h-2 rounded-full overflow-hidden bg-black/40">
                                                {[1, 2, 3, 4, 5].map((score) => {
                                                    const count = consensus.distribution[score] || 0;
                                                    const percentage =
                                                        (count / consensus.totalVotes) * 100;
                                                    return (
                                                        <div
                                                            key={score}
                                                            className={`${getScoreColor(score)} transition-all`}
                                                            style={{ width: `${percentage}%` }}
                                                            title={`${score}: ${count} votes (${percentage.toFixed(
                                                                1
                                                            )}%)`}
                                                        />
                                                    );
                                                })}
                                            </div>
                                        </div>
                                    )}

                                    {/* Confidence Level */}
                                    <div className="mb-4">
                                        <div className="text-xs font-mono text-gray-500 uppercase mb-2">
                                            Confidence Level
                                        </div>
                                        <div className="flex gap-2">
                                            {(['low', 'medium', 'high']).map(
                                                (level) => (
                                                    <button
                                                        key={level}
                                                        onClick={() =>
                                                            setSelectedConfidence((prev) => ({
                                                                ...prev,
                                                                [metric.id]: level,
                                                            }))
                                                        }
                                                        className={`flex-1 py-2 px-3 rounded border text-xs uppercase font-mono transition-all ${(selectedConfidence[metric.id] || 'medium') === level
                                                            ? 'border-green-500 bg-green-500/20 text-green-500'
                                                            : 'border-white/10 bg-black/40 text-gray-400 hover:border-white/30'
                                                            }`}
                                                    >
                                                        {level}
                                                    </button>
                                                )
                                            )}
                                        </div>
                                    </div>

                                    {/* Rationale */}
                                    <div>
                                        <div className="text-xs font-mono text-gray-500 uppercase mb-2">
                                            Rationale (Optional)
                                        </div>
                                        <textarea
                                            value={rationales[metric.id] || ''}
                                            onChange={(e) =>
                                                setRationales((prev) => ({
                                                    ...prev,
                                                    [metric.id]: e.target.value,
                                                }))
                                            }
                                            placeholder="Explain your reasoning..."
                                            className="w-full bg-black/40 border border-white/10 rounded py-2 px-3 text-sm text-white focus:outline-none focus:border-green-500/50 font-mono resize-none"
                                            rows={2}
                                        />
                                    </div>
                                </GlassPanel>
                            );
                        })}
                    </div>
                </div>
            </div>
        </div>
    );
};

export default CommunityVotingView;
