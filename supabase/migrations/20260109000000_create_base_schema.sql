-- Migration: Create base schema with metrics table
-- This is the foundational migration that must run before all others

-- Create the metrics table
CREATE TABLE IF NOT EXISTS public.metrics (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  question TEXT NOT NULL,
  criteria TEXT NOT NULL,
  min_val INTEGER DEFAULT 1,
  max_val INTEGER DEFAULT 5,
  community_score DECIMAL(3,1),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
-- Insert the 20 hardcoded metrics (set community_score default to 0.0 if not null)
INSERT INTO public.metrics (id, name, category, question, criteria, community_score) VALUES
  (1, 'Internal Consistency', 'CORE', 'How internally consistent is this disclosure?', 'No contradictions to Full logical coherence', 0.0),
  (2, 'Corroboration Level', 'CORE', 'How well is this disclosure corroborated?', 'Single source to Multiple independent confirmations', 0.0),
  (3, 'Source Expertise', 'CORE', 'What is the expertise level of the source?', 'No relevant background to Direct program involvement', 0.0),
  (4, 'Chain of Custody', 'CORE', 'How strong is the information chain?', 'Fourth-hand to Direct witness/participant', 0.0),
  (5, 'Documentation Quality', 'CORE', 'Quality of supporting documentation', 'No documentation to Official classified documents', 0.0),
  (6, 'Temporal Precision', 'INTEGRITY', 'Precision of timeline information', 'Vague decades to Exact dates and times', 0.0),
  (7, 'Location Specificity', 'INTEGRITY', 'Specificity of location data', 'Unknown location to Precise coordinates', 0.0),
  (8, 'Technical Detail', 'INTEGRITY', 'Level of technical specificity', 'Vague descriptions to Detailed technical specifications', 0.0),
  (9, 'Verifiable Claims', 'INTEGRITY', 'How verifiable are the specific claims?', 'No verifiable elements to Fully independently verifiable', 0.0),
  (10, 'Admission Against Interest', 'INTEGRITY', 'Does disclosure harm source credibility?', 'Self-serving to Significant personal/professional risk', 0.0),
  (11, 'Security Implications', 'IMPACT', 'Implications for national security', 'Minimal impact to Critical security concerns', 0.0),
  (12, 'Scientific Significance', 'IMPACT', 'Scientific importance of claims', 'Conventional science to Paradigm-shifting', 0.0),
  (13, 'Historical Importance', 'IMPACT', 'Historical significance', 'Minor footnote to Historical turning point', 0.0),
  (14, 'Public Interest', 'IMPACT', 'Level of legitimate public interest', 'Limited interest to Essential public knowledge', 0.0),
  (15, 'Institutional Response', 'IMPACT', 'Official response to disclosure', 'Ignored to Major policy changes', 0.0),
  (16, 'Investigative Follow-up', 'IMPACT', 'Extent of subsequent investigation', 'No follow-up to Congressional hearings', 0.0),
  (17, 'Media Scrutiny', 'IMPACT', 'Level of media investigation', 'No coverage to Intensive investigative journalism', 0.0),
  (18, 'Expert Analysis', 'IMPACT', 'Depth of expert examination', 'No expert review to Comprehensive peer review', 0.0),
  (19, 'Legal Protections Used', 'IMPACT', 'Use of legal disclosure frameworks', 'No protections to Full whistleblower protections', 0.0),
  (20, 'Ongoing Access', 'IMPACT', 'Continued source access to information', 'No current access to Active ongoing access', 0.0)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  question = EXCLUDED.question,
  criteria = EXCLUDED.criteria,
  community_score = COALESCE(metrics.community_score, EXCLUDED.community_score);
-- Create updated_at trigger function if it doesn't exist
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Add trigger for metrics table
DROP TRIGGER IF EXISTS set_updated_at ON public.metrics;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.metrics
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
