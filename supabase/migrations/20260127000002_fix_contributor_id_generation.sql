-- =====================================================================
-- FIX: Contributor ID Generation and Handle New User Error Handling
-- Migration: 20260127000002_fix_contributor_id_generation.sql
-- =====================================================================
-- 1. Introduces a sequence for reliable contributor_id generation.
-- 2. Updates generate_contributor_id to use the sequence.
-- 3. Updates handle_new_user with proper search_path and error handling.
-- =====================================================================

-- Step 1: Create sequence
CREATE SEQUENCE IF NOT EXISTS public.contributor_id_seq;

-- Step 2: Sync sequence with existing data
DO $$
DECLARE
  max_id INTEGER;
BEGIN
  SELECT COALESCE(
    MAX(CAST(SUBSTRING(contributor_id FROM 5) AS INTEGER)),
    0
  ) INTO max_id
  FROM public.user_profiles
  WHERE contributor_id ~ '^FVS-[0-9]+$';

  -- Sync sequence
  IF max_id > 0 THEN
    PERFORM setval('public.contributor_id_seq', max_id);
  ELSE
    -- If no users, start at 1
    PERFORM setval('public.contributor_id_seq', 1, false);
  END IF;
  
  RAISE NOTICE ' synced contributor_id_seq to %', max_id;
END $$;

-- Step 3: Update generation function to use sequence
CREATE OR REPLACE FUNCTION public.generate_contributor_id()
RETURNS TEXT AS $$
DECLARE
  next_id INTEGER;
BEGIN
  -- Get next value from sequence
  next_id := nextval('public.contributor_id_seq');
  
  -- Format as FVS-XXXXX (5 digits, zero-padded)
  RETURN 'FVS-' || LPAD(next_id::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Update handle_new_user to include better error handling and search_path
-- We also explicitly set search_path to public to avoid any visibility issues
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $$
DECLARE
  oauth_provider_name TEXT;
  oauth_user_handle TEXT;
  user_role TEXT;
BEGIN
  BEGIN
    -- Extract OAuth provider
    oauth_provider_name := NEW.app_metadata->>'provider';

    -- Extract OAuth handle based on provider
    oauth_user_handle := CASE
      WHEN oauth_provider_name = 'github'
        THEN NEW.raw_user_meta_data->>'user_name'
      WHEN oauth_provider_name = 'twitter'
        THEN NEW.raw_user_meta_data->>'user_name'
      WHEN oauth_provider_name = 'discord'
        THEN NEW.raw_user_meta_data->>'full_name'
      ELSE NULL
    END;

    -- Determine user role (default: user)
    -- Logic replicated from 20260126000002_add_beta_feature_flag.sql
    user_role := 'user';

    INSERT INTO public.user_profiles (
      user_id,
      role,
      full_name,
      contributor_id,
      pseudonym,
      anonymous,
      last_pseudonym_change,
      oauth_provider,
      oauth_handle,
      beta_features_enabled
    )
    VALUES (
        NEW.id,
        user_role,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            split_part(NEW.email, '@', 1)
        ),
        public.generate_contributor_id(),
        public.generate_default_pseudonym(),
        true,  -- Default to anonymous
        NOW(),
        oauth_provider_name,
        oauth_user_handle,
        (user_role IN ('contributor', 'admin'))
    );
    
    RETURN NEW;
    
  EXCEPTION WHEN OTHERS THEN
    -- Log the error for admin debug
    RAISE LOG 'Error in handle_new_user: %', SQLERRM;
    -- Raise a clear exception that might surface in Auth logs/response
    RAISE EXCEPTION 'Database error saving new user (Extended): %', SQLERRM;
  END;
END;
$$ LANGUAGE plpgsql;

-- Verification
DO $$
BEGIN
  RAISE NOTICE '✅ Fixed contributor_id generation (using sequence) and added error handling to handle_new_user';
END $$;
