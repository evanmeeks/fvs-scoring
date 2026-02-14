


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "api";


ALTER SCHEMA "api" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "wrappers" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."approve_target_submission"("submission_id_param" "uuid", "target_id_param" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    submission_record RECORD;
BEGIN
    SELECT * INTO submission_record
    FROM public.target_submissions
    WHERE id = submission_id_param;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission not found';
    END IF;

    INSERT INTO public.targets (
        id,
        name,
        case_id,
        origin,
        context,
        verified,
        description,
        source_url,
        date_of_disclosure,
        primary_source
    ) VALUES (
        target_id_param,
        submission_record.target_name,
        submission_record.case_id,
        submission_record.origin,
        submission_record.context,
        true,
        submission_record.description,
        submission_record.source_url,
        submission_record.date_of_disclosure,
        submission_record.primary_source
    )
    ON CONFLICT (id) DO UPDATE
    SET
        name = EXCLUDED.name,
        case_id = EXCLUDED.case_id,
        origin = EXCLUDED.origin,
        context = EXCLUDED.context,
        verified = EXCLUDED.verified,
        description = EXCLUDED.description,
        source_url = EXCLUDED.source_url,
        date_of_disclosure = EXCLUDED.date_of_disclosure,
        primary_source = EXCLUDED.primary_source,
        updated_at = NOW();

    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'approved_targets'
    ) THEN
        INSERT INTO public.approved_targets (
            id,
            name,
            case_id,
            origin,
            context,
            description,
            source_url,
            date_of_disclosure,
            primary_source,
            verified,
            submission_id
        ) VALUES (
            target_id_param,
            submission_record.target_name,
            submission_record.case_id,
            submission_record.origin,
            submission_record.context,
            submission_record.description,
            submission_record.source_url,
            submission_record.date_of_disclosure,
            submission_record.primary_source,
            true,
            submission_id_param
        )
        ON CONFLICT (id) DO UPDATE
        SET
            name = EXCLUDED.name,
            case_id = EXCLUDED.case_id,
            origin = EXCLUDED.origin,
            context = EXCLUDED.context,
            description = EXCLUDED.description,
            source_url = EXCLUDED.source_url,
            date_of_disclosure = EXCLUDED.date_of_disclosure,
            primary_source = EXCLUDED.primary_source,
            verified = EXCLUDED.verified,
            submission_id = EXCLUDED.submission_id;
    END IF;

    UPDATE public.target_submissions
    SET status = 'approved', reviewed_by = auth.uid(), reviewed_at = NOW()
    WHERE id = submission_id_param;
END;
$$;


ALTER FUNCTION "public"."approve_target_submission"("submission_id_param" "uuid", "target_id_param" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."archive_old_assessment_notes"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Mark previous notes as not current
    UPDATE public.assessment_notes
    SET is_current = false
    WHERE target_id = NEW.target_id
        AND metric_id = NEW.metric_id
        AND user_id = NEW.user_id
        AND id != NEW.id
        AND is_current = true;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."archive_old_assessment_notes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_generate_case_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF NEW.case_id IS NULL OR NEW.case_id = '' THEN
        NEW.case_id := generate_case_id(NEW.origin, NEW.context);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_generate_case_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
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
$_$;


ALTER FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") IS 'Check if a pseudonym is available (validates format and uniqueness)';



CREATE OR REPLACE FUNCTION "public"."create_user_preferences"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.user_id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_user_preferences"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."demote_admin_to_user"("target_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."demote_admin_to_user"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."demote_contributor_to_user"("target_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."demote_contributor_to_user"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."disable_beta_features_non_contributors"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Only admins can call this function
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Only admins can disable beta features';
  END IF;

  -- Disable beta features for non-contributors/admins
  UPDATE public.user_profiles
  SET beta_features_enabled = false,
      updated_at = NOW()
  WHERE role NOT IN ('contributor', 'admin')
    AND beta_features_enabled = true;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'users_updated', updated_count,
    'message', 'Beta features disabled for non-contributors (emergency rollback)'
  );
END;
$$;


ALTER FUNCTION "public"."disable_beta_features_non_contributors"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."disable_beta_features_non_contributors"() IS 'Admin-only: Emergency rollback - disable beta for non-contributors';



CREATE OR REPLACE FUNCTION "public"."enable_beta_features_all"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Only admins can call this function
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Only admins can enable beta features for all users';
  END IF;

  -- Enable beta features for all users
  UPDATE public.user_profiles
  SET beta_features_enabled = true,
      updated_at = NOW()
  WHERE beta_features_enabled = false;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RETURN jsonb_build_object(
    'success', true,
    'users_updated', updated_count,
    'message', 'Beta features enabled for all users'
  );
END;
$$;


ALTER FUNCTION "public"."enable_beta_features_all"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."enable_beta_features_all"() IS 'Admin-only: Enable beta features for all users (Phase 2 rollout)';



CREATE OR REPLACE FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    origin_abbr TEXT;
    context_slug_upper TEXT;
    ref_number TEXT;
    case_id TEXT;
BEGIN
    -- Get origin abbreviation from origin_types table
    SELECT abbreviation INTO origin_abbr
    FROM public.origin_types
    WHERE is_active = true
      AND (slug = origin_param OR label = origin_param)
    LIMIT 1;

    -- Legacy string fallback for origin
    IF origin_abbr IS NULL THEN
        origin_abbr := CASE origin_param
            WHEN 'IC/NGA' THEN 'IC'
            WHEN 'DoD/DIA' THEN 'DOD'
            WHEN 'USN' THEN 'USN'
            WHEN 'USAF' THEN 'USAF'
            WHEN 'NASA' THEN 'NASA'
            WHEN 'Congressional' THEN 'CONG'
            WHEN 'Private Sector' THEN 'PRIV'
            WHEN 'Academic' THEN 'ACAD'
            WHEN 'Other' THEN 'UNK'
            ELSE 'UNK'
        END;
    END IF;

    -- Get context slug and convert to uppercase
    SELECT UPPER(slug) INTO context_slug_upper
    FROM public.context_types
    WHERE is_active = true
      AND (slug = context_param OR label = context_param)
    LIMIT 1;

    -- Legacy string fallback for context (convert to uppercase)
    IF context_slug_upper IS NULL THEN
        context_slug_upper := UPPER(CASE context_param
            WHEN 'Congressional' THEN 'congressional_hearing'
            WHEN 'Internal' THEN 'internal'
            WHEN 'Operational' THEN 'operational'
            WHEN 'Public Statement' THEN 'public_statement'
            WHEN 'Media Interview' THEN 'media_interview'
            WHEN 'Document Release' THEN 'document_release'
            WHEN 'Other' THEN 'unspecified'
            ELSE LOWER(REPLACE(context_param, ' ', '_'))
        END);
    END IF;

    -- Get next reference number (zero-padded to 4 digits)
    ref_number := LPAD(nextval('case_id_ref_seq')::TEXT, 4, '0');

    -- Construct case ID: QDD-ORIGIN-CONTEXT-REF
    case_id := 'QDD-' || origin_abbr || '-' || context_slug_upper || '-' || ref_number;

    RETURN case_id;
END;
$$;


ALTER FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") IS 'Generates case ID in format QDD-ORIGIN-CONTEXT-REF (e.g., QDD-DOD-CONGRESSIONAL_HEARING-0001)';



CREATE OR REPLACE FUNCTION "public"."generate_contributor_id"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  next_id INTEGER;
BEGIN
  -- Get next value from sequence
  next_id := nextval('public.contributor_id_seq');
  
  -- Format as QDD-XXXXX (5 digits, zero-padded)
  RETURN 'QDD-' || LPAD(next_id::TEXT, 5, '0');
END;
$$;


ALTER FUNCTION "public"."generate_contributor_id"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_contributor_id"() IS 'Auto-generate sequential contributor IDs (QDD-XXXXX)';



CREATE OR REPLACE FUNCTION "public"."generate_default_pseudonym"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."generate_default_pseudonym"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_default_pseudonym"() IS 'Auto-generate unique pseudonyms for new users';



CREATE OR REPLACE FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $_$
DECLARE
    cleaned_name TEXT;
    slug TEXT;
BEGIN
    -- Clean the target name:
    -- 1. Trim whitespace
    -- 2. Replace spaces with underscores
    -- 3. Remove non-alphanumeric characters (except underscores and hyphens)
    -- 4. Remove leading/trailing underscores and hyphens
    cleaned_name := TRIM(p_target_name);
    cleaned_name := REGEXP_REPLACE(cleaned_name, '\s+', '_', 'g');
    cleaned_name := REGEXP_REPLACE(cleaned_name, '[^a-zA-Z0-9_-]', '', 'g');
    cleaned_name := REGEXP_REPLACE(cleaned_name, '^[_-]+|[_-]+$', '', 'g');

    -- Construct slug: CASE_ID-TARGET_NAME
    slug := COALESCE(p_case_id, 'QDD-000') || '-' || cleaned_name;

    RETURN slug;
END;
$_$;


ALTER FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") IS 'Generates URL-safe slug from case_id and target name. Format: CASE_ID-Target_Name';



CREATE OR REPLACE FUNCTION "public"."get_admin_user_list"() RETURNS TABLE("id" "uuid", "email" "text", "role" "text", "full_name" "text", "created_at" timestamp with time zone, "is_verified" boolean, "location" "text", "website" "text", "bio" "text", "contributor_id" "text", "pseudonym" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
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


ALTER FUNCTION "public"."get_admin_user_list"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_admin_user_list"() IS 'Get full user list with emails (Admin only) - Fixed ambiguous column references';



CREATE OR REPLACE FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer DEFAULT NULL::integer) RETURNS TABLE("id" "uuid", "user_name" "text", "note_text" "text", "note_type" "text", "is_public" boolean, "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    an.id,
    up.full_name as user_name,
    an.note_text,
    an.note_type,
    an.is_public,
    an.created_at
  FROM public.assessment_notes an
  JOIN public.user_profiles up ON up.user_id = an.user_id
  WHERE an.target_id = p_target_id
    AND (p_metric_id IS NULL OR an.metric_id = p_metric_id)
    AND (an.is_public = true OR an.user_id = auth.uid())
  ORDER BY an.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer) IS 'Get assessment notes for a target, optionally filtered by metric';



CREATE OR REPLACE FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) RETURNS TABLE("action_vote" "text", "vote_count" bigint, "percentage" numeric)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    us.action_vote,
    COUNT(*) as vote_count,
    ROUND((COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (), 0)), 2) as percentage
  FROM public.user_scores us
  WHERE us.target_id = target_id_param
    AND us.metric_id = metric_id_param
    AND us.action_vote IS NOT NULL
  GROUP BY us.action_vote
  ORDER BY vote_count DESC;
END;
$$;


ALTER FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) IS 'Returns vote distribution for a specific metric on a target';



CREATE OR REPLACE FUNCTION "public"."get_metric_discussion_count"("metric_id_param" integer) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM metric_discussions
        WHERE metric_id = metric_id_param
    );
END;
$$;


ALTER FUNCTION "public"."get_metric_discussion_count"("metric_id_param" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_saved_searches"() RETURNS TABLE("id" "uuid", "search_query" "text", "search_context" "text", "saved_name" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    sh.id,
    sh.search_query,
    sh.search_context,
    sh.saved_name,
    sh.created_at
  FROM public.search_history sh
  WHERE sh.user_id = auth.uid()
    AND sh.is_saved = true
  ORDER BY sh.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_saved_searches"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_saved_searches"() IS 'Get all saved searches for current user';



CREATE OR REPLACE FUNCTION "public"."get_system_activity_feed"("p_limit" integer DEFAULT 100, "p_offset" integer DEFAULT 0, "p_activity_types" "text"[] DEFAULT NULL::"text"[]) RETURNS TABLE("id" "uuid", "user_name" "text", "activity_type" "text", "description" "text", "target_name" "text", "metric_name" "text", "metadata" "jsonb", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    al.id,
    up.full_name as user_name,
    al.activity_type,
    al.description,
    t.name as target_name,
    m.name as metric_name,
    al.metadata,
    al.created_at
  FROM public.activity_log al
  LEFT JOIN public.user_profiles up ON up.user_id = al.user_id
  LEFT JOIN public.targets t ON t.id = al.target_id
  LEFT JOIN public.metrics m ON m.id = al.metric_id
  WHERE (p_activity_types IS NULL OR al.activity_type = ANY(p_activity_types))
  ORDER BY al.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_system_activity_feed"("p_limit" integer, "p_offset" integer, "p_activity_types" "text"[]) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_system_activity_feed"("p_limit" integer, "p_offset" integer, "p_activity_types" "text"[]) IS 'Get system-wide activity feed with optional filtering';



CREATE OR REPLACE FUNCTION "public"."get_user_activity_feed"("p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0) RETURNS TABLE("id" "uuid", "activity_type" "text", "description" "text", "target_name" "text", "metric_name" "text", "metadata" "jsonb", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    al.id,
    al.activity_type,
    al.description,
    t.name as target_name,
    m.name as metric_name,
    al.metadata,
    al.created_at
  FROM public.activity_log al
  LEFT JOIN public.targets t ON t.id = al.target_id
  LEFT JOIN public.metrics m ON m.id = al.metric_id
  WHERE al.user_id = auth.uid()
  ORDER BY al.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."get_user_activity_feed"("p_limit" integer, "p_offset" integer) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_activity_feed"("p_limit" integer, "p_offset" integer) IS 'Get activity feed for current user';



CREATE OR REPLACE FUNCTION "public"."get_user_preferences"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_preferences RECORD;
BEGIN
  SELECT * INTO v_preferences
  FROM public.user_preferences
  WHERE user_id = auth.uid();

  IF NOT FOUND THEN
    -- Create default preferences
    INSERT INTO public.user_preferences (user_id)
    VALUES (auth.uid())
    RETURNING * INTO v_preferences;
  END IF;

  RETURN row_to_json(v_preferences);
END;
$$;


ALTER FUNCTION "public"."get_user_preferences"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_preferences"() IS 'Get current user preferences, creating defaults if needed';



CREATE OR REPLACE FUNCTION "public"."get_user_role"() RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    user_role TEXT;
BEGIN
    SELECT role INTO user_role
    FROM public.user_profiles
    WHERE user_id = auth.uid();

    RETURN COALESCE(user_role, 'user');
END;
$$;


ALTER FUNCTION "public"."get_user_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") RETURNS TABLE("metric_id" integer, "metric_name" "text", "vote_value" integer, "confidence_level" "text", "rationale" "text", "voted_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
  SELECT
    cv.metric_id,
    m.name as metric_name,
    cv.vote_value,
    cv.confidence_level,
    cv.rationale,
    cv.created_at as voted_at
  FROM public.community_votes cv
  JOIN public.metrics m ON m.id = cv.metric_id
  WHERE cv.user_id = auth.uid()
    AND cv.target_id = p_target_id
  ORDER BY cv.metric_id;
END;
$$;


ALTER FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") IS 'Get all votes by current user for a specific target';



CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'extensions', 'pg_temp'
    AS $$
DECLARE
  oauth_provider_name TEXT;
  oauth_user_handle TEXT;
  user_role TEXT;
BEGIN
  BEGIN
    -- Extract OAuth provider
    -- FIX: Use raw_app_meta_data instead of app_metadata
    oauth_provider_name := NEW.raw_app_meta_data->>'provider';

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

    -- Determine user role (default: user)
    -- Logic replicated from 20260126000002_add_beta_feature_flag.sql
    user_role := 'user';

    INSERT INTO public.user_profiles (
      user_id,
      role,
      full_name,
      contributor_id,
      pseudonym,
      anonymous,
      last_pseudonym_change,
      oauth_provider,
      oauth_handle,
      beta_features_enabled
    )
    VALUES (
        NEW.id,
        user_role,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            split_part(NEW.email, '@', 1)
        ),
        public.generate_contributor_id(),
        public.generate_default_pseudonym(),
        true,  -- Default to anonymous
        NOW(),
        oauth_provider_name,
        oauth_user_handle,
        (user_role IN ('contributor', 'admin'))
    );
    
    RETURN NEW;
    
  EXCEPTION WHEN OTHERS THEN
    -- Log the error for admin debug
    RAISE LOG 'Error in handle_new_user: %', SQLERRM;
    -- Raise a clear exception that might surface in Auth logs/response
    RAISE EXCEPTION 'Database error saving new user (Extended): %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_beta_access"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  has_access BOOLEAN;
BEGIN
  SELECT beta_features_enabled INTO has_access
  FROM public.user_profiles
  WHERE user_id = auth.uid();

  RETURN COALESCE(has_access, false);
END;
$$;


ALTER FUNCTION "public"."has_beta_access"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."has_beta_access"() IS 'Check if current user has beta feature access';



CREATE OR REPLACE FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rfc RECORD;
  v_new_metric_id INTEGER;
BEGIN
  -- Check admin permission
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Admin access required';
  END IF;

  -- Get RFC
  SELECT * INTO v_rfc
  FROM public.rfc_proposals
  WHERE id = p_rfc_id AND status = 'approved';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'RFC proposal not found or not approved';
  END IF;

  -- Handle new metric creation
  IF v_rfc.proposal_type = 'new_metric' THEN
    INSERT INTO public.metrics (name, category, question, criteria, community_score)
    VALUES (
      v_rfc.proposed_name,
      v_rfc.proposed_category,
      v_rfc.proposed_question,
      v_rfc.proposed_min_criteria || ' to ' || v_rfc.proposed_max_criteria,
      2.5 -- Default neutral score
    )
    RETURNING id INTO v_new_metric_id;

  -- Handle metric modification
  ELSIF v_rfc.proposal_type = 'modify_existing' THEN
    -- Update metric (only fields that were proposed)
    UPDATE public.metrics
    SET
      name = COALESCE(v_rfc.proposed_name, name),
      category = COALESCE(v_rfc.proposed_category, category),
      question = COALESCE(v_rfc.proposed_question, question),
      criteria = COALESCE(
        v_rfc.proposed_min_criteria || ' to ' || v_rfc.proposed_max_criteria,
        criteria
      ),
      updated_at = NOW()
    WHERE id = v_rfc.metric_id;
  END IF;

  -- Mark RFC as implemented
  UPDATE public.rfc_proposals
  SET status = 'implemented', updated_at = NOW()
  WHERE id = p_rfc_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, metric_id, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'admin_action', COALESCE(v_new_metric_id, v_rfc.metric_id), p_rfc_id,
    'Implemented RFC proposal',
    jsonb_build_object('rfc_id', p_rfc_id, 'proposal_type', v_rfc.proposal_type)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', p_rfc_id,
    'new_metric_id', v_new_metric_id,
    'message', 'RFC implemented successfully'
  );
END;
$$;


ALTER FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") IS 'Admin-only function to implement an approved RFC proposal';



CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE user_id = auth.uid() AND role = 'admin'
    );
END;
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_contributor"() RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profiles
        WHERE user_id = auth.uid() 
        AND role IN ('contributor', 'admin')
    );
END;
$$;


ALTER FUNCTION "public"."is_contributor"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."is_contributor"() IS 'Check if current user has contributor role (or admin)';



CREATE OR REPLACE FUNCTION "public"."log_user_score_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  change_type_val TEXT;
BEGIN
  -- Determine what changed
  IF TG_OP = 'INSERT' THEN
    change_type_val := 'full_update';
  ELSIF TG_OP = 'UPDATE' THEN
    IF (OLD.score IS DISTINCT FROM NEW.score) AND
       (OLD.action_vote IS DISTINCT FROM NEW.action_vote) THEN
      change_type_val := 'full_update';
    ELSIF (OLD.score IS DISTINCT FROM NEW.score) THEN
      change_type_val := 'score_update';
    ELSIF (OLD.action_vote IS DISTINCT FROM NEW.action_vote OR
           OLD.action_notes IS DISTINCT FROM NEW.action_notes) THEN
      change_type_val := 'governance_vote';
    ELSIF (OLD.notes IS DISTINCT FROM NEW.notes) THEN
      change_type_val := 'notes_update';
    ELSE
      RETURN NEW; -- No relevant changes, skip logging
    END IF;
  END IF;

  -- Insert history record
  INSERT INTO public.user_score_history (
    user_score_id,
    user_id,
    target_id,
    metric_id,
    score,
    notes,
    action_vote,
    action_notes,
    change_type
  ) VALUES (
    NEW.id,
    NEW.user_id,
    NEW.target_id,
    NEW.metric_id,
    NEW.score,
    NEW.notes,
    NEW.action_vote,
    NEW.action_notes,
    change_type_val
  );

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."log_user_score_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") RETURNS "text"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
DECLARE
    case_id TEXT;
BEGIN
    -- Match pattern: QDD-...-NNNN (where NNNN is 4 digits at the end of case_id)
    -- Everything before the last segment that starts with a capital letter is the case_id
    -- Example: QDD-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar
    --          case_id = QDD-DOD-ACADEMIC_SYMPOSIUM-0002

    -- Strategy: Find the last occurrence of -[0-9]{4}- and take everything before the next hyphen
    -- This assumes case IDs always end with -NNNN and target names always start with a capital letter

    -- Match: Start to the last -NNNN followed by a hyphen and capital letter
    case_id := SUBSTRING(p_slug FROM '^(.+?-[0-9]{4})-[A-Z]');

    -- Fallback: if no match, try simpler pattern (legacy support)
    IF case_id IS NULL THEN
        case_id := SUBSTRING(p_slug FROM '^([A-Z0-9.-]+(?:-[A-Z0-9.-]+)*)-');
    END IF;

    RETURN case_id;
END;
$$;


ALTER FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") IS 'Extracts case_id from a slug string. Handles format: QDD-ORIGIN-CONTEXT-REF-Target_Name';



CREATE OR REPLACE FUNCTION "public"."promote_user_to_admin"("target_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."promote_user_to_admin"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."promote_user_to_contributor"("target_user_id" "uuid") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."promote_user_to_contributor"("target_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Check admin permission
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Admin access required';
  END IF;

  -- Validate status
  IF p_status NOT IN ('approved', 'rejected', 'under_review') THEN
    RAISE EXCEPTION 'status must be approved, rejected, or under_review';
  END IF;

  -- Update RFC status
  UPDATE public.rfc_proposals
  SET
    status = p_status,
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    review_notes = p_review_notes,
    updated_at = NOW()
  WHERE id = p_rfc_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'RFC proposal not found';
  END IF;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'admin_action', p_rfc_id,
    'Reviewed RFC proposal',
    jsonb_build_object('rfc_id', p_rfc_id, 'new_status', p_status)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', p_rfc_id,
    'status', p_status,
    'message', 'RFC proposal reviewed successfully'
  );
END;
$$;


ALTER FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text") IS 'Admin-only function to review and update RFC proposal status';



CREATE OR REPLACE FUNCTION "public"."revoke_target_submission"("submission_id_param" "uuid", "review_notes_param" "text" DEFAULT ''::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
DECLARE
    target_id_to_remove TEXT;
BEGIN
    -- 1. Check if approved_targets table exists and get ID if so
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'approved_targets'
    ) THEN
        BEGIN
            -- Using dynamic SQL to avoid compilation errors if table doesn't exist
            EXECUTE 'SELECT id FROM public.approved_targets WHERE submission_id = $1'
            INTO target_id_to_remove
            USING submission_id_param;
        EXCEPTION WHEN OTHERS THEN
            -- Log error but continue to allow status reset
            RAISE NOTICE 'Error accessing approved_targets: %', SQLERRM;
        END;
    END IF;

    -- 2. If we found a target ID, delete it
    IF target_id_to_remove IS NOT NULL THEN
        -- Delete from approved_targets first
        EXECUTE 'DELETE FROM public.approved_targets WHERE id = $1'
        USING target_id_to_remove;
        
        -- Delete from targets
        -- Note: This might still fail if there are dependencies without ON DELETE CASCADE
        -- We wrap in block to allow continuation
        BEGIN
            DELETE FROM public.targets WHERE id = target_id_to_remove;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Could not delete from targets table: %', SQLERRM;
        END;
    END IF;

    -- 3. Update the submission status back to pending
    UPDATE public.target_submissions
    SET 
        status = 'pending',
        reviewed_by = NULL,
        reviewed_at = NULL,
        review_notes = review_notes_param
    WHERE id = submission_id_param;
END;
$_$;


ALTER FUNCTION "public"."revoke_target_submission"("submission_id_param" "uuid", "review_notes_param" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_search_id UUID;
BEGIN
  -- Upsert saved search
  INSERT INTO public.search_history (
    user_id, search_query, search_context, is_saved, saved_name
  ) VALUES (
    auth.uid(), p_search_query, p_search_context, true, p_saved_name
  )
  RETURNING id INTO v_search_id;

  RETURN jsonb_build_object(
    'success', true,
    'search_id', v_search_id,
    'message', 'Search saved successfully'
  );
END;
$$;


ALTER FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") IS 'Save a search for quick access';



CREATE OR REPLACE FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text" DEFAULT 'assessment'::"text", "p_is_public" boolean DEFAULT true) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_note_id UUID;
BEGIN
  -- Validate note_type
  IF p_note_type NOT IN ('assessment', 'verification', 'context', 'correction') THEN
    RAISE EXCEPTION 'note_type must be assessment, verification, context, or correction';
  END IF;

  -- Insert note
  INSERT INTO public.assessment_notes (
    user_id, target_id, metric_id, note_text, note_type, is_public
  ) VALUES (
    auth.uid(), p_target_id, p_metric_id, p_note_text, p_note_type, p_is_public
  )
  RETURNING id INTO v_note_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, target_id, metric_id, description, metadata
  ) VALUES (
    auth.uid(), 'comment', p_target_id, p_metric_id,
    'Added assessment note',
    jsonb_build_object('note_type', p_note_type, 'note_id', v_note_id)
  );

  RETURN jsonb_build_object(
    'success', true,
    'note_id', v_note_id,
    'message', 'Assessment note submitted successfully'
  );
END;
$$;


ALTER FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text", "p_is_public" boolean) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text", "p_is_public" boolean) IS 'Submit an assessment note for a target metric';



CREATE OR REPLACE FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text" DEFAULT NULL::"text", "p_proposed_question" "text" DEFAULT NULL::"text", "p_proposed_min_criteria" "text" DEFAULT NULL::"text", "p_proposed_max_criteria" "text" DEFAULT NULL::"text", "p_proposed_category" "text" DEFAULT NULL::"text", "p_rich_entries" "text" DEFAULT NULL::"text", "p_rationale" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_rfc_id UUID;
BEGIN
  -- Validate proposal type
  IF p_proposal_type NOT IN ('modify_existing', 'new_metric') THEN
    RAISE EXCEPTION 'proposal_type must be modify_existing or new_metric';
  END IF;

  -- For modify_existing, metric_id is required
  IF p_proposal_type = 'modify_existing' AND p_metric_id IS NULL THEN
    RAISE EXCEPTION 'metric_id is required for modify_existing proposals';
  END IF;

  -- Rationale is required
  IF p_rationale IS NULL OR p_rationale = '' THEN
    RAISE EXCEPTION 'rationale is required';
  END IF;

  -- Insert RFC proposal
  INSERT INTO public.rfc_proposals (
    user_id, metric_id, proposal_type,
    proposed_name, proposed_question, proposed_min_criteria, proposed_max_criteria, proposed_category,
    rich_entries, rationale
  ) VALUES (
    auth.uid(), p_metric_id, p_proposal_type,
    p_proposed_name, p_proposed_question, p_proposed_min_criteria, p_proposed_max_criteria, p_proposed_category,
    p_rich_entries, p_rationale
  )
  RETURNING id INTO v_rfc_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, metric_id, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'rfc_submit', p_metric_id, v_rfc_id,
    'Submitted RFC proposal',
    jsonb_build_object('proposal_type', p_proposal_type, 'metric_id', p_metric_id)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', v_rfc_id,
    'message', 'RFC proposal submitted successfully'
  );
END;
$$;


ALTER FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text", "p_proposed_question" "text", "p_proposed_min_criteria" "text", "p_proposed_max_criteria" "text", "p_proposed_category" "text", "p_rich_entries" "text", "p_rationale" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text", "p_proposed_question" "text", "p_proposed_min_criteria" "text", "p_proposed_max_criteria" "text", "p_proposed_category" "text", "p_rich_entries" "text", "p_rationale" "text") IS 'Submit an RFC proposal to modify or create a metric';



CREATE OR REPLACE FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean DEFAULT false) RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  -- Update or insert session
  INSERT INTO public.user_sessions (
    user_id, session_id, page_views, actions_count
  ) VALUES (
    auth.uid(), p_session_id, CASE WHEN p_page_view THEN 1 ELSE 0 END, 1
  )
  ON CONFLICT (session_id) DO UPDATE SET
    last_activity_at = NOW(),
    page_views = user_sessions.page_views + CASE WHEN p_page_view THEN 1 ELSE 0 END,
    actions_count = user_sessions.actions_count + 1;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Session activity tracked'
  );
END;
$$;


ALTER FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean) IS 'Track user session activity and page views';



CREATE OR REPLACE FUNCTION "public"."unlink_oauth_handle"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."unlink_oauth_handle"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."unlink_oauth_handle"() IS 'Remove OAuth verification and revert to anonymous mode';



CREATE OR REPLACE FUNCTION "public"."update_discussion_votes"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes + 1 WHERE id = NEW.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes + 1 WHERE id = NEW.discussion_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes - 1 WHERE id = OLD.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes - 1 WHERE id = OLD.discussion_id;
        END IF;
        IF NEW.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes + 1 WHERE id = NEW.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes + 1 WHERE id = NEW.discussion_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes - 1 WHERE id = OLD.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes - 1 WHERE id = OLD.discussion_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_discussion_votes"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_metric_discussions_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_metric_discussions_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_proposal_vote_counts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE public.new_metric_proposals
        SET
            support_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = NEW.proposal_id AND vote_type = 'support'
            ),
            opposition_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = NEW.proposal_id AND vote_type = 'oppose'
            )
        WHERE id = NEW.proposal_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.new_metric_proposals
        SET
            support_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = OLD.proposal_id AND vote_type = 'support'
            ),
            opposition_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = OLD.proposal_id AND vote_type = 'oppose'
            )
        WHERE id = OLD.proposal_id;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_proposal_vote_counts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_protocol_version"("new_version" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
    -- Validate format (must be 3 digits)
    IF new_version !~ '^\d{3}$' THEN
        RAISE EXCEPTION 'Protocol version must be exactly 3 digits (e.g., 001, 002, 003)';
    END IF;

    -- Update protocol version
    UPDATE protocol_config
    SET
        config_value = new_version,
        updated_at = NOW(),
        updated_by = auth.uid()
    WHERE config_key = 'protocol_version';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Protocol version configuration not found';
    END IF;
END;
$_$;


ALTER FUNCTION "public"."update_protocol_version"("new_version" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_protocol_version"("new_version" "text") IS 'Admin function to update the QDD Protocol version (must be 3 digits)';



CREATE OR REPLACE FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") IS 'Update user pseudonym with 24-hour throttle protection';



CREATE OR REPLACE FUNCTION "public"."update_saved_search_usage"("search_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    UPDATE public.saved_searches
    SET
        last_used_at = NOW(),
        use_count = use_count + 1
    WHERE id = search_id;
END;
$$;


ALTER FUNCTION "public"."update_saved_search_usage"("search_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_target_submissions_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_target_submissions_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_updated RECORD;
BEGIN
  -- Upsert preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (auth.uid())
  ON CONFLICT (user_id) DO UPDATE SET
    last_viewed_tab = COALESCE((p_preferences->>'last_viewed_tab')::TEXT, user_preferences.last_viewed_tab),
    sidebar_collapsed = COALESCE((p_preferences->>'sidebar_collapsed')::BOOLEAN, user_preferences.sidebar_collapsed),
    theme = COALESCE((p_preferences->>'theme')::TEXT, user_preferences.theme),
    saved_filters = COALESCE((p_preferences->'saved_filters')::JSONB, user_preferences.saved_filters),
    email_notifications = COALESCE((p_preferences->>'email_notifications')::BOOLEAN, user_preferences.email_notifications),
    discussion_notifications = COALESCE((p_preferences->>'discussion_notifications')::BOOLEAN, user_preferences.discussion_notifications),
    rfc_notifications = COALESCE((p_preferences->>'rfc_notifications')::BOOLEAN, user_preferences.rfc_notifications),
    items_per_page = COALESCE((p_preferences->>'items_per_page')::INTEGER, user_preferences.items_per_page),
    show_consensus_overlay = COALESCE((p_preferences->>'show_consensus_overlay')::BOOLEAN, user_preferences.show_consensus_overlay),
    updated_at = NOW()
  RETURNING * INTO v_updated;

  RETURN jsonb_build_object(
    'success', true,
    'preferences', row_to_json(v_updated),
    'message', 'Preferences updated successfully'
  );
END;
$$;


ALTER FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") IS 'Update user UI/UX preferences';



CREATE OR REPLACE FUNCTION "public"."update_user_scores_timestamp"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.last_updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_scores_timestamp"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  v_vote_id UUID;
  v_is_new BOOLEAN;
BEGIN
  -- Validate inputs
  IF p_vote_value NOT BETWEEN 1 AND 5 THEN
    RAISE EXCEPTION 'vote_value must be between 1 and 5';
  END IF;

  IF p_confidence_level NOT IN ('low', 'medium', 'high') THEN
    RAISE EXCEPTION 'confidence_level must be low, medium, or high';
  END IF;

  -- Upsert vote
  INSERT INTO public.community_votes (
    user_id, target_id, metric_id, vote_value, confidence_level, rationale
  ) VALUES (
    auth.uid(), p_target_id, p_metric_id, p_vote_value, p_confidence_level, p_rationale
  )
  ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET
    vote_value = EXCLUDED.vote_value,
    confidence_level = EXCLUDED.confidence_level,
    rationale = EXCLUDED.rationale,
    updated_at = NOW()
  RETURNING id, (xmax = 0) INTO v_vote_id, v_is_new;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, target_id, metric_id, description, metadata
  ) VALUES (
    auth.uid(),
    'vote',
    p_target_id,
    p_metric_id,
    CASE WHEN v_is_new THEN 'Submitted community vote' ELSE 'Updated community vote' END,
    jsonb_build_object(
      'vote_value', p_vote_value,
      'confidence_level', p_confidence_level,
      'is_new', v_is_new
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'vote_id', v_vote_id,
    'is_new', v_is_new,
    'message', CASE WHEN v_is_new THEN 'Vote submitted' ELSE 'Vote updated' END
  );
END;
$$;


ALTER FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text") IS 'Submit or update a community vote with confidence level';



CREATE OR REPLACE FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_confidence_level" "text" DEFAULT NULL::"text", "p_notes" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_vote_id UUID;
BEGIN
    INSERT INTO public.rfc_votes (rfc_id, user_id, confidence_level, notes, updated_at)
    VALUES (p_rfc_id, auth.uid(), p_confidence_level, p_notes, NOW())
    ON CONFLICT (rfc_id, user_id)
    DO UPDATE SET
        confidence_level = COALESCE(EXCLUDED.confidence_level, public.rfc_votes.confidence_level),
        notes = COALESCE(EXCLUDED.notes, public.rfc_votes.notes),
        updated_at = NOW()
    RETURNING id INTO v_vote_id;

    RETURN jsonb_build_object(
        'success', true,
        'vote_id', v_vote_id
    );
END;
$$;


ALTER FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_confidence_level" "text", "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_vote" "text", "p_confidence_level" "text" DEFAULT NULL::"text", "p_notes" "text" DEFAULT NULL::"text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_vote_id UUID;
BEGIN
    -- Validate vote
    IF p_vote NOT IN ('approve', 'reject', 'abstain') THEN
        RAISE EXCEPTION 'Invalid vote type. Must be approve, reject, or abstain';
    END IF;

    INSERT INTO public.rfc_votes (rfc_id, user_id, vote, confidence_level, notes, updated_at)
    VALUES (p_rfc_id, auth.uid(), p_vote, p_confidence_level, p_notes, NOW())
    ON CONFLICT (rfc_id, user_id)
    DO UPDATE SET
        vote = EXCLUDED.vote,
        confidence_level = COALESCE(EXCLUDED.confidence_level, public.rfc_votes.confidence_level),
        notes = COALESCE(EXCLUDED.notes, public.rfc_votes.notes),
        updated_at = NOW()
    RETURNING id INTO v_vote_id;

    RETURN jsonb_build_object(
        'success', true,
        'vote_id', v_vote_id
    );
END;
$$;


ALTER FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_vote" "text", "p_confidence_level" "text", "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verify_oauth_handle"() RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;


ALTER FUNCTION "public"."verify_oauth_handle"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."verify_oauth_handle"() IS 'Verify and link OAuth handle from current session (requires re-authentication)';



CREATE FOREIGN DATA WRAPPER "qdd_d_analyitcs_fdw" HANDLER "extensions"."iceberg_fdw_handler" VALIDATOR "extensions"."iceberg_fdw_validator";




CREATE SERVER "qdd_d_analyitcs_fdw_server" FOREIGN DATA WRAPPER "qdd_d_analyitcs_fdw" OPTIONS (
    "catalog_uri" 'https://iurzpjeubpbcbxhydlud.storage.supabase.co/storage/v1/iceberg',
    "s3.endpoint" 'https://iurzpjeubpbcbxhydlud.storage.supabase.co/storage/v1/s3',
    "vault_aws_access_key_id" '8653cb64-f1a0-4089-b5e9-b12fc247100b',
    "vault_aws_secret_access_key" '511903d5-00a9-4e90-a703-28805605f6f0',
    "vault_token" 'a640b954-998e-45b6-bf52-2b8820c711d7',
    "warehouse" 'qdd-d-analyitcs'
);


ALTER SERVER "qdd_d_analyitcs_fdw_server" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."new_metric_proposals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "proposed_by" "uuid" NOT NULL,
    "metric_name" "text" NOT NULL,
    "metric_question" "text" NOT NULL,
    "min_criteria" "text" NOT NULL,
    "max_criteria" "text" NOT NULL,
    "rich_entries" "text",
    "rationale" "text" NOT NULL,
    "category" "text",
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "review_notes" "text",
    "support_count" integer DEFAULT 0,
    "opposition_count" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "implemented_metric_id" integer,
    "implemented_at" timestamp with time zone,
    CONSTRAINT "new_metric_proposals_category_check" CHECK (("category" = ANY (ARRAY['core'::"text", 'integrity'::"text", 'impact'::"text"]))),
    CONSTRAINT "new_metric_proposals_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'submitted'::"text", 'under_review'::"text", 'approved'::"text", 'rejected'::"text", 'implemented'::"text"])))
);


ALTER TABLE "public"."new_metric_proposals" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profiles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'user'::"text" NOT NULL,
    "full_name" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "avatar_url" "text",
    "bio" "text",
    "location" "text",
    "website" "text",
    "is_verified" boolean DEFAULT false,
    "contributor_id" "text",
    "pseudonym" "text",
    "anonymous" boolean DEFAULT true,
    "last_pseudonym_change" timestamp with time zone,
    "allow_public_profile" boolean DEFAULT true,
    "show_in_leaderboard" boolean DEFAULT true,
    "oauth_provider" "text",
    "oauth_handle" "text",
    "oauth_verified" boolean DEFAULT false,
    "oauth_verified_at" timestamp with time zone,
    "oauth_profile_url" "text",
    "beta_features_enabled" boolean DEFAULT false,
    CONSTRAINT "user_profiles_role_check" CHECK (("role" = ANY (ARRAY['user'::"text", 'contributor'::"text", 'admin'::"text"])))
);


ALTER TABLE "public"."user_profiles" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_profiles"."avatar_url" IS 'URL to user avatar image';



COMMENT ON COLUMN "public"."user_profiles"."bio" IS 'User biography/description';



COMMENT ON COLUMN "public"."user_profiles"."location" IS 'User location (optional)';



COMMENT ON COLUMN "public"."user_profiles"."website" IS 'User website URL';



COMMENT ON COLUMN "public"."user_profiles"."is_verified" IS 'Whether user is verified contributor';



COMMENT ON COLUMN "public"."user_profiles"."contributor_id" IS 'Auto-generated immutable public ID (QDD-00001)';



COMMENT ON COLUMN "public"."user_profiles"."pseudonym" IS 'User-chosen unique handle (editable, throttled to 1 change/24h)';



COMMENT ON COLUMN "public"."user_profiles"."anonymous" IS 'Privacy flag: true = show pseudonym, false = show OAuth handle (if verified)';



COMMENT ON COLUMN "public"."user_profiles"."last_pseudonym_change" IS 'Timestamp of last pseudonym change (for 24-hour throttle)';



COMMENT ON COLUMN "public"."user_profiles"."oauth_verified" IS 'Whether OAuth handle has been verified via re-authentication';



COMMENT ON COLUMN "public"."user_profiles"."beta_features_enabled" IS 'Feature flag for phased rollout: enables access to /profile routes and anonymity features';



CREATE OR REPLACE VIEW "public"."active_metric_proposals" AS
 SELECT "nmp"."id",
    "nmp"."proposed_by",
    "nmp"."metric_name",
    "nmp"."metric_question",
    "nmp"."min_criteria",
    "nmp"."max_criteria",
    "nmp"."rich_entries",
    "nmp"."rationale",
    "nmp"."category",
    "nmp"."status",
    "nmp"."reviewed_by",
    "nmp"."reviewed_at",
    "nmp"."review_notes",
    "nmp"."support_count",
    "nmp"."opposition_count",
    "nmp"."created_at",
    "nmp"."updated_at",
    "nmp"."implemented_metric_id",
    "nmp"."implemented_at",
    "up"."full_name" AS "proposer_name",
    COALESCE("nmp"."support_count", 0) AS "total_support",
    COALESCE("nmp"."opposition_count", 0) AS "total_opposition",
    (COALESCE("nmp"."support_count", 0) - COALESCE("nmp"."opposition_count", 0)) AS "net_support"
   FROM ("public"."new_metric_proposals" "nmp"
     LEFT JOIN "public"."user_profiles" "up" ON (("nmp"."proposed_by" = "up"."user_id")))
  WHERE ("nmp"."status" = ANY (ARRAY['submitted'::"text", 'under_review'::"text"]))
  ORDER BY "nmp"."created_at" DESC;


ALTER VIEW "public"."active_metric_proposals" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."activity_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "activity_type" "text" NOT NULL,
    "target_id" "text",
    "metric_id" integer,
    "discussion_id" "uuid",
    "rfc_id" "uuid",
    "metadata" "jsonb" DEFAULT '{}'::"jsonb",
    "description" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "activity_log_activity_type_check" CHECK (("activity_type" = ANY (ARRAY['score'::"text", 'vote'::"text", 'comment'::"text", 'reply'::"text", 'upvote'::"text", 'downvote'::"text", 'rfc_submit'::"text", 'target_submit'::"text", 'login'::"text", 'logout'::"text", 'admin_action'::"text", 'edit'::"text", 'verification'::"text"])))
);


ALTER TABLE "public"."activity_log" OWNER TO "postgres";


COMMENT ON TABLE "public"."activity_log" IS 'Comprehensive activity tracking for all user actions';



COMMENT ON COLUMN "public"."activity_log"."activity_type" IS 'Type of activity performed';



COMMENT ON COLUMN "public"."activity_log"."metadata" IS 'JSONB field containing activity-specific data';



COMMENT ON COLUMN "public"."activity_log"."description" IS 'Human-readable description of the activity';



CREATE TABLE IF NOT EXISTS "public"."approved_targets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "case_id" "text",
    "origin" "text",
    "context" "text",
    "description" "text" NOT NULL,
    "source_url" "text",
    "date_of_disclosure" "date" NOT NULL,
    "primary_source" "text",
    "verified" boolean DEFAULT false,
    "submission_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "slug" "text" GENERATED ALWAYS AS ("public"."generate_target_slug"("case_id", "name")) STORED
);


ALTER TABLE "public"."approved_targets" OWNER TO "postgres";


COMMENT ON TABLE "public"."approved_targets" IS 'Approved disclosure targets available for scoring';



CREATE TABLE IF NOT EXISTS "public"."assessment_notes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "target_id" "text" NOT NULL,
    "metric_id" integer NOT NULL,
    "note_text" "text" NOT NULL,
    "note_type" "text" DEFAULT 'assessment'::"text",
    "is_public" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "version" integer DEFAULT 1,
    "is_current" boolean DEFAULT true,
    CONSTRAINT "assessment_notes_note_type_check" CHECK (("note_type" = ANY (ARRAY['assessment'::"text", 'verification'::"text", 'context'::"text", 'correction'::"text"])))
);


ALTER TABLE "public"."assessment_notes" OWNER TO "postgres";


COMMENT ON TABLE "public"."assessment_notes" IS 'Detailed assessment notes for target metrics';



COMMENT ON COLUMN "public"."assessment_notes"."note_type" IS 'Type: assessment, verification, context, or correction';



CREATE SEQUENCE IF NOT EXISTS "public"."case_id_ref_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."case_id_ref_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."community_votes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "target_id" "text",
    "metric_id" integer,
    "vote_value" integer NOT NULL,
    "confidence_level" "text" DEFAULT 'medium'::"text" NOT NULL,
    "rationale" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "vote_timestamp" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "community_votes_confidence_level_check" CHECK (("confidence_level" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text"]))),
    CONSTRAINT "community_votes_vote_value_check" CHECK ((("vote_value" >= 1) AND ("vote_value" <= 5)))
);


ALTER TABLE "public"."community_votes" OWNER TO "postgres";


COMMENT ON TABLE "public"."community_votes" IS 'Community voting on metrics with confidence levels and rationales';



COMMENT ON COLUMN "public"."community_votes"."vote_value" IS 'Vote score: 1 (very low) to 5 (very high)';



COMMENT ON COLUMN "public"."community_votes"."confidence_level" IS 'Voter confidence: low, medium, or high';



COMMENT ON COLUMN "public"."community_votes"."rationale" IS 'Optional explanation for the vote';



CREATE TABLE IF NOT EXISTS "public"."context_types" (
    "slug" "text" NOT NULL,
    "label" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."context_types" OWNER TO "postgres";


COMMENT ON TABLE "public"."context_types" IS 'Reference table for disclosure context types';



COMMENT ON COLUMN "public"."context_types"."is_active" IS 'Whether this context type is currently active and available for selection';



CREATE SEQUENCE IF NOT EXISTS "public"."contributor_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."contributor_id_seq" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."current_assessment_notes" AS
 SELECT "id",
    "user_id",
    "target_id",
    "metric_id",
    "note_text",
    "note_type",
    "is_public",
    "created_at",
    "updated_at",
    "version",
    "is_current"
   FROM "public"."assessment_notes"
  WHERE ("is_current" = true);


ALTER VIEW "public"."current_assessment_notes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."discussion_votes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "discussion_id" "uuid",
    "user_id" "uuid",
    "vote_type" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "discussion_votes_vote_type_check" CHECK (("vote_type" = ANY (ARRAY['upvote'::"text", 'downvote'::"text"])))
);


ALTER TABLE "public"."discussion_votes" OWNER TO "postgres";


COMMENT ON TABLE "public"."discussion_votes" IS 'User votes on metric discussions';



CREATE TABLE IF NOT EXISTS "public"."metric_discussions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "metric_id" integer NOT NULL,
    "user_id" "uuid",
    "comment" "text" NOT NULL,
    "parent_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "upvotes" integer DEFAULT 0,
    "downvotes" integer DEFAULT 0
);


ALTER TABLE "public"."metric_discussions" OWNER TO "postgres";


COMMENT ON TABLE "public"."metric_discussions" IS 'Discussion threads for QDD metrics';



CREATE TABLE IF NOT EXISTS "public"."metric_proposal_votes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "proposal_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "vote_type" "text" NOT NULL,
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "metric_proposal_votes_vote_type_check" CHECK (("vote_type" = ANY (ARRAY['support'::"text", 'oppose'::"text", 'abstain'::"text"])))
);


ALTER TABLE "public"."metric_proposal_votes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."metric_versions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "metric_id" integer NOT NULL,
    "version_number" integer NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "question" "text" NOT NULL,
    "criteria" "text" NOT NULL,
    "min_val" integer,
    "max_val" integer,
    "changed_by" "uuid",
    "change_reason" "text",
    "rfc_id" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."metric_versions" OWNER TO "postgres";


COMMENT ON TABLE "public"."metric_versions" IS 'Version history for metric definition changes';



COMMENT ON COLUMN "public"."metric_versions"."version_number" IS 'Sequential version number per metric';



CREATE TABLE IF NOT EXISTS "public"."metrics" (
    "id" integer NOT NULL,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "question" "text" NOT NULL,
    "criteria" "text" NOT NULL,
    "min_val" integer DEFAULT 1,
    "max_val" integer DEFAULT 5,
    "community_score" numeric(3,1) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "low_description" "text",
    "high_description" "text",
    "scoring_criteria" "jsonb"
);


ALTER TABLE "public"."metrics" OWNER TO "postgres";


COMMENT ON TABLE "public"."metrics" IS 'QDD Protocol: 20 standard metrics for evaluating Qualitative Directional Disclosure';



COMMENT ON COLUMN "public"."metrics"."low_description" IS 'Description for the lowest score (1)';



COMMENT ON COLUMN "public"."metrics"."high_description" IS 'Description for the highest score (5)';



COMMENT ON COLUMN "public"."metrics"."scoring_criteria" IS 'Rich JSON array defining criteria for scores 1-5 (metrics 1-10 only)';



CREATE SEQUENCE IF NOT EXISTS "public"."metrics_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."metrics_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."metrics_id_seq" OWNED BY "public"."metrics"."id";



CREATE TABLE IF NOT EXISTS "public"."origin_types" (
    "slug" "text" NOT NULL,
    "label" "text" NOT NULL,
    "abbreviation" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."origin_types" OWNER TO "postgres";


COMMENT ON TABLE "public"."origin_types" IS 'Reference table for disclosure origin types';



COMMENT ON COLUMN "public"."origin_types"."is_active" IS 'Whether this origin type is currently active and available for selection';



CREATE TABLE IF NOT EXISTS "public"."protocol_config" (
    "id" integer NOT NULL,
    "config_key" "text" NOT NULL,
    "config_value" "text" NOT NULL,
    "description" "text",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "updated_by" "uuid"
);


ALTER TABLE "public"."protocol_config" OWNER TO "postgres";


COMMENT ON TABLE "public"."protocol_config" IS 'Configuration table for QDD Protocol settings including version management';



CREATE SEQUENCE IF NOT EXISTS "public"."protocol_config_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."protocol_config_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."protocol_config_id_seq" OWNED BY "public"."protocol_config"."id";



CREATE OR REPLACE VIEW "public"."public_profiles" AS
 SELECT "user_id",
    "contributor_id",
        CASE
            WHEN (("anonymous" = true) OR ("anonymous" IS NULL)) THEN "pseudonym"
            WHEN ("oauth_verified" = true) THEN "oauth_handle"
            ELSE "pseudonym"
        END AS "display_name",
        CASE
            WHEN (("oauth_verified" = true) AND ("anonymous" = false)) THEN "oauth_provider"
            ELSE NULL::"text"
        END AS "verified_provider",
        CASE
            WHEN (("oauth_verified" = true) AND ("anonymous" = false)) THEN "oauth_profile_url"
            ELSE NULL::"text"
        END AS "verified_url",
    "oauth_verified",
    "anonymous",
        CASE
            WHEN "allow_public_profile" THEN "bio"
            ELSE NULL::"text"
        END AS "bio",
        CASE
            WHEN "allow_public_profile" THEN "avatar_url"
            ELSE NULL::"text"
        END AS "avatar_url",
    "created_at"
   FROM "public"."user_profiles"
  WHERE (("allow_public_profile" = true) OR ("allow_public_profile" IS NULL));


ALTER VIEW "public"."public_profiles" OWNER TO "postgres";


COMMENT ON VIEW "public"."public_profiles" IS 'Privacy-safe view of user profiles for public consumption';



CREATE TABLE IF NOT EXISTS "public"."rfc_proposals" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "metric_id" integer,
    "proposal_type" "text" NOT NULL,
    "proposed_name" "text",
    "proposed_question" "text",
    "proposed_min_criteria" "text",
    "proposed_max_criteria" "text",
    "proposed_category" "text",
    "rich_entries" "text",
    "rationale" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "review_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "rfc_proposals_proposal_type_check" CHECK (("proposal_type" = ANY (ARRAY['modify_existing'::"text", 'new_metric'::"text"]))),
    CONSTRAINT "rfc_proposals_proposed_category_check" CHECK (("proposed_category" = ANY (ARRAY['CORE'::"text", 'INTEGRITY'::"text", 'IMPACT'::"text"]))),
    CONSTRAINT "rfc_proposals_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'under_review'::"text", 'approved'::"text", 'rejected'::"text", 'implemented'::"text"])))
);


ALTER TABLE "public"."rfc_proposals" OWNER TO "postgres";


COMMENT ON TABLE "public"."rfc_proposals" IS 'Structured RFC proposals for modifying or creating metrics';



COMMENT ON COLUMN "public"."rfc_proposals"."proposal_type" IS 'Type: modify_existing or new_metric';



COMMENT ON COLUMN "public"."rfc_proposals"."rich_entries" IS 'Optional: examples and detailed explanations';



COMMENT ON COLUMN "public"."rfc_proposals"."rationale" IS 'Required: explanation for the proposed change';



COMMENT ON COLUMN "public"."rfc_proposals"."status" IS 'Workflow: pending → under_review → approved/rejected → implemented';



CREATE TABLE IF NOT EXISTS "public"."rfc_votes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "rfc_id" "uuid",
    "user_id" "uuid",
    "confidence_level" "text",
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "vote" "text" NOT NULL,
    CONSTRAINT "rfc_votes_confidence_level_check" CHECK (("confidence_level" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text"]))),
    CONSTRAINT "rfc_votes_vote_check" CHECK (("vote" = ANY (ARRAY['approve'::"text", 'reject'::"text", 'abstain'::"text"])))
);


ALTER TABLE "public"."rfc_votes" OWNER TO "postgres";


COMMENT ON COLUMN "public"."rfc_votes"."vote" IS 'Vote type: approve, reject, or abstain';



CREATE TABLE IF NOT EXISTS "public"."saved_searches" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "search_query" "text" NOT NULL,
    "filters" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "last_used_at" timestamp with time zone DEFAULT "now"(),
    "use_count" integer DEFAULT 0
);


ALTER TABLE "public"."saved_searches" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."search_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "search_query" "text" NOT NULL,
    "search_context" "text",
    "results_count" integer,
    "is_saved" boolean DEFAULT false,
    "saved_name" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "search_history_search_context_check" CHECK (("search_context" = ANY (ARRAY['metrics'::"text", 'targets'::"text", 'discussions'::"text", 'global'::"text"])))
);


ALTER TABLE "public"."search_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."search_history" IS 'User search history and saved searches';



COMMENT ON COLUMN "public"."search_history"."is_saved" IS 'Whether this search is saved for quick access';



CREATE TABLE IF NOT EXISTS "public"."submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "metric_id" integer,
    "submission_type" "text" NOT NULL,
    "title" "text" NOT NULL,
    "content" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "submissions_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text", 'under_review'::"text"]))),
    CONSTRAINT "submissions_submission_type_check" CHECK (("submission_type" = ANY (ARRAY['rfc'::"text", 'score_verification'::"text", 'context_addendum'::"text", 'general_edit'::"text"])))
);


ALTER TABLE "public"."submissions" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."targets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "case_id" "text" NOT NULL,
    "origin" "text" NOT NULL,
    "context" "text" NOT NULL,
    "verified" boolean DEFAULT false,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "source_url" "text",
    "date_of_disclosure" "date",
    "primary_source" "text",
    "tags" "text"[],
    "slug" "text" GENERATED ALWAYS AS ("public"."generate_target_slug"("case_id", "name")) STORED
);


ALTER TABLE "public"."targets" OWNER TO "postgres";


COMMENT ON COLUMN "public"."targets"."source_url" IS 'Primary source URL for the disclosure';



COMMENT ON COLUMN "public"."targets"."date_of_disclosure" IS 'Date when the disclosure occurred';



COMMENT ON COLUMN "public"."targets"."primary_source" IS 'Name of the primary source/whistleblower';



COMMENT ON COLUMN "public"."targets"."tags" IS 'Array of tags for categorization';



CREATE TABLE IF NOT EXISTS "public"."user_scores" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "target_id" "text",
    "metric_id" integer,
    "score" integer NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "action_vote" "text",
    "action_notes" "text",
    "confidence_level" "text",
    "score_type" "text" DEFAULT 'slider'::"text",
    "last_updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "user_scores_action_vote_check" CHECK (("action_vote" = ANY (ARRAY['keep'::"text", 'modify'::"text", 'drop'::"text", 'low'::"text", 'medium'::"text", 'high'::"text"]))),
    CONSTRAINT "user_scores_confidence_level_check" CHECK (("confidence_level" = ANY (ARRAY['low'::"text", 'medium'::"text", 'high'::"text"]))),
    CONSTRAINT "user_scores_score_check" CHECK ((("score" >= 0) AND ("score" <= 5))),
    CONSTRAINT "user_scores_score_type_check" CHECK (("score_type" = ANY (ARRAY['slider'::"text", 'button'::"text"])))
);


ALTER TABLE "public"."user_scores" OWNER TO "postgres";


COMMENT ON COLUMN "public"."user_scores"."action_vote" IS 'Governance vote: keep, modify, drop OR Confidence level: low, medium, high';



COMMENT ON COLUMN "public"."user_scores"."action_notes" IS 'User notes explaining their governance vote';



COMMENT ON COLUMN "public"."user_scores"."confidence_level" IS 'User confidence in their score (optional)';



COMMENT ON COLUMN "public"."user_scores"."score_type" IS 'Whether score came from slider or button interface';



CREATE OR REPLACE VIEW "public"."target_score_aggregates" AS
 SELECT "t"."id" AS "target_id",
    "t"."name" AS "target_name",
    "m"."id" AS "metric_id",
    "m"."name" AS "metric_name",
    "count"("us"."id") FILTER (WHERE ("us"."score" IS NOT NULL)) AS "total_votes",
    "avg"("us"."score") FILTER (WHERE ("us"."score" IS NOT NULL)) AS "average_score",
    "mode"() WITHIN GROUP (ORDER BY "us"."score") FILTER (WHERE ("us"."score" IS NOT NULL)) AS "most_common_score",
    "count"("us"."id") FILTER (WHERE ("us"."action_vote" IS NOT NULL)) AS "total_governance_votes",
    "count"("us"."id") FILTER (WHERE ("us"."action_vote" = 'keep'::"text")) AS "keep_votes",
    "count"("us"."id") FILTER (WHERE ("us"."action_vote" = 'modify'::"text")) AS "modify_votes",
    "count"("us"."id") FILTER (WHERE ("us"."action_vote" = 'drop'::"text")) AS "drop_votes",
    "mode"() WITHIN GROUP (ORDER BY "us"."action_vote") FILTER (WHERE ("us"."action_vote" IS NOT NULL)) AS "consensus_action"
   FROM (("public"."targets" "t"
     CROSS JOIN "public"."metrics" "m")
     LEFT JOIN "public"."user_scores" "us" ON ((("us"."target_id" = "t"."id") AND ("us"."metric_id" = "m"."id"))))
  GROUP BY "t"."id", "t"."name", "m"."id", "m"."name";


ALTER VIEW "public"."target_score_aggregates" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."target_submissions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "target_name" "text" NOT NULL,
    "case_id" "text",
    "origin" "text",
    "context" "text",
    "description" "text" NOT NULL,
    "source_url" "text",
    "date_of_disclosure" "date" NOT NULL,
    "primary_source" "text",
    "additional_notes" "text",
    "status" "text" DEFAULT 'pending'::"text",
    "submitted_by" "uuid",
    "submitted_at" timestamp with time zone DEFAULT "now"(),
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "review_notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "target_submissions_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."target_submissions" OWNER TO "postgres";


COMMENT ON TABLE "public"."target_submissions" IS 'User-submitted disclosure targets pending review';



CREATE TABLE IF NOT EXISTS "public"."target_tags" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "target_id" "text" NOT NULL,
    "tag_name" "text" NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."target_tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."target_tags" IS 'Tagging system for disclosure targets';



COMMENT ON COLUMN "public"."target_tags"."tag_name" IS 'Tag name (case-sensitive)';



CREATE TABLE IF NOT EXISTS "public"."user_preferences" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "last_viewed_tab" "text",
    "sidebar_collapsed" boolean DEFAULT false,
    "theme" "text" DEFAULT 'dark'::"text",
    "saved_filters" "jsonb" DEFAULT '{}'::"jsonb",
    "email_notifications" boolean DEFAULT true,
    "discussion_notifications" boolean DEFAULT true,
    "rfc_notifications" boolean DEFAULT true,
    "items_per_page" integer DEFAULT 20,
    "show_consensus_overlay" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "selected_category_filter" "text" DEFAULT 'all'::"text",
    "search_query" "text" DEFAULT ''::"text",
    CONSTRAINT "user_preferences_items_per_page_check" CHECK ((("items_per_page" >= 10) AND ("items_per_page" <= 100))),
    CONSTRAINT "user_preferences_last_viewed_tab_check" CHECK (("last_viewed_tab" = ANY (ARRAY['standards'::"text", 'scoring'::"text", 'voting'::"text", 'activity'::"text"]))),
    CONSTRAINT "user_preferences_theme_check" CHECK (("theme" = ANY (ARRAY['light'::"text", 'dark'::"text", 'auto'::"text"])))
);


ALTER TABLE "public"."user_preferences" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_preferences" IS 'User UI/UX preferences and settings';



COMMENT ON COLUMN "public"."user_preferences"."theme" IS 'UI theme: light, dark, or auto (system)';



COMMENT ON COLUMN "public"."user_preferences"."saved_filters" IS 'JSONB object containing saved filter states';



COMMENT ON COLUMN "public"."user_preferences"."items_per_page" IS 'Number of items to display per page (10-100)';



CREATE TABLE IF NOT EXISTS "public"."user_score_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_score_id" "uuid",
    "user_id" "uuid",
    "target_id" "text",
    "metric_id" integer,
    "score" integer,
    "notes" "text",
    "action_vote" "text",
    "action_notes" "text",
    "change_type" "text" NOT NULL,
    "changed_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    CONSTRAINT "user_score_history_action_vote_check" CHECK (("action_vote" = ANY (ARRAY['keep'::"text", 'modify'::"text", 'drop'::"text", 'low'::"text", 'medium'::"text", 'high'::"text"]))),
    CONSTRAINT "user_score_history_change_type_check" CHECK (("change_type" = ANY (ARRAY['score_update'::"text", 'governance_vote'::"text", 'notes_update'::"text", 'full_update'::"text"]))),
    CONSTRAINT "user_score_history_score_check" CHECK ((("score" >= 0) AND ("score" <= 5)))
);


ALTER TABLE "public"."user_score_history" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_score_history" IS 'Audit trail of all changes to user scores and governance votes';



CREATE TABLE IF NOT EXISTS "public"."user_sessions" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "session_id" "text" NOT NULL,
    "ip_address" "inet",
    "user_agent" "text",
    "device_type" "text",
    "started_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "last_activity_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "ended_at" timestamp with time zone,
    "page_views" integer DEFAULT 0,
    "actions_count" integer DEFAULT 0,
    CONSTRAINT "user_sessions_device_type_check" CHECK (("device_type" = ANY (ARRAY['mobile'::"text", 'tablet'::"text", 'desktop'::"text", 'unknown'::"text"])))
);


ALTER TABLE "public"."user_sessions" OWNER TO "postgres";


COMMENT ON TABLE "public"."user_sessions" IS 'Enhanced session tracking and analytics';



COMMENT ON COLUMN "public"."user_sessions"."session_id" IS 'Unique session identifier';



CREATE TABLE IF NOT EXISTS "public"."vote_rationales" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "vote_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "metric_id" integer NOT NULL,
    "target_id" "text" NOT NULL,
    "rationale" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."vote_rationales" OWNER TO "postgres";


ALTER TABLE ONLY "public"."metrics" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."metrics_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."protocol_config" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."protocol_config_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."activity_log"
    ADD CONSTRAINT "activity_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."approved_targets"
    ADD CONSTRAINT "approved_targets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assessment_notes"
    ADD CONSTRAINT "assessment_notes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."community_votes"
    ADD CONSTRAINT "community_votes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."community_votes"
    ADD CONSTRAINT "community_votes_user_id_target_id_metric_id_key" UNIQUE ("user_id", "target_id", "metric_id");



ALTER TABLE ONLY "public"."context_types"
    ADD CONSTRAINT "context_types_pkey" PRIMARY KEY ("slug");



ALTER TABLE ONLY "public"."discussion_votes"
    ADD CONSTRAINT "discussion_votes_discussion_id_user_id_key" UNIQUE ("discussion_id", "user_id");



ALTER TABLE ONLY "public"."discussion_votes"
    ADD CONSTRAINT "discussion_votes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."metric_discussions"
    ADD CONSTRAINT "metric_discussions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."metric_proposal_votes"
    ADD CONSTRAINT "metric_proposal_votes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."metric_proposal_votes"
    ADD CONSTRAINT "metric_proposal_votes_proposal_id_user_id_key" UNIQUE ("proposal_id", "user_id");



ALTER TABLE ONLY "public"."metric_versions"
    ADD CONSTRAINT "metric_versions_metric_id_version_number_key" UNIQUE ("metric_id", "version_number");



ALTER TABLE ONLY "public"."metric_versions"
    ADD CONSTRAINT "metric_versions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."metrics"
    ADD CONSTRAINT "metrics_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."new_metric_proposals"
    ADD CONSTRAINT "new_metric_proposals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."origin_types"
    ADD CONSTRAINT "origin_types_abbreviation_key" UNIQUE ("abbreviation");



ALTER TABLE ONLY "public"."origin_types"
    ADD CONSTRAINT "origin_types_pkey" PRIMARY KEY ("slug");



ALTER TABLE ONLY "public"."protocol_config"
    ADD CONSTRAINT "protocol_config_config_key_key" UNIQUE ("config_key");



ALTER TABLE ONLY "public"."protocol_config"
    ADD CONSTRAINT "protocol_config_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rfc_proposals"
    ADD CONSTRAINT "rfc_proposals_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rfc_votes"
    ADD CONSTRAINT "rfc_votes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."rfc_votes"
    ADD CONSTRAINT "rfc_votes_rfc_id_user_id_key" UNIQUE ("rfc_id", "user_id");



ALTER TABLE ONLY "public"."saved_searches"
    ADD CONSTRAINT "saved_searches_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."saved_searches"
    ADD CONSTRAINT "saved_searches_user_id_name_key" UNIQUE ("user_id", "name");



ALTER TABLE ONLY "public"."search_history"
    ADD CONSTRAINT "search_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."target_submissions"
    ADD CONSTRAINT "target_submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."target_tags"
    ADD CONSTRAINT "target_tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."target_tags"
    ADD CONSTRAINT "target_tags_target_id_tag_name_key" UNIQUE ("target_id", "tag_name");



ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_case_id_key" UNIQUE ("case_id");



ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "targets_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."user_score_history"
    ADD CONSTRAINT "user_score_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_user_id_target_id_metric_id_key" UNIQUE ("user_id", "target_id", "metric_id");



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_session_id_key" UNIQUE ("session_id");



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_vote_id_key" UNIQUE ("vote_id");



CREATE INDEX "idx_activity_log_activity_type" ON "public"."activity_log" USING "btree" ("activity_type");



CREATE INDEX "idx_activity_log_created_at" ON "public"."activity_log" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_activity_log_discussion_id" ON "public"."activity_log" USING "btree" ("discussion_id") WHERE ("discussion_id" IS NOT NULL);



CREATE INDEX "idx_activity_log_metric_id" ON "public"."activity_log" USING "btree" ("metric_id") WHERE ("metric_id" IS NOT NULL);



CREATE INDEX "idx_activity_log_rfc_id" ON "public"."activity_log" USING "btree" ("rfc_id") WHERE ("rfc_id" IS NOT NULL);



CREATE INDEX "idx_activity_log_target_id" ON "public"."activity_log" USING "btree" ("target_id") WHERE ("target_id" IS NOT NULL);



CREATE INDEX "idx_activity_log_user_created" ON "public"."activity_log" USING "btree" ("user_id", "created_at" DESC) WHERE ("user_id" IS NOT NULL);



CREATE INDEX "idx_activity_log_user_id" ON "public"."activity_log" USING "btree" ("user_id") WHERE ("user_id" IS NOT NULL);



CREATE INDEX "idx_approved_targets_slug" ON "public"."approved_targets" USING "btree" ("slug");



CREATE INDEX "idx_assessment_notes_created_at" ON "public"."assessment_notes" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_assessment_notes_current" ON "public"."assessment_notes" USING "btree" ("target_id", "metric_id", "user_id", "is_current") WHERE ("is_current" = true);



CREATE INDEX "idx_assessment_notes_metric_id" ON "public"."assessment_notes" USING "btree" ("metric_id");



CREATE INDEX "idx_assessment_notes_target_id" ON "public"."assessment_notes" USING "btree" ("target_id");



CREATE INDEX "idx_assessment_notes_user_id" ON "public"."assessment_notes" USING "btree" ("user_id");



CREATE INDEX "idx_community_votes_created_at" ON "public"."community_votes" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_community_votes_metric_id" ON "public"."community_votes" USING "btree" ("metric_id");



CREATE INDEX "idx_community_votes_target_id" ON "public"."community_votes" USING "btree" ("target_id");



CREATE INDEX "idx_community_votes_user_id" ON "public"."community_votes" USING "btree" ("user_id");



CREATE INDEX "idx_context_types_is_active" ON "public"."context_types" USING "btree" ("is_active");



CREATE INDEX "idx_context_types_sort_order" ON "public"."context_types" USING "btree" ("sort_order");



CREATE INDEX "idx_metric_discussions_created_at" ON "public"."metric_discussions" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_metric_discussions_metric_id" ON "public"."metric_discussions" USING "btree" ("metric_id");



CREATE INDEX "idx_metric_discussions_parent_id" ON "public"."metric_discussions" USING "btree" ("parent_id");



CREATE INDEX "idx_metric_proposal_votes_proposal" ON "public"."metric_proposal_votes" USING "btree" ("proposal_id");



CREATE INDEX "idx_metric_proposal_votes_user" ON "public"."metric_proposal_votes" USING "btree" ("user_id");



CREATE INDEX "idx_metric_versions_changed_by" ON "public"."metric_versions" USING "btree" ("changed_by") WHERE ("changed_by" IS NOT NULL);



CREATE INDEX "idx_metric_versions_created_at" ON "public"."metric_versions" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_metric_versions_metric_id" ON "public"."metric_versions" USING "btree" ("metric_id");



CREATE INDEX "idx_metric_versions_rfc_id" ON "public"."metric_versions" USING "btree" ("rfc_id") WHERE ("rfc_id" IS NOT NULL);



CREATE INDEX "idx_new_metric_proposals_created_at" ON "public"."new_metric_proposals" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_new_metric_proposals_proposed_by" ON "public"."new_metric_proposals" USING "btree" ("proposed_by");



CREATE INDEX "idx_new_metric_proposals_status" ON "public"."new_metric_proposals" USING "btree" ("status");



CREATE INDEX "idx_origin_types_is_active" ON "public"."origin_types" USING "btree" ("is_active");



CREATE INDEX "idx_origin_types_sort_order" ON "public"."origin_types" USING "btree" ("sort_order");



CREATE INDEX "idx_rfc_proposals_created_at" ON "public"."rfc_proposals" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_rfc_proposals_metric_id" ON "public"."rfc_proposals" USING "btree" ("metric_id");



CREATE INDEX "idx_rfc_proposals_proposal_type" ON "public"."rfc_proposals" USING "btree" ("proposal_type");



CREATE INDEX "idx_rfc_proposals_reviewed_by" ON "public"."rfc_proposals" USING "btree" ("reviewed_by") WHERE ("reviewed_by" IS NOT NULL);



CREATE INDEX "idx_rfc_proposals_status" ON "public"."rfc_proposals" USING "btree" ("status");



CREATE INDEX "idx_rfc_proposals_user_id" ON "public"."rfc_proposals" USING "btree" ("user_id");



CREATE INDEX "idx_rfc_votes_vote" ON "public"."rfc_votes" USING "btree" ("vote");



CREATE INDEX "idx_saved_searches_last_used" ON "public"."saved_searches" USING "btree" ("last_used_at" DESC);



CREATE INDEX "idx_saved_searches_user_id" ON "public"."saved_searches" USING "btree" ("user_id");



CREATE INDEX "idx_search_history_created_at" ON "public"."search_history" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_search_history_is_saved" ON "public"."search_history" USING "btree" ("is_saved") WHERE ("is_saved" = true);



CREATE INDEX "idx_search_history_user_id" ON "public"."search_history" USING "btree" ("user_id");



CREATE INDEX "idx_submissions_metric_id" ON "public"."submissions" USING "btree" ("metric_id");



CREATE INDEX "idx_submissions_status" ON "public"."submissions" USING "btree" ("status");



CREATE INDEX "idx_submissions_user_id" ON "public"."submissions" USING "btree" ("user_id");



CREATE INDEX "idx_target_submissions_status" ON "public"."target_submissions" USING "btree" ("status");



CREATE INDEX "idx_target_submissions_submitted_at" ON "public"."target_submissions" USING "btree" ("submitted_at" DESC);



CREATE INDEX "idx_target_submissions_submitted_by" ON "public"."target_submissions" USING "btree" ("submitted_by");



CREATE INDEX "idx_target_tags_created_by" ON "public"."target_tags" USING "btree" ("created_by") WHERE ("created_by" IS NOT NULL);



CREATE INDEX "idx_target_tags_tag_name" ON "public"."target_tags" USING "btree" ("tag_name");



CREATE INDEX "idx_target_tags_target_id" ON "public"."target_tags" USING "btree" ("target_id");



CREATE INDEX "idx_targets_slug" ON "public"."targets" USING "btree" ("slug");



CREATE INDEX "idx_user_preferences_user_id" ON "public"."user_preferences" USING "btree" ("user_id");



CREATE INDEX "idx_user_profiles_anonymous" ON "public"."user_profiles" USING "btree" ("anonymous");



CREATE INDEX "idx_user_profiles_beta_features" ON "public"."user_profiles" USING "btree" ("beta_features_enabled") WHERE ("beta_features_enabled" = true);



CREATE INDEX "idx_user_profiles_contributor_id" ON "public"."user_profiles" USING "btree" ("contributor_id");



CREATE UNIQUE INDEX "idx_user_profiles_contributor_id_unique" ON "public"."user_profiles" USING "btree" ("contributor_id") WHERE ("contributor_id" IS NOT NULL);



CREATE INDEX "idx_user_profiles_oauth_verified" ON "public"."user_profiles" USING "btree" ("oauth_verified") WHERE ("oauth_verified" = true);



CREATE INDEX "idx_user_profiles_pseudonym" ON "public"."user_profiles" USING "btree" ("pseudonym");



CREATE UNIQUE INDEX "idx_user_profiles_pseudonym_unique" ON "public"."user_profiles" USING "btree" ("pseudonym") WHERE ("pseudonym" IS NOT NULL);



CREATE INDEX "idx_user_profiles_role" ON "public"."user_profiles" USING "btree" ("role");



CREATE INDEX "idx_user_profiles_user_id" ON "public"."user_profiles" USING "btree" ("user_id");



CREATE INDEX "idx_user_score_history_change_type" ON "public"."user_score_history" USING "btree" ("change_type");



CREATE INDEX "idx_user_score_history_changed_at" ON "public"."user_score_history" USING "btree" ("changed_at" DESC);



CREATE INDEX "idx_user_score_history_user_id" ON "public"."user_score_history" USING "btree" ("user_id");



CREATE INDEX "idx_user_score_history_user_score_id" ON "public"."user_score_history" USING "btree" ("user_score_id");



CREATE INDEX "idx_user_scores_metric_id" ON "public"."user_scores" USING "btree" ("metric_id");



CREATE INDEX "idx_user_scores_score_type" ON "public"."user_scores" USING "btree" ("score_type");



CREATE INDEX "idx_user_scores_target_id" ON "public"."user_scores" USING "btree" ("target_id");



CREATE INDEX "idx_user_scores_user_id" ON "public"."user_scores" USING "btree" ("user_id");



CREATE INDEX "idx_user_sessions_session_id" ON "public"."user_sessions" USING "btree" ("session_id");



CREATE INDEX "idx_user_sessions_started_at" ON "public"."user_sessions" USING "btree" ("started_at" DESC);



CREATE INDEX "idx_user_sessions_user_id" ON "public"."user_sessions" USING "btree" ("user_id") WHERE ("user_id" IS NOT NULL);



CREATE INDEX "idx_vote_rationales_metric_id" ON "public"."vote_rationales" USING "btree" ("metric_id");



CREATE INDEX "idx_vote_rationales_user_id" ON "public"."vote_rationales" USING "btree" ("user_id");



CREATE INDEX "idx_vote_rationales_vote_id" ON "public"."vote_rationales" USING "btree" ("vote_id");



CREATE OR REPLACE TRIGGER "on_user_profile_created_preferences" AFTER INSERT ON "public"."user_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."create_user_preferences"();



CREATE OR REPLACE TRIGGER "set_assessment_notes_updated_at" BEFORE UPDATE ON "public"."assessment_notes" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_community_votes_updated_at" BEFORE UPDATE ON "public"."community_votes" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_rfc_proposals_updated_at" BEFORE UPDATE ON "public"."rfc_proposals" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_submissions_updated_at" BEFORE UPDATE ON "public"."submissions" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_targets_updated_at" BEFORE UPDATE ON "public"."targets" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_updated_at" BEFORE UPDATE ON "public"."metrics" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_user_preferences_updated_at" BEFORE UPDATE ON "public"."user_preferences" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_user_scores_updated_at" BEFORE UPDATE ON "public"."user_scores" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_archive_assessment_notes" AFTER INSERT ON "public"."assessment_notes" FOR EACH ROW EXECUTE FUNCTION "public"."archive_old_assessment_notes"();



CREATE OR REPLACE TRIGGER "trigger_auto_generate_case_id" BEFORE INSERT ON "public"."target_submissions" FOR EACH ROW EXECUTE FUNCTION "public"."auto_generate_case_id"();



CREATE OR REPLACE TRIGGER "trigger_log_user_score_change" AFTER INSERT OR UPDATE ON "public"."user_scores" FOR EACH ROW EXECUTE FUNCTION "public"."log_user_score_change"();



CREATE OR REPLACE TRIGGER "trigger_update_discussion_votes" AFTER INSERT OR DELETE OR UPDATE ON "public"."discussion_votes" FOR EACH ROW EXECUTE FUNCTION "public"."update_discussion_votes"();



CREATE OR REPLACE TRIGGER "trigger_update_metric_discussions_updated_at" BEFORE UPDATE ON "public"."metric_discussions" FOR EACH ROW EXECUTE FUNCTION "public"."update_metric_discussions_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_proposal_votes" AFTER INSERT OR DELETE OR UPDATE ON "public"."metric_proposal_votes" FOR EACH ROW EXECUTE FUNCTION "public"."update_proposal_vote_counts"();



CREATE OR REPLACE TRIGGER "trigger_update_target_submissions_updated_at" BEFORE UPDATE ON "public"."target_submissions" FOR EACH ROW EXECUTE FUNCTION "public"."update_target_submissions_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_update_user_scores_timestamp" BEFORE UPDATE ON "public"."user_scores" FOR EACH ROW EXECUTE FUNCTION "public"."update_user_scores_timestamp"();



ALTER TABLE ONLY "public"."activity_log"
    ADD CONSTRAINT "activity_log_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_log"
    ADD CONSTRAINT "activity_log_rfc_id_fkey" FOREIGN KEY ("rfc_id") REFERENCES "public"."rfc_proposals"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_log"
    ADD CONSTRAINT "activity_log_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."activity_log"
    ADD CONSTRAINT "activity_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."approved_targets"
    ADD CONSTRAINT "approved_targets_submission_id_fkey" FOREIGN KEY ("submission_id") REFERENCES "public"."target_submissions"("id");



ALTER TABLE ONLY "public"."assessment_notes"
    ADD CONSTRAINT "assessment_notes_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assessment_notes"
    ADD CONSTRAINT "assessment_notes_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assessment_notes"
    ADD CONSTRAINT "assessment_notes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."community_votes"
    ADD CONSTRAINT "community_votes_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."community_votes"
    ADD CONSTRAINT "community_votes_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."community_votes"
    ADD CONSTRAINT "community_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."discussion_votes"
    ADD CONSTRAINT "discussion_votes_discussion_id_fkey" FOREIGN KEY ("discussion_id") REFERENCES "public"."metric_discussions"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."discussion_votes"
    ADD CONSTRAINT "discussion_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."approved_targets"
    ADD CONSTRAINT "fk_approved_targets_context_types" FOREIGN KEY ("context") REFERENCES "public"."context_types"("slug");



ALTER TABLE ONLY "public"."approved_targets"
    ADD CONSTRAINT "fk_approved_targets_origin_types" FOREIGN KEY ("origin") REFERENCES "public"."origin_types"("slug");



ALTER TABLE ONLY "public"."target_submissions"
    ADD CONSTRAINT "fk_target_submissions_context_types" FOREIGN KEY ("context") REFERENCES "public"."context_types"("slug");



ALTER TABLE ONLY "public"."target_submissions"
    ADD CONSTRAINT "fk_target_submissions_origin_types" FOREIGN KEY ("origin") REFERENCES "public"."origin_types"("slug");



ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "fk_targets_context_types" FOREIGN KEY ("context") REFERENCES "public"."context_types"("slug");



ALTER TABLE ONLY "public"."targets"
    ADD CONSTRAINT "fk_targets_origin_types" FOREIGN KEY ("origin") REFERENCES "public"."origin_types"("slug");



ALTER TABLE ONLY "public"."metric_discussions"
    ADD CONSTRAINT "metric_discussions_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."metric_discussions"("id");



ALTER TABLE ONLY "public"."metric_discussions"
    ADD CONSTRAINT "metric_discussions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."metric_proposal_votes"
    ADD CONSTRAINT "metric_proposal_votes_proposal_id_fkey" FOREIGN KEY ("proposal_id") REFERENCES "public"."new_metric_proposals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."metric_proposal_votes"
    ADD CONSTRAINT "metric_proposal_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."metric_versions"
    ADD CONSTRAINT "metric_versions_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."metric_versions"
    ADD CONSTRAINT "metric_versions_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."metric_versions"
    ADD CONSTRAINT "metric_versions_rfc_id_fkey" FOREIGN KEY ("rfc_id") REFERENCES "public"."rfc_proposals"("id");



ALTER TABLE ONLY "public"."new_metric_proposals"
    ADD CONSTRAINT "new_metric_proposals_implemented_metric_id_fkey" FOREIGN KEY ("implemented_metric_id") REFERENCES "public"."metrics"("id");



ALTER TABLE ONLY "public"."new_metric_proposals"
    ADD CONSTRAINT "new_metric_proposals_proposed_by_fkey" FOREIGN KEY ("proposed_by") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."new_metric_proposals"
    ADD CONSTRAINT "new_metric_proposals_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."protocol_config"
    ADD CONSTRAINT "protocol_config_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."rfc_proposals"
    ADD CONSTRAINT "rfc_proposals_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."rfc_proposals"
    ADD CONSTRAINT "rfc_proposals_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."rfc_proposals"
    ADD CONSTRAINT "rfc_proposals_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."rfc_votes"
    ADD CONSTRAINT "rfc_votes_rfc_id_fkey" FOREIGN KEY ("rfc_id") REFERENCES "public"."rfc_proposals"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."rfc_votes"
    ADD CONSTRAINT "rfc_votes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."saved_searches"
    ADD CONSTRAINT "saved_searches_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."search_history"
    ADD CONSTRAINT "search_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."submissions"
    ADD CONSTRAINT "submissions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."target_submissions"
    ADD CONSTRAINT "target_submissions_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."target_submissions"
    ADD CONSTRAINT "target_submissions_submitted_by_fkey" FOREIGN KEY ("submitted_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."target_tags"
    ADD CONSTRAINT "target_tags_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."target_tags"
    ADD CONSTRAINT "target_tags_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_preferences"
    ADD CONSTRAINT "user_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_profiles"
    ADD CONSTRAINT "user_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_score_history"
    ADD CONSTRAINT "user_score_history_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_score_history"
    ADD CONSTRAINT "user_score_history_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_score_history"
    ADD CONSTRAINT "user_score_history_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_score_history"
    ADD CONSTRAINT "user_score_history_user_score_id_fkey" FOREIGN KEY ("user_score_id") REFERENCES "public"."user_scores"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_scores"
    ADD CONSTRAINT "user_scores_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_sessions"
    ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_metric_id_fkey" FOREIGN KEY ("metric_id") REFERENCES "public"."metrics"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_target_id_fkey" FOREIGN KEY ("target_id") REFERENCES "public"."targets"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vote_rationales"
    ADD CONSTRAINT "vote_rationales_vote_id_fkey" FOREIGN KEY ("vote_id") REFERENCES "public"."community_votes"("id") ON DELETE CASCADE;



CREATE POLICY "Admins can delete tags" ON "public"."target_tags" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "Admins can manage approved targets" ON "public"."approved_targets" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."user_id" = "auth"."uid"()) AND ("user_profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can review metric proposals" ON "public"."new_metric_proposals" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."user_id" = "auth"."uid"()) AND ("user_profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can update any RFC proposal" ON "public"."rfc_proposals" FOR UPDATE USING ("public"."is_admin"());



CREATE POLICY "Admins can update protocol config" ON "public"."protocol_config" FOR UPDATE USING ((((("auth"."jwt"() ->> 'raw_user_meta_data'::"text"))::"jsonb" ->> 'role'::"text") = 'admin'::"text")) WITH CHECK ((((("auth"."jwt"() ->> 'raw_user_meta_data'::"text"))::"jsonb" ->> 'role'::"text") = 'admin'::"text"));



CREATE POLICY "Admins can update submissions" ON "public"."target_submissions" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."user_id" = "auth"."uid"()) AND ("user_profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Admins can view all submissions" ON "public"."target_submissions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."user_id" = "auth"."uid"()) AND ("user_profiles"."role" = 'admin'::"text")))));



CREATE POLICY "Anyone can read protocol config" ON "public"."protocol_config" FOR SELECT USING (true);



CREATE POLICY "Anyone can view RFC proposals" ON "public"."rfc_proposals" FOR SELECT USING (true);



CREATE POLICY "Anyone can view activity log" ON "public"."activity_log" FOR SELECT USING (true);



CREATE POLICY "Anyone can view approved targets" ON "public"."approved_targets" FOR SELECT USING (true);



CREATE POLICY "Anyone can view community votes" ON "public"."community_votes" FOR SELECT USING (true);



CREATE POLICY "Anyone can view context types" ON "public"."context_types" FOR SELECT USING (true);



CREATE POLICY "Anyone can view discussions" ON "public"."metric_discussions" FOR SELECT USING (true);



CREATE POLICY "Anyone can view metric proposal votes" ON "public"."metric_proposal_votes" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Anyone can view metric proposals" ON "public"."new_metric_proposals" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Anyone can view metric versions" ON "public"."metric_versions" FOR SELECT USING (true);



CREATE POLICY "Anyone can view origin types" ON "public"."origin_types" FOR SELECT USING (true);



CREATE POLICY "Anyone can view public assessment notes" ON "public"."assessment_notes" FOR SELECT USING ((("is_public" = true) OR ("auth"."uid"() = "user_id")));



CREATE POLICY "Anyone can view target tags" ON "public"."target_tags" FOR SELECT USING (true);



CREATE POLICY "Anyone can view votes" ON "public"."discussion_votes" FOR SELECT USING (true);



CREATE POLICY "Authenticated users can create tags" ON "public"."target_tags" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Authenticated users can insert discussions" ON "public"."metric_discussions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Authenticated users can insert votes" ON "public"."discussion_votes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Authenticated users can view all profiles" ON "public"."user_profiles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Contributors can view all submissions" ON "public"."target_submissions" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_profiles"
  WHERE (("user_profiles"."user_id" = "auth"."uid"()) AND ("user_profiles"."role" = ANY (ARRAY['admin'::"text", 'contributor'::"text"]))))));



CREATE POLICY "Enable delete for authenticated users only" ON "public"."metrics" FOR DELETE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable insert for authenticated users" ON "public"."targets" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable insert for authenticated users only" ON "public"."metrics" FOR INSERT WITH CHECK (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "Enable read access for all submissions" ON "public"."submissions" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."metrics" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."targets" FOR SELECT USING (true);



CREATE POLICY "Enable update for authenticated users only" ON "public"."metrics" FOR UPDATE USING (("auth"."role"() = 'authenticated'::"text"));



CREATE POLICY "System can insert activity logs" ON "public"."activity_log" FOR INSERT WITH CHECK (true);



CREATE POLICY "System can insert history records" ON "public"."user_score_history" FOR INSERT WITH CHECK (true);



CREATE POLICY "System can insert metric versions" ON "public"."metric_versions" FOR INSERT WITH CHECK (true);



CREATE POLICY "System can insert profiles" ON "public"."user_profiles" FOR INSERT WITH CHECK (true);



CREATE POLICY "System can manage sessions" ON "public"."user_sessions" USING (true);



CREATE POLICY "Users can create metric proposals" ON "public"."new_metric_proposals" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "proposed_by"));



CREATE POLICY "Users can create their own vote rationales" ON "public"."vote_rationales" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own discussions" ON "public"."metric_discussions" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own notes" ON "public"."assessment_notes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own pending proposals" ON "public"."rfc_proposals" FOR DELETE USING ((("auth"."uid"() = "user_id") AND ("status" = 'pending'::"text")));



CREATE POLICY "Users can delete their own preferences" ON "public"."user_preferences" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own scores" ON "public"."user_scores" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own searches" ON "public"."search_history" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own votes" ON "public"."community_votes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can delete their own votes" ON "public"."discussion_votes" FOR DELETE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert submissions" ON "public"."target_submissions" FOR INSERT WITH CHECK (("auth"."uid"() = "submitted_by"));



CREATE POLICY "Users can insert their own RFC proposals" ON "public"."rfc_proposals" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own notes" ON "public"."assessment_notes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own preferences" ON "public"."user_preferences" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own scores" ON "public"."user_scores" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own searches" ON "public"."search_history" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own submissions" ON "public"."submissions" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert their own votes" ON "public"."community_votes" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can insert/update their own votes" ON "public"."rfc_votes" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can manage their own saved searches" ON "public"."saved_searches" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own discussions" ON "public"."metric_discussions" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own draft proposals" ON "public"."new_metric_proposals" FOR UPDATE TO "authenticated" USING ((("auth"."uid"() = "proposed_by") AND ("status" = 'draft'::"text"))) WITH CHECK (("auth"."uid"() = "proposed_by"));



CREATE POLICY "Users can update their own notes" ON "public"."assessment_notes" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own pending proposals" ON "public"."rfc_proposals" FOR UPDATE USING ((("auth"."uid"() = "user_id") AND ("status" = 'pending'::"text")));



CREATE POLICY "Users can update their own preferences" ON "public"."user_preferences" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own profile" ON "public"."user_profiles" FOR UPDATE USING (("auth"."uid"() = "user_id")) WITH CHECK ((("auth"."uid"() = "user_id") AND ("role" = ( SELECT "user_profiles_1"."role"
   FROM "public"."user_profiles" "user_profiles_1"
  WHERE ("user_profiles_1"."id" = "user_profiles_1"."id")))));



CREATE POLICY "Users can update their own saved searches" ON "public"."search_history" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own scores" ON "public"."user_scores" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own submissions" ON "public"."submissions" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own vote rationales" ON "public"."vote_rationales" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own votes" ON "public"."community_votes" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own votes" ON "public"."discussion_votes" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can update their own votes" ON "public"."metric_proposal_votes" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view all RFC votes" ON "public"."rfc_votes" FOR SELECT USING (true);



CREATE POLICY "Users can view all vote rationales" ON "public"."vote_rationales" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can view their own preferences" ON "public"."user_preferences" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own score history" ON "public"."user_score_history" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own scores" ON "public"."user_scores" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own search history" ON "public"."search_history" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own sessions" ON "public"."user_sessions" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Users can view their own submissions" ON "public"."target_submissions" FOR SELECT USING (("auth"."uid"() = "submitted_by"));



CREATE POLICY "Users can vote on metric proposals" ON "public"."metric_proposal_votes" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."activity_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."approved_targets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."assessment_notes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."community_votes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."context_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."discussion_votes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."metric_discussions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."metric_proposal_votes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."metric_versions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."metrics" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."new_metric_proposals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."origin_types" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."protocol_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."rfc_proposals" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."rfc_votes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."saved_searches" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."search_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."submissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."target_submissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."target_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."targets" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_score_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_scores" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_sessions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vote_rationales" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "api" TO "anon";
GRANT USAGE ON SCHEMA "api" TO "authenticated";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
























































































































































































































































































































GRANT ALL ON FUNCTION "public"."approve_target_submission"("submission_id_param" "uuid", "target_id_param" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."approve_target_submission"("submission_id_param" "uuid", "target_id_param" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."approve_target_submission"("submission_id_param" "uuid", "target_id_param" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."archive_old_assessment_notes"() TO "anon";
GRANT ALL ON FUNCTION "public"."archive_old_assessment_notes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."archive_old_assessment_notes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_generate_case_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_generate_case_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_generate_case_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_pseudonym_available"("p_pseudonym" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_preferences"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_preferences"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_preferences"() TO "service_role";



GRANT ALL ON FUNCTION "public"."demote_admin_to_user"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."demote_admin_to_user"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."demote_admin_to_user"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."demote_contributor_to_user"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."demote_contributor_to_user"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."demote_contributor_to_user"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."disable_beta_features_non_contributors"() TO "anon";
GRANT ALL ON FUNCTION "public"."disable_beta_features_non_contributors"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."disable_beta_features_non_contributors"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enable_beta_features_all"() TO "anon";
GRANT ALL ON FUNCTION "public"."enable_beta_features_all"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enable_beta_features_all"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_case_id"("origin_param" "text", "context_param" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_contributor_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_contributor_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_contributor_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_default_pseudonym"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_default_pseudonym"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_default_pseudonym"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_target_slug"("p_case_id" "text", "p_target_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_user_list"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_user_list"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_user_list"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_assessment_notes"("p_target_id" "text", "p_metric_id" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_governance_summary"("target_id_param" "text", "metric_id_param" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_metric_discussion_count"("metric_id_param" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_metric_discussion_count"("metric_id_param" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_metric_discussion_count"("metric_id_param" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_saved_searches"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_saved_searches"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_saved_searches"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_system_activity_feed"("p_limit" integer, "p_offset" integer, "p_activity_types" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."get_system_activity_feed"("p_limit" integer, "p_offset" integer, "p_activity_types" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_system_activity_feed"("p_limit" integer, "p_offset" integer, "p_activity_types" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_activity_feed"("p_limit" integer, "p_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_activity_feed"("p_limit" integer, "p_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_activity_feed"("p_limit" integer, "p_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_preferences"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_preferences"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_preferences"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_votes_for_target"("p_target_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."has_beta_access"() TO "anon";
GRANT ALL ON FUNCTION "public"."has_beta_access"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_beta_access"() TO "service_role";



GRANT ALL ON FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."implement_rfc"("p_rfc_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_contributor"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_contributor"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_contributor"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_user_score_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_user_score_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_user_score_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."parse_case_id_from_slug"("p_slug" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."promote_user_to_admin"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."promote_user_to_admin"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."promote_user_to_admin"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."promote_user_to_contributor"("target_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."promote_user_to_contributor"("target_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."promote_user_to_contributor"("target_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."review_rfc_proposal"("p_rfc_id" "uuid", "p_status" "text", "p_review_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."revoke_target_submission"("submission_id_param" "uuid", "review_notes_param" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."revoke_target_submission"("submission_id_param" "uuid", "review_notes_param" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."revoke_target_submission"("submission_id_param" "uuid", "review_notes_param" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."save_search"("p_search_query" "text", "p_search_context" "text", "p_saved_name" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text", "p_is_public" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text", "p_is_public" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_assessment_note"("p_target_id" "text", "p_metric_id" integer, "p_note_text" "text", "p_note_type" "text", "p_is_public" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text", "p_proposed_question" "text", "p_proposed_min_criteria" "text", "p_proposed_max_criteria" "text", "p_proposed_category" "text", "p_rich_entries" "text", "p_rationale" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text", "p_proposed_question" "text", "p_proposed_min_criteria" "text", "p_proposed_max_criteria" "text", "p_proposed_category" "text", "p_rich_entries" "text", "p_rationale" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_rfc_proposal"("p_metric_id" integer, "p_proposal_type" "text", "p_proposed_name" "text", "p_proposed_question" "text", "p_proposed_min_criteria" "text", "p_proposed_max_criteria" "text", "p_proposed_category" "text", "p_rich_entries" "text", "p_rationale" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_session_activity"("p_session_id" "text", "p_page_view" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."unlink_oauth_handle"() TO "anon";
GRANT ALL ON FUNCTION "public"."unlink_oauth_handle"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."unlink_oauth_handle"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_discussion_votes"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_discussion_votes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_discussion_votes"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_metric_discussions_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_metric_discussions_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_metric_discussions_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_proposal_vote_counts"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_proposal_vote_counts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_proposal_vote_counts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_protocol_version"("new_version" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_protocol_version"("new_version" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_protocol_version"("new_version" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_pseudonym"("p_new_pseudonym" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_saved_search_usage"("search_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_saved_search_usage"("search_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_saved_search_usage"("search_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_target_submissions_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_target_submissions_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_target_submissions_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_preferences"("p_preferences" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_scores_timestamp"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_scores_timestamp"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_scores_timestamp"() TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_community_vote"("p_target_id" "text", "p_metric_id" integer, "p_vote_value" integer, "p_confidence_level" "text", "p_rationale" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_confidence_level" "text", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_confidence_level" "text", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_confidence_level" "text", "p_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_vote" "text", "p_confidence_level" "text", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_vote" "text", "p_confidence_level" "text", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."upsert_rfc_vote"("p_rfc_id" "uuid", "p_vote" "text", "p_confidence_level" "text", "p_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."verify_oauth_handle"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_oauth_handle"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_oauth_handle"() TO "service_role";





















GRANT ALL ON TABLE "public"."new_metric_proposals" TO "anon";
GRANT ALL ON TABLE "public"."new_metric_proposals" TO "authenticated";
GRANT ALL ON TABLE "public"."new_metric_proposals" TO "service_role";



GRANT ALL ON TABLE "public"."user_profiles" TO "anon";
GRANT ALL ON TABLE "public"."user_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."active_metric_proposals" TO "anon";
GRANT ALL ON TABLE "public"."active_metric_proposals" TO "authenticated";
GRANT ALL ON TABLE "public"."active_metric_proposals" TO "service_role";



GRANT ALL ON TABLE "public"."activity_log" TO "anon";
GRANT ALL ON TABLE "public"."activity_log" TO "authenticated";
GRANT ALL ON TABLE "public"."activity_log" TO "service_role";



GRANT ALL ON TABLE "public"."approved_targets" TO "anon";
GRANT ALL ON TABLE "public"."approved_targets" TO "authenticated";
GRANT ALL ON TABLE "public"."approved_targets" TO "service_role";



GRANT ALL ON TABLE "public"."assessment_notes" TO "anon";
GRANT ALL ON TABLE "public"."assessment_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."assessment_notes" TO "service_role";



GRANT ALL ON SEQUENCE "public"."case_id_ref_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."case_id_ref_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."case_id_ref_seq" TO "service_role";



GRANT ALL ON TABLE "public"."community_votes" TO "anon";
GRANT ALL ON TABLE "public"."community_votes" TO "authenticated";
GRANT ALL ON TABLE "public"."community_votes" TO "service_role";



GRANT ALL ON TABLE "public"."context_types" TO "anon";
GRANT ALL ON TABLE "public"."context_types" TO "authenticated";
GRANT ALL ON TABLE "public"."context_types" TO "service_role";



GRANT ALL ON SEQUENCE "public"."contributor_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."contributor_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."contributor_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."current_assessment_notes" TO "anon";
GRANT ALL ON TABLE "public"."current_assessment_notes" TO "authenticated";
GRANT ALL ON TABLE "public"."current_assessment_notes" TO "service_role";



GRANT ALL ON TABLE "public"."discussion_votes" TO "anon";
GRANT ALL ON TABLE "public"."discussion_votes" TO "authenticated";
GRANT ALL ON TABLE "public"."discussion_votes" TO "service_role";



GRANT ALL ON TABLE "public"."metric_discussions" TO "anon";
GRANT ALL ON TABLE "public"."metric_discussions" TO "authenticated";
GRANT ALL ON TABLE "public"."metric_discussions" TO "service_role";



GRANT ALL ON TABLE "public"."metric_proposal_votes" TO "anon";
GRANT ALL ON TABLE "public"."metric_proposal_votes" TO "authenticated";
GRANT ALL ON TABLE "public"."metric_proposal_votes" TO "service_role";



GRANT ALL ON TABLE "public"."metric_versions" TO "anon";
GRANT ALL ON TABLE "public"."metric_versions" TO "authenticated";
GRANT ALL ON TABLE "public"."metric_versions" TO "service_role";



GRANT ALL ON TABLE "public"."metrics" TO "anon";
GRANT ALL ON TABLE "public"."metrics" TO "authenticated";
GRANT ALL ON TABLE "public"."metrics" TO "service_role";



GRANT ALL ON SEQUENCE "public"."metrics_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."metrics_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."metrics_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."origin_types" TO "anon";
GRANT ALL ON TABLE "public"."origin_types" TO "authenticated";
GRANT ALL ON TABLE "public"."origin_types" TO "service_role";



GRANT ALL ON TABLE "public"."protocol_config" TO "anon";
GRANT ALL ON TABLE "public"."protocol_config" TO "authenticated";
GRANT ALL ON TABLE "public"."protocol_config" TO "service_role";



GRANT ALL ON SEQUENCE "public"."protocol_config_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."protocol_config_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."protocol_config_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."public_profiles" TO "anon";
GRANT ALL ON TABLE "public"."public_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."public_profiles" TO "service_role";



GRANT ALL ON TABLE "public"."rfc_proposals" TO "anon";
GRANT ALL ON TABLE "public"."rfc_proposals" TO "authenticated";
GRANT ALL ON TABLE "public"."rfc_proposals" TO "service_role";



GRANT ALL ON TABLE "public"."rfc_votes" TO "anon";
GRANT ALL ON TABLE "public"."rfc_votes" TO "authenticated";
GRANT ALL ON TABLE "public"."rfc_votes" TO "service_role";



GRANT ALL ON TABLE "public"."saved_searches" TO "anon";
GRANT ALL ON TABLE "public"."saved_searches" TO "authenticated";
GRANT ALL ON TABLE "public"."saved_searches" TO "service_role";



GRANT ALL ON TABLE "public"."search_history" TO "anon";
GRANT ALL ON TABLE "public"."search_history" TO "authenticated";
GRANT ALL ON TABLE "public"."search_history" TO "service_role";



GRANT ALL ON TABLE "public"."submissions" TO "anon";
GRANT ALL ON TABLE "public"."submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."submissions" TO "service_role";



GRANT ALL ON TABLE "public"."targets" TO "anon";
GRANT ALL ON TABLE "public"."targets" TO "authenticated";
GRANT ALL ON TABLE "public"."targets" TO "service_role";



GRANT ALL ON TABLE "public"."user_scores" TO "anon";
GRANT ALL ON TABLE "public"."user_scores" TO "authenticated";
GRANT ALL ON TABLE "public"."user_scores" TO "service_role";



GRANT ALL ON TABLE "public"."target_score_aggregates" TO "anon";
GRANT ALL ON TABLE "public"."target_score_aggregates" TO "authenticated";
GRANT ALL ON TABLE "public"."target_score_aggregates" TO "service_role";



GRANT ALL ON TABLE "public"."target_submissions" TO "anon";
GRANT ALL ON TABLE "public"."target_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."target_submissions" TO "service_role";



GRANT ALL ON TABLE "public"."target_tags" TO "anon";
GRANT ALL ON TABLE "public"."target_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."target_tags" TO "service_role";



GRANT ALL ON TABLE "public"."user_preferences" TO "anon";
GRANT ALL ON TABLE "public"."user_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."user_preferences" TO "service_role";



GRANT ALL ON TABLE "public"."user_score_history" TO "anon";
GRANT ALL ON TABLE "public"."user_score_history" TO "authenticated";
GRANT ALL ON TABLE "public"."user_score_history" TO "service_role";



GRANT ALL ON TABLE "public"."user_sessions" TO "anon";
GRANT ALL ON TABLE "public"."user_sessions" TO "authenticated";
GRANT ALL ON TABLE "public"."user_sessions" TO "service_role";



GRANT ALL ON TABLE "public"."vote_rationales" TO "anon";
GRANT ALL ON TABLE "public"."vote_rationales" TO "authenticated";
GRANT ALL ON TABLE "public"."vote_rationales" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































