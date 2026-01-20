import { createFileRoute } from '@tanstack/react-router'
import { Manifesto } from '../components/views/landing/Manifesto'
import { createHeadConfig, PAGE_SEO } from '../utils/seo'

export const Route = createFileRoute('/_landing/manifesto')({
    head: () => createHeadConfig(PAGE_SEO.manifesto),
    component: ManifestoComponent,
})

function ManifestoComponent() {
    return (
        <Manifesto />
    )
}
