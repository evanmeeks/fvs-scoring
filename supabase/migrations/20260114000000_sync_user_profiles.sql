-- =====================================================================
-- SYNC USER PROFILES (AUTO-BACKFILL)
-- Migration: 20260114000000_sync_user_profiles.sql
-- =====================================================================
-- This migration automatically backfills missing user profiles.
-- It works by finding users in auth.users that don't have a corresponding
-- record in public.user_profiles and inserting them immediately.
-- =====================================================================

DO $$
DECLARE
    inserted_count INTEGER;
BEGIN
    -- Insert missing profiles
    WITH new_profiles AS (
        INSERT INTO public.user_profiles (user_id, role, full_name)
        SELECT 
            au.id,
            'user', -- Default role
            COALESCE(
                au.raw_user_meta_data->>'full_name',
                split_part(au.email, '@', 1)
            )
        FROM auth.users au
        LEFT JOIN public.user_profiles up ON au.id = up.user_id
        WHERE up.id IS NULL
        RETURNING 1
    )
    SELECT COUNT(*) INTO inserted_count FROM new_profiles;

    RAISE NOTICE 'Successfully synced % user profiles', inserted_count;
END $$;
