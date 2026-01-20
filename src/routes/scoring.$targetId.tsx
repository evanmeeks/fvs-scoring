import { useEffect, useMemo } from 'react'
import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { useApp } from '../context/AppContext'
import CommunityVotingView from '../components/views/CommunityVotingView'
import { useTargets } from '../hooks/useSupabase'
import { normalizeTarget, type NormalizedTarget } from '../utils/targets'
import { createScoringHeadConfig } from '../utils/seo'

export const Route = createFileRoute('/scoring/$targetId')({
    // No auth required - users can view target stats publicly
    // Auth will be required when attempting to submit scores
    head: ({ params }) => createScoringHeadConfig(params.targetId),
    component: ScoringComponent,
})

function ScoringComponent() {
    const { activeTarget, setActiveTarget } = useApp()
    const navigate = useNavigate()
    const { targetId } = Route.useParams()
    const { data: targets } = useTargets()

    const normalizedTargets = useMemo(
        () => (
            Array.isArray(targets)
                ? targets
                    .map(normalizeTarget)
                    .filter((t): t is NormalizedTarget => Boolean(t))
                : []
        ),
        [targets]
    )

    const targetFromParams = useMemo(() => {
        if (!targetId) return null
        return (
            normalizedTargets.find((t) => t.id === targetId) ||
            (activeTarget?.id === targetId ? activeTarget : null)
        )
    }, [targetId, normalizedTargets, activeTarget])

    const fallbackTarget = useMemo(() => {
        if (targetFromParams) return targetFromParams
        if (normalizedTargets.length > 0) return normalizedTargets[0]
        return activeTarget || null
    }, [targetFromParams, normalizedTargets, activeTarget])

    // 1. Handle invalid/missing URL params by redirecting to a valid target
    useEffect(() => {
        // If we have no targetId in URL (should be caught by router, but safety check)
        // OR if the targetId is invalid (not in our list) AND matches nothing known
        if (!targetId || (!targetFromParams && normalizedTargets.length > 0)) {
            const fallback = activeTarget?.id || normalizedTargets[0]?.id || 'grusch-2024';
            console.warn(`Invalid or missing target '${targetId}'. Redirecting to ${fallback}`);
            navigate({
                to: '/scoring/$targetId',
                params: { targetId: fallback },
                replace: true,
            })
        }
    }, [targetId, targetFromParams, normalizedTargets, activeTarget?.id, navigate])

    // 2. Sync URL -> State (Source of Truth)
    // When URL changes, we update the global activeTarget to match.
    useEffect(() => {
        if (!targetFromParams) return;

        // If the URL target is valid and different from global state, update global state
        if (activeTarget?.id !== targetFromParams.id) {
            setActiveTarget(targetFromParams)
        }
    }, [targetFromParams, activeTarget?.id, setActiveTarget])

    // REMOVED: The reverse sync (State -> URL) is causing loops.
    // The Sidebar triggers navigation directly now (in __root.jsx),
    // or if Sidebar is used elsewhere, we rely on the user clicking "View" to navigate.


    const targetIdForView =
        targetFromParams?.id || targetId || fallbackTarget?.id || 'grusch-2024'

    return (
        <CommunityVotingView activeTarget={targetIdForView} />
    )
}
