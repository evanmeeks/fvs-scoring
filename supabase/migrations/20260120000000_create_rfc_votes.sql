-- Create table for RFC votes/feedback
CREATE TABLE IF NOT EXISTS public.rfc_votes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    rfc_id UUID REFERENCES public.rfc_proposals(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    confidence_level TEXT CHECK (confidence_level IN ('low', 'medium', 'high')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(rfc_id, user_id)
);
-- RLS Policies
ALTER TABLE public.rfc_votes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view all RFC votes"
    ON public.rfc_votes FOR SELECT
    USING (true);
CREATE POLICY "Users can insert/update their own votes"
    ON public.rfc_votes FOR ALL
    USING (auth.uid() = user_id);
-- RPC for upserting votes
CREATE OR REPLACE FUNCTION public.upsert_rfc_vote(
    p_rfc_id UUID,
    p_confidence_level TEXT DEFAULT NULL,
    p_notes TEXT DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
    v_vote_id UUID;
BEGIN
    INSERT INTO public.rfc_votes (rfc_id, user_id, confidence_level, notes, updated_at)
    VALUES (p_rfc_id, auth.uid(), p_confidence_level, p_notes, NOW())
    ON CONFLICT (rfc_id, user_id)
    DO UPDATE SET
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
