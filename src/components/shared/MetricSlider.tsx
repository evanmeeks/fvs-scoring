/**
 * Metric Slider Component
 * Enhanced slider with 1-5 discrete steps
 */

import type { ScoreValue, CommunityConsensus } from '../../types';

interface MetricSliderProps {
    label: string;
    value: ScoreValue; // 1-5
    onChange: (val: ScoreValue) => void;
    description: string;
    color?: 'green' | 'blue' | 'red' | 'yellow';
    minLabel?: string;
    maxLabel?: string;
    consensus?: CommunityConsensus;
    showConsensus?: boolean;
}

export function MetricSlider({
    label,
    value,
    onChange,
    description,
    color = 'green',
    minLabel = 'Low',
    maxLabel = 'High',
    // consensus, // Unused
    // showConsensus = false, // Unused
}: MetricSliderProps) {
    // Map score value (1-5) to percentage (0-100)
    const valueToPercent = (score: ScoreValue): number => ((score - 1) / 4) * 100;
    const percentToValue = (percent: number): ScoreValue => {
        const score = Math.round((percent / 100) * 4) + 1;
        return Math.max(1, Math.min(5, score)) as ScoreValue;
    };

    const getColorClass = (c: string) => {
        switch (c) {
            case 'blue':
                return 'bg-blue-500 text-blue-500';
            case 'red':
                return 'bg-red-500 text-red-500';
            case 'yellow':
                return 'bg-yellow-500 text-yellow-500';
            default:
                return 'bg-green-500 text-green-500';
        }
    };

    const colorBase = getColorClass(color);
    const textColor = colorBase.split(' ')[1];
    const bgColor = colorBase.split(' ')[0];

    const percent = valueToPercent(value);

    return (
        <div className="mb-6 group">
            <div className="flex justify-between items-end mb-2">
                <div>
                    <h4 className="text-xs font-mono tracking-widest text-gray-400 uppercase">
                        {label}
                    </h4>
                    <p className="text-[10px] text-gray-600 mt-1 max-w-[250px] leading-tight">
                        {description}
                    </p>
                </div>
                <div className="text-right">
                    <div className="text-[10px] text-gray-500">YOUR SCORE</div>
                    <span className={`text-xl font-mono font-bold ${textColor}`}>
                        {value}
                    </span>
                </div>
            </div>

            <div className="relative h-8 flex items-center">
                {/* Track */}
                <div className="absolute w-full h-1 bg-gray-800 rounded-full overflow-hidden">
                    {/* User score bar */}
                    <div
                        className={`absolute h-full ${bgColor} opacity-30 transition-all duration-300`}
                        style={{ width: `${percent}%` }}
                    ></div>
                </div>

                {/* Input */}
                <input
                    type="range"
                    min="0"
                    max="100"
                    step="25" // 5 discrete steps: 0, 25, 50, 75, 100
                    value={percent}
                    onChange={(e) => onChange(percentToValue(parseFloat(e.target.value)))}
                    className="relative w-full h-8 opacity-0 cursor-pointer z-10"
                />

                {/* Score markers (1-5) */}
                <div className="absolute w-full pointer-events-none flex justify-between px-0">
                    {[1, 2, 3, 4, 5].map((score) => {
                        const scorePercent = valueToPercent(score as ScoreValue);
                        const isActive = score === value;
                        return (
                            <div
                                key={score}
                                className="flex flex-col items-center"
                                style={{ position: 'absolute', left: `${scorePercent}%`, transform: 'translateX(-50%)' }}
                            >
                                <div
                                    className={`w-3 h-3 rounded-full border-2 transition-all ${isActive
                                        ? `${bgColor} border-black shadow-[0_0_10px_rgba(0,255,65,0.5)]`
                                        : 'bg-gray-700 border-gray-600'
                                        }`}
                                ></div>
                                <div className={`text-[10px] mt-1 font-mono ${isActive ? textColor : 'text-gray-600'}`}>
                                    {score}
                                </div>
                            </div>
                        );
                    })}
                </div>
            </div>

            {/* Min/Max labels */}
            <div className="mt-2 flex justify-between text-[10px] text-gray-600 font-mono px-1">
                <span>{minLabel}</span>
                <span>{maxLabel}</span>
            </div>
        </div>
    );
}
