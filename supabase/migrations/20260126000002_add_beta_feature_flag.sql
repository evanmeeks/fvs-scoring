-- =====================================================================
-- BETA FEATURE FLAG FOR PHASED ROLLOUT
-- Migration: 20260126000002_add_beta_feature_flag.sql
-- =====================================================================
-- This migration adds a feature flag to control access to the new
-- anonymity system during phased rollout (contributors-only beta).
-- =====================================================================

-- Step 1: Add beta feature flag column
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS beta_features_enabled BOOLEAN DEFAULT false;

-- Step 2: Enable beta features for existing contributors and admins only
UPDATE public.user_profiles
SET beta_features_enabled = true
WHERE role IN ('contributor', 'admin');

-- Step 3: Create index for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_beta_features
  ON public.user_profiles(beta_features_enabled)
  WHERE beta_features_enabled = true;

-- Step 4: Update handle_new_user to set beta flag for new contributors/admins
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  oauth_provider_name TEXT;
  oauth_user_handle TEXT;
  user_role TEXT;
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
      beta_features_enabled  -- New field
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
        -- Enable beta for contributors/admins, disable for users
        (user_role IN ('contributor', 'admin'))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Create function to enable beta features for all users (Phase 2)
CREATE OR REPLACE FUNCTION public.enable_beta_features_all()
RETURNS jsonb AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Only admins can call this function
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Only admins can enable beta features for all users';
  END IF;

  -- Enable beta features for all users
  UPDATE public.user_profiles
  SET beta_features_enabled = true,
      updated_at = NOW()
  WHERE beta_features_enabled = false;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'users_updated', updated_count,
    'message', 'Beta features enabled for all users'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: Create function to disable beta features (emergency rollback)
CREATE OR REPLACE FUNCTION public.disable_beta_features_non_contributors()
RETURNS jsonb AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Only admins can call this function
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Only admins can disable beta features';
  END IF;

  -- Disable beta features for non-contributors/admins
  UPDATE public.user_profiles
  SET beta_features_enabled = false,
      updated_at = NOW()
  WHERE role NOT IN ('contributor', 'admin')
    AND beta_features_enabled = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'users_updated', updated_count,
    'message', 'Beta features disabled for non-contributors (emergency rollback)'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 7: Create function to check if beta features enabled for current user
CREATE OR REPLACE FUNCTION public.has_beta_access()
RETURNS BOOLEAN AS $$
DECLARE
  has_access BOOLEAN;
BEGIN
  SELECT beta_features_enabled INTO has_access
  FROM public.user_profiles
  WHERE user_id = auth.uid();

  RETURN COALESCE(has_access, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Grant permissions
GRANT EXECUTE ON FUNCTION public.enable_beta_features_all() TO authenticated;
GRANT EXECUTE ON FUNCTION public.disable_beta_features_non_contributors() TO authenticated;
GRANT EXECUTE ON FUNCTION public.has_beta_access() TO authenticated, anon;

-- Step 9: Add comments
COMMENT ON COLUMN public.user_profiles.beta_features_enabled IS 'Feature flag for phased rollout: enables access to /profile routes and anonymity features';
COMMENT ON FUNCTION public.enable_beta_features_all IS 'Admin-only: Enable beta features for all users (Phase 2 rollout)';
COMMENT ON FUNCTION public.disable_beta_features_non_contributors IS 'Admin-only: Emergency rollback - disable beta for non-contributors';
COMMENT ON FUNCTION public.has_beta_access IS 'Check if current user has beta feature access';

-- Success message
DO $$
DECLARE
  contributor_count INTEGER;
  total_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO contributor_count
  FROM public.user_profiles
  WHERE beta_features_enabled = true;

  SELECT COUNT(*) INTO total_count
  FROM public.user_profiles;

  RAISE NOTICE '✅ Beta feature flag migration completed!';
  RAISE NOTICE '';
  RAISE NOTICE 'Phase 1: Contributors-Only Beta';
  RAISE NOTICE '  - Beta access enabled for: % users (contributors + admins)', contributor_count;
  RAISE NOTICE '  - Total users: %', total_count;
  RAISE NOTICE '  - Feature flag column: beta_features_enabled';
  RAISE NOTICE '';
  RAISE NOTICE 'Route guards should check has_beta_access() to restrict /profile routes';
  RAISE NOTICE 'Phase 2: Run enable_beta_features_all() to open to all users';
  RAISE NOTICE 'Emergency: Run disable_beta_features_non_contributors() to rollback';
END $$;
