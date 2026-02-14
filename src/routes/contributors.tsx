import { createFileRoute, Outlet } from "@tanstack/react-router";
import { ensureContributor } from "../utils/routeGuards";
import { createHeadConfig } from "../utils/seo";

export const Route = createFileRoute('/contributors')({
    beforeLoad: ({ location }) => ensureContributor(location),
    head: () => createHeadConfig({
        title: 'Contributors',
        description: 'Contributor portal for Forecast Audit',
        path: '/contributors',
        noindex: true,
    }),
    component: ContributorsLayout,
});

function ContributorsLayout() {
    return <Outlet />;
}
