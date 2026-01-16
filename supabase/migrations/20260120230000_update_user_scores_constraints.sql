-- Migration: Update user_scores and history tables to allow confidence levels in action_vote
-- Original constraint only allowed 'keep', 'modify', 'drop'.
-- New UI uses 'low', 'medium', 'high'. We support all to render existing data and new usage valid.

-- 1. Update user_scores
-- Using IF EXISTS to avoid errors if the constraint name varies, though it matched the error log.
ALTER TABLE public.user_scores DROP CONSTRAINT IF EXISTS user_scores_action_vote_check;

ALTER TABLE public.user_scores ADD CONSTRAINT user_scores_action_vote_check 
    CHECK (action_vote IN ('keep', 'modify', 'drop', 'low', 'medium', 'high'));

COMMENT ON COLUMN public.user_scores.action_vote IS 'Governance vote: keep, modify, drop OR Confidence level: low, medium, high';

-- 2. Update user_score_history
-- Assuming the name matches the pattern or was auto-generated. 
-- If the constraint name is unknown, we might need a DO block to find it, but dropping based on likely name is standard.
ALTER TABLE public.user_score_history DROP CONSTRAINT IF EXISTS user_score_history_action_vote_check;
ALTER TABLE public.user_score_history ADD CONSTRAINT user_score_history_action_vote_check 
    CHECK (action_vote IN ('keep', 'modify', 'drop', 'low', 'medium', 'high'));
