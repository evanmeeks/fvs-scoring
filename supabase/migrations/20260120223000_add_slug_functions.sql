-- =====================================================================
-- Add slug generation and parsing functions
-- Migration: 20260120220000_add_slug_functions.sql
--
-- Purpose: Centralize slug logic in the database to ensure consistency
-- Format: [Case ID]-[Target_Name]
-- Example: FVS-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar
-- =====================================================================

-- Function to generate a URL-safe slug from a target's case_id and name
CREATE OR REPLACE FUNCTION public.generate_target_slug(
    p_case_id TEXT,
    p_target_name TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
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
    slug := COALESCE(p_case_id, 'FVS-000') || '-' || cleaned_name;

    RETURN slug;
END;
$$;

-- Function to extract case_id from a slug
-- Handles the new format: FVS-ORIGIN-CONTEXT-REF-Target_Name
-- The case_id is everything before the final hyphen followed by a capital letter
CREATE OR REPLACE FUNCTION public.parse_case_id_from_slug(
    p_slug TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    case_id TEXT;
BEGIN
    -- Match pattern: FVS-...-NNNN (where NNNN is 4 digits at the end of case_id)
    -- Everything before the last segment that starts with a capital letter is the case_id
    -- Example: FVS-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar
    --          case_id = FVS-DOD-ACADEMIC_SYMPOSIUM-0002

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

-- Add computed column to targets table for easy slug access
-- This will automatically generate slugs for all targets
ALTER TABLE public.targets
ADD COLUMN IF NOT EXISTS slug TEXT
GENERATED ALWAYS AS (public.generate_target_slug(case_id, name)) STORED;

-- Add computed column to approved_targets for legacy support
ALTER TABLE public.approved_targets
ADD COLUMN IF NOT EXISTS slug TEXT
GENERATED ALWAYS AS (public.generate_target_slug(case_id, name)) STORED;

-- Create index on slug for fast lookups
CREATE INDEX IF NOT EXISTS idx_targets_slug ON public.targets(slug);
CREATE INDEX IF NOT EXISTS idx_approved_targets_slug ON public.approved_targets(slug);

-- Comment the functions
COMMENT ON FUNCTION public.generate_target_slug IS 'Generates URL-safe slug from case_id and target name. Format: CASE_ID-Target_Name';
COMMENT ON FUNCTION public.parse_case_id_from_slug IS 'Extracts case_id from a slug string. Handles format: FVS-ORIGIN-CONTEXT-REF-Target_Name';
