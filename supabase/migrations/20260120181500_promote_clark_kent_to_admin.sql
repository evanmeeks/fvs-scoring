-- =====================================================================
-- Promote Clark Kent (ed209m@gmail.com) to Admin
-- =====================================================================
-- Ensures the user profile exists and sets the role to admin.
-- Uses the known Supabase auth user ID to avoid email case issues.
-- =====================================================================

DO $$
DECLARE
    v_user_id   uuid := '0956a3e7-0848-468f-88b2-d38727f87514';
    v_email     text := 'ed209m@gmail.com';
    v_full_name text := 'Clark Kent';
BEGIN
    -- Verify user exists in auth.users
    IF NOT EXISTS (
        SELECT 1 FROM auth.users WHERE id = v_user_id AND email = v_email
    ) THEN
        RAISE WARNING '⚠️  User % (% ) not found in auth.users. Promotion skipped.', v_email, v_user_id;
        RETURN;
    END IF;

    -- Ensure a user_profile exists; insert if missing
    IF NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE user_id = v_user_id) THEN
        INSERT INTO public.user_profiles (user_id, role, full_name, is_verified)
        VALUES (v_user_id, 'admin', v_full_name, true);
    ELSE
        UPDATE public.user_profiles
        SET
            role = 'admin',
            full_name = COALESCE(full_name, v_full_name),
            is_verified = COALESCE(is_verified, true),
            updated_at = NOW()
        WHERE user_id = v_user_id;
    END IF;

    RAISE NOTICE '✅ User % (% ) has been promoted to admin.', v_email, v_user_id;
END $$;
