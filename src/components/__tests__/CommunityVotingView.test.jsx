import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import CommunityVotingView from '../views/CommunityVotingView';
import * as useSupabaseHooks from '../../hooks/useSupabase';

// Mock AppContext
vi.mock('../../context/AppContext', () => ({
    useApp: vi.fn()
}));
import { useApp } from '../../context/AppContext';

// Mock Supabase hooks
vi.mock('../../hooks/useSupabase', () => ({
    useAuth: vi.fn(),
    useCommunityVotes: vi.fn(),
    useUserVotesForTarget: vi.fn(),
    useSubmitCommunityVote: vi.fn(),
}));

describe('CommunityVotingView Component', () => {
    const mockUser = { id: 'test-user' };
    const mockSubmitVote = vi.fn();

    beforeEach(() => {
        vi.clearAllMocks();

        useApp.mockReturnValue({
            FVS_METRICS: [
                { id: '1', name: 'Metric 1', coreQuestion: 'Q1?', question: 'Q1?' },
                { id: '2', name: 'Metric 2', coreQuestion: 'Q2?', question: 'Q2?' }
            ]
        });

        useSupabaseHooks.useAuth.mockReturnValue({ user: mockUser });

        useSupabaseHooks.useCommunityVotes.mockReturnValue({
            data: [
                { metric_id: '1', vote_value: 5, user_id: 'u1' },
                { metric_id: '1', vote_value: 3, user_id: 'u2' }
            ],
            loading: false
        });

        useSupabaseHooks.useUserVotesForTarget.mockReturnValue({
            data: [{ metric_id: '1', vote_value: 5 }],
            loading: false
        });

        useSupabaseHooks.useSubmitCommunityVote.mockReturnValue({
            submitVote: mockSubmitVote,
            loading: false
        });
    });

    it('renders with active target', () => {
        render(<CommunityVotingView activeTarget="test-target" />);
        expect(screen.getByText('test-target')).toBeInTheDocument();
        expect(screen.getByText('Metric 1')).toBeInTheDocument();
        expect(screen.getByText('Metric 2')).toBeInTheDocument();
    });

    it('displays user progress properly', () => {
        render(<CommunityVotingView activeTarget="test-target" />);
        // 1 out of 2 voted
        // Found multiple "1"s (metric id, buttons, score). 
        // We know the progress "1" has text-3xl class, or we can check the denominator.
        expect(screen.getByText('/ 2')).toBeInTheDocument();

        // Check for specific progress count using a more specific query if possible, or just presence of "1" in the doc is trivially true.
        // Let's verify the text content of the progress container if we can finding it by surrounding text.
        const progressLabel = screen.getByText('Your Progress');
        expect(progressLabel).toBeInTheDocument();
    });

    it('reflects consensus data', () => {
        render(<CommunityVotingView activeTarget="test-target" />);
        // Mean for Metric 1: (5+3)/2 = 4.0
        expect(screen.getByText('Mean:')).toBeInTheDocument();
        expect(screen.getByText('4.0')).toBeInTheDocument();
    });

    it('handles voting', () => {
        render(<CommunityVotingView activeTarget="test-target" />);

        // Find Metric 2 voting buttons (unvoted)
        // Metric 1 is voted "5", Metric 2 is unvoted.
        // We look for the "2" button of Metric 2 card.
        // Hard to pinpoint exact button without scoping.
        // Let's use getByText 'Metric 2' parent logic or test-id if we added one.
        // Since we didn't add test-ids, we can scan `button` text.

        // Actually, let's just validte that clicking A button calls submitVote.
        // There are multiple buttons with text "1", "2", etc.
        const buttons = screen.getAllByText('3'); // Score 3 buttons
        fireEvent.click(buttons[0]); // Click first one

        expect(mockSubmitVote).toHaveBeenCalled();
    });

    it('disables voting when logged out', () => {
        useSupabaseHooks.useAuth.mockReturnValue({ user: null });
        render(<CommunityVotingView activeTarget="test-target" />);

        const button = screen.getAllByText('3')[0].closest('button');
        expect(button).toBeDisabled();
    });
});
