-- =====================================================================
-- ROLLBACK: Anonymity System Migration
-- Migration: 20260126000001_rollback_anonymity_system.sql
-- =====================================================================
-- This migration REVERTS all changes from 20260126000000_add_anonymity_system.sql
-- Run this if you need to rollback the anonymity features
-- =====================================================================

-- IMPORTANT: Only run this if you need to rollback!
-- Uncomment the DO block below to enable rollback

/*

DO $$
BEGIN
  RAISE NOTICE '⚠️  WARNING: Rolling back anonymity system...';
  RAISE NOTICE 'This will remove contributor IDs, pseudonyms, and OAuth verification.';
END $$;

-- Step 1: Drop view
DROP VIEW IF EXISTS public.public_profiles;

-- Step 2: Drop functions
DROP FUNCTION IF EXISTS public.unlink_oauth_handle();
DROP FUNCTION IF EXISTS public.verify_oauth_handle();
DROP FUNCTION IF EXISTS public.update_pseudonym(TEXT);
DROP FUNCTION IF EXISTS public.check_pseudonym_available(TEXT);
DROP FUNCTION IF EXISTS public.generate_default_pseudonym();
DROP FUNCTION IF EXISTS public.generate_contributor_id();

-- Step 3: Revert handle_new_user trigger to original version
-- (You'll need to restore the original version from your previous migration)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id, role, full_name)
    VALUES (
        NEW.id,
        'user',
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            split_part(NEW.email, '@', 1)
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Drop indexes
DROP INDEX IF EXISTS idx_user_profiles_oauth_verified;
DROP INDEX IF EXISTS idx_user_profiles_anonymous;
DROP INDEX IF EXISTS idx_user_profiles_pseudonym;
DROP INDEX IF EXISTS idx_user_profiles_contributor_id;
DROP INDEX IF EXISTS idx_user_profiles_pseudonym_unique;
DROP INDEX IF EXISTS idx_user_profiles_contributor_id_unique;

-- Step 5: Drop columns from user_profiles
ALTER TABLE public.user_profiles
DROP COLUMN IF EXISTS oauth_profile_url,
DROP COLUMN IF EXISTS oauth_verified_at,
DROP COLUMN IF EXISTS oauth_verified,
DROP COLUMN IF EXISTS oauth_handle,
DROP COLUMN IF EXISTS oauth_provider,
DROP COLUMN IF EXISTS show_in_leaderboard,
DROP COLUMN IF EXISTS allow_public_profile,
DROP COLUMN IF EXISTS last_pseudonym_change,
DROP COLUMN IF EXISTS anonymous,
DROP COLUMN IF EXISTS avatar_url,
DROP COLUMN IF EXISTS bio,
DROP COLUMN IF EXISTS pseudonym,
DROP COLUMN IF EXISTS contributor_id;

DO $$
BEGIN
  RAISE NOTICE '✅ Anonymity system rollback completed!';
  RAISE NOTICE 'All anonymity features have been removed.';
  RAISE NOTICE 'User profiles reverted to original schema.';
END $$;

*/

-- Keep this migration file but leave it commented out
-- This serves as documentation for how to rollback if needed
DO $$
BEGIN
  RAISE NOTICE '📝 Rollback migration exists but is DISABLED (commented out)';
  RAISE NOTICE 'To rollback anonymity system, edit this file and uncomment the code block.';
END $$;
