-- =====================================================================
-- Update approve_target_submission to sync approved targets with targets
-- Migration: 20260111002000_update_approve_target_submission.sql
-- =====================================================================

DO $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'approved_targets'
    ) THEN
        INSERT INTO public.targets (
            id,
            name,
            case_id,
            origin,
            context,
            verified,
            description,
            source_url,
            claim_date,
            primary_source
        )
        SELECT
            id,
            name,
            case_id,
            origin,
            context,
            verified,
            description,
            source_url,
            claim_date,
            primary_source
        FROM public.approved_targets
        ON CONFLICT (id) DO UPDATE
        SET
            name = EXCLUDED.name,
            case_id = EXCLUDED.case_id,
            origin = EXCLUDED.origin,
            context = EXCLUDED.context,
            verified = EXCLUDED.verified,
            description = EXCLUDED.description,
            source_url = EXCLUDED.source_url,
            claim_date = EXCLUDED.claim_date,
            primary_source = EXCLUDED.primary_source,
            updated_at = NOW();
    END IF;
END;
$$;
CREATE OR REPLACE FUNCTION public.approve_target_submission(
    submission_id_param UUID,
    target_id_param TEXT
)
RETURNS void AS $$
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
        claim_date,
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
        submission_record.claim_date,
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
        claim_date = EXCLUDED.claim_date,
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
            claim_date,
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
            submission_record.claim_date,
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
            claim_date = EXCLUDED.claim_date,
            primary_source = EXCLUDED.primary_source,
            verified = EXCLUDED.verified,
            submission_id = EXCLUDED.submission_id;
    END IF;

    UPDATE public.target_submissions
    SET status = 'approved', reviewed_by = auth.uid(), reviewed_at = NOW()
    WHERE id = submission_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
