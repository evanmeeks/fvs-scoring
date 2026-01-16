-- Fix RLS policies for target_submissions and approved_targets
-- These policies were checking JWT metadata which is outdated
-- They should check the user_profiles table for role information

-- Drop the old policies that check JWT metadata
DROP POLICY IF EXISTS "Admins can view all submissions" ON target_submissions;
DROP POLICY IF EXISTS "Admins can update submissions" ON target_submissions;
DROP POLICY IF EXISTS "Admins can manage approved targets" ON approved_targets;
-- Create new policies that check user_profiles table
CREATE POLICY "Admins can view all submissions"
    ON target_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );
CREATE POLICY "Admins can update submissions"
    ON target_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );
CREATE POLICY "Admins can manage approved targets"
    ON approved_targets
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role = 'admin'
        )
    );
-- Add a policy for contributors to view all submissions (for review purposes)
CREATE POLICY "Contributors can view all submissions"
    ON target_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_profiles
            WHERE user_id = auth.uid() AND role IN ('admin', 'contributor')
        )
    );
