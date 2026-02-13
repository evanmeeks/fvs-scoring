-- Fix proposed_category CHECK constraint to match updated metric categories
-- Old categories: CORE, INTEGRITY, IMPACT
-- New categories: PRECISION, CALIBRATION, INTEGRITY, VALUE (from prediction market update)

-- Drop old constraint first
ALTER TABLE public.rfc_proposals
DROP CONSTRAINT IF EXISTS rfc_proposals_proposed_category_check;

-- Migrate existing rows from old categories to new ones
UPDATE public.rfc_proposals SET proposed_category = 'PRECISION' WHERE proposed_category = 'CORE';
UPDATE public.rfc_proposals SET proposed_category = 'VALUE' WHERE proposed_category = 'IMPACT';

-- Add new constraint
ALTER TABLE public.rfc_proposals
ADD CONSTRAINT rfc_proposals_proposed_category_check
CHECK (proposed_category IN ('PRECISION', 'CALIBRATION', 'INTEGRITY', 'VALUE'));
