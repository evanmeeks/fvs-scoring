import { createFileRoute, Outlet } from '@tanstack/react-router'
import { LandingView } from '../components/views/LandingView'

export const Route = createFileRoute('/_landing')({
    component: LandingLayout,
})

function LandingLayout() {
    return (
        <LandingView>
            <Outlet />
        </LandingView>
    )
}
