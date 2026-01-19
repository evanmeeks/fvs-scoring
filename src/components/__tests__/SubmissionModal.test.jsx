import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import SubmissionModal from '../SubmissionModal';

// Mock Icon to avoid rendering issues
vi.mock('../Icon', () => ({
    default: ({ name }) => <span data-testid={`icon-${name}`}>{name}</span>
}));

describe('SubmissionModal', () => {
    const mockOnSubmit = vi.fn();
    const mockOnClose = vi.fn();
    const mockUser = { id: 'user-1' };

    it('renders correctly in RFC mode', () => {
        render(
            <SubmissionModal
                isOpen={true}
                user={mockUser}
                initialMode="rfc"
                metricId="1"
                metricName="Test Metric"
                onSubmit={mockOnSubmit}
                onClose={mockOnClose}
            />
        );

        expect(screen.getByText('Submit RFC Proposal')).toBeInTheDocument();
        expect(screen.getByLabelText(/Target Metric/i)).toBeInTheDocument();
        expect(screen.getByLabelText(/Rationale \/ Data/i)).toBeInTheDocument();
    });

    it('renders correctly in New Metric mode', () => {
        render(
            <SubmissionModal
                isOpen={true}
                user={mockUser}
                initialMode="new-metric"
                onSubmit={mockOnSubmit}
                onClose={mockOnClose}
            />
        );

        // Debug assertions
        // If this fails, it means mode is stuck on RFC
        const rfcTitle = screen.queryByText(/Submit RFC Proposal/i);
        if (rfcTitle) {
            console.log("Found RFC title when expecting New Metric title. Mode prop ignored?");
        }

        const elements = screen.getAllByText(/Propose New Metric/i);
        expect(elements.length).toBeGreaterThan(0);
        expect(elements[0]).toBeInTheDocument();
        expect(screen.getByPlaceholderText(/e.g., Source Attribution Quality/i)).toBeInTheDocument();
    });

    it('submits data correctly for RFC', () => {
        render(
            <SubmissionModal
                isOpen={true}
                user={mockUser}
                initialMode="rfc"
                metricId="1"
                onSubmit={mockOnSubmit}
                onClose={mockOnClose}
            />
        );

        // Fill rationale
        fireEvent.change(screen.getByLabelText(/Rationale \/ Data/i), {
            target: { value: 'This is my rationale' }
        });

        // Click submit
        fireEvent.click(screen.getByText('Submit to Ledger'));

        expect(mockOnSubmit).toHaveBeenCalledWith(
            expect.objectContaining({
                targetMetric: "1",
                rationale: 'This is my rationale',
                contributionType: 'RFC (Request for Comment)'
            }),
            'rfc'
        );
    });

    it('submits data correctly for New Metric', () => {
        render(
            <SubmissionModal
                isOpen={true}
                user={mockUser}
                initialMode="new-metric"
                onSubmit={mockOnSubmit}
                onClose={mockOnClose}
            />
        );

        // Fill Name
        fireEvent.change(screen.getByPlaceholderText('e.g., Source Attribution Quality'), {
            target: { value: 'My New Metric' }
        });

        // Fill Question
        fireEvent.change(screen.getByPlaceholderText('e.g., How well are sources cited and attributed?'), {
            target: { value: 'Is it good?' }
        });

        // Click submit
        fireEvent.click(screen.getByText('Submit to Ledger'));

        expect(mockOnSubmit).toHaveBeenCalledWith(
            expect.objectContaining({
                metricName: 'My New Metric',
                metricQuestion: 'Is it good?'
            }),
            'new-metric'
        );
    });

    it('disables submit if user not logged in', () => {
        render(
            <SubmissionModal
                isOpen={true}
                user={null}
                initialMode="rfc"
                onSubmit={mockOnSubmit}
                onClose={mockOnClose}
            />
        );

        expect(screen.getByText('Login to Submit')).toBeDisabled();
    });
});
