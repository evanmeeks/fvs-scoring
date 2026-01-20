 
/* eslint-disable @typescript-eslint/no-explicit-any */
import { createFileRoute, redirect } from '@tanstack/react-router'
import { useApp } from '../context/AppContext'
import MetricTable from '../components/MetricTable'

export const Route = createFileRoute('/review')({
    beforeLoad: () => {
        // Route deprecated: redirect to contributors governance
        throw redirect({ to: '/contributors/governance' })
    },
    component: ReviewComponent,
})

function ReviewComponent() {
    const {
        scores,
        handleScoreChange,
        selectedMetricId,
        FVS_METRICS,
        setSelectedMetricId,
        setIsInspectorOpen,
    } = useApp()

    const handleSelect = (metric: any) => {
        if (selectedMetricId === metric.id) {
            setIsInspectorOpen(false)
            setSelectedMetricId(null)
        } else {
            setSelectedMetricId(metric.id)
            setIsInspectorOpen(true)
        }
    }

    return (
        <MetricTable
            data={FVS_METRICS}
            mode="review"
            scores={scores}
            onScoreChange={handleScoreChange}
            onSelect={handleSelect}
            isSelected={selectedMetricId}
        />
    )
}
