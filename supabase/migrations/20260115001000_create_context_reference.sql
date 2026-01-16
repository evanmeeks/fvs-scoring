-- =====================================================================
-- Authoritative context reference + normalization to lowercase slugs
-- Migration: 20260115001000_create_context_reference.sql
-- =====================================================================

-- 1) Create context_types reference table
CREATE TABLE IF NOT EXISTS public.context_types (
    slug TEXT PRIMARY KEY,
    label TEXT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true NOT NULL,
    sort_order SMALLINT DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
COMMENT ON TABLE public.context_types IS 'Authoritative list of disclosure contexts';
COMMENT ON COLUMN public.context_types.slug IS 'Lowercase machine key (e.g., academic_symposium)';
ALTER TABLE public.context_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view context types"
    ON public.context_types
    FOR SELECT
    USING (true);
CREATE TRIGGER set_context_types_updated_at
    BEFORE UPDATE ON public.context_types
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
-- 2) Seed comprehensive context catalog
INSERT INTO public.context_types (slug, label, description, sort_order, is_active)
VALUES
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
ON CONFLICT (slug) DO UPDATE
SET
    label = EXCLUDED.label,
    description = EXCLUDED.description,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;
-- 3) Normalize existing context values to lowercase slugs
DO $$
DECLARE
    rec RECORD;
BEGIN
    FOR rec IN
        SELECT unnest(ARRAY['targets', 'approved_targets', 'target_submissions']) AS tbl
    LOOP
        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'congressional_hearing', 'Congressional';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'internal', 'Internal';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'operational', 'Operational';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'public_statement', 'Public Statement';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'media_interview', 'Media Interview';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'document_release', 'Document Release';

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context = $2',
            rec.tbl
        ) USING 'unspecified', 'Other';

        EXECUTE format(
            'UPDATE public.%I SET context = lower(context) WHERE context IS NOT NULL',
            rec.tbl
        );

        EXECUTE format(
            'UPDATE public.%I SET context = $1 WHERE context IS NULL OR context NOT IN (SELECT slug FROM public.context_types)',
            rec.tbl
        ) USING 'unspecified';
    END LOOP;
END $$;
-- 4) Enforce FK relationships to context_types
ALTER TABLE public.targets
    ADD CONSTRAINT fk_targets_context_types
    FOREIGN KEY (context) REFERENCES public.context_types(slug);
ALTER TABLE public.approved_targets
    ADD CONSTRAINT fk_approved_targets_context_types
    FOREIGN KEY (context) REFERENCES public.context_types(slug);
ALTER TABLE public.target_submissions
    ADD CONSTRAINT fk_target_submissions_context_types
    FOREIGN KEY (context) REFERENCES public.context_types(slug);
