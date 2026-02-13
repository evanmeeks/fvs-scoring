-- Recreate origin_types and context_types tables with is_active column
-- These tables were dropped by 20260120170217_remote_schema.sql
-- This migration recreates them with the is_active column included from the start

-- Recreate origin_types table with is_active
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

-- Recreate context_types table with is_active
CREATE TABLE IF NOT EXISTS public.context_types (
    slug TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Restore the complete data from the 20260115000000_update_origin_reference.sql migration
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
    sort_order = EXCLUDED.sort_order,
    updated_at = NOW();

-- Restore the complete data from the 20260115001000_create_context_reference.sql migration
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
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active,
    updated_at = NOW();

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_origin_types_is_active ON public.origin_types(is_active);
CREATE INDEX IF NOT EXISTS idx_context_types_is_active ON public.context_types(is_active);
CREATE INDEX IF NOT EXISTS idx_origin_types_sort_order ON public.origin_types(sort_order);
CREATE INDEX IF NOT EXISTS idx_context_types_sort_order ON public.context_types(sort_order);

-- Enable RLS
ALTER TABLE public.origin_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.context_types ENABLE ROW LEVEL SECURITY;

-- RLS Policies - anyone can view
CREATE POLICY "Anyone can view origin types"
    ON public.origin_types FOR SELECT
    USING (true);

CREATE POLICY "Anyone can view context types"
    ON public.context_types FOR SELECT
    USING (true);

-- Add foreign key constraints back
-- Foreign key constraints are skipped here to avoid data inconsistencies.
-- They will be re-applied in 20260125002000_fix_reference_tables.sql after data normalization.

-- ALTER TABLE public.targets
-- ADD CONSTRAINT fk_targets_origin_types
--     FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
-- 
-- ALTER TABLE public.targets
-- ADD CONSTRAINT fk_targets_context_types
--     FOREIGN KEY (context) REFERENCES public.context_types(slug);
-- 
-- ALTER TABLE public.approved_targets
-- ADD CONSTRAINT fk_approved_targets_origin_types
--     FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
-- 
-- ALTER TABLE public.approved_targets
-- ADD CONSTRAINT fk_approved_targets_context_types
--     FOREIGN KEY (context) REFERENCES public.context_types(slug);
-- 
-- ALTER TABLE public.target_submissions
-- ADD CONSTRAINT fk_target_submissions_origin_types
--     FOREIGN KEY (origin) REFERENCES public.origin_types(slug);
-- 
-- ALTER TABLE public.target_submissions
-- ADD CONSTRAINT fk_target_submissions_context_types
--     FOREIGN KEY (context) REFERENCES public.context_types(slug);

-- Comments
COMMENT ON TABLE public.origin_types IS 'Reference table for disclosure origin types';
COMMENT ON TABLE public.context_types IS 'Reference table for disclosure context types';
COMMENT ON COLUMN public.origin_types.is_active IS 'Whether this origin type is currently active and available for selection';
COMMENT ON COLUMN public.context_types.is_active IS 'Whether this context type is currently active and available for selection';
