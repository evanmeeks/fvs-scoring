import { renderHook, act, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { AppContextProvider, useApp } from '../AppContext';

// Mock data
const mockMetrics = [
    { id: 1, communityScore: 1 },
    { id: 2, communityScore: 5 }
];

// Mock useUserVotesForTarget hook
const mockUserVotesForTarget = vi.fn();

vi.mock('../../hooks/useSupabase', () => ({
    useUserVotesForTarget: () => mockUserVotesForTarget()
}));

// Wrapper component
const wrapper = ({ children }) => (
    <AppContextProvider initialMetrics={mockMetrics}>
        {children}
    </AppContextProvider>
);

describe('AppContext Score Syncing', () => {
    beforeEach(() => {
        vi.clearAllMocks();
    });

    it('syncs scores from database votes', async () => {
        // Mock server return
        mockUserVotesForTarget.mockReturnValue({
            data: [
                { metric_id: 1, vote_value: 3 },
                { metric_id: 2, vote_value: 5 }
            ]
        });

        const { result } = renderHook(() => useApp(), { wrapper });

        // Wait for useEffect
        await waitFor(() => {
            expect(result.current.scores[1]).toBe(3);
            expect(result.current.scores[2]).toBe(5);
        });

        // Calculate total score based on synced values
        expect(result.current.totalScore).toBe(8);
    });

    it('handles default empty state before sync', async () => {
        mockUserVotesForTarget.mockReturnValue({ data: null });

        const { result } = renderHook(() => useApp(), { wrapper });

        expect(result.current.scores[1]).toBe(0);
        expect(result.current.totalScore).toBe(0);
    });

    it('updates scores when user slides manually (local override)', async () => {
        mockUserVotesForTarget.mockReturnValue({ data: null });

        const { result } = renderHook(() => useApp(), { wrapper });

        await act(async () => {
            result.current.handleScoreChange(1, 4);
        });

        expect(result.current.scores[1]).toBe(4);
        expect(result.current.totalScore).toBe(4);
    });
});
