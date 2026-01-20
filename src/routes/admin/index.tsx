
/* eslint-disable @typescript-eslint/no-explicit-any */
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useState, useEffect, useCallback } from "react";
import AdminReviewPanel from "../../components/AdminReviewPanel";
import UserManagementPanel from "../../components/UserManagementPanel";
import { supabase } from "../../utils/supabase";

type PendingSubmission = {
    id: string;
    type: 'target' | 'rfc';
    submittedBy: string;
    content: string;
    date: string;
    status: string;
};

type StatState = {
    pendingReviews: number;
    activeTargets: number;
    totalUsers: number;
};

export const Route = createFileRoute('/admin/')({
    component: AdminPage,
});

export function AdminPage() {
    const navigate = useNavigate();
    const [activeTab, setActiveTab] = useState<"dashboard" | "users" | "reviews">("dashboard");
    const [stats, setStats] = useState<StatState>({
        pendingReviews: 0,
        activeTargets: 0,
        totalUsers: 0
    });
    const [isReviewOpen, setIsReviewOpen] = useState(false);
    const [authChecked, setAuthChecked] = useState(false);
    const [currentUser, setCurrentUser] = useState<any>(null);

    const loadStats = useCallback(async () => {
        try {
            const { count: pendingTargets } = await supabase
                .from('target_submissions')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'pending');

            const { count: pendingRFCs } = await supabase
                .from('rfc_proposals')
                .select('*', { count: 'exact', head: true })
                .eq('status', 'pending');

            const { count: activeCount } = await supabase
                .from('approved_targets')
                .select('*', { count: 'exact', head: true });

            const { count: userCount } = await supabase
                .from('user_profiles')
                .select('*', { count: 'exact', head: true });

            setStats({
                pendingReviews: (pendingTargets || 0) + (pendingRFCs || 0),
                activeTargets: activeCount || 0,
                totalUsers: userCount || 0
            });
        } catch (e) {
            console.error('Error loading stats', e);
        }
    }, []);

    useEffect(() => {
        let cancelled = false;

        const verifyAccess = async () => {
            const { data } = await supabase.auth.getSession();
            const user = data?.session?.user;
            if (!user) {
                if (!cancelled) {
                    navigate({ to: '/login', search: { redirect: '/admin' } });
                }
                return;
            }

            if (!cancelled) setCurrentUser(user);

            const { data: isAdminResult } = await supabase.rpc('is_admin');
            if (!isAdminResult) {
                if (!cancelled) {
                    navigate({ to: '/login', search: { redirect: '/admin' } });
                }
                return;
            }

            if (!cancelled) setAuthChecked(true);
            loadStats();
        };

        verifyAccess();
        return () => {
            cancelled = true;
        };
    }, [navigate, loadStats]);

    if (!authChecked) {
        return null;
    }

    return (
        <div className="flex-1 flex flex-col h-full overflow-hidden bg-background">
            <div className="p-6 pb-0 max-w-7xl mx-auto w-full">
                <div className="mb-6 flex justify-between items-end">
                    <div>
                        <h1 className="text-3xl font-bold text-white mb-2">Admin Dashboard</h1>
                        <p className="text-text-muted">Manage target submissions and system settings</p>
                    </div>
                </div>

                <div className="flex gap-2 border-b border-border">
                    <TabButton
                        active={activeTab === 'dashboard'}
                        onClick={() => setActiveTab('dashboard')}
                        icon="dashboard"
                        label="Overview"
                    />
                    <TabButton
                        active={activeTab === 'users'}
                        onClick={() => setActiveTab('users')}
                        icon="group"
                        label="User Management"
                    />
                    <TabButton
                        active={activeTab === 'reviews'}
                        onClick={() => setActiveTab('reviews')}
                        icon="pending_actions"
                        label="Review Queue"
                    />
                </div>
            </div>

            <div className="flex-1 overflow-y-auto p-6">
                <div className="max-w-7xl mx-auto w-full">
                    {activeTab === 'dashboard' && (
                        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 animate-fade-in">
                            <StatCard
                                icon="pending_actions"
                                title="Review Queue"
                                value={stats.pendingReviews}
                                onClick={() => setActiveTab('reviews')}
                                color="yellow"
                            />
                            <StatCard
                                icon="target"
                                title="Active Targets"
                                value={stats.activeTargets}
                                color="cyan"
                            />
                            <StatCard
                                icon="group"
                                title="Total Users"
                                value={stats.totalUsers}
                                onClick={() => setActiveTab('users')}
                                color="purple"
                            />
                            <StatCard
                                icon="flag"
                                title="System Flags"
                                value={2}
                                color="red"
                            />
                        </div>
                    )}

                    {activeTab === 'users' && (
                        <div className="bg-panel border border-border rounded-lg animate-fade-in">
                            <UserManagementPanel currentUser={currentUser} />
                        </div>
                    )}

                    {activeTab === 'reviews' && (
                        <div className="animate-fade-in">
                            <ReviewQueueTable onOpenFullPanel={() => setIsReviewOpen(true)} />
                        </div>
                    )}
                </div>
            </div>

            <AdminReviewPanel
                isOpen={isReviewOpen}
                onClose={() => {
                    setIsReviewOpen(false);
                    loadStats();
                }}
                onStatsChange={loadStats}
            />
        </div>
    );
}

type TabButtonProps = {
    active: boolean;
    onClick: () => void;
    icon: string;
    label: string;
};

function TabButton({ active, onClick, icon, label }: TabButtonProps) {
    return (
        <button
            onClick={onClick}
            className={`px-4 py-3 flex items-center gap-2 text-sm font-bold border-b-2 transition-all ${active
                ? 'border-primary text-primary'
                : 'border-transparent text-text-muted hover:text-white hover:border-border'
                }`}
        >
            <span className="material-symbols-outlined text-lg">{icon}</span>
            {label}
        </button>
    );
}

type StatCardProps = {
    icon: string;
    title: string;
    value: number;
    onClick?: () => void;
    color?: 'yellow' | 'cyan' | 'purple' | 'red';
};

function StatCard({ icon, title, value, onClick, color = 'cyan' }: StatCardProps) {
    const colorClasses = {
        yellow: {
            border: 'border-l-yellow-500',
            icon: 'text-yellow-500',
        },
        cyan: {
            border: 'border-l-cyan-500',
            icon: 'text-cyan-500',
        },
        purple: {
            border: 'border-l-purple-500',
            icon: 'text-purple-500',
        },
        red: {
            border: 'border-l-red-500',
            icon: 'text-red-500',
        },
    };

    const { border, icon: iconColor } = colorClasses[color];

    return (
        <button
            onClick={onClick}
            disabled={!onClick}
            className={`bg-panel border border-border ${border} border-l-4 rounded-lg p-5 text-left transition-all group ${onClick ? 'hover:border-primary cursor-pointer' : ''}`}
        >
            <div className="flex justify-between items-start">
                <div>
                    <div className="text-xs text-text-muted font-mono uppercase mb-1">{title}</div>
                    <div className="text-3xl font-black text-white mt-1">{value}</div>
                </div>
                <span className={`material-symbols-outlined text-2xl ${iconColor}`}>{icon}</span>
            </div>
        </button>
    );
}

type ReviewQueueTableProps = {
    onOpenFullPanel: () => void;
};

function ReviewQueueTable({ onOpenFullPanel }: ReviewQueueTableProps) {
    const [submissions, setSubmissions] = useState<PendingSubmission[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const loadPendingSubmissions = async () => {
            try {
                const { data: targets } = await supabase
                    .from('target_submissions')
                    .select('id, target_name, submitted_by, submitted_at, status')
                    .eq('status', 'pending')
                    .order('submitted_at', { ascending: false })
                    .limit(10);

                const { data: rfcs } = await supabase
                    .from('rfc_proposals')
                    .select('id, proposed_name, user_id, created_at, status')
                    .eq('status', 'pending')
                    .order('created_at', { ascending: false })
                    .limit(10);

                const targetSubmissions: PendingSubmission[] = (targets || []).map(t => ({
                    id: t.id,
                    type: 'target' as const,
                    submittedBy: t.submitted_by?.slice(0, 12) || 'Unknown',
                    content: t.target_name,
                    date: new Date(t.submitted_at!).toLocaleDateString(),
                    status: t.status || 'pending'
                }));

                const rfcSubmissions: PendingSubmission[] = (rfcs || []).map(r => ({
                    id: r.id,
                    type: 'rfc' as const,
                    submittedBy: r.user_id?.slice(0, 12) || 'Unknown',
                    content: r.proposed_name || 'Metric Proposal',
                    date: new Date(r.created_at).toLocaleDateString(),
                    status: r.status || 'pending'
                }));

                const combined = [...targetSubmissions, ...rfcSubmissions]
                    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
                    .slice(0, 10);

                setSubmissions(combined);
            } catch (error) {
                console.error('Error loading pending submissions:', error);
            } finally {
                setLoading(false);
            }
        };

        loadPendingSubmissions();
    }, []);

    const handleApprove = async (submissionId: string) => {
        console.log('Approve:', submissionId);
        onOpenFullPanel();
    };

    const handleReject = async (submissionId: string) => {
        console.log('Reject:', submissionId);
        onOpenFullPanel();
    };

    return (
        <div className="bg-panel border border-border rounded-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-border bg-black/50 flex justify-between items-center">
                <h3 className="text-sm font-mono uppercase text-white flex items-center gap-2">
                    <span className="material-symbols-outlined text-sm text-yellow-500">warning</span>
                    Pending Submissions
                </h3>
                <button
                    onClick={onOpenFullPanel}
                    className="text-xs font-mono text-cyan-400 hover:text-white transition-colors"
                >
                    REFRESH
                </button>
            </div>

            {loading ? (
                <div className="p-6 text-center text-text-muted">Loading...</div>
            ) : submissions.length === 0 ? (
                <div className="p-6 text-center text-text-muted">No pending submissions</div>
            ) : (
                <table className="w-full text-left text-sm">
                    <thead className="bg-black/30 text-xs font-mono uppercase text-text-muted">
                        <tr>
                            <th className="px-6 py-3">Submitted By</th>
                            <th className="px-6 py-3">Type</th>
                            <th className="px-6 py-3">Content</th>
                            <th className="px-6 py-3">Date</th>
                            <th className="px-6 py-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-border text-gray-400">
                        {submissions.map((submission) => (
                            <tr key={submission.id} className="hover:bg-white/5 transition-colors">
                                <td className="px-6 py-4 font-mono text-xs">{submission.submittedBy}</td>
                                <td className="px-6 py-4">
                                    <span
                                        className={`px-2 py-1 rounded text-[10px] border ${submission.type === 'target'
                                            ? 'bg-blue-900/30 text-blue-400 border-blue-900/50'
                                            : 'bg-purple-900/30 text-purple-400 border-purple-900/50'
                                            }`}
                                    >
                                        {submission.type === 'target' ? 'NEW TARGET' : 'METRIC EDIT'}
                                    </span>
                                </td>
                                <td className="px-6 py-4 text-white">{submission.content}</td>
                                <td className="px-6 py-4 font-mono text-xs">{submission.date}</td>
                                <td className="px-6 py-4 text-right">
                                    <div className="flex justify-end gap-2">
                                        <button
                                            onClick={() => handleApprove(submission.id)}
                                            className="p-1 hover:text-green-500 transition-colors"
                                            title="Approve"
                                        >
                                            <span className="material-symbols-outlined text-lg">check</span>
                                        </button>
                                        <button
                                            onClick={() => handleReject(submission.id)}
                                            className="p-1 hover:text-red-500 transition-colors"
                                            title="Reject"
                                        >
                                            <span className="material-symbols-outlined text-lg">close</span>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}
