import { createFileRoute, Outlet } from '@tanstack/react-router';
import { ensureAuthenticated } from '../utils/routeGuards';

/**
 * Layout for /my/* routes
 * All routes under /my require authentication
 */
export const Route = createFileRoute('/my')({
  beforeLoad: ensureAuthenticated,
  component: MyLayout,
});

function MyLayout() {
  return (
    <div className="flex-1 flex flex-col">
      <Outlet />
    </div>
  );
}
