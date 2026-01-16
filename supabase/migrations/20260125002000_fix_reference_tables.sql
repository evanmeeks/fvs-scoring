-- Fix missing reference tables, permissions, and normalize data
-- This ensures origin_types and context_types exist, have correct permissions, and data is clean before constraints
-- Migration: 20260125002000_fix_reference_tables.sql

-- 1. Ensure tables exist
CREATE TABLE IF NOT EXISTS public.origin_types (
    slug TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    abbreviation TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.context_types (
    slug TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Grant permissions (Crucial since they were revoked by remote_schema)
GRANT SELECT ON public.origin_types TO anon, authenticated, service_role;
GRANT SELECT ON public.context_types TO anon, authenticated, service_role;

-- 3. Enable RLS
ALTER TABLE public.origin_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.context_types ENABLE ROW LEVEL SECURITY;

-- 4. Create Policies if not exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'origin_types' AND policyname = 'Anyone can view origin types'
    ) THEN
        CREATE POLICY "Anyone can view origin types" ON public.origin_types FOR SELECT USING (true);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies WHERE tablename = 'context_types' AND policyname = 'Anyone can view context types'
    ) THEN
        CREATE POLICY "Anyone can view context types" ON public.context_types FOR SELECT USING (true);
    END IF;
END
$$;

-- 5. Insert Data (Upsert)
INSERT INTO public.origin_types (slug, label, abbreviation, description, sort_order) VALUES
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
ON CONFLICT (slug) DO UPDATE SET
    label = EXCLUDED.label,
    abbreviation = EXCLUDED.abbreviation,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order;

INSERT INTO public.context_types (slug, label, description, sort_order, is_active) VALUES
    ('academic_symposium', 'Academic Symposium', 'Curated research or academic convenings.', 10, true),
    ('scientific_paper', 'Scientific Paper', 'Peer-reviewed or preprint technical publication.', 20, true),
    ('media_broadcast', 'Media Broadcast', 'Televised/radio/stream broadcast or feature interview.', 30, true),
    ('public_statement', 'Public Statement', 'On-record prepared remarks or declaration.', 40, true),
    ('documentary_film', 'Documentary Film', 'Documentary-format film release.', 50, true),
    ('nonfiction_film', 'Nonfiction Film', 'Nonfiction film outside traditional documentary form.', 60, true),
    ('fiction_film', 'Fiction Film', 'Scripted/fictionalized film with disclosure content.', 70, true),
    ('podcast_episode', 'Podcast Episode', 'Audio/video podcast episode.', 80, true),
    ('press_conference', 'Press Conference', 'Live or recorded press conference/gaggle.', 90, true),
    ('book_publication', 'Book Publication', 'Published book or e-book release.', 100, true),
    ('government_report', 'Government Report', 'Official governmental/agency report.', 110, true),
    ('classified_proceeding', 'Classified Proceeding', 'SCIF, closed-door, or compartmentalized session.', 120, true),
    ('declassified_document', 'Declassified Document', 'Formerly classified material now released.', 130, true),
    ('congressional_hearing', 'Congressional Hearing', 'Formal congressional hearing or briefing.', 140, true),
    ('press_release', 'Press Release', 'Formal press release distribution.', 150, true),
    ('international_agreement', 'International Agreement', 'Treaty/MoU or joint declaration.', 160, true),
    ('international_statement', 'International Statement', 'Official international/foreign government statement.', 170, true),
    ('legal_filing', 'Legal Filing', 'Court filing, motion, or pleading.', 180, true),
    ('witness_testimony', 'Witness Testimony', 'Sworn testimony or deposition equivalent.', 190, true),
    ('whistleblower_account', 'Whistleblower Account', 'On-record or protected disclosure by an insider.', 200, true),
    ('legal_deposition', 'Legal Deposition', 'Recorded deposition or affidavit.', 210, true),
    ('visual_evidence', 'Visual Evidence', 'Photo/video/audio artifact offered as evidence.', 220, true),
    ('forensic_claim', 'Forensic Claim', 'Forensic examination or evidentiary claim.', 230, true),
    ('material_sample', 'Material Sample', 'Physical sample release or chain-of-custody claim.', 240, true),
    ('archaeological_find', 'Archaeological Find', 'Archaeological or historical material discovery.', 250, true),
    ('viral_narrative', 'Viral Narrative', 'Rapidly spreading narrative or rumor chain.', 260, true),
    ('social_media', 'Social Media', 'Platform-first social post/space/thread.', 270, true),
    ('fourchan_leak', '4chan Leak', 'Leak originating on 4chan.', 280, true),
    ('forum_leak', 'Forum Leak', 'Leak originating on forums outside 4chan.', 290, true),
    ('anon_hack_and_release', 'Anon Hack and Release', 'Anonymous hack-and-dump release.', 300, true),
    ('patent_application', 'Patent Application', 'Patent or provisional application.', 310, true),
    -- Compatibility / legacy holders
    ('internal', 'Internal', 'Internal-only circulation.', 400, false),
    ('operational', 'Operational', 'Operational context.', 410, false),
    ('media_interview', 'Media Interview', 'Interview-format media appearance.', 420, false),
    ('document_release', 'Document Release', 'General document release.', 430, false),
    ('unspecified', 'Unspecified / Other', 'Unspecified or legacy context.', 999, false)
ON CONFLICT (slug) DO UPDATE SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order;

-- 6. Clean up and normalize legacy string data to slugs BEFORE adding constraints
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT unnest(ARRAY['targets', 'approved_targets', 'target_submissions']) AS tbl
    LOOP
        -- Origin normalization
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'ic_national', 'IC/NGA';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'dod_joint', 'DoD/DIA';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'dod_usn', 'USN';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'dod_usaf_ussf', 'USAF';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'nasa_civil_space', 'NASA';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'legislative_branch', 'Congressional';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'private_sector_corporate', 'Private Sector';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2', rec.tbl) USING 'academic_institution', 'Academic';
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin = $2 OR origin = $3', rec.tbl) USING 'unspecified', 'Other', 'unknown';
        
        -- Also catch cases where origin matches a label but should be a slug (e.g. 'US Navy' -> 'dod_usn')
        EXECUTE format('UPDATE public.%I t SET origin = ot.slug FROM public.origin_types ot WHERE t.origin = ot.label', rec.tbl);

        -- Fallback for any remaining invalid origins
        EXECUTE format('UPDATE public.%I SET origin = $1 WHERE origin IS NULL OR origin NOT IN (SELECT slug FROM public.origin_types)', rec.tbl) USING 'unspecified';

        -- Context normalization
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'congressional_hearing', 'Congressional';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'internal', 'Internal';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'operational', 'Operational';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'public_statement', 'Public Statement';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'media_interview', 'Media Interview';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2', rec.tbl) USING 'document_release', 'Document Release';
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context = $2 OR context = $3', rec.tbl) USING 'unspecified', 'Other', 'unknown';

        -- Also catch cases where context might match a label
        EXECUTE format('UPDATE public.%I t SET context = ct.slug FROM public.context_types ct WHERE t.context = ct.label', rec.tbl);
        
        -- Lowercase existing slugs if they were somehow uppercased
        EXECUTE format('UPDATE public.%I SET context = lower(context) WHERE context IS NOT NULL', rec.tbl);

        -- Fallback for any remaining invalid contexts
        EXECUTE format('UPDATE public.%I SET context = $1 WHERE context IS NULL OR context NOT IN (SELECT slug FROM public.context_types)', rec.tbl) USING 'unspecified';
    END LOOP;
END $$;


-- 7. Add Foreign Keys explicitly with IF NOT EXISTS checks (via DO block)
DO $$
BEGIN
    -- Targets
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_targets_origin_types') THEN
        ALTER TABLE public.targets ADD CONSTRAINT fk_targets_origin_types FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_targets_context_types') THEN
        ALTER TABLE public.targets ADD CONSTRAINT fk_targets_context_types FOREIGN KEY (context) REFERENCES public.context_types(slug);
    END IF;

    -- Approved Targets
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_approved_targets_origin_types') THEN
        ALTER TABLE public.approved_targets ADD CONSTRAINT fk_approved_targets_origin_types FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_approved_targets_context_types') THEN
        ALTER TABLE public.approved_targets ADD CONSTRAINT fk_approved_targets_context_types FOREIGN KEY (context) REFERENCES public.context_types(slug);
    END IF;

    -- Target Submissions
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_target_submissions_origin_types') THEN
        ALTER TABLE public.target_submissions ADD CONSTRAINT fk_target_submissions_origin_types FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'fk_target_submissions_context_types') THEN
        ALTER TABLE public.target_submissions ADD CONSTRAINT fk_target_submissions_context_types FOREIGN KEY (context) REFERENCES public.context_types(slug);
    END IF;
END $$;
