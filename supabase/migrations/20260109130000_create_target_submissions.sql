-- Create target_submissions table
CREATE TABLE IF NOT EXISTS target_submissions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    target_name TEXT NOT NULL,
    case_id TEXT,
    origin TEXT,
    context TEXT,
    description TEXT NOT NULL,
    source_url TEXT,
    claim_date DATE NOT NULL,
    primary_source TEXT,
    additional_notes TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    submitted_by UUID REFERENCES auth.users(id),
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    review_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Create index on status for efficient filtering
CREATE INDEX idx_target_submissions_status ON target_submissions(status);
CREATE INDEX idx_target_submissions_submitted_by ON target_submissions(submitted_by);
CREATE INDEX idx_target_submissions_submitted_at ON target_submissions(submitted_at DESC);
-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_target_submissions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_target_submissions_updated_at
    BEFORE UPDATE ON target_submissions
    FOR EACH ROW
    EXECUTE FUNCTION update_target_submissions_updated_at();
-- Enable Row Level Security
ALTER TABLE target_submissions ENABLE ROW LEVEL SECURITY;
-- Policy: Users can view their own submissions
CREATE POLICY "Users can view their own submissions"
    ON target_submissions
    FOR SELECT
    USING (auth.uid() = submitted_by);
-- Policy: Users can insert their own submissions
CREATE POLICY "Users can insert submissions"
    ON target_submissions
    FOR INSERT
    WITH CHECK (auth.uid() = submitted_by);
-- Policy: Admins can view all submissions (you'll need to create an admin role)
CREATE POLICY "Admins can view all submissions"
    ON target_submissions
    FOR SELECT
    USING (
        (auth.jwt()->>'raw_user_meta_data')::jsonb->>'role' = 'admin'
    );
-- Policy: Admins can update submissions (for review)
CREATE POLICY "Admins can update submissions"
    ON target_submissions
    FOR UPDATE
    USING (
        (auth.jwt()->>'raw_user_meta_data')::jsonb->>'role' = 'admin'
    );
-- Create approved_targets table (targets that have been approved)
CREATE TABLE IF NOT EXISTS approved_targets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    case_id TEXT,
    origin TEXT,
    context TEXT,
    description TEXT NOT NULL,
    source_url TEXT,
    claim_date DATE NOT NULL,
    primary_source TEXT,
    verified BOOLEAN DEFAULT false,
    submission_id UUID REFERENCES target_submissions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
-- Enable Row Level Security for approved_targets
ALTER TABLE approved_targets ENABLE ROW LEVEL SECURITY;
-- Policy: Everyone can view approved targets
CREATE POLICY "Anyone can view approved targets"
    ON approved_targets
    FOR SELECT
    USING (true);
-- Policy: Only admins can insert/update/delete approved targets
CREATE POLICY "Admins can manage approved targets"
    ON approved_targets
    FOR ALL
    USING (
        (auth.jwt()->>'raw_user_meta_data')::jsonb->>'role' = 'admin'
    );
-- Create function to approve a target submission
CREATE OR REPLACE FUNCTION approve_target_submission(
    submission_id_param UUID,
    target_id_param TEXT
)
RETURNS void AS $$
DECLARE
    submission_record RECORD;
BEGIN
    -- Get the submission
    SELECT * INTO submission_record
    FROM target_submissions
    WHERE id = submission_id_param;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission not found';
    END IF;

    -- Insert into approved_targets
    INSERT INTO approved_targets (
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
    );

    -- Update submission status
    UPDATE target_submissions
    SET
        status = 'approved',
        reviewed_by = auth.uid(),
        reviewed_at = NOW()
    WHERE id = submission_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
COMMENT ON TABLE target_submissions IS 'User-submitted forecast targets pending review';
COMMENT ON TABLE approved_targets IS 'Approved forecast targets available for scoring';
