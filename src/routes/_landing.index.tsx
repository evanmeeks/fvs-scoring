import { createFileRoute } from '@tanstack/react-router'
import { CurrentTargetsView } from '../components/views/landing/CurrentTargetsView'
import { createHeadConfig, PAGE_SEO } from '../utils/seo'

export const Route = createFileRoute('/_landing/')({
    head: () => createHeadConfig(PAGE_SEO.home),
    component: IndexComponent,
})

function IndexComponent() {
    return (
        <CurrentTargetsView />
    )
}
