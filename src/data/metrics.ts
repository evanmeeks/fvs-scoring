// Forecast Audit Protocol: Standard 20 Metrics for Prediction Market Forecast Evaluation
// This is the authoritative local definition - matches database schema
// Database is primary source of truth; this serves as fallback/reference

export type ScoringCriterion = {
  score: number;
  label: string;
  description: string;
};

export type MetricDefinition = {
  id: number;
  name: string;
  category: string;
  question: string;
  low: string;
  high: string;
  scoringCriteria: ScoringCriterion[];
};

export const FVS_METRICS: MetricDefinition[] = [
  // PRECISION (1-5): Core Forecast Quality
  {
    id: 1, name: "Forecast Specificity", category: "PRECISION",
    question: "Does the forecast make concrete, measurable predictions with defined outcomes?",
    low: "Vague or unfalsifiable", high: "Precise conditions and measurable criteria",
    scoringCriteria: [
      { score: 1, label: "Unfalsifiable", description: "Vague prediction with no measurable criteria or defined outcomes" },
      { score: 2, label: "Loosely defined", description: "General direction stated but lacks specific thresholds or conditions" },
      { score: 3, label: "Partially specific", description: "Some measurable elements but key variables remain undefined" },
      { score: 4, label: "Well-defined", description: "Clear outcome criteria with specific thresholds and conditions" },
      { score: 5, label: "Operationally precise", description: "Exact measurable criteria, resolution conditions, and edge cases defined" },
    ],
  },
  {
    id: 2, name: "Causal Model", category: "PRECISION",
    question: "Does the forecast articulate a clear causal mechanism for the predicted outcome?",
    low: "No causal reasoning", high: "Clear cause → effect → outcome chain",
    scoringCriteria: [
      { score: 1, label: "No mechanism", description: "Pure assertion with no causal reasoning or model" },
      { score: 2, label: "Implied causation", description: "Vague or hand-wavy causal logic" },
      { score: 3, label: "Partial model", description: "Some causal links explained but chain is incomplete" },
      { score: 4, label: "Strong model", description: "Clear causal chain with identified drivers and transmission mechanisms" },
      { score: 5, label: "Full causal framework", description: "Explicit cause → effect → outcome with feedback loops and contingencies" },
    ],
  },
  {
    id: 3, name: "Actionability", category: "PRECISION",
    question: "Can decision-makers, analysts, or investors act on this forecast?",
    low: "No actionable insight", high: "Clear decision-relevant implications",
    scoringCriteria: [
      { score: 1, label: "No action possible", description: "Too vague or abstract to inform any decision" },
      { score: 2, label: "Minimal utility", description: "Slight directional signal but insufficient for action" },
      { score: 3, label: "Moderately actionable", description: "Some decision-relevant implications identifiable" },
      { score: 4, label: "Highly actionable", description: "Clear implications for portfolio, policy, or strategy decisions" },
      { score: 5, label: "Directly tradeable", description: "Specific enough to immediately inform trading, hedging, or strategic action" },
    ],
  },
  {
    id: 4, name: "Information Novelty", category: "PRECISION",
    question: "Does this forecast provide meaningfully new predictive insight?",
    low: "Recycled consensus / obvious", high: "Novel analysis or contrarian with basis",
    scoringCriteria: [
      { score: 1, label: "Consensus echo", description: "Restates widely known consensus with no new insight" },
      { score: 2, label: "Minor reframe", description: "Slight variation on existing analysis" },
      { score: 3, label: "Partial novelty", description: "Mix of known factors with some new analytical angle" },
      { score: 4, label: "Substantially novel", description: "New data, framework, or non-obvious connection identified" },
      { score: 5, label: "Genuine edge", description: "Unique information or analytical framework not available elsewhere" },
    ],
  },
  {
    id: 5, name: "Source Quality", category: "PRECISION",
    question: "Are data sources, models, and prior forecasts properly cited?",
    low: "No sourcing", high: "Clear data lineage and methodology",
    scoringCriteria: [
      { score: 1, label: "No sources", description: "No data cited, no methodology referenced" },
      { score: 2, label: "Weak sourcing", description: "Vague references to unnamed sources or models" },
      { score: 3, label: "Partial sourcing", description: "Some data cited but gaps in methodology disclosure" },
      { score: 4, label: "Well-sourced", description: "Key data sources and models identified and cited" },
      { score: 5, label: "Full data lineage", description: "Complete source chain, model documentation, and reproducible methodology" },
    ],
  },

  // CALIBRATION (6-10): Forecaster & Methodology Quality
  {
    id: 6, name: "Forecaster Track Record", category: "CALIBRATION",
    question: "Does the forecaster have a documented calibration history?",
    low: "No track record", high: "Verified calibration history",
    scoringCriteria: [
      { score: 1, label: "Unknown", description: "No public forecast history or calibration data" },
      { score: 2, label: "Limited record", description: "Few documented forecasts, no calibration metrics" },
      { score: 3, label: "Some history", description: "Track record exists but calibration is mixed or unverified" },
      { score: 4, label: "Good track record", description: "Documented history with reasonable calibration across domains" },
      { score: 5, label: "Elite calibration", description: "Verified calibration metrics (Brier scores), superforecaster-level track record" },
    ],
  },
  {
    id: 7, name: "Resistance to Bias", category: "CALIBRATION",
    question: "Is the forecast grounded in data rather than narrative or ideology?",
    low: "Narrative-driven / wishful thinking", high: "Evidence-based, bias-acknowledged",
    scoringCriteria: [
      { score: 1, label: "Ideological", description: "Forecast driven by narrative, identity, or wishful thinking" },
      { score: 2, label: "Bias-heavy", description: "Data cherry-picked to support predetermined conclusion" },
      { score: 3, label: "Mixed", description: "Some evidence-based reasoning but notable blind spots" },
      { score: 4, label: "Mostly objective", description: "Data-driven with acknowledged limitations and biases" },
      { score: 5, label: "Debiased analysis", description: "Systematic bias mitigation, considers base rates, acknowledges uncertainty" },
    ],
  },
  {
    id: 8, name: "Market Signal Alignment", category: "CALIBRATION",
    question: "Does the forecast align with or credibly diverge from prediction market prices?",
    low: "Ignores market signals", high: "Engages with market data explicitly",
    scoringCriteria: [
      { score: 1, label: "Market-blind", description: "Makes no reference to existing market prices or consensus" },
      { score: 2, label: "Loosely aware", description: "Vague awareness of market consensus but no engagement" },
      { score: 3, label: "References markets", description: "Cites market prices but doesn't explain divergence or alignment" },
      { score: 4, label: "Market-engaged", description: "Explicitly compares to market prices with reasoning for any divergence" },
      { score: 5, label: "Alpha-generating", description: "Deep market analysis with specific edge thesis explaining mispricing" },
    ],
  },
  {
    id: 9, name: "Timing Precision", category: "CALIBRATION",
    question: "Does the forecast specify a clear time horizon and resolution criteria?",
    low: "Open-ended / no timeline", high: "Precise resolution date and criteria",
    scoringCriteria: [
      { score: 1, label: "No timeline", description: "Open-ended prediction with no resolution timeframe" },
      { score: 2, label: "Vague horizon", description: "General timeframe (years) without specific resolution criteria" },
      { score: 3, label: "Approximate", description: "Reasonable timeframe with partial resolution criteria" },
      { score: 4, label: "Well-timed", description: "Clear horizon with defined resolution date and conditions" },
      { score: 5, label: "Precision-timed", description: "Exact resolution date, interim checkpoints, and unambiguous success criteria" },
    ],
  },
  {
    id: 10, name: "Methodological Rigor", category: "CALIBRATION",
    question: "Is the forecasting methodology transparent and reproducible?",
    low: "No methodology described", high: "Transparent, reproducible approach",
    scoringCriteria: [
      { score: 1, label: "Black box", description: "No methodology described, pure gut feeling or assertion" },
      { score: 2, label: "Informal reasoning", description: "Some logic shown but not systematic or reproducible" },
      { score: 3, label: "Partial methodology", description: "Framework described but key assumptions undisclosed" },
      { score: 4, label: "Rigorous", description: "Clear methodology with stated assumptions and model structure" },
      { score: 5, label: "Fully reproducible", description: "Complete methodology, open model, stated priors, and sensitivity analysis" },
    ],
  },

  // INTEGRITY (11-15): Transparency & Verifiability
  {
    id: 11, name: "Update Responsiveness", category: "INTEGRITY",
    question: "Does the forecaster update predictions in response to new evidence?",
    low: "Ignores contradicting data", high: "Explicitly updates with new evidence",
    scoringCriteria: [
      { score: 1, label: "Immovable", description: "Never updates regardless of new evidence" },
      { score: 2, label: "Reluctant updater", description: "Rarely acknowledges contradicting evidence" },
      { score: 3, label: "Occasional updates", description: "Updates sometimes but inconsistently" },
      { score: 4, label: "Responsive", description: "Regularly updates with clear reasoning for changes" },
      { score: 5, label: "Bayesian updater", description: "Systematic updating with explicit reasoning and probability revisions" },
    ],
  },
  {
    id: 12, name: "Incentive Transparency", category: "INTEGRITY",
    question: "Are financial positions or conflicts of interest disclosed?",
    low: "Hidden incentives / talking book", high: "Full disclosure of positions",
    scoringCriteria: [
      { score: 1, label: "Hidden book", description: "Undisclosed financial interests likely influencing forecast" },
      { score: 2, label: "Vague disclosure", description: "Generic disclaimers without specific position disclosure" },
      { score: 3, label: "Partial disclosure", description: "Some positions disclosed but not comprehensive" },
      { score: 4, label: "Good disclosure", description: "Material positions and conflicts clearly stated" },
      { score: 5, label: "Full transparency", description: "Complete position disclosure, conflict analysis, and interest separation" },
    ],
  },
  {
    id: 13, name: "Signal Density", category: "INTEGRITY",
    question: "What is the signal-to-noise ratio of the forecast?",
    low: "Padded with filler", high: "High-density, precise analysis",
    scoringCriteria: [
      { score: 1, label: "All noise", description: "Padded with filler, hedging, and irrelevant content" },
      { score: 2, label: "Mostly noise", description: "Key signal buried in excessive commentary" },
      { score: 3, label: "Mixed signal", description: "Some useful analysis mixed with unnecessary content" },
      { score: 4, label: "High signal", description: "Focused analysis with minimal noise" },
      { score: 5, label: "Pure signal", description: "Every element adds predictive value, zero filler" },
    ],
  },
  {
    id: 14, name: "External Verifiability", category: "INTEGRITY",
    question: "Can the forecast resolution be independently verified?",
    low: "Subjective / unfalsifiable", high: "Clear verification criteria",
    scoringCriteria: [
      { score: 1, label: "Unfalsifiable", description: "No way to independently verify the outcome" },
      { score: 2, label: "Subjective resolution", description: "Resolution depends on interpretation or judgment calls" },
      { score: 3, label: "Partially verifiable", description: "Some elements verifiable but resolution has ambiguity" },
      { score: 4, label: "Largely verifiable", description: "Clear data sources for resolution with minor edge cases" },
      { score: 5, label: "Independently verifiable", description: "Unambiguous resolution criteria using public, third-party data" },
    ],
  },
  {
    id: 15, name: "Resolution Direction", category: "INTEGRITY",
    question: "Does the forecast drive toward a clear resolution or perpetual ambiguity?",
    low: "Moving goalposts", high: "Defined success/failure criteria",
    scoringCriteria: [
      { score: 1, label: "Moving goalposts", description: "Resolution criteria shift to avoid being proven wrong" },
      { score: 2, label: "Ambiguous outcome", description: "Unclear what constitutes success or failure" },
      { score: 3, label: "Partial clarity", description: "Some resolution criteria but room for goalpost movement" },
      { score: 4, label: "Clear resolution", description: "Well-defined success/failure with minimal ambiguity" },
      { score: 5, label: "Binary resolution", description: "Unambiguous yes/no outcome with pre-committed criteria" },
    ],
  },

  // VALUE (16-20): Impact & Analysis Quality
  {
    id: 16, name: "Independent Analysis", category: "VALUE",
    question: "Is the forecast derived independently or borrowed from echo chambers?",
    low: "Herding / groupthink", high: "Independent reasoning documented",
    scoringCriteria: [
      { score: 1, label: "Pure herding", description: "Copying consensus without independent analysis" },
      { score: 2, label: "Echo chamber", description: "Mostly derived from a single community or source" },
      { score: 3, label: "Mixed sources", description: "Some independent thinking but heavily influenced by consensus" },
      { score: 4, label: "Largely independent", description: "Clear independent reasoning with acknowledged influences" },
      { score: 5, label: "Fully independent", description: "Original analysis with documented reasoning chain, diverges from consensus where warranted" },
    ],
  },
  {
    id: 17, name: "Base Rate Awareness", category: "VALUE",
    question: "Are historical base rates and precedents properly incorporated?",
    low: "Ignores base rates", high: "Calibrated against historical data",
    scoringCriteria: [
      { score: 1, label: "Base rate blind", description: "No reference to historical frequency or precedent" },
      { score: 2, label: "Anecdotal", description: "Cherry-picked examples without systematic base rate analysis" },
      { score: 3, label: "Partial awareness", description: "Some base rate consideration but not systematic" },
      { score: 4, label: "Well-calibrated", description: "Explicit base rate analysis with appropriate adjustment" },
      { score: 5, label: "Reference class mastery", description: "Rigorous reference class forecasting with multiple historical analogues" },
    ],
  },
  {
    id: 18, name: "Stress Testing", category: "VALUE",
    question: "Does the forecast hold up under adversarial questioning and edge cases?",
    low: "Fragile under scrutiny", high: "Robust across scenarios",
    scoringCriteria: [
      { score: 1, label: "Fragile", description: "Collapses under basic questioning or alternative scenarios" },
      { score: 2, label: "Weak resilience", description: "Handles soft questions but fails adversarial probing" },
      { score: 3, label: "Moderate robustness", description: "Survives some stress tests but has notable vulnerabilities" },
      { score: 4, label: "Robust", description: "Holds up well across most scenarios and edge cases" },
      { score: 5, label: "Anti-fragile", description: "Strengthens under scrutiny, pre-addresses objections, considers tail risks" },
    ],
  },
  {
    id: 19, name: "Strategic Coherence", category: "VALUE",
    question: "Is the forecast part of a coherent analytical framework?",
    low: "One-off / reactive", high: "Integrated into systematic approach",
    scoringCriteria: [
      { score: 1, label: "Reactive", description: "One-off prediction with no broader analytical framework" },
      { score: 2, label: "Loosely connected", description: "Some thematic connection to other work but not systematic" },
      { score: 3, label: "Partially integrated", description: "Part of a framework but with gaps or inconsistencies" },
      { score: 4, label: "Coherent framework", description: "Well-integrated into a consistent analytical approach" },
      { score: 5, label: "Systematic program", description: "Part of a rigorous, documented forecasting program with cross-validated models" },
    ],
  },
  {
    id: 20, name: "Net Predictive Value", category: "VALUE",
    question: "Does this forecast meaningfully reduce uncertainty about the outcome?",
    low: "Adds noise", high: "Meaningfully narrows probability range",
    scoringCriteria: [
      { score: 1, label: "Net negative", description: "Adds noise, increases confusion, or misleads" },
      { score: 2, label: "Marginal value", description: "Slightly informative but doesn't meaningfully reduce uncertainty" },
      { score: 3, label: "Moderate value", description: "Provides useful signal that somewhat narrows outcome space" },
      { score: 4, label: "High value", description: "Substantially reduces uncertainty with clear probability update" },
      { score: 5, label: "Decision-grade", description: "Dramatically narrows probability range, high-conviction with justification" },
    ],
  },
];

export type QddMetric = (typeof FVS_METRICS)[number];
