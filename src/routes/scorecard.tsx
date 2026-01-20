import { createFileRoute } from '@tanstack/react-router'
import { LandingView } from '../components/views/LandingView'
import { ScorecardPanel } from '../components/views/landing/ScorecardPanel'
import { createHeadConfig, PAGE_SEO } from '../utils/seo'

export const Route = createFileRoute('/scorecard')({
    head: () => createHeadConfig(PAGE_SEO.scorecard),
    component: ScorecardComponent,
})

function ScorecardComponent() {
    return (
        <LandingView>
            <ScorecardPanel />
        </LandingView>
    )
}
