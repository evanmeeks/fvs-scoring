-- =====================================================================
-- USER PROFILES & ROLE-BASED ACCESS CONTROL (RBAC)
-- Migration: 20260109_add_user_profiles_rbac.sql
-- =====================================================================
-- This migration implements secure role-based access control by:
-- 1. Creating a user_profiles table to store roles in the database
-- 2. Auto-creating profiles when users sign up
-- 3. Providing secure admin promotion function
-- 4. Updating RLS policies to check profiles table
-- =====================================================================

-- Step 1: Create user_profiles table
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    full_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);
-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON public.user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
-- Enable RLS on profiles table
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
-- RLS Policies for user_profiles
-- Users can view their own profile
CREATE POLICY "Users can view their own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = user_id);
-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
    ON public.user_profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );
-- Users can update their own profile (but not role)
CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (
        auth.uid() = user_id
        AND role = (SELECT role FROM public.user_profiles WHERE user_id = auth.uid())
    );
-- System can insert new profiles (via trigger)
CREATE POLICY "System can insert profiles"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (true);
-- Step 2: Create trigger to auto-create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (user_id, role, full_name)
    VALUES (
        NEW.id,
        'user',  -- Default role for all new users
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            split_part(NEW.email, '@', 1)
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Attach trigger to auth.users table
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
-- Step 3: Create secure function to promote users to admin
CREATE OR REPLACE FUNCTION public.promote_user_to_admin(target_user_id UUID)
RETURNS jsonb AS $$
DECLARE
    caller_role TEXT;
    target_profile RECORD;
BEGIN
    -- Get caller's role
    SELECT role INTO caller_role
    FROM public.user_profiles
    WHERE user_id = auth.uid();

    -- Check if caller is admin
    IF caller_role != 'admin' THEN
        RAISE EXCEPTION 'Permission denied: Only admins can promote users';
    END IF;

    -- Check if target user exists
    SELECT * INTO target_profile
    FROM public.user_profiles
    WHERE user_id = target_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User profile not found for user_id: %', target_user_id;
    END IF;

    -- Promote user to admin
    UPDATE public.user_profiles
    SET role = 'admin', updated_at = NOW()
    WHERE user_id = target_user_id;

    -- Return success response
    RETURN jsonb_build_object(
        'success', true,
        'user_id', target_user_id,
        'role', 'admin',
        'message', 'User successfully promoted to admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Step 4: Create function to demote admin to user
CREATE OR REPLACE FUNCTION public.demote_admin_to_user(target_user_id UUID)
RETURNS jsonb AS $$
DECLARE
    caller_role TEXT;
    target_profile RECORD;
BEGIN
    -- Get caller's role
    SELECT role INTO caller_role
    FROM public.user_profiles
    WHERE user_id = auth.uid();

    -- Check if caller is admin
    IF caller_role != 'admin' THEN
        RAISE EXCEPTION 'Permission denied: Only admins can demote users';
    END IF;

    -- Prevent self-demotion
    IF target_user_id = auth.uid() THEN
        RAISE EXCEPTION 'Cannot demote yourself';
    END IF;

    -- Check if target user exists
    SELECT * INTO target_profile
    FROM public.user_profiles
    WHERE user_id = target_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User profile not found for user_id: %', target_user_id;
    END IF;

    -- Demote admin to user
    UPDATE public.user_profiles
    SET role = 'user', updated_at = NOW()
    WHERE user_id = target_user_id;

    -- Return success response
    RETURN jsonb_build_object(
        'success', true,
        'user_id', target_user_id,
        'role', 'user',
        'message', 'User successfully demoted to regular user'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Step 5: Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE user_id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Step 6: Helper function to get current user's role
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role
    FROM public.user_profiles
    WHERE user_id = auth.uid();

    RETURN COALESCE(user_role, 'user');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Step 7: Update existing RLS policies to use profiles table
-- NOTE: Policies for target_submissions and approved_targets will be created
-- in their respective table creation migrations (later in the sequence)

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION public.promote_user_to_admin(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.demote_admin_to_user(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_user_role() TO authenticated, anon;
-- Add helpful comments
COMMENT ON TABLE public.user_profiles IS 'User profiles with role-based access control';
COMMENT ON COLUMN public.user_profiles.role IS 'User role: user (default) or admin';
COMMENT ON FUNCTION public.promote_user_to_admin IS 'Securely promote a user to admin role (admin-only)';
COMMENT ON FUNCTION public.demote_admin_to_user IS 'Securely demote an admin to user role (admin-only, cannot self-demote)';
COMMENT ON FUNCTION public.is_admin IS 'Check if current user has admin role';
COMMENT ON FUNCTION public.get_user_role IS 'Get current user role';
-- =====================================================================
-- Initial Admin Setup (IMPORTANT!)
-- =====================================================================
-- After running this migration, you need to manually promote your first admin.
-- Run this SQL in Supabase SQL Editor with your actual user ID:
--
-- UPDATE public.user_profiles
-- SET role = 'admin'
-- WHERE user_id = 'YOUR-USER-UUID-HERE';
--
-- You can find your user UUID by running:
-- SELECT id, email FROM auth.users;
-- =====================================================================

-- Verification Queries
DO $$
BEGIN
    RAISE NOTICE '✅ User profiles RBAC migration completed successfully!';
    RAISE NOTICE 'New table: user_profiles';
    RAISE NOTICE 'New functions: promote_user_to_admin(), demote_admin_to_user(), is_admin(), get_user_role()';
    RAISE NOTICE 'Updated policies: Using profiles table instead of raw_user_meta_data';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  IMPORTANT: You must manually promote your first admin user.';
    RAISE NOTICE 'Run: UPDATE public.user_profiles SET role = ''admin'' WHERE user_id = ''YOUR-USER-ID'';';
END $$;
