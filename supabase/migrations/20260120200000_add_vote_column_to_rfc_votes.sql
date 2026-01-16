-- Add vote column to rfc_votes table
-- This column stores approve/reject/abstain votes for RFC proposals

-- Add vote column
ALTER TABLE public.rfc_votes
ADD COLUMN IF NOT EXISTS vote TEXT CHECK (vote IN ('approve', 'reject', 'abstain'));

-- Make vote column required for new rows
-- (Don't enforce NOT NULL yet in case there's existing data)
-- ALTER TABLE public.rfc_votes ALTER COLUMN vote SET NOT NULL;

-- Update any existing rows to have a default vote
UPDATE public.rfc_votes
SET vote = 'approve'
WHERE vote IS NULL;

-- Now make it NOT NULL
ALTER TABLE public.rfc_votes
ALTER COLUMN vote SET NOT NULL;

-- Add index for vote column for faster queries
CREATE INDEX IF NOT EXISTS idx_rfc_votes_vote ON public.rfc_votes(vote);

-- Comment
COMMENT ON COLUMN public.rfc_votes.vote IS 'Vote type: approve, reject, or abstain';

-- Update the upsert function to include vote parameter
CREATE OR REPLACE FUNCTION public.upsert_rfc_vote(
    p_rfc_id UUID,
    p_vote TEXT,
    p_confidence_level TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
    v_vote_id UUID;
BEGIN
    -- Validate vote
    IF p_vote NOT IN ('approve', 'reject', 'abstain') THEN
        RAISE EXCEPTION 'Invalid vote type. Must be approve, reject, or abstain';
    END IF;

    INSERT INTO public.rfc_votes (rfc_id, user_id, vote, confidence_level, notes, updated_at)
    VALUES (p_rfc_id, auth.uid(), p_vote, p_confidence_level, p_notes, NOW())
    ON CONFLICT (rfc_id, user_id)
    DO UPDATE SET
        vote = EXCLUDED.vote,
        confidence_level = COALESCE(EXCLUDED.confidence_level, public.rfc_votes.confidence_level),
        notes = COALESCE(EXCLUDED.notes, public.rfc_votes.notes),
        updated_at = NOW()
    RETURNING id INTO v_vote_id;

    RETURN jsonb_build_object(
        'success', true,
        'vote_id', v_vote_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.upsert_rfc_vote(UUID, TEXT, TEXT, TEXT) TO authenticated;
