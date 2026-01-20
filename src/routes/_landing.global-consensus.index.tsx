import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/_landing/global-consensus/')({
  component: RouteComponent,
})

function RouteComponent() {
  return <div>Hello "/_landing/global-consensus/"!</div>
}
