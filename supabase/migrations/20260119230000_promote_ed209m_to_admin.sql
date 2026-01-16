-- =====================================================================
-- Promote ed209m@gmail.com to Admin
-- Migration: 20260119230000_promote_ed209m_to_admin.sql
-- =====================================================================

DO $$
DECLARE
    v_user_id UUID;
BEGIN
    -- unique email for target user
    SELECT id INTO v_user_id
    FROM auth.users
    WHERE email = 'ed209m@gmail.com';

    IF v_user_id IS NOT NULL THEN
        -- Update the user's profile to admin
        UPDATE public.user_profiles
        SET role = 'admin',
            updated_at = NOW()
        WHERE user_id = v_user_id;

        RAISE NOTICE '✅ User ed209m@gmail.com has been promoted to admin.';
    ELSE
        RAISE WARNING '⚠️  User ed209m@gmail.com not found in auth.users. Migration skipped for this user.';
    END IF;
END $$;
