-- Seed public targets from prototype UI (ScoreCardVewPublicGlobalAudtCards.html)
-- Adds unaudited targets with auto-generated case IDs
-- All entries will have 0 scores initially (no user_scores entries)
-- Uses slug values for origin and context that match the reference tables

DO $$
DECLARE
    admin_user_id UUID;
    sol_foundation_id UUID := gen_random_uuid();
    grusch_newsnation_id UUID := gen_random_uuid();
    congress_scif_id UUID := gen_random_uuid();
    jellyfish_id UUID := gen_random_uuid();
    nazca_id UUID := gen_random_uuid();
    miami_id UUID := gen_random_uuid();
    aaro_id UUID := gen_random_uuid();
    ilyumzhinov_id UUID := gen_random_uuid();
    sheehan_id UUID := gen_random_uuid();
BEGIN
    -- Get admin user ID for submission attribution
    SELECT user_id INTO admin_user_id FROM user_profiles WHERE role = 'admin' LIMIT 1;

    -- Sol Foundation Symposium 2023 (AUDITED in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        sol_foundation_id, 'Sol Foundation Symposium 2023', 'academic_institution', 'academic_symposium',
        'Academic symposium on UAP disclosure hosted by Sol Foundation', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2023-11-01', 'Sol Foundation'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('sol-foundation-2023', sol_foundation_id, 'Sol Foundation Symposium 2023', NULL, 'academic_institution', 'academic_symposium', 'Academic symposium on UAP disclosure hosted by Sol Foundation', '2023-11-01', 'Sol Foundation', true)
    ON CONFLICT (id) DO NOTHING;

    -- David Grusch NewsNation Interview (AUDITED in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        grusch_newsnation_id, 'David Grusch - NewsNation Interview', 'private_sector_corporate', 'media_broadcast',
        'NewsNation interview with David Grusch discussing UAP disclosure', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2023-06-11', 'NewsNation'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('grusch-newsnation-2023', grusch_newsnation_id, 'David Grusch - NewsNation Interview', NULL, 'private_sector_corporate', 'media_broadcast', 'NewsNation interview with David Grusch discussing UAP disclosure', '2023-06-11', 'NewsNation', true)
    ON CONFLICT (id) DO NOTHING;

    -- Congressional SCIF Briefing (AUDITED in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        congress_scif_id, 'Congressional SCIF Briefing (Jan)', 'legislative_branch', 'classified_proceeding',
        'Classified briefing to Congressional members regarding UAP', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2024-01-15', 'US Congress'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('congressional-scif-jan-2024', congress_scif_id, 'Congressional SCIF Briefing (Jan)', NULL, 'legislative_branch', 'classified_proceeding', 'Classified briefing to Congressional members regarding UAP', '2024-01-15', 'US Congress', true)
    ON CONFLICT (id) DO NOTHING;

    -- Jellyfish UAP Video (AUDITED in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        jellyfish_id, 'Jellyfish UAP Video Release', 'independent_researcher', 'visual_evidence',
        'Release of alleged UAP video footage showing jellyfish-like object', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2024-01-10', 'Jeremy Corbell'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('jellyfish-uap-jan-2024', jellyfish_id, 'Jellyfish UAP Video Release', NULL, 'independent_researcher', 'visual_evidence', 'Release of alleged UAP video footage showing jellyfish-like object', '2024-01-10', 'Jeremy Corbell', false)
    ON CONFLICT (id) DO NOTHING;

    -- Nazca Mummies (MIXED/AMBIGUOUS in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        nazca_id, 'Nazca Mummies (Initial Release)', 'independent_researcher', 'forensic_claim',
        'Initial public presentation of alleged non-human mummies from Peru', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2023-09-13', 'Jaime Maussan'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('nazca-mummies-2023', nazca_id, 'Nazca Mummies (Initial Release)', NULL, 'independent_researcher', 'forensic_claim', 'Initial public presentation of alleged non-human mummies from Peru', '2023-09-13', 'Jaime Maussan', false)
    ON CONFLICT (id) DO NOTHING;

    -- Miami Mall Incident (OCCUPATION in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        miami_id, 'Miami Mall Incident (Social Media)', 'unspecified', 'viral_narrative',
        'Social media viral narrative regarding alleged incident at Miami mall', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2024-01-03', 'Social Media'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('miami-mall-jan-2024', miami_id, 'Miami Mall Incident (Social Media)', NULL, 'unspecified', 'viral_narrative', 'Social media viral narrative regarding alleged incident at Miami mall', '2024-01-03', 'Social Media', false)
    ON CONFLICT (id) DO NOTHING;

    -- AARO Historical Report (OCCUPATION in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        aaro_id, 'AARO Historical Report Vol 1', 'dod_joint', 'government_report',
        'All-domain Anomaly Resolution Office historical report volume 1', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2024-02-29', 'AARO/DoD'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('aaro-report-vol1-2024', aaro_id, 'AARO Historical Report Vol 1', NULL, 'dod_joint', 'government_report', 'All-domain Anomaly Resolution Office historical report volume 1', '2024-02-29', 'AARO/DoD', true)
    ON CONFLICT (id) DO NOTHING;

    -- Kirsan Ilyumzhinov Interview (PENDING AUDIT in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        ilyumzhinov_id, 'Kirsan Ilyumzhinov Interview', 'media_organization', 'witness_testimony',
        'Interview with former FIDE president regarding alleged UAP encounter', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2023-10-15', 'Various Media'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('ilyumzhinov-interview-2023', ilyumzhinov_id, 'Kirsan Ilyumzhinov Interview', NULL, 'media_organization', 'witness_testimony', 'Interview with former FIDE president regarding alleged UAP encounter', '2023-10-15', 'Various Media', false)
    ON CONFLICT (id) DO NOTHING;

    -- Danny Sheehan Disclosure Project (PENDING AUDIT in prototype)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        sheehan_id, 'Danny Sheehan - Disclosure Project', 'ngo_thinktank', 'public_statement',
        'Public statement and disclosure initiative from attorney Danny Sheehan', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Prototype UI Seed Data',
        '2023-12-01', 'New Paradigm Institute'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('sheehan-disclosure-2023', sheehan_id, 'Danny Sheehan - Disclosure Project', NULL, 'ngo_thinktank', 'public_statement', 'Public statement and disclosure initiative from attorney Danny Sheehan', '2023-12-01', 'New Paradigm Institute', false)
    ON CONFLICT (id) DO NOTHING;

END $$;
-- Note: case_id will be auto-generated via trigger using the new format: FVS-ORIGIN-CONTEXT-XXXX
-- Note: No user_scores entries are created - all targets start with 0 scores (unaudited)
-- Examples of generated case_ids:
--   FVS-ACAD-SYMP-0001 (Sol Foundation)
--   FVS-PRIV-BCAST-0002 (Grusch NewsNation)
--   FVS-CONG-SCIF-0003 (Congressional SCIF);
