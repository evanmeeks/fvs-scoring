-- =====================================================================
-- Update case_id format to FVS-ORIGIN-CONTEXT-AUTODIGITS
-- Migration: 20260119000000_update_case_id_format.sql
--
-- Changes:
-- - Old format: FVS-001-DOD-0007
-- - New format: FVS-DOD-CONGRESSIONAL_HEARING-0001
--
-- This migration updates the generate_case_id function to use:
-- FVS-[ORIGIN_ABBR]-[CONTEXT_SLUG_UPPER]-[AUTO_DIGITS]
-- =====================================================================

-- Drop existing trigger to prevent it from firing during updates
DROP TRIGGER IF EXISTS trigger_auto_generate_case_id ON target_submissions;
-- Update the generate_case_id function to use new format
CREATE OR REPLACE FUNCTION public.generate_case_id(
    origin_param TEXT,
    context_param TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $function$
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

    -- Construct case ID: FVS-ORIGIN-CONTEXT-REF
    case_id := 'FVS-' || origin_abbr || '-' || context_slug_upper || '-' || ref_number;

    RETURN case_id;
END;
$function$;
-- Recreate the trigger
CREATE TRIGGER trigger_auto_generate_case_id
    BEFORE INSERT ON target_submissions
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_case_id();
-- Update function comment to reflect new format
COMMENT ON FUNCTION public.generate_case_id IS 'Generates case ID in format FVS-ORIGIN-CONTEXT-REF (e.g., FVS-DOD-CONGRESSIONAL_HEARING-0001)';
-- Note: Existing case_id values in approved_targets are preserved for historical accuracy
-- New submissions will use the updated format;
