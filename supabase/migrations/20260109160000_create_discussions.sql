-- Create discussions table for metric discussions
CREATE TABLE IF NOT EXISTS metric_discussions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    metric_id INTEGER NOT NULL,
    user_id UUID REFERENCES auth.users(id),
    comment TEXT NOT NULL,
    parent_id UUID REFERENCES metric_discussions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0
);
-- Create index for efficient queries
CREATE INDEX idx_metric_discussions_metric_id ON metric_discussions(metric_id);
CREATE INDEX idx_metric_discussions_parent_id ON metric_discussions(parent_id);
CREATE INDEX idx_metric_discussions_created_at ON metric_discussions(created_at DESC);
-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_metric_discussions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_metric_discussions_updated_at
    BEFORE UPDATE ON metric_discussions
    FOR EACH ROW
    EXECUTE FUNCTION update_metric_discussions_updated_at();
-- Create votes table
CREATE TABLE IF NOT EXISTS discussion_votes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    discussion_id UUID REFERENCES metric_discussions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id),
    vote_type TEXT CHECK (vote_type IN ('upvote', 'downvote')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(discussion_id, user_id)
);
-- Enable Row Level Security
ALTER TABLE metric_discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_votes ENABLE ROW LEVEL SECURITY;
-- Policy: Anyone can view discussions
CREATE POLICY "Anyone can view discussions"
    ON metric_discussions
    FOR SELECT
    USING (true);
-- Policy: Authenticated users can insert discussions
CREATE POLICY "Authenticated users can insert discussions"
    ON metric_discussions
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);
-- Policy: Users can update their own discussions
CREATE POLICY "Users can update their own discussions"
    ON metric_discussions
    FOR UPDATE
    USING (auth.uid() = user_id);
-- Policy: Users can delete their own discussions
CREATE POLICY "Users can delete their own discussions"
    ON metric_discussions
    FOR DELETE
    USING (auth.uid() = user_id);
-- Policy: Anyone can view votes
CREATE POLICY "Anyone can view votes"
    ON discussion_votes
    FOR SELECT
    USING (true);
-- Policy: Authenticated users can insert votes
CREATE POLICY "Authenticated users can insert votes"
    ON discussion_votes
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);
-- Policy: Users can update their own votes
CREATE POLICY "Users can update their own votes"
    ON discussion_votes
    FOR UPDATE
    USING (auth.uid() = user_id);
-- Policy: Users can delete their own votes
CREATE POLICY "Users can delete their own votes"
    ON discussion_votes
    FOR DELETE
    USING (auth.uid() = user_id);
-- Create function to get discussion count for a metric
CREATE OR REPLACE FUNCTION get_metric_discussion_count(metric_id_param INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM metric_discussions
        WHERE metric_id = metric_id_param
    );
END;
$$ LANGUAGE plpgsql;
-- Create function to handle vote updates
CREATE OR REPLACE FUNCTION update_discussion_votes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes + 1 WHERE id = NEW.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes + 1 WHERE id = NEW.discussion_id;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes - 1 WHERE id = OLD.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes - 1 WHERE id = OLD.discussion_id;
        END IF;
        IF NEW.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes + 1 WHERE id = NEW.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes + 1 WHERE id = NEW.discussion_id;
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF OLD.vote_type = 'upvote' THEN
            UPDATE metric_discussions SET upvotes = upvotes - 1 WHERE id = OLD.discussion_id;
        ELSE
            UPDATE metric_discussions SET downvotes = downvotes - 1 WHERE id = OLD.discussion_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_discussion_votes
    AFTER INSERT OR UPDATE OR DELETE ON discussion_votes
    FOR EACH ROW
    EXECUTE FUNCTION update_discussion_votes();
COMMENT ON TABLE metric_discussions IS 'Discussion threads for FVS metrics';
COMMENT ON TABLE discussion_votes IS 'User votes on metric discussions';
