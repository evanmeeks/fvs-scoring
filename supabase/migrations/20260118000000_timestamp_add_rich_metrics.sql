-- Add rich metrics data columns
ALTER TABLE public.metrics
ADD COLUMN IF NOT EXISTS scoring_criteria JSONB,
ADD COLUMN IF NOT EXISTS low_description TEXT,
ADD COLUMN IF NOT EXISTS high_description TEXT;

-- Update Metrics 1-10 (Rich Data from metrics.ts)
UPDATE public.metrics
SET 
    low_description = 'No specific details, vague generalities only',
    high_description = 'Highly specific names, dates, locations, documents',
    scoring_criteria = '[
      {"score": 1, "label": "Pure abstraction", "description": "No specific details, vague generalities only"},
      {"score": 2, "label": "Minimal specificity", "description": "Few concrete details, mostly abstract claims"},
      {"score": 3, "label": "Mixed", "description": "Some verifiable details mixed with abstractions"},
      {"score": 4, "label": "Largely specific", "description": "Multiple concrete, verifiable details provided"},
      {"score": 5, "label": "Names verifiable entities", "description": "Highly specific names, dates, locations, documents"}
    ]'::jsonb
WHERE id = 1;

UPDATE public.metrics
SET 
    low_description = 'Circular reasoning, no forward momentum',
    high_description = 'Explicit, verifiable causal mechanism explained',
    scoring_criteria = '[
      {"score": 1, "label": "No link", "description": "Circular reasoning, no forward momentum"},
      {"score": 2, "label": "Weak link", "description": "Unclear or tenuous causal connections"},
      {"score": 3, "label": "Mixed / Partial Evidence", "description": "Some logical progression, some gaps"},
      {"score": 4, "label": "Strong causation", "description": "Clear logical flow with few gaps"},
      {"score": 5, "label": "Clear cause→effect chain", "description": "Explicit, verifiable causal mechanism explained"}
    ]'::jsonb
WHERE id = 2;

UPDATE public.metrics
SET 
    low_description = 'Dead end, no actionable leads',
    high_description = 'Specific, immediately actionable intelligence',
    scoring_criteria = '[
      {"score": 1, "label": "No follow-up", "description": "Dead end, no actionable leads"},
      {"score": 2, "label": "Minimal action", "description": "Very limited follow-up possibilities"},
      {"score": 3, "label": "Moderate actionability", "description": "Some concrete next steps possible"},
      {"score": 4, "label": "Highly actionable", "description": "Multiple clear investigative paths"},
      {"score": 5, "label": "Clear FOIA/hearing targets", "description": "Specific, immediately actionable intelligence"}
    ]'::jsonb
WHERE id = 3;

UPDATE public.metrics
SET 
    low_description = 'Rehashed claims, nothing new',
    high_description = 'Genuinely new, independently verifiable claims',
    scoring_criteria = '[
      {"score": 1, "label": "Recycled lore", "description": "Rehashed claims, nothing new"},
      {"score": 2, "label": "Minor variation", "description": "Slight twist on existing narratives"},
      {"score": 3, "label": "Some novelty", "description": "Mix of known and new information"},
      {"score": 4, "label": "Largely novel", "description": "Substantial new insights or connections"},
      {"score": 5, "label": "Previously undisclosed info", "description": "Genuinely new, independently verifiable claims"}
    ]'::jsonb
WHERE id = 4;

UPDATE public.metrics
SET 
    low_description = 'No attribution, plagiarized claims',
    high_description = 'Transparent, complete source attribution',
    scoring_criteria = '[
      {"score": 1, "label": "Laundered ideas", "description": "No attribution, plagiarized claims"},
      {"score": 2, "label": "Poor attribution", "description": "Vague or incomplete source citations"},
      {"score": 3, "label": "Mixed attribution", "description": "Some sources cited, others missing"},
      {"score": 4, "label": "Good attribution", "description": "Most sources properly acknowledged"},
      {"score": 5, "label": "Clear lineage", "description": "Transparent, complete source attribution"}
    ]'::jsonb
WHERE id = 5;

UPDATE public.metrics
SET 
    low_description = 'No risk, purely financial gain',
    high_description = 'Serious legal, professional, or safety risk',
    scoring_criteria = '[
      {"score": 1, "label": "Monetize/Safe", "description": "No risk, purely financial gain"},
      {"score": 2, "label": "Low risk", "description": "Minimal personal or professional exposure"},
      {"score": 3, "label": "Moderate risk", "description": "Some professional or reputational stakes"},
      {"score": 4, "label": "Significant risk", "description": "Substantial professional/legal exposure"},
      {"score": 5, "label": "Skipped/Personal risk", "description": "Serious legal, professional, or safety risk"}
    ]'::jsonb
WHERE id = 6;

UPDATE public.metrics
SET 
    low_description = 'Mythological framing, no grounding',
    high_description = 'Completely grounded in verifiable facts',
    scoring_criteria = '[
      {"score": 1, "label": "Archetypal/Savian", "description": "Mythological framing, no grounding"},
      {"score": 2, "label": "Heavily mythologized", "description": "Mostly narrative-driven, little substance"},
      {"score": 3, "label": "Mixed grounding", "description": "Some facts, some mythological elements"},
      {"score": 4, "label": "Mostly grounded", "description": "Evidence-based with minor mythic elements"},
      {"score": 5, "label": "Clinical/Procedural", "description": "Completely grounded in verifiable facts"}
    ]'::jsonb
WHERE id = 7;

UPDATE public.metrics
SET 
    low_description = 'Vague institutional blame, no specifics',
    high_description = 'Directly challenges specific power holders',
    scoring_criteria = '[
      {"score": 1, "label": "Abstract \"system\"", "description": "Vague institutional blame, no specifics"},
      {"score": 2, "label": "General institutions", "description": "Names organizations but not individuals"},
      {"score": 3, "label": "Mixed accountability", "description": "Some specific targets, some abstract"},
      {"score": 4, "label": "Specific entities", "description": "Names departments, programs, or roles"},
      {"score": 5, "label": "Names specific offices", "description": "Directly challenges specific power holders"}
    ]'::jsonb
WHERE id = 8;

UPDATE public.metrics
SET 
    low_description = 'Perfectly timed for publicity, suspicious',
    high_description = 'Truth-driven timing, ignores media cycles',
    scoring_criteria = '[
      {"score": 1, "label": "Media sync", "description": "Perfectly timed for publicity, suspicious"},
      {"score": 2, "label": "Opportunistic", "description": "Timing suggests strategic media play"},
      {"score": 3, "label": "Neutral timing", "description": "No clear pattern either way"},
      {"score": 4, "label": "Authentic timing", "description": "Timing aligns with genuine circumstances"},
      {"score": 5, "label": "Disclosure-first", "description": "Truth-driven timing, ignores media cycles"}
    ]'::jsonb
WHERE id = 9;

UPDATE public.metrics
SET 
    low_description = 'No operational understanding, superficial',
    high_description = 'Exceptional operational and analytical rigor',
    scoring_criteria = '[
      {"score": 1, "label": "Amateur", "description": "No operational understanding, superficial"},
      {"score": 2, "label": "Basic knowledge", "description": "Limited operational awareness"},
      {"score": 3, "label": "Moderate literacy", "description": "Decent operational understanding"},
      {"score": 4, "label": "Strong tradecraft", "description": "Clear operational expertise demonstrated"},
      {"score": 5, "label": "Deep tradecraft literacy", "description": "Exceptional operational and analytical rigor"}
    ]'::jsonb
WHERE id = 10;

-- Update Metrics 11-20 (Basic Data from metrics.js)
UPDATE public.metrics SET low_description = 'Ignores past contradictions', high_description = 'Explicitly reconciles conflict', scoring_criteria = NULL WHERE id = 11;
UPDATE public.metrics SET low_description = 'Hidden monetization', high_description = 'Clear separation from profit', scoring_criteria = NULL WHERE id = 12;
UPDATE public.metrics SET low_description = 'Long-form vagueness', high_description = 'High-density, low-fluff', scoring_criteria = NULL WHERE id = 13;
UPDATE public.metrics SET low_description = 'No verification path', high_description = 'Clear verification vectors', scoring_criteria = NULL WHERE id = 14;
UPDATE public.metrics SET low_description = 'Endless tease', high_description = 'Collapses ambiguity', scoring_criteria = NULL WHERE id = 15;
UPDATE public.metrics SET low_description = 'Circular validation', high_description = 'Independent of influencer networks', scoring_criteria = NULL WHERE id = 16;
UPDATE public.metrics SET low_description = 'Naïve/Mythic history', high_description = 'Accurate use of precedents', scoring_criteria = NULL WHERE id = 17;
UPDATE public.metrics SET low_description = 'Collapses under scrutiny', high_description = 'Strengthens under pressure', scoring_criteria = NULL WHERE id = 18;
UPDATE public.metrics SET low_description = 'Chaotic/Opportunistic', high_description = 'Coherent long-range arc', scoring_criteria = NULL WHERE id = 19;
UPDATE public.metrics SET low_description = 'Increases confusion', high_description = 'Meaningfully clarifies terrain', scoring_criteria = NULL WHERE id = 20;

COMMENT ON COLUMN public.metrics.scoring_criteria IS 'Rich JSON array defining criteria for score 1-5';
COMMENT ON COLUMN public.metrics.low_description IS 'Description for the lowest score (1)';
COMMENT ON COLUMN public.metrics.high_description IS 'Description for the highest score (5)';
