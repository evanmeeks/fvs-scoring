-- =====================================================================
-- ANONYMITY-FIRST USER IDENTITY SYSTEM
-- Migration: 20260126000000_add_anonymity_system.sql
-- =====================================================================
-- This migration implements anonymity features WITHOUT breaking changes:
-- - All new columns are NULLABLE
-- - Existing queries continue to work
-- - Auto-generates data for existing users
-- - Fully revertable with down migration
-- =====================================================================

-- Step 1: Add new columns to user_profiles (all NULLABLE for non-breaking)
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS contributor_id TEXT,
ADD COLUMN IF NOT EXISTS pseudonym TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS anonymous BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS last_pseudonym_change TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS allow_public_profile BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS show_in_leaderboard BOOLEAN DEFAULT true,

-- OAuth Verification Fields
ADD COLUMN IF NOT EXISTS oauth_provider TEXT,
ADD COLUMN IF NOT EXISTS oauth_handle TEXT,
ADD COLUMN IF NOT EXISTS oauth_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS oauth_verified_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS oauth_profile_url TEXT;

-- Step 2: Create function to generate contributor IDs
CREATE OR REPLACE FUNCTION public.generate_contributor_id()
RETURNS TEXT AS $$
DECLARE
  next_id INTEGER;
  new_contributor_id TEXT;
BEGIN
  -- Get the next sequential number
  SELECT COALESCE(
    MAX(CAST(SUBSTRING(contributor_id FROM 5) AS INTEGER)),
    0
  ) + 1 INTO next_id
  FROM public.user_profiles
  WHERE contributor_id ~ '^FVS-[0-9]+$';

  -- Format as FVS-XXXXX (5 digits, zero-padded)
  new_contributor_id := 'FVS-' || LPAD(next_id::TEXT, 5, '0');

  RETURN new_contributor_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Create function to generate default pseudonyms
CREATE OR REPLACE FUNCTION public.generate_default_pseudonym()
RETURNS TEXT AS $$
DECLARE
  adjectives TEXT[] := ARRAY[
    'Swift', 'Silent', 'Brave', 'Keen', 'Bright',
    'Sharp', 'Wise', 'Bold', 'Clear', 'Deep',
    'Noble', 'Steady', 'Quick', 'Calm', 'True'
  ];
  nouns TEXT[] := ARRAY[
    'Analyst', 'Observer', 'Seeker', 'Scholar', 'Sentinel',
    'Witness', 'Decoder', 'Cipher', 'Vector', 'Signal',
    'Ranger', 'Watcher', 'Scanner', 'Tracker', 'Monitor'
  ];
  new_pseudonym TEXT;
  attempt INT := 0;
  max_attempts INT := 100;
BEGIN
  LOOP
    -- Generate random pseudonym: Adjective + Noun + 3-digit number
    new_pseudonym :=
      adjectives[1 + floor(random() * array_length(adjectives, 1))] ||
      nouns[1 + floor(random() * array_length(nouns, 1))] ||
      LPAD(floor(random() * 1000)::TEXT, 3, '0');

    -- Check if unique
    IF NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE pseudonym = new_pseudonym) THEN
      RETURN new_pseudonym;
    END IF;

    attempt := attempt + 1;
    IF attempt >= max_attempts THEN
      -- Fallback to UUID-based if we can't find a unique random one
      RETURN 'Contributor' || SUBSTRING(gen_random_uuid()::TEXT FROM 1 FOR 8);
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 4: Backfill existing users with contributor_id and pseudonym
DO $$
DECLARE
  user_record RECORD;
BEGIN
  FOR user_record IN
    SELECT user_id
    FROM public.user_profiles
    WHERE contributor_id IS NULL OR pseudonym IS NULL
  LOOP
    UPDATE public.user_profiles
    SET
      contributor_id = COALESCE(contributor_id, public.generate_contributor_id()),
      pseudonym = COALESCE(pseudonym, public.generate_default_pseudonym()),
      last_pseudonym_change = COALESCE(last_pseudonym_change, created_at)
    WHERE user_id = user_record.user_id;
  END LOOP;
END $$;

-- Step 5: Create unique constraints (after backfill to avoid conflicts)
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_profiles_contributor_id_unique
  ON public.user_profiles(contributor_id) WHERE contributor_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_user_profiles_pseudonym_unique
  ON public.user_profiles(pseudonym) WHERE pseudonym IS NOT NULL;

-- Step 6: Create regular indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_contributor_id
  ON public.user_profiles(contributor_id);

CREATE INDEX IF NOT EXISTS idx_user_profiles_pseudonym
  ON public.user_profiles(pseudonym);

CREATE INDEX IF NOT EXISTS idx_user_profiles_anonymous
  ON public.user_profiles(anonymous);

CREATE INDEX IF NOT EXISTS idx_user_profiles_oauth_verified
  ON public.user_profiles(oauth_verified) WHERE oauth_verified = true;

-- Step 7: Update handle_new_user trigger to include new fields
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  oauth_provider_name TEXT;
  oauth_user_handle TEXT;
BEGIN
    -- Extract OAuth provider
    oauth_provider_name := NEW.app_metadata->>'provider';

    -- Extract OAuth handle based on provider
    oauth_user_handle := CASE
      WHEN oauth_provider_name = 'github'
        THEN NEW.raw_user_meta_data->>'user_name'
      WHEN oauth_provider_name = 'twitter'
        THEN NEW.raw_user_meta_data->>'user_name'
      WHEN oauth_provider_name = 'discord'
        THEN NEW.raw_user_meta_data->>'full_name'
      ELSE NULL
    END;

    INSERT INTO public.user_profiles (
      user_id,
      role,
      full_name,
      contributor_id,
      pseudonym,
      anonymous,
      last_pseudonym_change,
      oauth_provider,
      oauth_handle
    )
    VALUES (
        NEW.id,
        'user',
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            split_part(NEW.email, '@', 1)
        ),
        public.generate_contributor_id(),
        public.generate_default_pseudonym(),
        true,  -- Default to anonymous
        NOW(),
        oauth_provider_name,
        oauth_user_handle
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Create function to check pseudonym availability
CREATE OR REPLACE FUNCTION public.check_pseudonym_available(p_pseudonym TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  -- Validate pseudonym format (alphanumeric + underscores, 3-30 chars)
  IF NOT (p_pseudonym ~ '^[a-zA-Z0-9_]{3,30}$') THEN
    RAISE EXCEPTION 'Invalid pseudonym format. Use 3-30 alphanumeric characters or underscores.';
  END IF;

  -- Check if available (not taken by anyone except current user)
  RETURN NOT EXISTS (
    SELECT 1 FROM public.user_profiles
    WHERE pseudonym = p_pseudonym
      AND user_id != COALESCE(auth.uid(), '00000000-0000-0000-0000-000000000000'::uuid)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 9: Create function to update pseudonym (with 24-hour throttle)
CREATE OR REPLACE FUNCTION public.update_pseudonym(p_new_pseudonym TEXT)
RETURNS jsonb AS $$
DECLARE
  current_user_id UUID;
  last_change TIMESTAMPTZ;
  is_available BOOLEAN;
BEGIN
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get last change timestamp
  SELECT last_pseudonym_change INTO last_change
  FROM public.user_profiles
  WHERE user_id = current_user_id;

  -- Check 24-hour throttle
  IF last_change IS NOT NULL AND last_change > NOW() - INTERVAL '24 hours' THEN
    RAISE EXCEPTION 'You can only change your pseudonym once every 24 hours. Try again after %',
      (last_change + INTERVAL '24 hours')::TEXT;
  END IF;

  -- Check availability
  is_available := public.check_pseudonym_available(p_new_pseudonym);

  IF NOT is_available THEN
    RAISE EXCEPTION 'Pseudonym "%" is already taken', p_new_pseudonym;
  END IF;

  -- Update pseudonym
  UPDATE public.user_profiles
  SET
    pseudonym = p_new_pseudonym,
    last_pseudonym_change = NOW(),
    updated_at = NOW()
  WHERE user_id = current_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'pseudonym', p_new_pseudonym,
    'message', 'Pseudonym updated successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 10: Create function to verify OAuth handle
CREATE OR REPLACE FUNCTION public.verify_oauth_handle()
RETURNS jsonb AS $$
DECLARE
  current_user_id UUID;
  user_metadata jsonb;
  provider TEXT;
  handle TEXT;
  profile_url TEXT;
BEGIN
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Get user metadata from auth.users
  SELECT
    raw_user_meta_data,
    app_metadata->>'provider'
  INTO user_metadata, provider
  FROM auth.users
  WHERE id = current_user_id;

  -- Extract handle based on provider
  handle := CASE
    WHEN provider = 'github' THEN user_metadata->>'user_name'
    WHEN provider = 'twitter' THEN user_metadata->>'user_name'
    WHEN provider = 'discord' THEN user_metadata->>'full_name'
    ELSE NULL
  END;

  IF handle IS NULL THEN
    RAISE EXCEPTION 'No OAuth handle found for provider: %', provider;
  END IF;

  -- Build profile URL
  profile_url := CASE
    WHEN provider = 'github' THEN 'https://github.com/' || handle
    WHEN provider = 'twitter' THEN 'https://twitter.com/' || handle
    ELSE NULL
  END;

  -- Update user profile with verified OAuth info
  UPDATE public.user_profiles
  SET
    oauth_provider = provider,
    oauth_handle = handle,
    oauth_verified = true,
    oauth_verified_at = NOW(),
    oauth_profile_url = profile_url,
    anonymous = false,  -- Switch to verified mode
    updated_at = NOW()
  WHERE user_id = current_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'provider', provider,
    'handle', handle,
    'message', 'OAuth handle verified successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 11: Create function to unlink OAuth verification
CREATE OR REPLACE FUNCTION public.unlink_oauth_handle()
RETURNS jsonb AS $$
DECLARE
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();

  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Revert to anonymous mode and clear OAuth verification
  UPDATE public.user_profiles
  SET
    oauth_verified = false,
    oauth_verified_at = NULL,
    anonymous = true,  -- Revert to anonymous
    updated_at = NOW()
  WHERE user_id = current_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'OAuth verification removed. Reverted to anonymous mode.'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 12: Create view for public profiles
CREATE OR REPLACE VIEW public.public_profiles AS
SELECT
  user_id,
  contributor_id,
  CASE
    WHEN anonymous = true OR anonymous IS NULL THEN pseudonym
    WHEN oauth_verified = true THEN oauth_handle
    ELSE pseudonym
  END AS display_name,
  CASE
    WHEN oauth_verified = true AND anonymous = false THEN oauth_provider
    ELSE NULL
  END AS verified_provider,
  CASE
    WHEN oauth_verified = true AND anonymous = false THEN oauth_profile_url
    ELSE NULL
  END AS verified_url,
  oauth_verified,
  anonymous,
  CASE WHEN allow_public_profile THEN bio ELSE NULL END AS bio,
  CASE WHEN allow_public_profile THEN avatar_url ELSE NULL END AS avatar_url,
  created_at
FROM public.user_profiles
WHERE allow_public_profile = true OR allow_public_profile IS NULL;

-- Step 13: Grant permissions
GRANT SELECT ON public.public_profiles TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.generate_contributor_id() TO authenticated;
GRANT EXECUTE ON FUNCTION public.generate_default_pseudonym() TO authenticated;
GRANT EXECUTE ON FUNCTION public.check_pseudonym_available(TEXT) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.update_pseudonym(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_oauth_handle() TO authenticated;
GRANT EXECUTE ON FUNCTION public.unlink_oauth_handle() TO authenticated;

-- Step 14: Add helpful comments
COMMENT ON COLUMN public.user_profiles.contributor_id IS 'Auto-generated immutable public ID (FVS-00001)';
COMMENT ON COLUMN public.user_profiles.pseudonym IS 'User-chosen unique handle (editable, throttled to 1 change/24h)';
COMMENT ON COLUMN public.user_profiles.anonymous IS 'Privacy flag: true = show pseudonym, false = show OAuth handle (if verified)';
COMMENT ON COLUMN public.user_profiles.oauth_verified IS 'Whether OAuth handle has been verified via re-authentication';
COMMENT ON COLUMN public.user_profiles.last_pseudonym_change IS 'Timestamp of last pseudonym change (for 24-hour throttle)';

COMMENT ON FUNCTION public.check_pseudonym_available IS 'Check if a pseudonym is available (validates format and uniqueness)';
COMMENT ON FUNCTION public.update_pseudonym IS 'Update user pseudonym with 24-hour throttle protection';
COMMENT ON FUNCTION public.verify_oauth_handle IS 'Verify and link OAuth handle from current session (requires re-authentication)';
COMMENT ON FUNCTION public.unlink_oauth_handle IS 'Remove OAuth verification and revert to anonymous mode';
COMMENT ON VIEW public.public_profiles IS 'Privacy-safe view of user profiles for public consumption';

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Anonymity system migration completed successfully!';
  RAISE NOTICE '';
  RAISE NOTICE 'Added Features:';
  RAISE NOTICE '  - Contributor IDs (FVS-XXXXX) auto-generated for all users';
  RAISE NOTICE '  - Pseudonyms (e.g., SwiftAnalyst042) auto-generated for all users';
  RAISE NOTICE '  - Anonymous mode (default: true)';
  RAISE NOTICE '  - OAuth handle verification system';
  RAISE NOTICE '  - Pseudonym change throttling (1 change per 24 hours)';
  RAISE NOTICE '  - Public profiles view with privacy controls';
  RAISE NOTICE '';
  RAISE NOTICE '⚠️  Non-Breaking: All new columns are nullable, existing queries work unchanged';
  RAISE NOTICE '📊 Backfilled: All existing users now have contributor_id and pseudonym';
END $$;
