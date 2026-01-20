import { createFileRoute } from '@tanstack/react-router';
import { createHeadConfig } from '../utils/seo';
import { useAuth } from '../context/AuthContext';

/**
 * Beta Waitlist Page
 * Shown to users who don't have beta_features_enabled
 *
 * Phase 1 (Contributors-only beta):
 * - Contributors get immediate access
 * - Other users see waitlist message
 *
 * Phase 2 (All users):
 * - This page becomes obsolete
 * - Can be removed or repurposed
 */
export const Route = createFileRoute('/beta-waitlist')({
  head: () =>
    createHeadConfig({
      title: 'Beta Access',
      description: 'Join the FVS Profile Beta Program.',
      path: '/beta-waitlist',
      noindex: true,
    }),
  component: BetaWaitlistPage,
});

function BetaWaitlistPage() {
  const { user, isContributor } = useAuth();

  return (
    <div className="container mx-auto p-6 max-w-3xl">
      <div className="bg-glass-dark rounded-lg border border-white/10 p-8">
        <h1 className="text-3xl font-bold mb-4">Profile Beta Access</h1>

        {user ? (
          <>
            <p className="text-lg text-muted mb-6">
              The new profile dashboard is currently in beta testing.
            </p>

            <div className="bg-primary/10 border border-primary/30 rounded-lg p-6 mb-6">
              <h2 className="text-xl font-semibold mb-3">
                Phase 1: Contributors-Only Beta
              </h2>
              <p className="text-muted mb-4">
                We're rolling out profile features to contributors first to
                gather feedback and ensure quality.
              </p>

              {isContributor ? (
                <div className="bg-green-500/10 border border-green-500/30 rounded-lg p-4">
                  <p className="font-semibold text-green-400">
                    ✓ You're a contributor!
                  </p>
                  <p className="text-sm text-muted mt-2">
                    If you're seeing this page, your beta access may not be
                    enabled yet. Contact an admin or check back soon.
                  </p>
                </div>
              ) : (
                <div className="bg-yellow-500/10 border border-yellow-500/30 rounded-lg p-4">
                  <p className="font-semibold text-yellow-400">
                    Become a Contributor
                  </p>
                  <p className="text-sm text-muted mt-2">
                    To access the beta, you need contributor status. Submit
                    quality scores and participate in governance to earn
                    contributor access.
                  </p>
                </div>
              )}
            </div>

            <div className="space-y-4 text-muted">
              <h3 className="text-lg font-semibold text-white">
                What's Coming in Profile Beta:
              </h3>
              <ul className="list-disc list-inside space-y-2 ml-2">
                <li>
                  <strong>Anonymity-first identity:</strong> Choose between
                  pseudonym, verified handle, or real name
                </li>
                <li>
                  <strong>Contributor verification:</strong> Link your GitHub,
                  Twitter/X, or Discord for verified badge
                </li>
                <li>
                  <strong>Privacy controls:</strong> Fine-grained control over
                  what others can see
                </li>
                <li>
                  <strong>Activity dashboard:</strong> Track your scores, RFCs,
                  and contributions
                </li>
              </ul>

              <h3 className="text-lg font-semibold text-white mt-6">
                Rollout Timeline:
              </h3>
              <ul className="list-disc list-inside space-y-2 ml-2">
                <li>
                  <strong>Phase 1 (Current):</strong> Contributors-only beta
                  (Weeks 1-2)
                </li>
                <li>
                  <strong>Phase 2:</strong> All authenticated users (Weeks 3-4)
                </li>
                <li>
                  <strong>Phase 3:</strong> Public features (Week 5+)
                </li>
              </ul>
            </div>

            <div className="mt-8 pt-6 border-t border-white/10">
              <p className="text-sm text-muted">
                Questions about beta access? Check our{' '}
                <a
                  href="/manifesto"
                  className="text-primary hover:underline"
                >
                  manifesto
                </a>{' '}
                or contact an admin.
              </p>
            </div>
          </>
        ) : (
          <>
            <p className="text-lg text-muted mb-6">
              You need to be logged in to access profile features.
            </p>
            <a
              href="/login"
              className="inline-block bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-primary/90 transition-colors"
            >
              Log In
            </a>
          </>
        )}
      </div>
    </div>
  );
}
