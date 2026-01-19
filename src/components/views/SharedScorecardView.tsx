

import { useMemo } from 'react';
import { CheckCircle2 } from 'lucide-react';
import { useCommunityVotes, usePublicUserVotesForTarget, useUserProfile } from '../../hooks/useSupabase';
import { useApp } from '../../context/AppContext';
import ShareButton from '../shared/ShareButton';
import { useUserDisplay } from '../../hooks/useUserDisplay';
import { VerifiedBadge } from '../shared/VerifiedBadge';
import type { DbVote, DbMetric } from '../../types/database';
import type { ReactNode } from 'react';
import { Link } from '@tanstack/react-router';

// Shared UI Component (could be extracted later)
interface GlassPanelProps {
    children: ReactNode;
    className?: string;
}

const GlassPanel = ({ children, className = '' }: GlassPanelProps) => (
    <div className={`bg-black/40 backdrop-blur-md border border-white/10 rounded-xl overflow-hidden ${className}`}>
        {children}
    </div>
);

interface SharedScorecardViewProps {
    targetId: string;
    userId: string;
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

type CommunityVote = DbVote & { metrics: DbMetric | null };

export const SharedScorecardView = ({ targetId = 'grusch-2024', userId }: SharedScorecardViewProps) => {
    const { FVS_METRICS } = useApp();

    // Hooks
    const { data: communityVotesData } = useCommunityVotes(targetId);
    const { data: userVotesData, loading: userVotesLoading } = usePublicUserVotesForTarget(targetId, userId);
    const { profile: userProfile } = useUserProfile(userId);

    // Derived User Votes Map
    const userVotes = useMemo(() => {
        const votes: Record<string | number, DbVote> = {};
        if (userVotesData) {
            userVotesData.forEach((v) => {
                if (v.metric_id !== null && v.metric_id !== undefined) {
                    votes[v.metric_id] = v;
                }
            });
        }
        return votes;
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

    const getVoteCount = () => Object.keys(userVotes).length;
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

    // Use privacy-aware display logic
    const { displayName, contributorId, isVerified } = useUserDisplay(userProfile, 'public');

    if (userVotesLoading) {
        return <div className="p-10 text-center text-gray-500">Loading scorecard...</div>;
    }

    return (
        <div className="p-4 md:p-6 pb-20 overflow-y-auto h-full">
            {/* Header / Breadcrumbs */}
            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 mb-6">
                <div className="flex items-center gap-2 text-xs font-mono text-gray-500">
                    <Link to="/" className="hover:text-white transition-colors">HOME</Link>
                    <span>/</span>
                    <span className="text-white uppercase">{targetId}</span>
                    <span>/</span>
                    <span className="text-green-500">SCORECARD</span>
                </div>

                <ShareButton
                    variant="button"
                    label="Share This Scorecard"
                    successMessage="Scorecard link copied!"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 max-w-7xl mx-auto">
                {/* Left Column: Summary */}
                <div className="lg:col-span-3 space-y-4">
                    <GlassPanel className="p-6">
                        <div className="text-center">
                            <div className="text-xs font-mono text-gray-500 uppercase mb-4">
                                Scorecard By
                            </div>
                            <div className="flex items-center justify-center gap-2 mb-1">
                                <div className="text-xl font-bold text-white">
                                    {displayName}
                                </div>
                                {isVerified && (
                                    <VerifiedBadge
                                        verifiedAt={userProfile?.oauth_verified_at}
                                        size="md"
                                    />
                                )}
                            </div>
                            <div className="text-xs text-primary font-mono mb-2">
                                {contributorId}
                            </div>
                            <div className="text-xs text-green-500 font-mono">
                                Voted on {getVoteCount()} / {FVS_METRICS.length} Metrics
                            </div>
                        </div>
                    </GlassPanel>

                    <GlassPanel className="p-4">
                        <div className="text-xs font-mono text-gray-500 uppercase mb-3 text-center">
                            Actions
                        </div>
                        <Link
                            to="/scorecard"
                            className="block w-full py-2 px-3 bg-green-500/10 border border-green-500/50 text-green-500 text-center rounded text-sm hover:bg-green-500/20 transition-all font-mono"
                        >
                            Create Your Own Scorecard
                        </Link>
                    </GlassPanel>
                </div>

                {/* Right Column: Vote Cards */}
                <div className="lg:col-span-9">
                    <div className="grid grid-cols-1 gap-4">
                        {FVS_METRICS.map((metric) => {
                            const vote = userVotes[metric.id];
                            const consensus = consensusData[metric.id];
                            const hasVoted = !!vote;

                            if (!hasVoted) return null; // Only show voted metrics? Or show skipped ones too? Showing only voted for now.

                            return (
                                <GlassPanel
                                    key={metric.id}
                                    className={`p-6 border-green-500/30`}
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
                                                <CheckCircle2 size={16} className="text-green-500" />
                                            </div>
                                            <p className="text-sm text-gray-400 mb-3">
                                                {(metric.coreQuestion as string) || metric.question || ""}
                                            </p>
                                        </div>
                                    </div>

                                    {/* Vote Display */}
                                    <div className="mb-4 bg-black/40 rounded p-4 border border-white/5">
                                        <div className="flex items-center justify-between">
                                            <div>
                                                <div className="text-xs font-mono text-gray-500 uppercase mb-1">
                                                    VOTE
                                                </div>
                                                <div className="text-2xl font-bold text-white font-mono">
                                                    {vote.vote_value} <span className="text-sm font-normal text-gray-500">/ 5</span>
                                                </div>
                                                <div className="text-xs text-green-500">
                                                    {getScoreLabel(vote.vote_value)}
                                                </div>
                                            </div>
                                            <div className="text-right">
                                                <div className="text-xs font-mono text-gray-500 uppercase mb-1">
                                                    CONFIDENCE
                                                </div>
                                                <div className={`text-sm font-bold uppercase font-mono ${vote.confidence_level === 'high' ? 'text-green-500' :
                                                    vote.confidence_level === 'medium' ? 'text-yellow-500' : 'text-red-500'
                                                    }`}>
                                                    {vote.confidence_level}
                                                </div>
                                            </div>
                                        </div>
                                        {vote.rationale && (
                                            <div className="mt-3 pt-3 border-t border-white/10">
                                                <div className="text-xs font-mono text-gray-500 uppercase mb-1">
                                                    Rationale
                                                </div>
                                                <p className="text-sm text-gray-300 italic">
                                                    "{vote.rationale}"
                                                </p>
                                            </div>
                                        )}
                                    </div>

                                    {/* Consensus Comparison */}
                                    {consensus && (
                                        <div className="mb-2">
                                            <div className="flex items-center justify-between text-xs mb-2">
                                                <span className="font-mono text-gray-500 uppercase">
                                                    Compared to Consensus
                                                </span>
                                                <div className="flex items-center gap-3 font-mono">
                                                    <span className="text-gray-500">
                                                        Mean: <span className="text-white">{consensus.mean.toFixed(1)}</span>
                                                    </span>
                                                </div>
                                            </div>
                                            <div className="relative h-2 bg-black/40 rounded-full overflow-hidden">
                                                {/* Consensus Distribution Bg */}
                                                <div className="absolute inset-0 flex gap-0.5 opacity-30">
                                                    {[1, 2, 3, 4, 5].map((s) => {
                                                        const p = (consensus.distribution[s] / consensus.totalVotes) * 100;
                                                        return (
                                                            <div key={s} className={getScoreColor(s)} style={{ width: `${p}%` }} />
                                                        )
                                                    })}
                                                </div>
                                                {/* User Marker */}
                                                <div
                                                    className="absolute top-0 bottom-0 w-1 bg-white shadow-[0_0_10px_rgba(255,255,255,0.8)] z-10"
                                                    style={{ left: `${((vote.vote_value - 1) / 4) * 100}%` }}
                                                />
                                            </div>
                                            <div className="flex justify-between text-[10px] text-gray-600 font-mono mt-1 px-1">
                                                <span>1</span>
                                                <span>5</span>
                                            </div>
                                        </div>
                                    )}
                                </GlassPanel>
                            );
                        })}

                        {getVoteCount() === 0 && (
                            <div className="text-center py-10">
                                <p className="text-gray-500 mb-4">No votes found for this target.</p>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};
