CREATE OR REPLACE FUNCTION public.revoke_target_submission(
    submission_id_param UUID,
    review_notes_param TEXT DEFAULT ''
)
RETURNS void AS $$
DECLARE
    target_id_to_remove TEXT;
BEGIN
    -- 1. Get the target ID from approved_targets directly
    -- We assume the table exists. If it doesn't, we want this to fail loudly.
    SELECT id INTO target_id_to_remove
    FROM public.approved_targets
    WHERE submission_id = submission_id_param;

    -- 2. If we found a target ID, delete it
    IF target_id_to_remove IS NOT NULL THEN
        -- Delete from approved_targets first
        DELETE FROM public.approved_targets WHERE id = target_id_to_remove;
        
        -- Delete from targets
        -- Note: This will fail if there are dependencies without ON DELETE CASCADE
        DELETE FROM public.targets WHERE id = target_id_to_remove;
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
