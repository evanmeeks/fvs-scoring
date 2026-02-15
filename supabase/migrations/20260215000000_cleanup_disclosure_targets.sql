-- Cleanup: Remove all non-prediction-market targets and submissions
-- Replaces old disclosure/UAP seed data with prediction market forecasts only

-- Delete scores tied to old targets
DELETE FROM public.user_scores
WHERE target_id IN ('grusch-2024', 'wilson-memo', 'nimitz-2004');

-- Delete community votes tied to old targets
DELETE FROM public.community_votes
WHERE target_id IN ('grusch-2024', 'wilson-memo', 'nimitz-2004');

-- Delete old approved targets
DELETE FROM public.approved_targets
WHERE id IN ('grusch-2024', 'wilson-memo', 'nimitz-2004');

-- Delete all non-prediction-market target submissions
DELETE FROM public.target_submissions
WHERE target_name NOT IN (
  'Fed Rate Trajectory 2024',
  'US Presidential Election 2024',
  'US Recession Probability 2024-2025',
  'Bitcoin Price EOY 2024',
  'Global Temperature Anomaly 2024',
  'AGI Development Timeline',
  'SpaceX Starship Orbital Success',
  'Next Pandemic Timeline',
  'Commercial Fusion Timeline'
);
