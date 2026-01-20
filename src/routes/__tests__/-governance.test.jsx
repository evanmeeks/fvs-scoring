import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { Route } from '../governance';

// We need to extract the component to test it directly or access it from the Route export
const GovernancePage = Route.options.component;

// Mock dependencies
const mockSetSelectedMetric = vi.fn();
const mockSetIsInspectorOpen = vi.fn();
const mockActiveTarget = { id: 'target-1' };
const mockFVSMetrics = [
    { id: 1, name: 'Metric 1', question: 'Q1' },
    { id: 2, name: 'Metric 2', question: 'Q2' }
];

// Mock useApp context
vi.mock('../../context/AppContext', () => ({
    useApp: () => ({
        FVS_METRICS: mockFVSMetrics,
        setIsInspectorOpen: mockSetIsInspectorOpen,
        setSelectedMetric: mockSetSelectedMetric,
        activeTarget: mockActiveTarget
    })
}));

// Mock useSupabase hooks
const mockSubmitGovernanceVote = vi.fn();
const mockUserScores = vi.fn();
const mockUser = { id: 'test-user' };

vi.mock('../../hooks/useSupabase', () => ({
    useUserVotesForTarget: vi.fn(), // Keeping this as it might be imported but unused
    useUserScores: (userId, targetId) => mockUserScores(userId, targetId),
    useGovernanceVote: () => ({
        submitGovernanceVote: mockSubmitGovernanceVote
    }),
    useAuth: () => ({ user: mockUser })
}));

// Mock MetricTable to inspect props
vi.mock('../../components/MetricTable', () => ({
    default: ({ data, votes, onVoteChange, saveStatus }) => (
        <div data-testid="metric-table">
            {data.map(m => (
                <div key={m.id} data-testid={`row-${m.id}`}>
                    <span data-testid={`action-${m.id}`}>{votes[m.id]?.action || 'keep'}</span>
                    <button
                        data-testid={`btn-change-${m.id}`}
                        onClick={() => onVoteChange(m.id, 'action', 'drop')}
                    >
                        Change to Drop
                    </button>
                    {saveStatus && saveStatus[m.id] && (
                        <span data-testid={`status-${m.id}`}>{saveStatus[m.id]}</span>
                    )}
                </div>
            ))}
        </div>
    )
}));

describe('GovernancePage', () => {
    beforeEach(() => {
        vi.clearAllMocks();
        // Default mock return for data
        mockUserScores.mockReturnValue({ data: [] });
    });

    it('renders and merges server data correctly', () => {
        // Mock server returning a 'modify' vote for Metric 1
        mockUserScores.mockReturnValue({
            data: [
                { metric_id: 1, action_vote: 'modify', action_notes: 'fix it' }
            ]
        });

        render(<GovernancePage />);

        // Metric 1 should show 'modify'
        expect(screen.getByTestId('action-1')).toHaveTextContent('modify');
        // Metric 2 should show default 'keep'
        expect(screen.getByTestId('action-2')).toHaveTextContent('keep');
    });

    it('handles vote changes with optimistic update and server submission', async () => {
        mockUserScores.mockReturnValue({ data: [] });
        mockSubmitGovernanceVote.mockResolvedValue({});

        render(<GovernancePage />);

        // Click to change vote
        fireEvent.click(screen.getByTestId('btn-change-1'));

        // 1. Optimistic Update: Should show 'drop' immediately
        expect(screen.getByTestId('action-1')).toHaveTextContent('drop');

        // 2. Status should be 'saving'
        expect(screen.getByTestId('status-1')).toHaveTextContent('saving');

        // 3. API call verification
        await waitFor(() => {
            expect(mockSubmitGovernanceVote).toHaveBeenCalledWith(
                'target-1',
                1,
                'drop',
                '' // notes default to empty string if not set
            );
        });

        // 4. Status should change to 'saved'
        await waitFor(() => {
            expect(screen.getByTestId('status-1')).toHaveTextContent('saved');
        });
    });

    it('handles API errors gracefully', async () => {
        // Suppress expected error log
        const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => { });

        mockUserScores.mockReturnValue({ data: [] });
        mockSubmitGovernanceVote.mockRejectedValue(new Error('Failed'));

        render(<GovernancePage />);

        fireEvent.click(screen.getByTestId('btn-change-1'));

        await waitFor(() => {
            expect(screen.getByTestId('status-1')).toHaveTextContent('error');
        });

        // Verify the error was indeed logged (optional but good for coverage)
        expect(consoleSpy).toHaveBeenCalledWith("Governance save failed", expect.any(Error));

        // Optimistic UI might persist the change, which is acceptable behavior (or it could revert)
        // In current implementation, it doesn't revert automatically on error, which is fine for now.
        expect(screen.getByTestId('action-1')).toHaveTextContent('drop');

        consoleSpy.mockRestore();
    });
});
