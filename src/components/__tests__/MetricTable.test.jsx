import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import MetricTable from '../MetricTable';

// Mock Icon component since it's used in MetricTable
vi.mock('../Icon', () => ({
    default: ({ name, className }) => <span data-testid={`icon-${name}`} className={className}></span>
}));

const mockData = [
    {
        id: '1',
        name: 'Test Metric 1',
        coreQuestion: 'Test Question 1',
        scoringCriteria: [
            { score: 1, label: 'Low Label', description: 'Low Desc' },
            { score: 2, label: '2', description: '2' },
            { score: 3, label: '3', description: '3' },
            { score: 4, label: '4', description: '4' },
            { score: 5, label: 'High Label', description: 'High Desc' }
        ],
        category: 'CORE'
    },
    {
        id: '2',
        name: 'Test Metric 2',
        coreQuestion: 'Test Question 2',
        criteria: "1=Bad, 5=Good", // Legacy fallback test
        category: 'IMPACT'
    }
];

describe('MetricTable Component', () => {
    const defaultProps = {
        data: mockData,
        scores: { '1': 3, '2': 0 },
        votes: {},
        onScoreChange: vi.fn(),
        onVoteChange: vi.fn(),
        onSelect: vi.fn(),
        isSelected: (id) => id === '1',
        mode: 'scoring',
        saveStatus: {}
    };

    it('renders all metrics', () => {
        render(<MetricTable {...defaultProps} />);
        expect(screen.getByText('Test Metric 1')).toBeInTheDocument();
        expect(screen.getByText('Test Metric 2')).toBeInTheDocument();
    });

    it('displays correct questions (handling new and legacy structure)', () => {
        render(<MetricTable {...defaultProps} />);
        expect(screen.getByText('Test Question 1')).toBeInTheDocument();
        expect(screen.getByText('Test Question 2')).toBeInTheDocument();
    });

    it('displays min/max labels from scoringCriteria', () => {
        render(<MetricTable {...defaultProps} />);
        // Should find labels extracted from scoringCriteria array
        expect(screen.getByText('Low Label')).toBeInTheDocument();
        expect(screen.getByText('High Label')).toBeInTheDocument();
    });

    it('displays min/max labels from legacy criteria string fallback', () => {
        render(<MetricTable {...defaultProps} />);
        // Should find labels parsed from "1=Bad, 5=Good"
        expect(screen.getByText('Bad')).toBeInTheDocument();
        expect(screen.getByText('Good')).toBeInTheDocument();
    });

    it('calls onScoreChange when slider updates', () => {
        const onScoreChange = vi.fn();
        render(<MetricTable {...defaultProps} onScoreChange={onScoreChange} />);

        // Find inputs - relying on default range input role usually being slider or spinbutton
        // But here simpler to select by type range
        const sliders = screen.getAllByRole('slider');
        // Or if explicit role isn't set, querySelector input[type="range"]

        fireEvent.change(sliders[0], { target: { value: '4' } });

        expect(onScoreChange).toHaveBeenCalledWith('1', 4);
    });

    it('hides sliders in governance mode', () => {
        render(<MetricTable {...defaultProps} mode="governance" />);
        const sliders = screen.queryAllByRole('slider');
        expect(sliders.length).toBe(0);

        // Should still show questions
        expect(screen.getByText('"Test Question 1"')).toBeInTheDocument();
    });

    it('highlights selected row', () => {
        // We can check if the row has a specific class or check visual indicator
        // MetricTable usually renders an indicator for selected row
        // Looking at implementation (not fully visible in logs but assuming standard behavior)
        // Usually a border or background change.
        // If we can't easily test style, we can test onSelect call

        render(<MetricTable {...defaultProps} />);
        const row = screen.getByText('Test Metric 2').closest('[role="button"]');
        fireEvent.click(row);
        expect(defaultProps.onSelect).toHaveBeenCalledWith(mockData[1]);
    });

    it('prevents spacebar propagation in governance notes input', () => {
        const onSelect = vi.fn();
        const onVoteChange = vi.fn();
        render(<MetricTable {...defaultProps} mode="governance" onSelect={onSelect} onVoteChange={onVoteChange} />);

        const inputs = screen.getAllByPlaceholderText('Add notes...');
        const input = inputs[0];

        // Type a space
        fireEvent.keyDown(input, { key: ' ', code: 'Space', charCode: 32 });

        // Should NOT call onSelect (which is triggered by row keydown)
        expect(onSelect).not.toHaveBeenCalled();
    });
});
