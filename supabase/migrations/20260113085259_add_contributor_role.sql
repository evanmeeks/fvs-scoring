-- =====================================================================
-- ADD CONTRIBUTOR ROLE
-- Migration: 20260113085259_add_contributor_role.sql
-- =====================================================================

-- 1. Update user_profiles check constraint to include 'contributor'
ALTER TABLE public.user_profiles
DROP CONSTRAINT IF EXISTS user_profiles_role_check;
ALTER TABLE public.user_profiles
ADD CONSTRAINT user_profiles_role_check
CHECK (role IN ('user', 'contributor', 'admin'));
-- 2. Check if user is contributor (or admin)
-- Contributors have access to scoring and review features.
-- Admins implicitly have contributor access.
CREATE OR REPLACE FUNCTION public.is_contributor()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE user_id = auth.uid() 
        AND role IN ('contributor', 'admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- 3. Promote user to contributor (Admin only)
CREATE OR REPLACE FUNCTION public.promote_user_to_contributor(target_user_id UUID)
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

    -- Promote user to contributor
    UPDATE public.user_profiles
    SET role = 'contributor', updated_at = NOW()
    WHERE user_id = target_user_id;

    RETURN jsonb_build_object(
        'success', true,
        'user_id', target_user_id,
        'role', 'contributor',
        'message', 'User successfully promoted to contributor'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- 4. Demote contributor to user (Admin only)
CREATE OR REPLACE FUNCTION public.demote_contributor_to_user(target_user_id UUID)
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

    -- Check if target user exists
    SELECT * INTO target_profile
    FROM public.user_profiles
    WHERE user_id = target_user_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'User profile not found for user_id: %', target_user_id;
    END IF;

    -- Prevent demoting another admin (must use demote_admin_to_user for that)
    IF target_profile.role = 'admin' THEN
        RAISE EXCEPTION 'Target is an admin. Use demote_admin_to_user instead.';
    END IF;

    -- Demote to user
    UPDATE public.user_profiles
    SET role = 'user', updated_at = NOW()
    WHERE user_id = target_user_id;

    RETURN jsonb_build_object(
        'success', true,
        'user_id', target_user_id,
        'role', 'user',
        'message', 'User successfully demoted to regular user'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Grant permissions
GRANT EXECUTE ON FUNCTION public.is_contributor() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.promote_user_to_contributor(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.demote_contributor_to_user(UUID) TO authenticated;
-- Comment
COMMENT ON FUNCTION public.is_contributor IS 'Check if current user has contributor role (or admin)';
