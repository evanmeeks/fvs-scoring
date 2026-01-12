-- Migration: Add targets and user_scores tables
-- This migration adds support for:
-- 1. Multiple forecast targets (Grusch, Wilson Memo, Nimitz, etc.)
-- 2. User-specific scores per target per metric
-- 3. Community submissions/RFCs

-- Create the targets table
CREATE TABLE IF NOT EXISTS public.targets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  case_id TEXT NOT NULL UNIQUE,
  origin TEXT NOT NULL,
  context TEXT NOT NULL,
  verified BOOLEAN DEFAULT false,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
-- Insert default targets
INSERT INTO public.targets (id, name, case_id, origin, context, verified, description) VALUES
  ('grusch-2024', 'Grusch_T_2024', 'NCI-8.3-XREF-FVS', 'IC/NGA', 'Congressional', true, 'David Grusch UAP disclosure testimony before Congress'),
  ('wilson-memo', 'Wilson_Memo_2002', 'NCI-7.1-XREF-FVS', 'DoD/DIA', 'Internal', true, 'Eric Davis notes from Admiral Wilson meeting'),
  ('nimitz-2004', 'Nimitz_Encounter_2004', 'NCI-9.2-XREF-FVS', 'USN', 'Operational', true, 'USS Nimitz carrier strike group UAP encounter')
ON CONFLICT (id) DO NOTHING;
-- Create the user_scores table
CREATE TABLE IF NOT EXISTS public.user_scores (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  target_id TEXT REFERENCES public.targets(id) ON DELETE CASCADE,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE,
  score INTEGER NOT NULL CHECK (score >= 0 AND score <= 5),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, target_id, metric_id)
);
-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_scores_user_id ON public.user_scores(user_id);
CREATE INDEX IF NOT EXISTS idx_user_scores_target_id ON public.user_scores(target_id);
CREATE INDEX IF NOT EXISTS idx_user_scores_metric_id ON public.user_scores(metric_id);
-- Create submissions table
CREATE TABLE IF NOT EXISTS public.submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE,
  submission_type TEXT NOT NULL CHECK (submission_type IN ('rfc', 'score_verification', 'context_addendum', 'general_edit')),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'under_review')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_submissions_user_id ON public.submissions(user_id);
CREATE INDEX IF NOT EXISTS idx_submissions_metric_id ON public.submissions(metric_id);
CREATE INDEX IF NOT EXISTS idx_submissions_status ON public.submissions(status);
-- Enable RLS
ALTER TABLE public.targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
-- Policies for targets
CREATE POLICY "Enable read access for all users" ON public.targets
  FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON public.targets
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
-- Policies for user_scores
CREATE POLICY "Users can view their own scores" ON public.user_scores
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own scores" ON public.user_scores
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own scores" ON public.user_scores
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own scores" ON public.user_scores
  FOR DELETE USING (auth.uid() = user_id);
-- Policies for submissions
CREATE POLICY "Enable read access for all submissions" ON public.submissions
  FOR SELECT USING (true);
CREATE POLICY "Users can insert their own submissions" ON public.submissions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own submissions" ON public.submissions
  FOR UPDATE USING (auth.uid() = user_id);
-- Triggers
CREATE TRIGGER set_targets_updated_at
  BEFORE UPDATE ON public.targets
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_user_scores_updated_at
  BEFORE UPDATE ON public.user_scores
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_submissions_updated_at
  BEFORE UPDATE ON public.submissions
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
-- Aggregated view
CREATE OR REPLACE VIEW public.target_score_aggregates AS
SELECT
  t.id as target_id,
  t.name as target_name,
  m.id as metric_id,
  m.name as metric_name,
  COUNT(us.id) as total_votes,
  AVG(us.score) as average_score,
  MODE() WITHIN GROUP (ORDER BY us.score) as most_common_score
FROM public.targets t
CROSS JOIN public.metrics m
LEFT JOIN public.user_scores us ON us.target_id = t.id AND us.metric_id = m.id
GROUP BY t.id, t.name, m.id, m.name;
GRANT SELECT ON public.target_score_aggregates TO authenticated;
GRANT SELECT ON public.target_score_aggregates TO anon;
