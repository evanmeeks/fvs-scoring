import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Inspector from '../Inspector';

// Mock dependencies
vi.mock('../Icon', () => ({
    default: ({ name, className }) => <span data-testid={`icon-${name}`} className={className}></span>
}));

vi.mock('../../utils/supabase', () => ({
    supabase: {
        from: vi.fn(() => ({
            select: vi.fn(() => ({
                eq: vi.fn(() => Promise.resolve({ count: 5, error: null }))
            }))
        }))
    }
}));

const mockMetric = {
    id: '1',
    name: 'Test Metric',
    coreQuestion: 'Test Core Question?',
    question: 'Legacy Question?',
    scoringCriteria: [
        { score: 1, label: 'Low Label', description: 'Low Description' },
        { score: 2, label: '2', description: 'Desc 2' },
        { score: 3, label: '3', description: 'Desc 3' },
        { score: 4, label: '4', description: 'Desc 4' },
        { score: 5, label: 'High Label', description: 'High Description' }
    ],
    communityScore: 4.2
};

describe('Inspector Component', () => {
    const defaultProps = {
        metric: mockMetric,
        onClose: vi.fn(),
        onSubmitRFC: vi.fn(),
        onViewDiscussion: vi.fn(),
        user: { id: 'test-user' },
        onRequireAuth: vi.fn()
    };

    it('renders empty state when no metric provided', () => {
        render(<Inspector {...defaultProps} metric={null} />);
        expect(screen.getByText('Detailed Inspection')).toBeInTheDocument();
    });

    it('renders metric details correctly', () => {
        render(<Inspector {...defaultProps} />);

        // Name
        expect(screen.getByText('Test Metric')).toBeInTheDocument();

        // Question (prefers coreQuestion)
        expect(screen.getByText('Test Core Question?')).toBeInTheDocument();

        // Scale labels
        expect(screen.getByText('SCORE 1: Low Label')).toBeInTheDocument();
        expect(screen.getByText('SCORE 5: High Label')).toBeInTheDocument();

        // Descriptions
        expect(screen.getByText('Low Description')).toBeInTheDocument();
        expect(screen.getByText('High Description')).toBeInTheDocument();
    });

    it('displays community score', () => {
        render(<Inspector {...defaultProps} />);
        expect(screen.getByText('4.2')).toBeInTheDocument();
        expect(screen.getByText('Community Score')).toBeInTheDocument();
    });

    it('calls onClose when close button clicked', () => {
        render(<Inspector {...defaultProps} />);
        const closeBtn = screen.getByTestId('icon-close').parentElement;
        fireEvent.click(closeBtn);
        expect(defaultProps.onClose).toHaveBeenCalled();
    });

    it('allows RFC submission when authenticated', () => {
        render(<Inspector {...defaultProps} />);
        fireEvent.click(screen.getByText('Submit RFC Proposal'));
        expect(defaultProps.onSubmitRFC).toHaveBeenCalled();
    });

    it('disables RFC submission when unauthenticated', () => {
        render(<Inspector {...defaultProps} user={null} />);
        const submitBtn = screen.getByText('Submit RFC Proposal').closest('button');
        expect(submitBtn).toBeDisabled();
    });

    it('fetches discussion count on load', async () => {
        render(<Inspector {...defaultProps} />);

        await waitFor(() => {
            // Check if discussion count logic was triggered (mock returns 5)
            // The button text should contain "(5)"
            expect(screen.getByText(/View Discussion/)).toHaveTextContent('(5)');
        });
    });
});
