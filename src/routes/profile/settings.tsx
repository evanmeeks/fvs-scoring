import { createFileRoute, Link } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import ProfileSettings from '../../components/views/ProfileSettings';
import { useAuth, useUserSubmissions } from '../../hooks/useSupabase';
import { useState } from 'react';

export const Route = createFileRoute('/profile/settings')({
  head: () =>
    createHeadConfig({
      title: 'Profile Settings',
      description: 'Manage your profile settings and display preferences.',
      path: '/profile/settings',
      noindex: true,
    }),
  component: ProfileSettingsPage,
});

function ProfileSettingsPage() {
  const { user } = useAuth();
  const { data: stats, loading } = useUserSubmissions(user?.id);
  const [activeSection, setActiveSection] = useState<'profile' | 'privacy' | 'preferences'>('profile');

  const { targets = [], rfcs = [], scoredTargets = [] } = stats || {};
  const totalContributions = targets.length + rfcs.length;
  const consensusRate = 94; // Placeholder

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        {/* Sidebar */}
        <div className="lg:col-span-1 space-y-6">
          {/* User Card */}
          <div className="bg-panel border border-border p-6 rounded-lg text-center">
            <div className="w-24 h-24 mx-auto bg-border rounded-full flex items-center justify-center text-4xl text-text-muted mb-4 relative overflow-hidden group cursor-pointer">
              <span className="material-symbols-outlined text-5xl">person</span>
              <div className="absolute inset-0 bg-black/60 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                <span className="material-symbols-outlined text-white text-sm">edit</span>
              </div>
            </div>
            <h3 className="text-white font-bold text-lg">{user?.email?.split('@')[0] || 'User'}</h3>
            <p className="text-xs font-mono text-cyan-400 uppercase mt-1">Lvl 3 Analyst</p>
            <div className="mt-4 flex justify-center gap-2">
              <span className="px-2 py-1 bg-green-900/30 text-green-500 text-[10px] font-mono rounded border border-green-900/50">
                VERIFIED
              </span>
              <span className="px-2 py-1 bg-blue-900/30 text-blue-500 text-[10px] font-mono rounded border border-blue-900/50">
                ANONYMOUS
              </span>
            </div>
          </div>

          {/* Settings Nav */}
          <div className="bg-panel border border-border rounded-lg overflow-hidden">
            <div className="p-3 border-b border-border text-xs font-mono text-text-muted uppercase">
              Settings
            </div>
            <button
              onClick={() => setActiveSection('profile')}
              className={`w-full text-left px-4 py-3 text-sm flex items-center gap-3 transition-colors border-l-2 ${activeSection === 'profile'
                  ? 'border-cyan-400 text-white bg-white/5'
                  : 'border-transparent text-gray-400 hover:bg-white/5 hover:text-white'
                }`}
            >
              <span className="material-symbols-outlined text-gray-400 text-lg">badge</span>
              Profile
            </button>
            <Link
              to="/profile/privacy"
              className="w-full text-left px-4 py-3 text-sm text-gray-400 hover:bg-white/5 flex items-center gap-3 transition-colors border-l-2 border-transparent hover:text-white"
            >
              <span className="material-symbols-outlined text-gray-400 text-lg">lock</span>
              Privacy
            </Link>
            <Link
              to="/profile/preferences"
              className="w-full text-left px-4 py-3 text-sm text-gray-400 hover:bg-white/5 flex items-center gap-3 transition-colors border-l-2 border-transparent hover:text-white"
            >
              <span className="material-symbols-outlined text-gray-400 text-lg">settings</span>
              Preferences
            </Link>
          </div>
        </div>

        {/* Main Content */}
        <div className="lg:col-span-3 space-y-6">
          {/* Stats Row */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-panel border border-border p-4 rounded-lg">
              <div className="text-xs text-text-muted font-mono uppercase">Audits Completed</div>
              <div className="text-2xl font-black text-white mt-1">{loading ? '-' : scoredTargets.length}</div>
            </div>
            <div className="bg-panel border border-border p-4 rounded-lg">
              <div className="text-xs text-text-muted font-mono uppercase">Contributions</div>
              <div className="text-2xl font-black text-cyan-400 mt-1">{loading ? '-' : totalContributions}</div>
            </div>
            <div className="bg-panel border border-border p-4 rounded-lg">
              <div className="text-xs text-text-muted font-mono uppercase">Consensus Rate</div>
              <div className="text-2xl font-black text-green-500 mt-1">{consensusRate}%</div>
            </div>
          </div>

          {/* Profile Settings */}
          <div className="bg-panel border border-border rounded-lg p-6">
            <h3 className="text-lg font-bold text-white mb-6 border-b border-border pb-4">
              Profile Settings
            </h3>
            <ProfileSettings />
          </div>

          {/* Activity Log */}
          <div className="bg-panel border border-border rounded-lg overflow-hidden">
            <div className="px-6 py-4 border-b border-border bg-black/50 flex justify-between items-center">
              <h3 className="text-sm font-mono uppercase text-white">Recent Profile Activity</h3>
            </div>
            <table className="w-full text-left text-sm">
              <thead className="bg-black/30 text-xs font-mono uppercase text-text-muted">
                <tr>
                  <th className="px-6 py-3">Action</th>
                  <th className="px-6 py-3">Target / Item</th>
                  <th className="px-6 py-3">Date</th>
                  <th className="px-6 py-3 text-right">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border text-gray-400">
                {loading ? (
                  <tr>
                    <td colSpan={4} className="px-6 py-4 text-center">Loading...</td>
                  </tr>
                ) : (
                  <>
                    {scoredTargets.slice(0, 3).map((target: { target_name: string; scored_at: string }, idx: number) => (
                      <tr key={idx}>
                        <td className="px-6 py-4">
                          <span className="text-cyan-400">AUDIT</span>
                        </td>
                        <td className="px-6 py-4 text-white">{target.target_name || 'Target'}</td>
                        <td className="px-6 py-4 font-mono text-xs">
                          {target.scored_at ? new Date(target.scored_at).toLocaleDateString() : 'N/A'}
                        </td>
                        <td className="px-6 py-4 text-right">
                          <span className="text-green-500 text-xs font-mono">PUBLISHED</span>
                        </td>
                      </tr>
                    ))}
                  </>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
}
