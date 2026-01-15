-- ============================================================================
-- Migration: Implement Controls Inventory Requirements
-- Description: Adds all missing database controls identified in CONTROLS_INVENTORY.md
-- Date: 2026-01-10
-- ============================================================================

-- ============================================================================
-- SECTION 1: Enhance Existing Tables
-- ============================================================================

-- Add timestamp tracking to user_scores (for metric slider updates)
ALTER TABLE public.user_scores
ADD COLUMN IF NOT EXISTS last_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
-- Create trigger to auto-update last_updated_at
CREATE OR REPLACE FUNCTION update_user_scores_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trigger_update_user_scores_timestamp ON public.user_scores;
CREATE TRIGGER trigger_update_user_scores_timestamp
    BEFORE UPDATE ON public.user_scores
    FOR EACH ROW
    EXECUTE FUNCTION update_user_scores_timestamp();
-- Add rationale column to community_votes (if not already exists)
ALTER TABLE public.community_votes
ADD COLUMN IF NOT EXISTS vote_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW();
-- Add review notes to target_submissions (for admin review)
ALTER TABLE public.target_submissions
ADD COLUMN IF NOT EXISTS review_notes TEXT;
-- ============================================================================
-- SECTION 2: Create Vote Rationales History Table
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.vote_rationales (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vote_id UUID NOT NULL REFERENCES public.community_votes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    metric_id INTEGER NOT NULL REFERENCES public.metrics(id) ON DELETE CASCADE,
    target_id TEXT NOT NULL REFERENCES public.targets(id) ON DELETE CASCADE,
    rationale TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(vote_id)
);
-- Enable RLS
ALTER TABLE public.vote_rationales ENABLE ROW LEVEL SECURITY;
-- Policies for vote_rationales
CREATE POLICY "Users can create their own vote rationales"
    ON public.vote_rationales FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can view all vote rationales"
    ON public.vote_rationales FOR SELECT
    TO authenticated
    USING (true);
CREATE POLICY "Users can update their own vote rationales"
    ON public.vote_rationales FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
-- Indexes
CREATE INDEX IF NOT EXISTS idx_vote_rationales_vote_id ON public.vote_rationales(vote_id);
CREATE INDEX IF NOT EXISTS idx_vote_rationales_user_id ON public.vote_rationales(user_id);
CREATE INDEX IF NOT EXISTS idx_vote_rationales_metric_id ON public.vote_rationales(metric_id);
-- ============================================================================
-- SECTION 3: Create New Metric Proposals Table (Structured)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.new_metric_proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposed_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

    -- Structured fields instead of JSON
    metric_name TEXT NOT NULL,
    metric_question TEXT NOT NULL,
    min_criteria TEXT NOT NULL,
    max_criteria TEXT NOT NULL,
    rich_entries TEXT,
    rationale TEXT NOT NULL,
    category TEXT CHECK (category IN ('core', 'integrity', 'impact')),

    -- Status workflow
    status TEXT NOT NULL DEFAULT 'draft' CHECK (
        status IN ('draft', 'submitted', 'under_review', 'approved', 'rejected', 'implemented')
    ),

    -- Review tracking
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_notes TEXT,

    -- Voting/support
    support_count INTEGER DEFAULT 0,
    opposition_count INTEGER DEFAULT 0,

    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Implementation tracking
    implemented_metric_id INTEGER REFERENCES public.metrics(id),
    implemented_at TIMESTAMP WITH TIME ZONE
);
-- Enable RLS
ALTER TABLE public.new_metric_proposals ENABLE ROW LEVEL SECURITY;
-- Policies
CREATE POLICY "Anyone can view metric proposals"
    ON public.new_metric_proposals FOR SELECT
    TO authenticated
    USING (true);
CREATE POLICY "Users can create metric proposals"
    ON public.new_metric_proposals FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = proposed_by);
CREATE POLICY "Users can update their own draft proposals"
    ON public.new_metric_proposals FOR UPDATE
    TO authenticated
    USING (auth.uid() = proposed_by AND status = 'draft')
    WITH CHECK (auth.uid() = proposed_by);
CREATE POLICY "Admins can review metric proposals"
    ON public.new_metric_proposals FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );
-- Indexes
CREATE INDEX IF NOT EXISTS idx_new_metric_proposals_status ON public.new_metric_proposals(status);
CREATE INDEX IF NOT EXISTS idx_new_metric_proposals_proposed_by ON public.new_metric_proposals(proposed_by);
CREATE INDEX IF NOT EXISTS idx_new_metric_proposals_created_at ON public.new_metric_proposals(created_at DESC);
-- ============================================================================
-- SECTION 4: Create Saved Searches Table
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.saved_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    search_query TEXT NOT NULL,
    filters JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    use_count INTEGER DEFAULT 0,

    UNIQUE(user_id, name)
);
-- Enable RLS
ALTER TABLE public.saved_searches ENABLE ROW LEVEL SECURITY;
-- Policies
CREATE POLICY "Users can manage their own saved searches"
    ON public.saved_searches FOR ALL
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
-- Indexes
CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id ON public.saved_searches(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_searches_last_used ON public.saved_searches(last_used_at DESC);
-- ============================================================================
-- SECTION 5: Enhance User Preferences with UI State
-- ============================================================================

-- Add UI state columns to user_preferences if they don't exist
ALTER TABLE public.user_preferences
ADD COLUMN IF NOT EXISTS last_viewed_tab TEXT DEFAULT 'standards_review',
ADD COLUMN IF NOT EXISTS sidebar_collapsed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS selected_category_filter TEXT DEFAULT 'all',
ADD COLUMN IF NOT EXISTS search_query TEXT DEFAULT '';
-- ============================================================================
-- SECTION 6: Create Assessment Notes Detail Table
-- ============================================================================

-- Enhanced version with timestamps and versioning
ALTER TABLE public.assessment_notes
ADD COLUMN IF NOT EXISTS version INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS is_current BOOLEAN DEFAULT true;
-- Create index for current notes
CREATE INDEX IF NOT EXISTS idx_assessment_notes_current
    ON public.assessment_notes(target_id, metric_id, user_id, is_current)
    WHERE is_current = true;
-- ============================================================================
-- SECTION 7: Create Metric Proposal Votes Table
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.metric_proposal_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id UUID NOT NULL REFERENCES public.new_metric_proposals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vote_type TEXT NOT NULL CHECK (vote_type IN ('support', 'oppose', 'abstain')),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(proposal_id, user_id)
);
-- Enable RLS
ALTER TABLE public.metric_proposal_votes ENABLE ROW LEVEL SECURITY;
-- Policies
CREATE POLICY "Users can vote on metric proposals"
    ON public.metric_proposal_votes FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Anyone can view metric proposal votes"
    ON public.metric_proposal_votes FOR SELECT
    TO authenticated
    USING (true);
CREATE POLICY "Users can update their own votes"
    ON public.metric_proposal_votes FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
-- Indexes
CREATE INDEX IF NOT EXISTS idx_metric_proposal_votes_proposal ON public.metric_proposal_votes(proposal_id);
CREATE INDEX IF NOT EXISTS idx_metric_proposal_votes_user ON public.metric_proposal_votes(user_id);
-- ============================================================================
-- SECTION 8: Create Helper Functions
-- ============================================================================

-- Function to update proposal vote counts
CREATE OR REPLACE FUNCTION update_proposal_vote_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE public.new_metric_proposals
        SET
            support_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = NEW.proposal_id AND vote_type = 'support'
            ),
            opposition_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = NEW.proposal_id AND vote_type = 'oppose'
            )
        WHERE id = NEW.proposal_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.new_metric_proposals
        SET
            support_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = OLD.proposal_id AND vote_type = 'support'
            ),
            opposition_count = (
                SELECT COUNT(*) FROM public.metric_proposal_votes
                WHERE proposal_id = OLD.proposal_id AND vote_type = 'oppose'
            )
        WHERE id = OLD.proposal_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trigger_update_proposal_votes ON public.metric_proposal_votes;
CREATE TRIGGER trigger_update_proposal_votes
    AFTER INSERT OR UPDATE OR DELETE ON public.metric_proposal_votes
    FOR EACH ROW
    EXECUTE FUNCTION update_proposal_vote_counts();
-- Function to update saved search usage
CREATE OR REPLACE FUNCTION update_saved_search_usage(search_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE public.saved_searches
    SET
        last_used_at = NOW(),
        use_count = use_count + 1
    WHERE id = search_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Function to archive old assessment notes when new one is created
CREATE OR REPLACE FUNCTION archive_old_assessment_notes()
RETURNS TRIGGER AS $$
BEGIN
    -- Mark previous notes as not current
    UPDATE public.assessment_notes
    SET is_current = false
    WHERE target_id = NEW.target_id
        AND metric_id = NEW.metric_id
        AND user_id = NEW.user_id
        AND id != NEW.id
        AND is_current = true;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS trigger_archive_assessment_notes ON public.assessment_notes;
CREATE TRIGGER trigger_archive_assessment_notes
    AFTER INSERT ON public.assessment_notes
    FOR EACH ROW
    EXECUTE FUNCTION archive_old_assessment_notes();
-- ============================================================================
-- SECTION 9: Create Views for Common Queries
-- ============================================================================

-- View for active metric proposals with vote counts
CREATE OR REPLACE VIEW public.active_metric_proposals AS
SELECT
    nmp.*,
    up.full_name as proposer_name,
    COALESCE(nmp.support_count, 0) as total_support,
    COALESCE(nmp.opposition_count, 0) as total_opposition,
    (COALESCE(nmp.support_count, 0) - COALESCE(nmp.opposition_count, 0)) as net_support
FROM public.new_metric_proposals nmp
LEFT JOIN public.user_profiles up ON nmp.proposed_by = up.user_id
WHERE nmp.status IN ('submitted', 'under_review')
ORDER BY nmp.created_at DESC;
-- View for current assessment notes only
CREATE OR REPLACE VIEW public.current_assessment_notes AS
SELECT *
FROM public.assessment_notes
WHERE is_current = true;
-- ============================================================================
-- SECTION 10: Grant Permissions
-- ============================================================================

-- Grant access to new tables
GRANT SELECT, INSERT, UPDATE ON public.vote_rationales TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.new_metric_proposals TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.saved_searches TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.metric_proposal_votes TO authenticated;
-- Grant access to views
GRANT SELECT ON public.active_metric_proposals TO authenticated;
GRANT SELECT ON public.current_assessment_notes TO authenticated;
-- Grant sequence usage
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;
-- ============================================================================
-- SECTION 11: Notifications
-- ============================================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Controls Inventory migration completed successfully!';
    RAISE NOTICE '';
    RAISE NOTICE 'New tables created:';
    RAISE NOTICE '  - vote_rationales (stores detailed rationales for community votes)';
    RAISE NOTICE '  - new_metric_proposals (structured storage for new metric proposals)';
    RAISE NOTICE '  - saved_searches (user search history and saved filters)';
    RAISE NOTICE '  - metric_proposal_votes (voting on new metric proposals)';
    RAISE NOTICE '';
    RAISE NOTICE 'Enhanced existing tables:';
    RAISE NOTICE '  - user_scores: +2 columns (timestamp tracking)';
    RAISE NOTICE '  - community_votes: +1 column (vote_timestamp)';
    RAISE NOTICE '  - target_submissions: +1 column (review_notes)';
    RAISE NOTICE '  - user_preferences: +4 columns (UI state tracking)';
    RAISE NOTICE '  - assessment_notes: +2 columns (versioning)';
    RAISE NOTICE '';
    RAISE NOTICE 'New views:';
    RAISE NOTICE '  - active_metric_proposals';
    RAISE NOTICE '  - current_assessment_notes';
    RAISE NOTICE '';
    RAISE NOTICE 'New functions:';
    RAISE NOTICE '  - update_proposal_vote_counts()';
    RAISE NOTICE '  - update_saved_search_usage()';
    RAISE NOTICE '  - archive_old_assessment_notes()';
END $$;
