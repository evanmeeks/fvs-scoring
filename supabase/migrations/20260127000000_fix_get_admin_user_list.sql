-- =====================================================================
-- FIX: ADMIN USER LIST WITH EMAILS
-- Migration: 20260127000000_fix_get_admin_user_list.sql
-- =====================================================================
-- This migration fixes the get_admin_user_list function by adding the
-- proper search_path configuration, which is required for SECURITY DEFINER
-- functions to access the auth schema in Supabase.
-- =====================================================================

CREATE OR REPLACE FUNCTION public.get_admin_user_list()
RETURNS TABLE (
  id uuid,
  email text,
  role text,
  full_name text,
  created_at timestamptz,
  is_verified boolean,
  location text,
  website text,
  bio text,
  contributor_id text,
  pseudonym text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Check if the caller is an admin
  IF NOT EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE user_id = auth.uid() AND role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  RETURN QUERY
  SELECT
    p.user_id as id,
    au.email::text as email,
    p.role,
    p.full_name,
    p.created_at,
    p.oauth_verified as is_verified,
    COALESCE(p.location, '') as location,
    COALESCE(p.website, '') as website,
    COALESCE(p.bio, '') as bio,
    COALESCE(p.contributor_id, '') as contributor_id,
    COALESCE(p.pseudonym, '') as pseudonym
  FROM public.user_profiles p
  JOIN auth.users au ON p.user_id = au.id
  ORDER BY p.created_at DESC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_user_list() TO authenticated;

COMMENT ON FUNCTION public.get_admin_user_list IS 'Get full user list with emails (Admin only) - Fixed with proper search_path';

-- Verification
DO $$
BEGIN
  RAISE NOTICE '✅ get_admin_user_list function updated with search_path configuration';
  RAISE NOTICE 'Function is now properly configured to access auth.users table';
END $$;
