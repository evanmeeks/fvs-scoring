-- Backfill missing submissions for seed targets
DO $$
DECLARE
    admin_user_id UUID;
    grusch_id UUID := gen_random_uuid();
    wilson_id UUID := gen_random_uuid();
    nimitz_id UUID := gen_random_uuid();
BEGIN
    -- Get an admin user ID for the 'submitted_by' and 'reviewed_by' fields
    SELECT user_id INTO admin_user_id FROM user_profiles WHERE role = 'admin' LIMIT 1;
    
    -- If no admin exists, we can't easily attribute, but we'll try to proceed or default to a system placeholder if necessary.
    -- For this script, we assume the previous steps verified an admin exists (evanmeeks).

    -- 1. Grusch
    INSERT INTO public.target_submissions (
        id, target_name, case_id, origin, context, description, status, 
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        grusch_id, 'Grusch_T_2024', 'NCI-8.3-XREF-FVS', 'IC/NGA', 'Congressional', 
        'David Grusch UAP disclosure testimony before Congress', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Initial Seed Data',
        '2023-07-26', 'Congressional Record'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('grusch-2024', grusch_id, 'Grusch_T_2024', 'NCI-8.3-XREF-FVS', 'IC/NGA', 'Congressional', 'David Grusch UAP disclosure testimony before Congress', '2023-07-26', 'Congressional Record', true)
    ON CONFLICT (id) DO UPDATE SET submission_id = grusch_id;

    -- 2. Wilson Memo
    INSERT INTO public.target_submissions (
        id, target_name, case_id, origin, context, description, status, 
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        wilson_id, 'Wilson_Memo_2002', 'NCI-7.1-XREF-FVS', 'DoD/DIA', 'Internal', 
        'Eric Davis notes from Admiral Wilson meeting', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Initial Seed Data',
        '2002-10-16', 'Eric Davis Notes'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('wilson-memo', wilson_id, 'Wilson_Memo_2002', 'NCI-7.1-XREF-FVS', 'DoD/DIA', 'Internal', 'Eric Davis notes from Admiral Wilson meeting', '2002-10-16', 'Eric Davis Notes', true)
    ON CONFLICT (id) DO UPDATE SET submission_id = wilson_id;

    -- 3. Nimitz
    INSERT INTO public.target_submissions (
        id, target_name, case_id, origin, context, description, status, 
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        nimitz_id, 'Nimitz_Encounter_2004', 'NCI-9.2-XREF-FVS', 'USN', 'Operational', 
        'USS Nimitz carrier strike group UAP encounter', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Initial Seed Data',
        '2004-11-14', 'US Navy'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('nimitz-2004', nimitz_id, 'Nimitz_Encounter_2004', 'NCI-9.2-XREF-FVS', 'USN', 'Operational', 'USS Nimitz carrier strike group UAP encounter', '2004-11-14', 'US Navy', true)
    ON CONFLICT (id) DO UPDATE SET submission_id = nimitz_id;

END $$;
