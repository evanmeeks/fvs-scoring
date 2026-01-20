import { createFileRoute, Link } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import Icon from '../../components/Icon';
import { useAuth, useUserSubmissions } from '../../hooks/useSupabase';

/**
 * Profile Dashboard
 * Central hub for all user-related functionality
 *
 * Provides access to:
 * - Submissions (targets, RFCs, scorecards)
 * - Settings (profile, privacy, preferences)
 * - Activity and stats
 */
export const Route = createFileRoute('/profile/')({
  head: () =>
    createHeadConfig({
      title: 'Profile Dashboard',
      description: 'Manage your FVS profile, submissions, and settings.',
      path: '/profile',
      noindex: true, // Private page, don't index
    }),
  component: ProfileDashboardPage,
});

function ProfileDashboardPage() {
  const { user } = useAuth();
  const { data: stats, loading } = useUserSubmissions(user?.id);

  const { targets, rfcs, scoredTargets } = stats || { targets: [], rfcs: [], scoredTargets: [] };

  return (
    <div className="container mx-auto p-6 max-w-6xl">
      <h1 className="text-3xl font-bold mb-2">Profile Dashboard</h1>
      <p className="text-muted mb-8">
        Manage your submissions, settings, and activity
      </p>

      <div className="grid gap-6">
        {/* Main Actions - Submissions */}
        <div className="bg-glass-dark rounded-lg border border-white/10 p-6">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h2 className="text-xl font-semibold">Profile Submissions</h2>
              <p className="text-sm text-muted mt-1">
                View and manage your targets, votes, and RFC proposals
              </p>
            </div>
            <Link
              to="/profile/submissions"
              className="flex items-center gap-2 px-4 py-2 bg-primary text-black font-bold rounded hover:bg-white transition-colors"
            >
              <Icon name="folder_open" className="text-lg" />
              View All
            </Link>
          </div>
        </div>

        {/* Settings Sections */}
        <div>
          <h2 className="text-lg font-semibold mb-4">Settings</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Link
              to="/profile/settings"
              className="bg-glass-dark rounded-lg border border-white/10 p-5 hover:border-primary/50 transition-colors group"
            >
              <div className="flex items-center gap-3 mb-3">
                <Icon
                  name="person"
                  className="text-2xl text-primary group-hover:scale-110 transition-transform"
                />
                <h3 className="font-semibold">Profile</h3>
              </div>
              <p className="text-sm text-muted">
                Display name, bio, and avatar settings
              </p>
            </Link>

            <Link
              to="/profile/privacy"
              className="bg-glass-dark rounded-lg border border-white/10 p-5 hover:border-primary/50 transition-colors group"
            >
              <div className="flex items-center gap-3 mb-3">
                <Icon
                  name="lock"
                  className="text-2xl text-primary group-hover:scale-110 transition-transform"
                />
                <h3 className="font-semibold">Privacy</h3>
              </div>
              <p className="text-sm text-muted">
                Anonymity, verification, and visibility
              </p>
            </Link>

            <Link
              to="/profile/preferences"
              className="bg-glass-dark rounded-lg border border-white/10 p-5 hover:border-primary/50 transition-colors group"
            >
              <div className="flex items-center gap-3 mb-3">
                <Icon
                  name="tune"
                  className="text-2xl text-primary group-hover:scale-110 transition-transform"
                />
                <h3 className="font-semibold">Preferences</h3>
              </div>
              <p className="text-sm text-muted">
                Notifications and display options
              </p>
            </Link>
          </div>
        </div>

        {/* Quick Stats */}
        <div className="bg-glass-dark rounded-lg border border-white/10 p-6">
          <h2 className="text-xl font-semibold mb-4">Activity Overview</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="text-center p-4 bg-surface rounded-lg">
              <div className="text-3xl font-bold text-primary mb-1">
                {loading ? '-' : scoredTargets.length}
              </div>
              <div className="text-sm text-muted">Votes</div>
            </div>
            <div className="text-center p-4 bg-surface rounded-lg">
              <div className="text-3xl font-bold text-primary mb-1">
                {loading ? '-' : targets.length}
              </div>
              <div className="text-sm text-muted">Target Proposals</div>
            </div>
            <div className="text-center p-4 bg-surface rounded-lg">
              <div className="text-3xl font-bold text-primary mb-1">
                {loading ? '-' : rfcs.length}
              </div>
              <div className="text-sm text-muted">RFC Proposals</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
