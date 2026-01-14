-- =====================================================================
-- ACTIVITY LOG TABLE
-- Migration: 20260110_04_create_activity_log.sql
-- =====================================================================
-- This migration creates a comprehensive activity tracking system
-- for auditing and displaying user actions throughout the application.
-- =====================================================================

-- Create activity_log table
CREATE TABLE IF NOT EXISTS public.activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,

  -- Activity details
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'score', 'vote', 'comment', 'reply', 'upvote', 'downvote',
    'rfc_submit', 'target_submit', 'login', 'logout',
    'admin_action', 'edit', 'verification'
  )),

  -- Related entities (nullable based on activity_type)
  target_id TEXT REFERENCES public.targets(id) ON DELETE SET NULL,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE SET NULL,
  discussion_id UUID, -- Note: FK to metric_discussions added later if table exists
  rfc_id UUID REFERENCES public.rfc_proposals(id) ON DELETE SET NULL,

  -- Activity metadata (JSONB for flexibility)
  metadata JSONB DEFAULT '{}'::jsonb,
  -- Example structures:
  -- {"score_value": 4, "changed_from": 3, "confidence": "high"}
  -- {"vote_type": "upvote", "comment_id": "uuid"}
  -- {"rfc_id": "uuid", "proposal_type": "modify_existing"}

  -- Human-readable description
  description TEXT NOT NULL,

  -- Timestamp
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Create indexes for performance
CREATE INDEX idx_activity_log_user_id ON public.activity_log(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_activity_log_activity_type ON public.activity_log(activity_type);
CREATE INDEX idx_activity_log_created_at ON public.activity_log(created_at DESC);
CREATE INDEX idx_activity_log_target_id ON public.activity_log(target_id) WHERE target_id IS NOT NULL;
CREATE INDEX idx_activity_log_metric_id ON public.activity_log(metric_id) WHERE metric_id IS NOT NULL;
CREATE INDEX idx_activity_log_discussion_id ON public.activity_log(discussion_id) WHERE discussion_id IS NOT NULL;
CREATE INDEX idx_activity_log_rfc_id ON public.activity_log(rfc_id) WHERE rfc_id IS NOT NULL;
-- Composite index for user activity feed
CREATE INDEX idx_activity_log_user_created ON public.activity_log(user_id, created_at DESC) WHERE user_id IS NOT NULL;
-- Enable Row Level Security
ALTER TABLE public.activity_log ENABLE ROW LEVEL SECURITY;
-- RLS Policies
-- Everyone can view public activity (for activity feed)
CREATE POLICY "Anyone can view activity log"
  ON public.activity_log
  FOR SELECT
  USING (true);
-- System can insert activity logs (via triggers and functions)
CREATE POLICY "System can insert activity logs"
  ON public.activity_log
  FOR INSERT
  WITH CHECK (true);
-- Comments
COMMENT ON TABLE public.activity_log IS 'Comprehensive activity tracking for all user actions';
COMMENT ON COLUMN public.activity_log.activity_type IS 'Type of activity performed';
COMMENT ON COLUMN public.activity_log.metadata IS 'JSONB field containing activity-specific data';
COMMENT ON COLUMN public.activity_log.description IS 'Human-readable description of the activity';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Activity log table created successfully!';
  RAISE NOTICE 'New table: public.activity_log';
  RAISE NOTICE 'Features: Comprehensive activity tracking, flexible metadata, optimized indexes';
END $$;
