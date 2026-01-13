-- =====================================================================
-- RFC PROPOSALS TABLE
-- Migration: 20260110_02_create_rfc_proposals.sql
-- =====================================================================
-- This migration creates a structured table for RFC (Request for Comments)
-- proposals, replacing the unstructured submissions.content field.
-- Supports both modifying existing metrics and proposing new ones.
-- =====================================================================

-- Create rfc_proposals table
CREATE TABLE IF NOT EXISTS public.rfc_proposals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE,

  -- Proposal type
  proposal_type TEXT NOT NULL CHECK (proposal_type IN ('modify_existing', 'new_metric')),

  -- Proposed changes (NULL if not proposing change to that field)
  proposed_name TEXT,
  proposed_question TEXT,
  proposed_min_criteria TEXT,
  proposed_max_criteria TEXT,
  proposed_category TEXT CHECK (proposed_category IN ('CORE', 'INTEGRITY', 'IMPACT')),

  -- Supporting information
  rich_entries TEXT, -- Examples, detailed explanations
  rationale TEXT NOT NULL, -- Why this change is needed

  -- Status tracking
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected', 'implemented')),

  -- Review metadata
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMPTZ,
  review_notes TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Create indexes
CREATE INDEX idx_rfc_proposals_user_id ON public.rfc_proposals(user_id);
CREATE INDEX idx_rfc_proposals_metric_id ON public.rfc_proposals(metric_id);
CREATE INDEX idx_rfc_proposals_status ON public.rfc_proposals(status);
CREATE INDEX idx_rfc_proposals_proposal_type ON public.rfc_proposals(proposal_type);
CREATE INDEX idx_rfc_proposals_created_at ON public.rfc_proposals(created_at DESC);
CREATE INDEX idx_rfc_proposals_reviewed_by ON public.rfc_proposals(reviewed_by) WHERE reviewed_by IS NOT NULL;
-- Enable Row Level Security
ALTER TABLE public.rfc_proposals ENABLE ROW LEVEL SECURITY;
-- RLS Policies
-- Everyone can view RFC proposals
CREATE POLICY "Anyone can view RFC proposals"
  ON public.rfc_proposals
  FOR SELECT
  USING (true);
-- Authenticated users can insert their own proposals
CREATE POLICY "Users can insert their own RFC proposals"
  ON public.rfc_proposals
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
-- Users can update their own pending proposals
CREATE POLICY "Users can update their own pending proposals"
  ON public.rfc_proposals
  FOR UPDATE
  USING (auth.uid() = user_id AND status = 'pending');
-- Admins can update any proposal (for review)
CREATE POLICY "Admins can update any RFC proposal"
  ON public.rfc_proposals
  FOR UPDATE
  USING (public.is_admin());
-- Users can delete their own pending proposals
CREATE POLICY "Users can delete their own pending proposals"
  ON public.rfc_proposals
  FOR DELETE
  USING (auth.uid() = user_id AND status = 'pending');
-- Create updated_at trigger
CREATE TRIGGER set_rfc_proposals_updated_at
  BEFORE UPDATE ON public.rfc_proposals
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
-- Comments
COMMENT ON TABLE public.rfc_proposals IS 'Structured RFC proposals for modifying or creating metrics';
COMMENT ON COLUMN public.rfc_proposals.proposal_type IS 'Type: modify_existing or new_metric';
COMMENT ON COLUMN public.rfc_proposals.rationale IS 'Required: explanation for the proposed change';
COMMENT ON COLUMN public.rfc_proposals.rich_entries IS 'Optional: examples and detailed explanations';
COMMENT ON COLUMN public.rfc_proposals.status IS 'Workflow: pending → under_review → approved/rejected → implemented';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ RFC proposals table created successfully!';
  RAISE NOTICE 'New table: public.rfc_proposals';
  RAISE NOTICE 'Features: Structured fields for metric proposals, status workflow, review tracking';
END $$;
