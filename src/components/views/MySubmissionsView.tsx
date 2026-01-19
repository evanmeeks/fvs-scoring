
import { useState } from 'react';
import { Link } from '@tanstack/react-router';
import { useAuth, useUserSubmissions } from '../../hooks/useSupabase';
import Icon from '../Icon';
import ShareButton from '../shared/ShareButton';

const MySubmissionsView = () => {
    const { user } = useAuth();
    // Removed unused variables

    const { data, loading, error } = useUserSubmissions(user?.id);
    const [activeTab, setActiveTab] = useState<'targets' | 'rfcs' | 'scores'>('targets');

    if (!user) {
        return (
            <div className="flex bg-background min-h-screen items-center justify-center p-6">
                <div className="text-center">
                    <Icon name="lock" className="text-4xl text-text-muted mb-4" />
                    <h2 className="text-2xl font-bold text-white mb-2">Authentication Required</h2>
                    <p className="text-text-muted">Please log in to view your submissions.</p>
                </div>
            </div>
        );
    }

    const { targets, rfcs, scoredTargets } = data || { targets: [], rfcs: [], scoredTargets: [] };

    const handleEdit = () => {
        // Placeholder for edit functionality
        alert("Editing submitted proposals is currently disabled during the review period.");
    };

    return (
        <div className="w-full px-4 sm:px-6 lg:px-8 py-8 animate-fade-in">
            <div className="mb-8">
                <h1 className="text-3xl font-bold text-white font-mono mb-2">Profile Submissions</h1>
                <p className="text-text-muted">Manage your contributions to the FVS Ledger.</p>
            </div>

            {/* Tabs */}
            <div className="flex gap-4 border-b border-border mb-8 overflow-x-auto">
                <button
                    onClick={() => setActiveTab('targets')}
                    className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${activeTab === 'targets'
                        ? 'text-primary border-b-2 border-primary'
                        : 'text-text-muted hover:text-white'
                        }`}
                >
                    Target Proposals ({targets.length})
                </button>
                <button
                    onClick={() => setActiveTab('rfcs')}
                    className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${activeTab === 'rfcs'
                        ? 'text-primary border-b-2 border-primary'
                        : 'text-text-muted hover:text-white'
                        }`}
                >
                    RFC Proposals ({rfcs.length})
                </button>
                <button
                    onClick={() => setActiveTab('scores')}
                    className={`pb-3 px-2 text-sm font-bold uppercase tracking-wide transition-colors whitespace-nowrap ${activeTab === 'scores'
                        ? 'text-primary border-b-2 border-primary'
                        : 'text-text-muted hover:text-white'
                        }`}
                >
                    Votes ({scoredTargets?.length || 0})
                </button>
            </div>

            {loading ? (
                <div className="py-12 text-center">
                    <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
                    <p className="mt-4 text-text-muted">Loading submissions...</p>
                </div>
            ) : error ? (
                <div className="bg-red-500/10 border border-red-500/30 p-4 rounded text-red-500">
                    Error loading data: {(error as Error).message}
                </div>
            ) : (
                <div className="space-y-4">
                    {/* Target Proposals Tab */}
                    {activeTab === 'targets' && (
                        targets.length === 0 ? (
                            <EmptyState message="No target proposals submitted yet." icon="add_location_alt" />
                        ) : (
                            <div className="grid grid-cols-1 gap-4">
                                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                                {targets.map((target: any) => (
                                    <div key={target.id} className="bg-panel border border-border rounded-lg p-6 hover:border-primary/50 transition-colors">
                                        <div className="flex justify-between items-start mb-4">
                                            <div>
                                                <div className="flex items-center gap-2 mb-1">
                                                    <span className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold border ${getStatusStyle(target.status)}`}>
                                                        {target.status}
                                                    </span>
                                                    <span className="text-xs text-text-muted font-mono">
                                                        {new Date(target.submitted_at).toLocaleDateString()}
                                                    </span>
                                                </div>
                                                <h3 className="text-xl font-bold text-white">{target.target_name}</h3>
                                                {target.case_id && <p className="text-xs text-primary font-mono mt-1">{target.case_id}</p>}
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <ShareButton
                                                    url={`${window.location.origin}/submissions/target/${target.id}`}
                                                    title={`Target Proposal: ${target.target_name}`}
                                                    variant="icon"
                                                />
                                            </div>
                                        </div>
                                        <p className="text-sm text-text-muted mb-6 line-clamp-2">{target.description}</p>
                                        <div className="flex gap-3">
                                            <Link
                                                to="/submissions/target/$id"
                                                params={{ id: target.id }}
                                                className="px-4 py-2 bg-surface border border-border rounded hover:bg-white/5 text-xs font-bold uppercase transition-colors"
                                            >
                                                View Details
                                            </Link>
                                            <button
                                                onClick={handleEdit}
                                                className="px-4 py-2 bg-surface border border-border rounded hover:bg-white/5 text-xs font-bold uppercase transition-colors"
                                            >
                                                Edit
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )
                    )}

                    {/* RFC Proposals Tab */}
                    {activeTab === 'rfcs' && (
                        rfcs.length === 0 ? (
                            <EmptyState message="No RFC proposals submitted yet." icon="description" />
                        ) : (
                            <div className="grid grid-cols-1 gap-4">
                                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                                {rfcs.map((rfc: any) => (
                                    <div key={rfc.id} className="bg-panel border border-border rounded-lg p-6 hover:border-primary/50 transition-colors">
                                        <div className="flex justify-between items-start mb-4">
                                            <div>
                                                <div className="flex items-center gap-2 mb-1">
                                                    <span className={`px-2 py-0.5 rounded text-[10px] uppercase font-bold border ${getStatusStyle(rfc.status)}`}>
                                                        {rfc.status}
                                                    </span>
                                                    <span className="text-xs text-text-muted font-mono">
                                                        {new Date(rfc.created_at).toLocaleDateString()}
                                                    </span>
                                                </div>
                                                <h3 className="text-xl font-bold text-white">
                                                    {rfc.proposal_type === 'new_metric' ? 'New Metric Proposal' : 'Metric Modification'}
                                                </h3>
                                                {rfc.proposed_name && <p className="text-sm text-primary font-mono mt-1">{rfc.proposed_name}</p>}
                                            </div>
                                            <div className="flex items-center gap-2">
                                                <ShareButton
                                                    url={`${window.location.origin}/submissions/rfc/${rfc.id}`}
                                                    title={`RFC Proposal`}
                                                    variant="icon"
                                                />
                                            </div>
                                        </div>
                                        <p className="text-sm text-text-muted mb-6 line-clamp-2">{rfc.rationale}</p>
                                        <div className="flex gap-3">
                                            <Link
                                                to="/submissions/rfc/$id"
                                                params={{ id: rfc.id }}
                                                className="px-4 py-2 bg-surface border border-border rounded hover:bg-white/5 text-xs font-bold uppercase transition-colors"
                                            >
                                                View Details
                                            </Link>
                                            <button
                                                onClick={handleEdit}
                                                className="px-4 py-2 bg-surface border border-border rounded hover:bg-white/5 text-xs font-bold uppercase transition-colors"
                                            >
                                                Edit
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )
                    )}

                    {/* Scores Tab */}
                    {activeTab === 'scores' && (
                        (!scoredTargets || scoredTargets.length === 0) ? (
                            <EmptyState message="You haven't scored any targets yet." icon="analytics" />
                        ) : (
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                                {scoredTargets.map((target: any) => (
                                    <div key={target.id} className="bg-panel border border-border rounded-lg p-6 hover:border-primary/50 transition-colors">
                                        <div className="flex justify-between items-start mb-4">
                                            <div>
                                                <h3 className="text-lg font-bold text-white">{target.name}</h3>
                                                <p className="text-xs text-text-muted font-mono mt-1">{target.case_id}</p>
                                            </div>
                                            <ShareButton
                                                url={`${window.location.origin}/share/scorecard/${target.id}/${user.id}`}
                                                title={`My Scorecard: ${target.name}`}
                                                variant="icon"
                                            />
                                        </div>
                                        <p className="text-xs text-text-muted mb-6">
                                            Last scored on {new Date(target.lastVoted).toLocaleDateString()}
                                        </p>
                                        <div className="flex gap-3">
                                            <a
                                                href={`/scoring/${target.id || 'grusch-2024'}`}
                                                className="flex-1 px-4 py-2 text-center bg-primary text-black rounded hover:bg-white text-xs font-bold uppercase transition-colors"
                                            >
                                                Edit / View Votes
                                            </a>
                                            <Link
                                                to={`/share/scorecard/$targetId/$userId`}
                                                params={{ targetId: target.id || '', userId: user.id }}
                                                className="flex-1 px-4 py-2 text-center bg-surface border border-border rounded hover:bg-white/5 text-xs font-bold uppercase transition-colors"
                                            >
                                                View Scorecard
                                            </Link>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )
                    )}
                </div>
            )}
        </div>
    );
};

const getStatusStyle = (status: string) => {
    switch (status) {
        case 'approved': return 'bg-green-500/10 text-green-500 border-green-500/20';
        case 'rejected': return 'bg-red-500/10 text-red-500 border-red-500/20';
        case 'pending': return 'bg-yellow-500/10 text-yellow-500 border-yellow-500/20';
        case 'voting': return 'bg-purple-500/10 text-purple-500 border-purple-500/20';
        default: return 'bg-gray-500/10 text-gray-500 border-gray-500/20';
    }
};

const EmptyState = ({ message, icon }: { message: string, icon: string }) => (
    <div className="text-center py-12 bg-panel border border-border rounded-lg border-dashed">
        <Icon name={icon} className="text-4xl text-text-muted mb-2 opacity-50" />
        <p className="text-text-muted">{message}</p>
    </div>
);

export default MySubmissionsView;
