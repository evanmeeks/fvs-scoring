-- =====================================================================
-- EXTEND EXISTING TABLES
-- Migration: 20260110_06_extend_existing_tables.sql
-- =====================================================================
-- This migration extends existing tables with new columns to capture
-- additional user input data that was previously missing.
-- =====================================================================

-- =====================================================================
-- 1. EXTEND TARGETS TABLE
-- =====================================================================
-- Add metadata fields from target_submissions

ALTER TABLE public.targets
  ADD COLUMN IF NOT EXISTS source_url TEXT,
  ADD COLUMN IF NOT EXISTS claim_date DATE,
  ADD COLUMN IF NOT EXISTS primary_source TEXT,
  ADD COLUMN IF NOT EXISTS tags TEXT[];
-- Migrate data from approved_targets if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approved_targets') THEN
    -- Update existing targets with data from approved_targets
    UPDATE public.targets t
    SET
      source_url = COALESCE(t.source_url, at.source_url),
      claim_date = COALESCE(t.claim_date, at.claim_date),
      primary_source = COALESCE(t.primary_source, at.primary_source)
    FROM public.approved_targets at
    WHERE t.id = at.id;

    -- Insert any targets from approved_targets that don't exist in targets
    INSERT INTO public.targets (
      id, name, case_id, origin, context, verified, description,
      source_url, claim_date, primary_source
    )
    SELECT
      id, name, case_id, origin, context, verified, description,
      source_url, claim_date, primary_source
    FROM public.approved_targets
    ON CONFLICT (id) DO NOTHING;

    RAISE NOTICE '✅ Migrated data from approved_targets to targets';
  END IF;
END $$;
COMMENT ON COLUMN public.targets.source_url IS 'Primary source URL for the disclosure';
COMMENT ON COLUMN public.targets.claim_date IS 'Date when the disclosure occurred';
COMMENT ON COLUMN public.targets.primary_source IS 'Name of the primary source/whistleblower';
COMMENT ON COLUMN public.targets.tags IS 'Array of tags for categorization';
-- =====================================================================
-- 2. EXTEND USER_SCORES TABLE
-- =====================================================================
-- Add confidence level and score type to distinguish slider vs button votes

ALTER TABLE public.user_scores
  ADD COLUMN IF NOT EXISTS confidence_level TEXT CHECK (confidence_level IN ('low', 'medium', 'high')),
  ADD COLUMN IF NOT EXISTS score_type TEXT DEFAULT 'slider' CHECK (score_type IN ('slider', 'button'));
-- Create index on score_type for filtering
CREATE INDEX IF NOT EXISTS idx_user_scores_score_type ON public.user_scores(score_type);
COMMENT ON COLUMN public.user_scores.confidence_level IS 'User confidence in their score (optional)';
COMMENT ON COLUMN public.user_scores.score_type IS 'Whether score came from slider or button interface';
-- =====================================================================
-- 3. EXTEND USER_PROFILES TABLE
-- =====================================================================
-- Add user profile enhancements

ALTER TABLE public.user_profiles
  ADD COLUMN IF NOT EXISTS avatar_url TEXT,
  ADD COLUMN IF NOT EXISTS bio TEXT,
  ADD COLUMN IF NOT EXISTS location TEXT,
  ADD COLUMN IF NOT EXISTS website TEXT,
  ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;
COMMENT ON COLUMN public.user_profiles.avatar_url IS 'URL to user avatar image';
COMMENT ON COLUMN public.user_profiles.bio IS 'User biography/description';
COMMENT ON COLUMN public.user_profiles.location IS 'User location (optional)';
COMMENT ON COLUMN public.user_profiles.website IS 'User website URL';
COMMENT ON COLUMN public.user_profiles.is_verified IS 'Whether user is verified contributor';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Existing tables extended successfully!';
  RAISE NOTICE 'Extended tables:';
  RAISE NOTICE '  - public.targets: +4 columns (source_url, claim_date, primary_source, tags)';
  RAISE NOTICE '  - public.user_scores: +2 columns (confidence_level, score_type)';
  RAISE NOTICE '  - public.user_profiles: +5 columns (avatar_url, bio, location, website, is_verified)';
END $$;
