-- =====================================================================
-- Ensure at least one admin user exists
-- Migration: 20260111001000_seed_first_admin.sql
-- =====================================================================
-- If no admin exists, promote the earliest user profile to admin.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM public.user_profiles
    WHERE role = 'admin'
  ) THEN
    UPDATE public.user_profiles
    SET role = 'admin',
        updated_at = NOW()
    WHERE user_id = (
      SELECT user_id
      FROM public.user_profiles
      ORDER BY created_at ASC
      LIMIT 1
    );
  END IF;
END;
$$;
