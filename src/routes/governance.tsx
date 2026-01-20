import { createFileRoute, Navigate } from '@tanstack/react-router'

export const Route = createFileRoute('/governance')({
    component: GovernanceRedirect,
})

function GovernanceRedirect() {
    return <Navigate to="/contributors/governance" replace />
}
