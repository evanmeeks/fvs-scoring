-- =====================================================================
-- Sync approved_targets to targets table
-- Migration: 20260120224000_sync_approved_targets_to_targets.sql
--
-- Purpose: Ensure all approved targets are in the targets table
-- The targets table is the primary table for active targets
-- The approved_targets table is for historical tracking
-- =====================================================================

-- Insert any approved targets that aren't in the targets table yet
-- Generate case_ids for targets that don't have one
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
    primary_source,
    created_at,
    updated_at
)
SELECT
    at.id,
    at.name,
    COALESCE(at.case_id, public.generate_case_id(at.origin, at.context)),
    at.origin,
    at.context,
    COALESCE(at.verified, true),
    at.description,
    at.source_url,
    at.claim_date,
    at.primary_source,
    COALESCE(at.created_at, NOW()),
    COALESCE(at.updated_at, NOW())
FROM public.approved_targets at
WHERE at.id NOT IN (SELECT id FROM public.targets)
ON CONFLICT (id) DO NOTHING;

-- Update approved_targets with the generated case_ids
UPDATE public.approved_targets at
SET case_id = t.case_id
FROM public.targets t
WHERE at.id = t.id AND at.case_id IS NULL;

-- Log the sync
DO $$
DECLARE
    synced_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO synced_count
    FROM public.approved_targets at
    WHERE at.id IN (SELECT id FROM public.targets);

    RAISE NOTICE '✅ Synced approved_targets to targets. Total targets: %', synced_count;
END $$;
