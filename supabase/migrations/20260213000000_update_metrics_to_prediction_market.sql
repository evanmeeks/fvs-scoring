-- Migration: Update all 20 metrics to prediction market forecast evaluation
-- Replaces disclosure-focused metrics with prediction market quality metrics
-- Categories: PRECISION (1-5), CALIBRATION (6-10), INTEGRITY (11-15), VALUE (16-20)

-- Metric 1: Forecast Specificity
UPDATE public.metrics
SET
    name = 'Forecast Specificity',
    category = 'PRECISION',
    question = 'Does the forecast make concrete, measurable predictions with defined outcomes?',
    criteria = 'Vague or unfalsifiable=1, Precise conditions and measurable criteria=5',
    low_description = 'Vague or unfalsifiable prediction',
    high_description = 'Precise conditions and measurable criteria',
    scoring_criteria = '[
      {"score": 1, "label": "Unfalsifiable", "description": "Vague prediction with no measurable criteria or defined outcomes"},
      {"score": 2, "label": "Loosely defined", "description": "General direction stated but lacks specific thresholds or conditions"},
      {"score": 3, "label": "Partially specific", "description": "Some measurable elements but key variables remain undefined"},
      {"score": 4, "label": "Well-defined", "description": "Clear outcome criteria with specific thresholds and conditions"},
      {"score": 5, "label": "Operationally precise", "description": "Exact measurable criteria, resolution conditions, and edge cases defined"}
    ]'::jsonb
WHERE id = 1;

-- Metric 2: Causal Model
UPDATE public.metrics
SET
    name = 'Causal Model',
    category = 'PRECISION',
    question = 'Does the forecast articulate a clear causal mechanism for the predicted outcome?',
    criteria = 'No causal reasoning=1, Clear cause-effect-outcome chain=5',
    low_description = 'No causal reasoning provided',
    high_description = 'Clear cause → effect → outcome chain',
    scoring_criteria = '[
      {"score": 1, "label": "No mechanism", "description": "Pure assertion with no causal reasoning or model"},
      {"score": 2, "label": "Implied causation", "description": "Vague or hand-wavy causal logic"},
      {"score": 3, "label": "Partial model", "description": "Some causal links explained but chain is incomplete"},
      {"score": 4, "label": "Strong model", "description": "Clear causal chain with identified drivers and transmission mechanisms"},
      {"score": 5, "label": "Full causal framework", "description": "Explicit cause → effect → outcome with feedback loops and contingencies"}
    ]'::jsonb
WHERE id = 2;

-- Metric 3: Actionability
UPDATE public.metrics
SET
    name = 'Actionability',
    category = 'PRECISION',
    question = 'Can decision-makers, analysts, or investors act on this forecast?',
    criteria = 'No actionable insight=1, Clear decision-relevant implications=5',
    low_description = 'No actionable insight',
    high_description = 'Clear decision-relevant implications',
    scoring_criteria = '[
      {"score": 1, "label": "No action possible", "description": "Too vague or abstract to inform any decision"},
      {"score": 2, "label": "Minimal utility", "description": "Slight directional signal but insufficient for action"},
      {"score": 3, "label": "Moderately actionable", "description": "Some decision-relevant implications identifiable"},
      {"score": 4, "label": "Highly actionable", "description": "Clear implications for portfolio, policy, or strategy decisions"},
      {"score": 5, "label": "Directly tradeable", "description": "Specific enough to immediately inform trading, hedging, or strategic action"}
    ]'::jsonb
WHERE id = 3;

-- Metric 4: Information Novelty
UPDATE public.metrics
SET
    name = 'Information Novelty',
    category = 'PRECISION',
    question = 'Does this forecast provide meaningfully new predictive insight?',
    criteria = 'Recycled consensus=1, Novel analysis or contrarian with basis=5',
    low_description = 'Recycled consensus or obvious prediction',
    high_description = 'Novel analysis or well-reasoned contrarian view',
    scoring_criteria = '[
      {"score": 1, "label": "Consensus echo", "description": "Restates widely known consensus with no new insight"},
      {"score": 2, "label": "Minor reframe", "description": "Slight variation on existing analysis"},
      {"score": 3, "label": "Partial novelty", "description": "Mix of known factors with some new analytical angle"},
      {"score": 4, "label": "Substantially novel", "description": "New data, framework, or non-obvious connection identified"},
      {"score": 5, "label": "Genuine edge", "description": "Unique information or analytical framework not available elsewhere"}
    ]'::jsonb
WHERE id = 4;

-- Metric 5: Source Quality
UPDATE public.metrics
SET
    name = 'Source Quality',
    category = 'PRECISION',
    question = 'Are data sources, models, and prior forecasts properly cited?',
    criteria = 'No sourcing=1, Clear data lineage and methodology=5',
    low_description = 'No sourcing or data citation',
    high_description = 'Clear data lineage and methodology',
    scoring_criteria = '[
      {"score": 1, "label": "No sources", "description": "No data cited, no methodology referenced"},
      {"score": 2, "label": "Weak sourcing", "description": "Vague references to unnamed sources or models"},
      {"score": 3, "label": "Partial sourcing", "description": "Some data cited but gaps in methodology disclosure"},
      {"score": 4, "label": "Well-sourced", "description": "Key data sources and models identified and cited"},
      {"score": 5, "label": "Full data lineage", "description": "Complete source chain, model documentation, and reproducible methodology"}
    ]'::jsonb
WHERE id = 5;

-- Metric 6: Forecaster Track Record
UPDATE public.metrics
SET
    name = 'Forecaster Track Record',
    category = 'CALIBRATION',
    question = 'Does the forecaster have a documented calibration history?',
    criteria = 'No track record=1, Verified calibration history=5',
    low_description = 'No track record or calibration data',
    high_description = 'Verified calibration history with Brier scores',
    scoring_criteria = '[
      {"score": 1, "label": "Unknown", "description": "No public forecast history or calibration data"},
      {"score": 2, "label": "Limited record", "description": "Few documented forecasts, no calibration metrics"},
      {"score": 3, "label": "Some history", "description": "Track record exists but calibration is mixed or unverified"},
      {"score": 4, "label": "Good track record", "description": "Documented history with reasonable calibration across domains"},
      {"score": 5, "label": "Elite calibration", "description": "Verified calibration metrics (Brier scores), superforecaster-level track record"}
    ]'::jsonb
WHERE id = 6;

-- Metric 7: Resistance to Bias
UPDATE public.metrics
SET
    name = 'Resistance to Bias',
    category = 'CALIBRATION',
    question = 'Is the forecast grounded in data rather than narrative or ideology?',
    criteria = 'Narrative-driven or wishful thinking=1, Evidence-based with bias acknowledged=5',
    low_description = 'Narrative-driven or wishful thinking',
    high_description = 'Evidence-based, bias-acknowledged',
    scoring_criteria = '[
      {"score": 1, "label": "Ideological", "description": "Forecast driven by narrative, identity, or wishful thinking"},
      {"score": 2, "label": "Bias-heavy", "description": "Data cherry-picked to support predetermined conclusion"},
      {"score": 3, "label": "Mixed", "description": "Some evidence-based reasoning but notable blind spots"},
      {"score": 4, "label": "Mostly objective", "description": "Data-driven with acknowledged limitations and biases"},
      {"score": 5, "label": "Debiased analysis", "description": "Systematic bias mitigation, considers base rates, acknowledges uncertainty"}
    ]'::jsonb
WHERE id = 7;

-- Metric 8: Market Signal Alignment
UPDATE public.metrics
SET
    name = 'Market Signal Alignment',
    category = 'CALIBRATION',
    question = 'Does the forecast align with or credibly diverge from prediction market prices?',
    criteria = 'Ignores market signals=1, Engages with market data explicitly=5',
    low_description = 'Ignores prediction market signals entirely',
    high_description = 'Engages with market data explicitly',
    scoring_criteria = '[
      {"score": 1, "label": "Market-blind", "description": "Makes no reference to existing market prices or consensus"},
      {"score": 2, "label": "Loosely aware", "description": "Vague awareness of market consensus but no engagement"},
      {"score": 3, "label": "References markets", "description": "Cites market prices but doesn''t explain divergence or alignment"},
      {"score": 4, "label": "Market-engaged", "description": "Explicitly compares to market prices with reasoning for any divergence"},
      {"score": 5, "label": "Alpha-generating", "description": "Deep market analysis with specific edge thesis explaining mispricing"}
    ]'::jsonb
WHERE id = 8;

-- Metric 9: Timing Precision
UPDATE public.metrics
SET
    name = 'Timing Precision',
    category = 'CALIBRATION',
    question = 'Does the forecast specify a clear time horizon and resolution criteria?',
    criteria = 'Open-ended with no timeline=1, Precise resolution date and criteria=5',
    low_description = 'Open-ended with no timeline',
    high_description = 'Precise resolution date and criteria',
    scoring_criteria = '[
      {"score": 1, "label": "No timeline", "description": "Open-ended prediction with no resolution timeframe"},
      {"score": 2, "label": "Vague horizon", "description": "General timeframe (years) without specific resolution criteria"},
      {"score": 3, "label": "Approximate", "description": "Reasonable timeframe with partial resolution criteria"},
      {"score": 4, "label": "Well-timed", "description": "Clear horizon with defined resolution date and conditions"},
      {"score": 5, "label": "Precision-timed", "description": "Exact resolution date, interim checkpoints, and unambiguous success criteria"}
    ]'::jsonb
WHERE id = 9;

-- Metric 10: Methodological Rigor
UPDATE public.metrics
SET
    name = 'Methodological Rigor',
    category = 'CALIBRATION',
    question = 'Is the forecasting methodology transparent and reproducible?',
    criteria = 'No methodology described=1, Transparent reproducible approach=5',
    low_description = 'No methodology described',
    high_description = 'Transparent, reproducible approach',
    scoring_criteria = '[
      {"score": 1, "label": "Black box", "description": "No methodology described, pure gut feeling or assertion"},
      {"score": 2, "label": "Informal reasoning", "description": "Some logic shown but not systematic or reproducible"},
      {"score": 3, "label": "Partial methodology", "description": "Framework described but key assumptions undisclosed"},
      {"score": 4, "label": "Rigorous", "description": "Clear methodology with stated assumptions and model structure"},
      {"score": 5, "label": "Fully reproducible", "description": "Complete methodology, open model, stated priors, and sensitivity analysis"}
    ]'::jsonb
WHERE id = 10;

-- Metric 11: Update Responsiveness
UPDATE public.metrics
SET
    name = 'Update Responsiveness',
    category = 'INTEGRITY',
    question = 'Does the forecaster update predictions in response to new evidence?',
    criteria = 'Ignores contradicting data=1, Explicitly updates with new evidence=5',
    low_description = 'Ignores contradicting data',
    high_description = 'Explicitly updates with new evidence',
    scoring_criteria = '[
      {"score": 1, "label": "Immovable", "description": "Never updates regardless of new evidence"},
      {"score": 2, "label": "Reluctant updater", "description": "Rarely acknowledges contradicting evidence"},
      {"score": 3, "label": "Occasional updates", "description": "Updates sometimes but inconsistently"},
      {"score": 4, "label": "Responsive", "description": "Regularly updates with clear reasoning for changes"},
      {"score": 5, "label": "Bayesian updater", "description": "Systematic updating with explicit reasoning and probability revisions"}
    ]'::jsonb
WHERE id = 11;

-- Metric 12: Incentive Transparency
UPDATE public.metrics
SET
    name = 'Incentive Transparency',
    category = 'INTEGRITY',
    question = 'Are financial positions or conflicts of interest disclosed?',
    criteria = 'Hidden incentives=1, Full disclosure of positions=5',
    low_description = 'Hidden incentives or talking book',
    high_description = 'Full disclosure of positions and interests',
    scoring_criteria = '[
      {"score": 1, "label": "Hidden book", "description": "Undisclosed financial interests likely influencing forecast"},
      {"score": 2, "label": "Vague disclosure", "description": "Generic disclaimers without specific position disclosure"},
      {"score": 3, "label": "Partial disclosure", "description": "Some positions disclosed but not comprehensive"},
      {"score": 4, "label": "Good disclosure", "description": "Material positions and conflicts clearly stated"},
      {"score": 5, "label": "Full transparency", "description": "Complete position disclosure, conflict analysis, and interest separation"}
    ]'::jsonb
WHERE id = 12;

-- Metric 13: Signal Density
UPDATE public.metrics
SET
    name = 'Signal Density',
    category = 'INTEGRITY',
    question = 'What is the signal-to-noise ratio of the forecast?',
    criteria = 'Padded with filler=1, High-density precise analysis=5',
    low_description = 'Padded with filler and noise',
    high_description = 'High-density, precise analysis',
    scoring_criteria = '[
      {"score": 1, "label": "All noise", "description": "Padded with filler, hedging, and irrelevant content"},
      {"score": 2, "label": "Mostly noise", "description": "Key signal buried in excessive commentary"},
      {"score": 3, "label": "Mixed signal", "description": "Some useful analysis mixed with unnecessary content"},
      {"score": 4, "label": "High signal", "description": "Focused analysis with minimal noise"},
      {"score": 5, "label": "Pure signal", "description": "Every element adds predictive value, zero filler"}
    ]'::jsonb
WHERE id = 13;

-- Metric 14: External Verifiability
UPDATE public.metrics
SET
    name = 'External Verifiability',
    category = 'INTEGRITY',
    question = 'Can the forecast resolution be independently verified?',
    criteria = 'Subjective or unfalsifiable=1, Clear verification criteria=5',
    low_description = 'Subjective or unfalsifiable outcome',
    high_description = 'Clear, independent verification criteria',
    scoring_criteria = '[
      {"score": 1, "label": "Unfalsifiable", "description": "No way to independently verify the outcome"},
      {"score": 2, "label": "Subjective resolution", "description": "Resolution depends on interpretation or judgment calls"},
      {"score": 3, "label": "Partially verifiable", "description": "Some elements verifiable but resolution has ambiguity"},
      {"score": 4, "label": "Largely verifiable", "description": "Clear data sources for resolution with minor edge cases"},
      {"score": 5, "label": "Independently verifiable", "description": "Unambiguous resolution criteria using public, third-party data"}
    ]'::jsonb
WHERE id = 14;

-- Metric 15: Resolution Direction
UPDATE public.metrics
SET
    name = 'Resolution Direction',
    category = 'INTEGRITY',
    question = 'Does the forecast drive toward a clear resolution or perpetual ambiguity?',
    criteria = 'Moving goalposts=1, Defined success/failure criteria=5',
    low_description = 'Moving goalposts and perpetual ambiguity',
    high_description = 'Defined success/failure criteria',
    scoring_criteria = '[
      {"score": 1, "label": "Moving goalposts", "description": "Resolution criteria shift to avoid being proven wrong"},
      {"score": 2, "label": "Ambiguous outcome", "description": "Unclear what constitutes success or failure"},
      {"score": 3, "label": "Partial clarity", "description": "Some resolution criteria but room for goalpost movement"},
      {"score": 4, "label": "Clear resolution", "description": "Well-defined success/failure with minimal ambiguity"},
      {"score": 5, "label": "Binary resolution", "description": "Unambiguous yes/no outcome with pre-committed criteria"}
    ]'::jsonb
WHERE id = 15;

-- Metric 16: Independent Analysis
UPDATE public.metrics
SET
    name = 'Independent Analysis',
    category = 'VALUE',
    question = 'Is the forecast derived independently or borrowed from echo chambers?',
    criteria = 'Herding or groupthink=1, Independent reasoning documented=5',
    low_description = 'Herding or groupthink',
    high_description = 'Independent reasoning documented',
    scoring_criteria = '[
      {"score": 1, "label": "Pure herding", "description": "Copying consensus without independent analysis"},
      {"score": 2, "label": "Echo chamber", "description": "Mostly derived from a single community or source"},
      {"score": 3, "label": "Mixed sources", "description": "Some independent thinking but heavily influenced by consensus"},
      {"score": 4, "label": "Largely independent", "description": "Clear independent reasoning with acknowledged influences"},
      {"score": 5, "label": "Fully independent", "description": "Original analysis with documented reasoning chain, diverges from consensus where warranted"}
    ]'::jsonb
WHERE id = 16;

-- Metric 17: Base Rate Awareness
UPDATE public.metrics
SET
    name = 'Base Rate Awareness',
    category = 'VALUE',
    question = 'Are historical base rates and precedents properly incorporated?',
    criteria = 'Ignores base rates=1, Calibrated against historical data=5',
    low_description = 'Ignores historical base rates',
    high_description = 'Calibrated against historical data',
    scoring_criteria = '[
      {"score": 1, "label": "Base rate blind", "description": "No reference to historical frequency or precedent"},
      {"score": 2, "label": "Anecdotal", "description": "Cherry-picked examples without systematic base rate analysis"},
      {"score": 3, "label": "Partial awareness", "description": "Some base rate consideration but not systematic"},
      {"score": 4, "label": "Well-calibrated", "description": "Explicit base rate analysis with appropriate adjustment"},
      {"score": 5, "label": "Reference class mastery", "description": "Rigorous reference class forecasting with multiple historical analogues"}
    ]'::jsonb
WHERE id = 17;

-- Metric 18: Stress Testing
UPDATE public.metrics
SET
    name = 'Stress Testing',
    category = 'VALUE',
    question = 'Does the forecast hold up under adversarial questioning and edge cases?',
    criteria = 'Fragile under scrutiny=1, Robust across scenarios=5',
    low_description = 'Fragile under scrutiny',
    high_description = 'Robust across scenarios',
    scoring_criteria = '[
      {"score": 1, "label": "Fragile", "description": "Collapses under basic questioning or alternative scenarios"},
      {"score": 2, "label": "Weak resilience", "description": "Handles soft questions but fails adversarial probing"},
      {"score": 3, "label": "Moderate robustness", "description": "Survives some stress tests but has notable vulnerabilities"},
      {"score": 4, "label": "Robust", "description": "Holds up well across most scenarios and edge cases"},
      {"score": 5, "label": "Anti-fragile", "description": "Strengthens under scrutiny, pre-addresses objections, considers tail risks"}
    ]'::jsonb
WHERE id = 18;

-- Metric 19: Strategic Coherence
UPDATE public.metrics
SET
    name = 'Strategic Coherence',
    category = 'VALUE',
    question = 'Is the forecast part of a coherent analytical framework?',
    criteria = 'One-off or reactive=1, Integrated into systematic approach=5',
    low_description = 'One-off or reactive prediction',
    high_description = 'Integrated into systematic approach',
    scoring_criteria = '[
      {"score": 1, "label": "Reactive", "description": "One-off prediction with no broader analytical framework"},
      {"score": 2, "label": "Loosely connected", "description": "Some thematic connection to other work but not systematic"},
      {"score": 3, "label": "Partially integrated", "description": "Part of a framework but with gaps or inconsistencies"},
      {"score": 4, "label": "Coherent framework", "description": "Well-integrated into a consistent analytical approach"},
      {"score": 5, "label": "Systematic program", "description": "Part of a rigorous, documented forecasting program with cross-validated models"}
    ]'::jsonb
WHERE id = 19;

-- Metric 20: Net Predictive Value
UPDATE public.metrics
SET
    name = 'Net Predictive Value',
    category = 'VALUE',
    question = 'Does this forecast meaningfully reduce uncertainty about the outcome?',
    criteria = 'Adds noise=1, Meaningfully narrows probability range=5',
    low_description = 'Adds noise and increases confusion',
    high_description = 'Meaningfully narrows probability range',
    scoring_criteria = '[
      {"score": 1, "label": "Net negative", "description": "Adds noise, increases confusion, or misleads"},
      {"score": 2, "label": "Marginal value", "description": "Slightly informative but doesn''t meaningfully reduce uncertainty"},
      {"score": 3, "label": "Moderate value", "description": "Provides useful signal that somewhat narrows outcome space"},
      {"score": 4, "label": "High value", "description": "Substantially reduces uncertainty with clear probability update"},
      {"score": 5, "label": "Decision-grade", "description": "Dramatically narrows probability range, high-conviction with justification"}
    ]'::jsonb
WHERE id = 20;

-- Update table comment
COMMENT ON TABLE public.metrics IS 'Forecast Audit Protocol: 20 standard metrics for evaluating prediction market forecast quality';
