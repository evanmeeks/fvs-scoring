 
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useMemo } from 'react';
import { useApp } from '../../../context/AppContext';
import { Radar, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ResponsiveContainer } from 'recharts';
// import { FVS_METRICS as STATIC_METRICS } from '../../../data/metrics'; // Removed

export const ScorecardPanel = () => {
    const {
        activeTarget,
        scores,
        totalScore,
        FVS_METRICS
    } = useApp();

    // Score scale: 1-5 per metric, so total max is FVS_METRICS.length * 5
    const maxPossible = FVS_METRICS.length * 5;
    const normalizedScore = Math.round((totalScore / maxPossible) * 100);

    // Helper to get color class based on score value (1-5 scale per metric)
    const getColorClass = (val: number) => {
        if (val === 1) return 'text-red-500';
        if (val === 2) return 'text-white';
        if (val === 3) return 'text-amber-500';
        if (val === 4) return 'text-white';
        if (val === 5) return 'text-cyan-400';
        return 'text-ops-text-dim';
    };

    // Classification styling based on normalized score
    const getClassification = () => {
        if (normalizedScore === 0) {
            return { label: 'Awaiting Data', color: 'text-ops-text-dim', chartColor: '#52525b', icon: 'hourglass_empty', iconBg: 'bg-ops-text-dim' };
        }
        if (normalizedScore <= 25) {
            return { label: 'NARRATIVE OCCUPATION', color: 'text-red-500', chartColor: '#ef4444', icon: 'block', iconBg: 'bg-red-600' };
        }
        if (normalizedScore <= 50) {
            return { label: 'AMBIGUOUS / MIXED UTILITY', color: 'text-orange-500', chartColor: '#f97316', icon: 'warning', iconBg: 'bg-orange-500' };
        }
        if (normalizedScore <= 75) {
            return { label: 'LEGITIMATE DISCLOSURE', color: 'text-yellow-400', chartColor: '#facc15', icon: 'check_circle', iconBg: 'bg-yellow-400' };
        }
        if (normalizedScore <= 90) {
            return { label: 'HIGH-VALUE DIRECTIONAL', color: 'text-cyan-400', chartColor: '#22d3ee', icon: 'verified', iconBg: 'bg-cyan-500' };
        }
        return { label: 'STRATEGIC DISCLOSURE EVENT', color: 'text-white', chartColor: '#ffffff', icon: 'stars', iconBg: 'bg-white', iconTextColor: 'text-black' };
    };

    const classification = getClassification();

    // Radar Data Calculation - map to actual metric categories
    const radarData = useMemo(() => {
        const catMap: Record<string, string[]> = {
            'Verifiability': ['1', '3'],      // Specificity, Actionability
            'Integrity': ['5', '6', '7', '10'], // Attribution, Risk, Myth Resistance, Intel Discipline
            'Strategy': ['8', '9'],            // Power Targeting, Timing
            'Quality': ['2', '4'],             // Causal Direction, Novelty
            'Momentum': ['3', '4', '8']        // Cross-category impact indicators
        };

        return Object.keys(catMap).map(category => {
            const ids = catMap[category];
            const sum = ids.reduce((acc, id) => acc + (Number(scores[id]) || 0), 0);
            const avg = ids.length ? sum / ids.length : 0; // Already 1-5 scale

            return {
                subject: category,
                A: avg,
                fullMark: 5
            };
        });
    }, [scores]);

    return (
        <div className="animate-fade-in">
            <div className="max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8 grid grid-cols-1 lg:grid-cols-12 gap-6 lg:gap-8">

                {/* Left Column: Target Info + Metrics Grid */}
                <div className="lg:col-span-8 space-y-6">

                    {/* Target Panel - Enhanced styling */}
                    <div className="bg-ops-panel/80 backdrop-blur border border-ops-border rounded-xl p-6 relative overflow-hidden group">
                        {/* Decorative glow */}
                        <div className="absolute top-0 right-0 w-40 h-40 bg-ops-accent/5 rounded-full blur-3xl pointer-events-none"></div>
                        <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-emerald-500/5 rounded-full blur-3xl pointer-events-none"></div>

                        <h2 className="text-xl font-bold text-white mb-4">Analysis Target</h2>

                        {/* Target Name Input with Verified Badge */}
                        <div className="relative">
                            <input
                                type="text"
                                readOnly
                                value={activeTarget?.name || "No Active Target"}
                                className="w-full bg-ops-black/80 border border-ops-border rounded-lg px-4 py-3 pr-24 text-white font-mono focus:border-ops-accent outline-none transition"
                            />
                            {activeTarget?.verified && (
                                <span className="absolute right-3 top-1/2 -translate-y-1/2 px-2.5 py-1 text-[10px] font-mono bg-cyan-500/20 text-cyan-400 rounded border border-cyan-500/30 uppercase tracking-wider">
                                    Verified
                                </span>
                            )}
                        </div>

                        {/* Target Metadata Grid */}
                        {activeTarget && (
                            <div className="grid grid-cols-3 gap-6 mt-5 pt-5 border-t border-ops-border/50">
                                <div>
                                    <div className="text-[10px] font-mono text-ops-text-dim uppercase tracking-wider mb-1">Case ID</div>
                                    <div className="text-sm font-mono text-white">{activeTarget.caseId || 'N/A'}</div>
                                </div>
                                <div>
                                    <div className="text-[10px] font-mono text-ops-text-dim uppercase tracking-wider mb-1">Origin</div>
                                    <div className="text-sm font-mono text-white">{activeTarget.origin || 'N/A'}</div>
                                </div>
                                <div>
                                    <div className="text-[10px] font-mono text-ops-text-dim uppercase tracking-wider mb-1">Date</div>
                                    <div className="text-sm font-mono text-white">
                                        {activeTarget.claim_date ? new Date(activeTarget.claim_date as string).toLocaleDateString() : 'N/A'}
                                    </div>
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Metrics Grid - Matching Reference Design */}
                    <div className="grid grid-cols-1 gap-0 divide-y divide-ops-border border border-ops-border rounded-xl overflow-hidden bg-ops-panel/60 backdrop-blur">
                        {FVS_METRICS.map((metric) => {
                            // Fallback to static for rich criteria
                            const criteria = (metric as any).scoringCriteria || [];

                            const val = Number(scores[metric.id]) || 0;
                            const colorClass = getColorClass(val);
                            const lowLabel = criteria[0]?.label || '';
                            const highLabel = criteria[4]?.label || '';

                            return (
                                <div
                                    key={metric.id}
                                    className="p-6 hover:bg-white/5 transition-colors group"
                                >
                                    {/* Header Row */}
                                    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-3">
                                        <div>
                                            <span className="text-xs font-mono text-ops-accent mb-1 block">
                                                METRIC {metric.id.toString().padStart(2, '0')}
                                            </span>
                                            <h4 className="text-white font-bold text-lg">
                                                {metric.name}
                                            </h4>
                                        </div>
                                        <div className="flex items-center gap-3">
                                            <div className="text-center w-12">
                                                <span className={`text-2xl font-black block ${colorClass}`}>
                                                    {val || '-'}
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Question */}
                                    <p className="text-gray-400 text-sm mb-4 border-l-2 border-gray-700 pl-3 italic">
                                        "{(metric as any).coreQuestion || (metric as any).question || metric.description}"
                                    </p>

                                    {/* Slider with Labels */}
                                    <div className="flex items-center gap-4">
                                        <span className="text-[10px] font-mono text-gray-500 uppercase w-24 text-right hidden sm:block">
                                            {lowLabel}
                                        </span>
                                        <input
                                            type="range"
                                            min="1"
                                            max="5"
                                            value={val || 1}
                                            step="1"
                                            readOnly
                                            className="flex-grow h-1 bg-zinc-800 rounded-full appearance-none cursor-default [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-4 [&::-webkit-slider-thumb]:h-4 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-ops-accent"
                                        />
                                        <span className="text-[10px] font-mono text-ops-accent uppercase w-24 hidden sm:block">
                                            {highLabel}
                                        </span>
                                    </div>
                                </div>
                            );
                        })}
                    </div>
                </div>

                {/* Right Column: Score Dashboard */}
                <div className="lg:col-span-4 space-y-6">
                    <div className="lg:sticky lg:top-24 space-y-6">

                        {/* Total Score Panel - Stunning Visual */}
                        <div className="bg-ops-panel/80 backdrop-blur border border-ops-border rounded-xl p-6 relative overflow-hidden">
                            {/* Background decorative elements */}
                            <div className="absolute top-0 right-0 w-48 h-48 bg-ops-accent/10 rounded-full blur-3xl pointer-events-none"></div>
                            <div className="absolute -bottom-10 -left-10 w-40 h-40 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none"></div>

                            {/* Decorative circuit pattern */}
                            <svg className="absolute right-4 top-4 w-20 h-20 text-ops-border opacity-30 pointer-events-none" viewBox="0 0 100 100">
                                <path d="M10 50 H40 V20 H70" stroke="currentColor" fill="none" strokeWidth="1" />
                                <path d="M30 70 H60 V40 H90" stroke="currentColor" fill="none" strokeWidth="1" />
                                <circle cx="40" cy="20" r="3" fill="currentColor" />
                                <circle cx="60" cy="40" r="3" fill="currentColor" />
                            </svg>

                            <div className="relative z-10">
                                <h3 className="text-[10px] font-mono uppercase text-ops-text-dim tracking-[0.2em] mb-2">
                                    Total Directional Score
                                </h3>

                                <div className="flex items-baseline gap-3">
                                    <span
                                        className={`text-7xl font-black font-mono tracking-tighter transition-colors duration-500 ${classification.color}`}
                                        style={{
                                            textShadow: normalizedScore > 0 ? `0 0 30px ${classification.chartColor}40, 0 0 60px ${classification.chartColor}20` : 'none'
                                        }}
                                    >
                                        {normalizedScore}
                                    </span>
                                    <span className="text-2xl text-ops-text-dim font-mono">/ 100</span>
                                </div>

                                {/* Progress Bar with gradient */}
                                <div className="w-full bg-ops-black h-2.5 rounded-full mt-6 overflow-hidden border border-ops-border">
                                    <div
                                        className="h-full rounded-full transition-all duration-700 ease-out"
                                        style={{ width: `${normalizedScore}%`, backgroundColor: classification.chartColor }}
                                    ></div>
                                </div>

                                {/* Classification */}
                                {/* Classification */}
                                <div className="mt-6 pt-5 border-t border-ops-border/50 flex justify-between items-center">
                                    <div>
                                        <h4 className="text-[10px] font-mono uppercase text-ops-text-dim tracking-[0.2em] mb-2">
                                            Classification
                                        </h4>
                                        <div className={`text-xl font-bold transition-colors duration-500 ${classification.color} ${normalizedScore > 0 ? 'animate-pulse' : ''}`}>
                                            {classification.label}
                                        </div>
                                    </div>
                                    <div className={`h-10 w-10 rounded flex items-center justify-center ${classification.iconBg}`}>
                                        <span className={`material-symbols-outlined ${classification.iconTextColor || 'text-white'}`}>
                                            {classification.icon}
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Radar Chart Panel */}
                        <div className="bg-ops-panel/80 backdrop-blur border border-ops-border rounded-xl p-5 relative overflow-hidden">
                            {/* Subtle radial background */}
                            <div className="absolute inset-0 bg-gradient-radial from-ops-accent/5 via-transparent to-transparent pointer-events-none"></div>

                            <h3 className="text-[10px] font-mono uppercase text-ops-text-dim tracking-[0.2em] mb-4 relative z-10">
                                Dimensional Analysis
                            </h3>

                            <div className="aspect-square relative flex items-center justify-center">
                                <ResponsiveContainer width="100%" height="100%">
                                    <RadarChart cx="50%" cy="50%" outerRadius="75%" data={radarData}>
                                        <PolarGrid gridType="polygon" stroke="#27272a" strokeOpacity={0.6} />
                                        <PolarAngleAxis
                                            dataKey="subject"
                                            tick={{ fill: '#a1a1aa', fontSize: 10, fontFamily: 'ui-monospace' }}
                                        />
                                        <PolarRadiusAxis angle={30} domain={[0, 5]} tick={false} axisLine={false} />
                                        <Radar
                                            name="Disclosure Profile"
                                            dataKey="A"
                                            stroke={classification.chartColor}
                                            strokeWidth={2}
                                            fill={classification.chartColor}
                                            fillOpacity={0.15}
                                        />
                                    </RadarChart>
                                </ResponsiveContainer>
                            </div>

                            {/* Category Legend */}
                            <div className="grid grid-cols-2 gap-3 mt-4 pt-4 border-t border-ops-border/50 relative z-10">
                                <div className="flex items-center gap-2">
                                    <span className="w-2 h-2 bg-cyan-400 rounded-full"></span>
                                    <span className="text-[10px] font-mono text-ops-text-dim">VERIFIABILITY</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className="w-2 h-2 bg-emerald-400 rounded-full"></span>
                                    <span className="text-[10px] font-mono text-ops-text-dim">INTEGRITY</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className="w-2 h-2 bg-amber-400 rounded-full"></span>
                                    <span className="text-[10px] font-mono text-ops-text-dim">QUALITY</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <span className="w-2 h-2 bg-purple-400 rounded-full"></span>
                                    <span className="text-[10px] font-mono text-ops-text-dim">STRATEGY</span>
                                </div>
                            </div>
                        </div>

                        {/* Login CTA Panel */}
                        <div className="bg-gradient-to-r from-ops-accent/10 to-emerald-500/10 border border-ops-accent/30 rounded-xl p-6 relative overflow-hidden">
                            <div className="absolute inset-0 bg-gradient-to-r from-ops-accent/5 to-emerald-500/5 pointer-events-none"></div>

                            <div className="relative z-10 text-center">
                                <button className="w-full flex items-center justify-center gap-3 bg-ops-accent text-ops-black font-bold py-4 px-6 rounded-lg hover:bg-cyan-400 transition-all duration-300 group shadow-lg shadow-ops-accent/20 hover:shadow-ops-accent/40">
                                    <span className="material-symbols-outlined text-xl group-hover:scale-110 transition-transform">login</span>
                                    LOGIN TO SCORE
                                </button>
                                <p className="text-[10px] font-mono text-ops-text-dim mt-3 uppercase tracking-wider">
                                    Authentication required for ledger entry
                                </p>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    );
};
