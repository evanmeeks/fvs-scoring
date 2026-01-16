-- =====================================================================
-- FIX: Ambiguous column reference in get_admin_user_list
-- Migration: 20260127000001_fix_ambiguous_role_column.sql
-- =====================================================================
-- The previous fix added search_path but introduced an ambiguity issue
-- because both public.user_profiles and auth.users have a 'role' column.
-- This migration fully qualifies all column references to eliminate ambiguity.
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
  -- Fully qualify the role column to avoid ambiguity
  IF NOT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.user_id = auth.uid() AND up.role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: Admin privileges required';
  END IF;

  RETURN QUERY
  SELECT
    p.user_id as id,
    au.email::text as email,
    p.role as role,  -- Explicitly qualify to avoid ambiguity with auth.users.role
    p.full_name as full_name,
    p.created_at as created_at,
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

COMMENT ON FUNCTION public.get_admin_user_list IS 'Get full user list with emails (Admin only) - Fixed ambiguous column references';

-- Verification
DO $$
BEGIN
  RAISE NOTICE '✅ get_admin_user_list function updated with fully qualified column references';
  RAISE NOTICE 'Fixed: Ambiguous role column reference (both user_profiles and auth.users have role)';
END $$;
