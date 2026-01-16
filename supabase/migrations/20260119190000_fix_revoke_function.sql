-- =====================================================================
-- Fix revoke_target_submission to be robust against missing approved_targets
-- Migration: 20260119000000_fix_revoke_function.sql
-- =====================================================================

-- Drop the existing function first to allow changing the return type
DROP FUNCTION IF EXISTS public.revoke_target_submission(UUID, TEXT);
CREATE OR REPLACE FUNCTION public.revoke_target_submission(
    submission_id_param UUID,
    review_notes_param TEXT DEFAULT ''
)
RETURNS void AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
