-- =====================================================================
-- Seed file: runs automatically after all migrations on `supabase db reset`
-- =====================================================================

-- Ensure known admin emails are promoted.
-- This handles the case where the user already exists in auth.users
-- (e.g., created by the demo data migration). The handle_new_user
-- trigger separately handles auto-promotion on fresh OAuth signup.
UPDATE public.user_profiles
SET role = 'admin', updated_at = NOW()
WHERE user_id IN (
  SELECT id FROM auth.users
  WHERE email IN (
    'ed209m@gmail.com'
    -- Add additional admin emails here as needed:
    -- , 'another-admin@example.com'
  )
)
AND role != 'admin';
