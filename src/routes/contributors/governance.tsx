import React, { useState, useMemo } from 'react'
import { createFileRoute } from '@tanstack/react-router'
import { useApp } from '../../context/AppContext'
import MetricTable from '../../components/MetricTable'
import { useUserScores, useGovernanceVote, useAuth } from '../../hooks/useSupabase'
import RFCProposalList from '../../components/RFCProposalList'
import { createHeadConfig } from '../../utils/seo'
import type { Metric } from '../../context/AppContext'

type VoteEntry = { confidence: string | null; notes: string };
type VoteState = Record<string, VoteEntry>;
type SaveStatusState = Record<string, 'saving' | 'saved' | 'error'>;
type DebounceTimers = Record<string, ReturnType<typeof setTimeout>>;

export const Route = createFileRoute('/contributors/governance')({
    head: () => createHeadConfig({
        title: 'Governance',
        description: 'Contributor governance portal for FVS metric proposals and voting.',
        path: '/contributors/governance',
        noindex: true,
    }),
    component: GovernancePage,
})

function GovernancePage() {
    const { FVS_METRICS, setIsInspectorOpen, setSelectedMetric, activeTarget } = useApp()
    const { user } = useAuth()
    const { data: userVotesData } = useUserScores(user?.id, activeTarget.id)
    const { submitGovernanceVote } = useGovernanceVote()

    const [localVotes, setLocalVotes] = useState<VoteState>({})
    const [saveStatus, setSaveStatus] = useState<SaveStatusState>({})

    const votes = useMemo(() => {
        const merged: VoteState = {};

        if (userVotesData) {
            userVotesData.forEach(v => {
                if (v.metric_id == null) return;
                if (!v.action_vote && !v.action_notes) return;

                merged[String(v.metric_id)] = {
                    confidence: v.action_vote || null,
                    notes: v.action_notes || ''
                }
            });
        }

        Object.keys(localVotes).forEach(metricId => {
            merged[metricId] = {
                ...merged[metricId],
                ...localVotes[metricId]
            }
        });

        return merged;
    }, [userVotesData, localVotes])

    const debounceTimers = React.useRef<DebounceTimers>({})

    const handleVoteChange = async (
        metricId: number | string,
        field: 'confidence' | 'notes',
        value: string | null
    ) => {
        const metricKey = String(metricId);
        const currentVote = votes[metricKey] || { confidence: null, notes: '' };
        const newVote: VoteEntry = { ...currentVote, [field]: value };

        setLocalVotes(prev => ({
            ...prev,
            [metricKey]: newVote
        }));

        if (debounceTimers.current[metricKey]) {
            clearTimeout(debounceTimers.current[metricKey]);
        }

        setSaveStatus(prev => ({ ...prev, [metricKey]: 'saving' }));

        debounceTimers.current[metricKey] = setTimeout(async () => {
            try {
                await submitGovernanceVote(
                    activeTarget.id,
                    Number(metricId),
                    newVote.confidence ?? '',
                    newVote.notes
                );

                setSaveStatus(prev => ({ ...prev, [metricKey]: 'saved' }));
                setTimeout(() => {
                    setSaveStatus(prev => {
                        const next: SaveStatusState = { ...prev };
                        delete next[metricKey];
                        return next;
                    });
                }, 2000);
            } catch (error) {
                console.error("Governance save failed", error);
                setSaveStatus(prev => ({ ...prev, [metricKey]: 'error' }));
            }
        }, 500);
    }

    const handleSelect = (metric: Metric) => {
        setSelectedMetric(metric)
        setIsInspectorOpen(true)
    }

    return (
        <>
            <MetricTable
                data={FVS_METRICS}
                scores={{}}
                votes={votes}
                onVoteChange={handleVoteChange}
                onSelect={handleSelect}
                mode="governance"
                saveStatus={saveStatus}
            />
            <div className="mt-8">
                <RFCProposalList />
            </div>
        </>
    )
}
