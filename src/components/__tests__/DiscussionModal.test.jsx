import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import DiscussionModal from '../DiscussionModal';
import * as useSupabaseHooks from '../../hooks/useSupabase';

// Mock Icon
vi.mock('../Icon', () => ({
    default: ({ name, className }) => <span data-testid={`icon-${name}`} className={className}></span>
}));

// Mock Supabase hooks
vi.mock('../../hooks/useSupabase', () => ({
    useDiscussions: vi.fn(),
    useSubmitComment: vi.fn(),
    useVoteOnComment: vi.fn(),
}));

// Mock Discussions Data
const mockDiscussions = [
    {
        id: '1',
        user_id: 'user1',
        comment: 'Top level comment',
        created_at: new Date().toISOString(),
        upvotes: 5,
        downvotes: 1,
        parent_id: null,
        user_profiles: { full_name: 'User One', avatar_url: null }
    },
    {
        id: '2',
        user_id: 'user2',
        comment: 'Reply comment',
        created_at: new Date().toISOString(),
        upvotes: 2,
        downvotes: 0,
        parent_id: '1',
        user_profiles: { full_name: 'User Two', avatar_url: null }
    }
];

describe('DiscussionModal Component', () => {
    const defaultProps = {
        isOpen: true,
        onClose: vi.fn(),
        metricId: '1',
        metricName: 'Test Metric',
        user: { id: 'test-user' },
        onRequireAuth: vi.fn()
    };

    const mockSubmitComment = vi.fn();
    const mockVoteOnComment = vi.fn();

    beforeEach(() => {
        vi.clearAllMocks();

        // Setup default hook returns
        useSupabaseHooks.useDiscussions.mockReturnValue({
            data: mockDiscussions,
            loading: false,
            error: null
        });

        useSupabaseHooks.useSubmitComment.mockReturnValue({
            submitComment: mockSubmitComment,
            loading: false,
            error: null
        });

        useSupabaseHooks.useVoteOnComment.mockReturnValue({
            voteOnComment: mockVoteOnComment,
            loading: false,
            error: null
        });
    });

    it('renders nothing when not open', () => {
        const { container } = render(<DiscussionModal {...defaultProps} isOpen={false} />);
        expect(container).toBeEmptyDOMElement();
    });

    it('renders discussions correctly', () => {
        render(<DiscussionModal {...defaultProps} />);

        expect(screen.getByText('Discussion')).toBeInTheDocument();
        expect(screen.getByText('Test Metric')).toBeInTheDocument();
        expect(screen.getByText('Top level comment')).toBeInTheDocument();
        // Check for nested reply
        expect(screen.getByText('Reply comment')).toBeInTheDocument();
    });

    it('shows loading state', () => {
        useSupabaseHooks.useDiscussions.mockReturnValue({
            data: [],
            loading: true,
            error: null
        });

        render(<DiscussionModal {...defaultProps} />);
        expect(screen.getByText('Loading discussions...')).toBeInTheDocument();
    });

    it('handles posting a new comment', async () => {
        render(<DiscussionModal {...defaultProps} />);

        const textarea = screen.getByPlaceholderText('Share your thoughts on this metric...');
        fireEvent.change(textarea, { target: { value: 'New Test Comment' } });

        const submitBtn = screen.getByText('Post Comment');
        fireEvent.click(submitBtn);

        await waitFor(() => {
            expect(mockSubmitComment).toHaveBeenCalledWith('1', 'New Test Comment', null);
        });
    });

    it('handles voting on a comment', async () => {
        render(<DiscussionModal {...defaultProps} />);

        // Find first upvote button
        const upvoteBtns = screen.getAllByTitle('Upvote');
        fireEvent.click(upvoteBtns[0]);

        await waitFor(() => {
            expect(mockVoteOnComment).toHaveBeenCalledWith('1', 'upvote');
        });
    });

    it('requires auth for interaction', () => {
        render(<DiscussionModal {...defaultProps} user={null} />);

        // Check comment prompt
        expect(screen.getByText(/Please log in to participate/)).toBeInTheDocument();
        expect(screen.getByText('Connect to Comment')).toBeInTheDocument();
        expect(screen.queryByPlaceholderText('Share your thoughts on this metric...')).not.toBeInTheDocument();

        // Check vote buttons disabled
        const voteBtns = screen.getAllByTitle('Log in to vote');
        expect(voteBtns[0]).toBeDisabled();
    });

    it('displays replies', () => {
        render(<DiscussionModal {...defaultProps} />);
        // With current mock data, comment 2 is a reply to comment 1
        // We verify it's rendered. Note: DiscussionModal implementation puts replies inside the parent map loop
        expect(screen.getByText('Reply comment')).toBeInTheDocument();
    });
});
