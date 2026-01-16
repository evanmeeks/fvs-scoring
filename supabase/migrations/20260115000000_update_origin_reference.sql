-- =====================================================================
-- Authoritative origin reference + case ID alignment
-- Migration: 20260115000000_update_origin_reference.sql
-- =====================================================================

-- 1) Create origin_types reference table
CREATE TABLE IF NOT EXISTS public.origin_types (
    slug TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    abbreviation TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order SMALLINT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE (abbreviation)
);
COMMENT ON TABLE public.origin_types IS 'Authoritative list of origin categories for forecast targets';
COMMENT ON COLUMN public.origin_types.slug IS 'Stable machine key (e.g., ic_national)';
COMMENT ON COLUMN public.origin_types.abbreviation IS 'Short code used in case IDs';
ALTER TABLE public.origin_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view origin types"
    ON public.origin_types
    FOR SELECT
    USING (true);
CREATE TRIGGER set_origin_types_updated_at
    BEFORE UPDATE ON public.origin_types
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
-- 2) Seed authoritative origin list
INSERT INTO public.origin_types (slug, label, abbreviation, description, sort_order)
VALUES
    ('ic_national', 'US Intelligence Community', 'IC', 'ODNI, CIA, NSA, NGA, NRO, DIA products or briefings.', 10),
    ('dod_joint', 'DoD Joint/OSD', 'DOD', 'Joint Staff, OSD, combatant commands, or cross-service task forces.', 20),
    ('dod_usaf_ussf', 'USAF/USSF', 'USAF', 'Air and Space Force programs, labs, or operational channels.', 21),
    ('dod_usn', 'US Navy', 'USN', 'Navy platforms, ONR, NAVAIR, NAVSEA, or fleet channels.', 22),
    ('dod_usa', 'US Army', 'USA', 'Army commands, labs, or service-owned programs.', 23),
    ('nasa_civil_space', 'NASA', 'NASA', 'Civil space agency missions, payloads, or directorates.', 30),
    ('federal_civil_agency', 'Federal Civil Agency', 'CIV', 'Non-defense agencies (NOAA, FAA, DOE, DHS, etc.).', 35),
    ('legislative_branch', 'Congressional', 'CONG', 'Committees, hearings, SCIF briefings, GAO/CRS reporting.', 40),
    ('law_enforcement', 'Law Enforcement', 'LE', 'FBI, NCIS, OSI, DHS/HSI, or other investigative arms.', 45),
    ('academic_institution', 'Academic', 'ACAD', 'Universities, research institutes, or symposium hosts.', 50),
    ('private_sector_corporate', 'Private Sector / Contractor', 'PRIV', 'Companies, defense primes, aerospace, data vendors.', 60),
    ('media_organization', 'Media Organization', 'MEDIA', 'Newsrooms or broadcasters acting as originators.', 70),
    ('ngo_thinktank', 'NGO / Think Tank', 'NGO', 'Nonprofits, policy shops, or advocacy organizations.', 80),
    ('international_gov', 'International Gov/Defense', 'INTL', 'Non-US government or defense entities.', 90),
    ('whistleblower_or_leak', 'Whistleblower / Leak', 'LEAK', 'Unauthorized disclosures from insiders or anonymous sources.', 95),
    ('independent_researcher', 'Independent Researcher', 'IND', 'Unaffiliated individuals releasing primary material.', 96),
    ('unspecified', 'Unspecified / Other', 'UNK', 'Unspecified or legacy origin entries.', 99)
ON CONFLICT (slug) DO UPDATE
SET
    label = EXCLUDED.label,
    abbreviation = EXCLUDED.abbreviation,
    description = EXCLUDED.description,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order;
-- 3) Update case ID generator to rely on origin_types (with legacy fallback)
CREATE OR REPLACE FUNCTION public.generate_case_id(origin_param text, context_param text)
RETURNS text
LANGUAGE plpgsql
AS $function$
DECLARE
    origin_abbr TEXT;
    protocol_number TEXT;
    ref_number TEXT;
BEGIN
    -- Get protocol version
    SELECT config_value INTO protocol_number
    FROM protocol_config
    WHERE config_key = 'protocol_version';

    IF protocol_number IS NULL THEN
        protocol_number := '001';
    END IF;

    -- Prefer authoritative reference
    SELECT abbreviation INTO origin_abbr
    FROM public.origin_types
    WHERE is_active = true
      AND (slug = origin_param OR label = origin_param)
    LIMIT 1;

    -- Legacy string fallback
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

    ref_number := LPAD(nextval('case_id_ref_seq')::TEXT, 4, '0');

    RETURN 'FVS-' || protocol_number || '-' || origin_abbr || '-' || ref_number;
END;
$function$;
-- 4) Normalize legacy origin values to new slugs
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT unnest(ARRAY['targets', 'approved_targets', 'target_submissions']) AS tbl
    LOOP
        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'ic_national', 'IC/NGA';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'dod_joint', 'DoD/DIA';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'dod_usn', 'USN';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'dod_usaf_ussf', 'USAF';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'nasa_civil_space', 'NASA';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'legislative_branch', 'Congressional';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'private_sector_corporate', 'Private Sector';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'academic_institution', 'Academic';

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin = $2',
            rec.tbl
        ) USING 'unspecified', 'Other';

        EXECUTE format(
            'UPDATE public.%I t SET origin = ot.slug FROM public.origin_types ot WHERE t.origin = ot.label',
            rec.tbl
        );

        EXECUTE format(
            'UPDATE public.%I SET origin = $1 WHERE origin IS NULL OR origin NOT IN (SELECT slug FROM public.origin_types)',
            rec.tbl
        ) USING 'unspecified';
    END LOOP;
END $$;
-- 5) Enforce FK relationships to reference data
ALTER TABLE public.targets
    ADD CONSTRAINT fk_targets_origin_types
    FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
ALTER TABLE public.approved_targets
    ADD CONSTRAINT fk_approved_targets_origin_types
    FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
ALTER TABLE public.target_submissions
    ADD CONSTRAINT fk_target_submissions_origin_types
    FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
