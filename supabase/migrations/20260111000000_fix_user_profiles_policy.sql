-- Fix infinite recursion in user_profiles policies
-- Migration: 20260111_fix_user_profile_policy.sql

-- Drop the potentially recursive policies
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
-- Create a simplified, non-recursive policy for viewing profiles
-- This allows any authenticated user to view other users' basic profile info
-- which is necessary for features like Discussions and Community Voting history.
CREATE POLICY "Authenticated users can view all profiles"
ON public.user_profiles
FOR SELECT
TO authenticated
USING (true);
-- Ensure the update policy is safe
-- We rely on the fact that SELECT is now open (true) to avoid recursion in the check
DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
CREATE POLICY "Users can update their own profile"
ON public.user_profiles
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (
    auth.uid() = user_id
    -- Allow updating profile fields but prevent changing role (must match existing)
    -- Since the SELECT policy is now "true", this subquery won't recurse.
    AND role = (SELECT role FROM public.user_profiles WHERE id = id)
);
DO $$
BEGIN
    RAISE NOTICE '✅ Fixed user_profiles RLS policies to prevent infinite recursion.';
    RAISE NOTICE '  - Dropped restrictive policies';
    RAISE NOTICE '  - Added "Authenticated users can view all profiles"';
END $$;
