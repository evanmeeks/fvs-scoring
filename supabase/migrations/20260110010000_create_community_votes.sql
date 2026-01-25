-- =====================================================================
-- COMMUNITY VOTES TABLE
-- Migration: 20260110_01_create_community_votes.sql
-- =====================================================================
-- This migration creates a dedicated table for community voting,
-- separate from slider-based scoring in user_scores.
-- Includes confidence levels and rationales for each vote.
-- =====================================================================

-- Create community_votes table
CREATE TABLE IF NOT EXISTS public.community_votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  target_id TEXT REFERENCES public.targets(id) ON DELETE CASCADE,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE,

  -- Vote data
  vote_value INTEGER NOT NULL CHECK (vote_value BETWEEN 1 AND 5),
  confidence_level TEXT NOT NULL CHECK (confidence_level IN ('low', 'medium', 'high')) DEFAULT 'medium',
  rationale TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  -- Ensure one vote per user per metric per target
  UNIQUE(user_id, target_id, metric_id)
);
-- Create indexes for performance
CREATE INDEX idx_community_votes_user_id ON public.community_votes(user_id);
CREATE INDEX idx_community_votes_target_id ON public.community_votes(target_id);
CREATE INDEX idx_community_votes_metric_id ON public.community_votes(metric_id);
CREATE INDEX idx_community_votes_created_at ON public.community_votes(created_at DESC);
-- Enable Row Level Security
ALTER TABLE public.community_votes ENABLE ROW LEVEL SECURITY;
-- RLS Policies
-- Users can view all votes (for consensus display)
CREATE POLICY "Anyone can view community votes"
  ON public.community_votes
  FOR SELECT
  USING (true);
-- Users can insert their own votes
CREATE POLICY "Users can insert their own votes"
  ON public.community_votes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
-- Users can update their own votes
CREATE POLICY "Users can update their own votes"
  ON public.community_votes
  FOR UPDATE
  USING (auth.uid() = user_id);
-- Users can delete their own votes
CREATE POLICY "Users can delete their own votes"
  ON public.community_votes
  FOR DELETE
  USING (auth.uid() = user_id);
-- Create updated_at trigger
CREATE TRIGGER set_community_votes_updated_at
  BEFORE UPDATE ON public.community_votes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
-- Comments
COMMENT ON TABLE public.community_votes IS 'Community voting on metrics with confidence levels and rationales';
COMMENT ON COLUMN public.community_votes.vote_value IS 'Vote score: 1 (very low) to 5 (very high)';
COMMENT ON COLUMN public.community_votes.confidence_level IS 'Voter confidence: low, medium, or high';
COMMENT ON COLUMN public.community_votes.rationale IS 'Optional explanation for the vote';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Community votes table created successfully!';
  RAISE NOTICE 'New table: public.community_votes';
  RAISE NOTICE 'Features: Vote value (1-5), confidence level, rationale';
END $$;
