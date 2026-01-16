-- =====================================================================
-- ENSURE ADMIN ACCESS FOR ed209m@gmail.com
-- Migration: 20260126000003_ensure_ed209m_admin_access.sql
-- =====================================================================
-- This migration GUARANTEES that ed209m retains full admin access
-- after the anonymity system migrations. It is IDEMPOTENT and safe
-- to run multiple times.
-- =====================================================================

DO $$
DECLARE
  v_user_id UUID;
  v_current_role TEXT;
  v_profile_exists BOOLEAN;
BEGIN
  -- Step 1: Find ed209m's user_id from auth.users
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email ILIKE '%ed209m%'
  LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE WARNING '⚠️  User ed209m@gmail.com not found in auth.users. Skipping.';
    RETURN;
  END IF;

  RAISE NOTICE 'Found ed209m user_id: %', v_user_id;

  -- Step 2: Check if profile exists
  SELECT EXISTS (
    SELECT 1 FROM public.user_profiles WHERE user_id = v_user_id
  ) INTO v_profile_exists;

  -- Step 3: Check current role
  SELECT role INTO v_current_role
  FROM public.user_profiles
  WHERE user_id = v_user_id;

  -- Step 4: Ensure profile exists with admin role and beta access
  IF NOT v_profile_exists THEN
    -- Profile doesn't exist - create it (shouldn't happen, but handle it)
    INSERT INTO public.user_profiles (
      user_id,
      role,
      full_name,
      contributor_id,
      pseudonym,
      beta_features_enabled,
      anonymous,
      last_pseudonym_change
    )
    VALUES (
      v_user_id,
      'admin',
      'Clark Kent',
      public.generate_contributor_id(),
      public.generate_default_pseudonym(),
      true,  -- Beta access for admin
      true,
      NOW()
    );

    RAISE NOTICE '✅ Created admin profile for ed209m@gmail.com';
  ELSE
    -- Profile exists - ensure role is admin and beta access enabled
    UPDATE public.user_profiles
    SET
      role = 'admin',  -- Force admin role
      beta_features_enabled = true,  -- Ensure beta access
      updated_at = NOW()
    WHERE user_id = v_user_id;

    RAISE NOTICE '✅ Updated admin access for ed209m@gmail.com';
    RAISE NOTICE '   - Previous role: %', v_current_role;
    RAISE NOTICE '   - New role: admin';
    RAISE NOTICE '   - Beta access: enabled';
  END IF;

  -- Step 5: Verify the fix
  SELECT role INTO v_current_role
  FROM public.user_profiles
  WHERE user_id = v_user_id;

  IF v_current_role = 'admin' THEN
    RAISE NOTICE '✅✅ VERIFICATION PASSED: ed209m has admin role';
  ELSE
    RAISE WARNING '❌ VERIFICATION FAILED: ed209m role is %, expected admin', v_current_role;
  END IF;

END $$;

-- Final verification query
SELECT
  up.user_id,
  au.email,
  up.role,
  up.full_name,
  up.contributor_id,
  up.pseudonym,
  up.beta_features_enabled,
  up.created_at,
  up.updated_at
FROM public.user_profiles up
JOIN auth.users au ON au.id = up.user_id
WHERE au.email ILIKE '%ed209m%';

-- Test admin functions
DO $$
DECLARE
  v_user_id UUID;
  v_is_admin BOOLEAN;
  v_is_contributor BOOLEAN;
BEGIN
  SELECT id INTO v_user_id
  FROM auth.users
  WHERE email ILIKE '%ed209m%'
  LIMIT 1;

  -- Note: These functions check auth.uid(), so they won't work in migration context
  -- They need to be tested by logging in as ed209m

  RAISE NOTICE '';
  RAISE NOTICE '📋 ADMIN ACCESS CHECKLIST:';
  RAISE NOTICE '   ☐ 1. Log in as ed209m@gmail.com';
  RAISE NOTICE '   ☐ 2. Run: SELECT public.is_admin(); (should return true)';
  RAISE NOTICE '   ☐ 3. Run: SELECT public.is_contributor(); (should return true)';
  RAISE NOTICE '   ☐ 4. Navigate to /admin route (should have access)';
  RAISE NOTICE '   ☐ 5. Navigate to /profile route (should have beta access)';
  RAISE NOTICE '   ☐ 6. Can view all users in admin panel';
  RAISE NOTICE '';

END $$;

-- =====================================================================
-- WHAT THIS MIGRATION DOES
-- =====================================================================

-- ✅ Finds ed209m@gmail.com in auth.users
-- ✅ Ensures profile exists in user_profiles
-- ✅ Forces role = 'admin' (even if it was changed)
-- ✅ Enables beta_features_enabled = true (Phase 1 access)
-- ✅ Preserves all other data (contributor_id, pseudonym, etc.)
-- ✅ Idempotent (safe to run multiple times)
-- ✅ Does not affect other users

-- =====================================================================
-- WHY THIS IS NEEDED
-- =====================================================================

-- While the anonymity migrations (20260126000000, 20260126000002) do NOT
-- modify the role column, this migration provides extra assurance that:
--
-- 1. If role was accidentally changed → it's restored to admin
-- 2. Beta access is explicitly enabled (for Phase 1 rollout)
-- 3. Profile exists with all required new columns
-- 4. Admin can access /profile routes during beta
--
-- This is a SAFETY migration, not a FIX for a known issue.

-- =====================================================================
-- ROLLBACK (if needed)
-- =====================================================================

/*
-- To revert this migration (NOT RECOMMENDED):
-- Just restore the previous role from backup if needed

UPDATE public.user_profiles
SET role = 'previous_role_value'
WHERE user_id IN (
  SELECT id FROM auth.users WHERE email ILIKE '%ed209m%'
);
*/

-- =====================================================================

COMMENT ON FUNCTION public.generate_contributor_id IS 'Auto-generate sequential contributor IDs (FVS-XXXXX)';
COMMENT ON FUNCTION public.generate_default_pseudonym IS 'Auto-generate unique pseudonyms for new users';
