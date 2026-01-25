-- Migration: Add governance voting fields and history tracking
-- This migration adds support for:
-- 1. Action votes (Keep/Modify/Drop) per user per metric per target
-- 2. Action notes to accompany governance votes
-- 3. Complete audit trail for all changes to scores and governance votes

-- Step 1: Extend user_scores table with governance voting fields
ALTER TABLE public.user_scores
  ADD COLUMN IF NOT EXISTS action_vote TEXT CHECK (action_vote IN ('keep', 'modify', 'drop')),
  ADD COLUMN IF NOT EXISTS action_notes TEXT;
-- Step 2: Create user_score_history table for complete audit trail
CREATE TABLE IF NOT EXISTS public.user_score_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_score_id UUID REFERENCES public.user_scores(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  target_id TEXT REFERENCES public.targets(id) ON DELETE CASCADE,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE,

  -- Snapshot of values at time of change
  score INTEGER CHECK (score >= 0 AND score <= 5),
  notes TEXT,
  action_vote TEXT CHECK (action_vote IN ('keep', 'modify', 'drop')),
  action_notes TEXT,

  -- Metadata
  change_type TEXT NOT NULL CHECK (change_type IN ('score_update', 'governance_vote', 'notes_update', 'full_update')),
  changed_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,

  -- Indexes for efficient querying
  CONSTRAINT fk_user_score FOREIGN KEY (user_score_id) REFERENCES public.user_scores(id) ON DELETE CASCADE
);
-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_score_history_user_score_id ON public.user_score_history(user_score_id);
CREATE INDEX IF NOT EXISTS idx_user_score_history_user_id ON public.user_score_history(user_id);
CREATE INDEX IF NOT EXISTS idx_user_score_history_changed_at ON public.user_score_history(changed_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_score_history_change_type ON public.user_score_history(change_type);
-- Enable RLS on history table
ALTER TABLE public.user_score_history ENABLE ROW LEVEL SECURITY;
-- Policies for user_score_history
CREATE POLICY "Users can view their own score history" ON public.user_score_history
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can insert history records" ON public.user_score_history
  FOR INSERT WITH CHECK (true);
-- Step 3: Create trigger to automatically log changes to user_scores
CREATE OR REPLACE FUNCTION public.log_user_score_change()
RETURNS TRIGGER AS $$
DECLARE
  change_type_val TEXT;
BEGIN
  -- Determine what changed
  IF TG_OP = 'INSERT' THEN
    change_type_val := 'full_update';
  ELSIF TG_OP = 'UPDATE' THEN
    IF (OLD.score IS DISTINCT FROM NEW.score) AND
       (OLD.action_vote IS DISTINCT FROM NEW.action_vote) THEN
      change_type_val := 'full_update';
    ELSIF (OLD.score IS DISTINCT FROM NEW.score) THEN
      change_type_val := 'score_update';
    ELSIF (OLD.action_vote IS DISTINCT FROM NEW.action_vote OR
           OLD.action_notes IS DISTINCT FROM NEW.action_notes) THEN
      change_type_val := 'governance_vote';
    ELSIF (OLD.notes IS DISTINCT FROM NEW.notes) THEN
      change_type_val := 'notes_update';
    ELSE
      RETURN NEW; -- No relevant changes, skip logging
    END IF;
  END IF;

  -- Insert history record
  INSERT INTO public.user_score_history (
    user_score_id,
    user_id,
    target_id,
    metric_id,
    score,
    notes,
    action_vote,
    action_notes,
    change_type
  ) VALUES (
    NEW.id,
    NEW.user_id,
    NEW.target_id,
    NEW.metric_id,
    NEW.score,
    NEW.notes,
    NEW.action_vote,
    NEW.action_notes,
    change_type_val
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Attach trigger to user_scores table
DROP TRIGGER IF EXISTS trigger_log_user_score_change ON public.user_scores;
CREATE TRIGGER trigger_log_user_score_change
  AFTER INSERT OR UPDATE ON public.user_scores
  FOR EACH ROW
  EXECUTE FUNCTION public.log_user_score_change();
-- Step 4: Update the target_score_aggregates view to include governance data
DROP VIEW IF EXISTS public.target_score_aggregates;
CREATE OR REPLACE VIEW public.target_score_aggregates AS
SELECT
  t.id as target_id,
  t.name as target_name,
  m.id as metric_id,
  m.name as metric_name,

  -- Scoring aggregates
  COUNT(us.id) FILTER (WHERE us.score IS NOT NULL) as total_votes,
  AVG(us.score) FILTER (WHERE us.score IS NOT NULL) as average_score,
  MODE() WITHIN GROUP (ORDER BY us.score) FILTER (WHERE us.score IS NOT NULL) as most_common_score,

  -- Governance aggregates
  COUNT(us.id) FILTER (WHERE us.action_vote IS NOT NULL) as total_governance_votes,
  COUNT(us.id) FILTER (WHERE us.action_vote = 'keep') as keep_votes,
  COUNT(us.id) FILTER (WHERE us.action_vote = 'modify') as modify_votes,
  COUNT(us.id) FILTER (WHERE us.action_vote = 'drop') as drop_votes,
  MODE() WITHIN GROUP (ORDER BY us.action_vote) FILTER (WHERE us.action_vote IS NOT NULL) as consensus_action

FROM public.targets t
CROSS JOIN public.metrics m
LEFT JOIN public.user_scores us ON us.target_id = t.id AND us.metric_id = m.id
GROUP BY t.id, t.name, m.id, m.name;
-- Grant permissions
GRANT SELECT ON public.target_score_aggregates TO authenticated;
GRANT SELECT ON public.target_score_aggregates TO anon;
-- Step 5: Create helper function to get governance vote summary
CREATE OR REPLACE FUNCTION public.get_governance_summary(
  target_id_param TEXT,
  metric_id_param INTEGER
)
RETURNS TABLE(
  action_vote TEXT,
  vote_count BIGINT,
  percentage NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    us.action_vote,
    COUNT(*) as vote_count,
    ROUND((COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (), 0)), 2) as percentage
  FROM public.user_scores us
  WHERE us.target_id = target_id_param
    AND us.metric_id = metric_id_param
    AND us.action_vote IS NOT NULL
  GROUP BY us.action_vote
  ORDER BY vote_count DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Comments for documentation
COMMENT ON COLUMN public.user_scores.action_vote IS 'Governance vote: keep, modify, or drop the metric';
COMMENT ON COLUMN public.user_scores.action_notes IS 'User notes explaining their governance vote';
COMMENT ON TABLE public.user_score_history IS 'Audit trail of all changes to user scores and governance votes';
COMMENT ON FUNCTION public.get_governance_summary IS 'Returns vote distribution for a specific metric on a target';
