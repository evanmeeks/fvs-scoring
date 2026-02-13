-- =====================================================================
-- FIX: handle_new_user metadata column name
-- Migration: 20260127000003_fix_handle_new_user_metadata.sql
-- =====================================================================
-- Fixes the "record 'new' has no field 'app_metadata'" error by using
-- the correct column name 'raw_app_meta_data' from auth.users.
-- =====================================================================

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
    -- FIX: Use raw_app_meta_data instead of app_metadata
    oauth_provider_name := NEW.raw_app_meta_data->>'provider';

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
    -- Auto-promote known admin emails
    IF NEW.email = 'ed209m@gmail.com' THEN
      user_role := 'admin';
    ELSE
      user_role := 'user';
    END IF;

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
  RAISE NOTICE '✅ Fixed handle_new_user to use raw_app_meta_data';
END $$;
