import { createFileRoute, Outlet } from "@tanstack/react-router";
import { ensureAdmin } from "../utils/routeGuards";
import { createHeadConfig, PAGE_SEO } from "../utils/seo";

export const Route = createFileRoute('/admin')({
    beforeLoad: ({ location }) => ensureAdmin(location),
    head: () => createHeadConfig({
        ...PAGE_SEO.admin,
        noindex: true,
    }),
    component: AdminLayout,
});

function AdminLayout() {
    return <Outlet />;
}
