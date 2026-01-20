import { createFileRoute, Outlet } from '@tanstack/react-router';
import { ensureAuthenticated } from '../utils/routeGuards';

/**
 * Layout for /profile/* routes
 * User Dashboard - all authenticated users can access
 *
 * Consolidates:
 * - User settings (pseudonym, privacy, preferences)
 * - Submissions (targets, RFCs, scorecards)
 * - Activity and stats
 */
export const Route = createFileRoute('/profile')({
  beforeLoad: ensureAuthenticated,
  component: ProfileLayout,
});

function ProfileLayout() {
  return (
    <div className="flex-1 flex flex-col">
      <Outlet />
    </div>
  );
}
