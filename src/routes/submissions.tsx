import { createFileRoute, Outlet } from '@tanstack/react-router';

/**
 * Layout for /submissions/* routes
 * These are public shareable result pages
 */
export const Route = createFileRoute('/submissions')({
  component: SubmissionsLayout,
});

function SubmissionsLayout() {
  return (
    <div className="flex-1 flex flex-col">
      <Outlet />
    </div>
  );
}
