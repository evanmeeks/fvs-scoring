BEGIN;

-- =============================================================================
-- 1. CLEAN UP ORPHANED DATA
-- =============================================================================

DELETE FROM user_scores WHERE target_id NOT IN (SELECT id FROM targets);
DELETE FROM community_votes WHERE target_id NOT IN (SELECT id FROM targets);
DELETE FROM activity_log WHERE metadata->>'target_id' IS NOT NULL
  AND metadata->>'target_id' NOT IN (SELECT id FROM targets);

-- Remove orphaned approved_targets
DELETE FROM approved_targets WHERE id NOT IN (SELECT id FROM targets);

-- =============================================================================
-- 2. FIX ORIGIN/CONTEXT ON PREDICTION MARKET TARGETS
-- =============================================================================

UPDATE targets SET origin = 'federal_civil_agency', context = 'government_report' WHERE id = 'fed-rate-2024';
UPDATE targets SET origin = 'media_organization', context = 'media_broadcast' WHERE id = 'election-2024';
UPDATE targets SET origin = 'academic_institution', context = 'government_report' WHERE id = 'recession-2024';
UPDATE targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'climate-temp-2024';
UPDATE targets SET origin = 'private_sector_corporate', context = 'scientific_paper' WHERE id = 'agi-timeline-2024';
UPDATE targets SET origin = 'private_sector_corporate', context = 'press_release' WHERE id = 'spacex-orbital-2024';
UPDATE targets SET origin = 'private_sector_corporate', context = 'media_broadcast' WHERE id = 'bitcoin-eoy-2024';
UPDATE targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'pandemic-timeline-2024';
UPDATE targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'fusion-timeline-2024';

-- Also fix approved_targets to match
UPDATE approved_targets SET origin = 'federal_civil_agency', context = 'government_report' WHERE id = 'fed-rate-2024';
UPDATE approved_targets SET origin = 'media_organization', context = 'media_broadcast' WHERE id = 'election-2024';
UPDATE approved_targets SET origin = 'academic_institution', context = 'government_report' WHERE id = 'recession-2024';
UPDATE approved_targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'climate-temp-2024';
UPDATE approved_targets SET origin = 'private_sector_corporate', context = 'scientific_paper' WHERE id = 'agi-timeline-2024';
UPDATE approved_targets SET origin = 'private_sector_corporate', context = 'press_release' WHERE id = 'spacex-orbital-2024';
UPDATE approved_targets SET origin = 'private_sector_corporate', context = 'media_broadcast' WHERE id = 'bitcoin-eoy-2024';
UPDATE approved_targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'pandemic-timeline-2024';
UPDATE approved_targets SET origin = 'academic_institution', context = 'scientific_paper' WHERE id = 'fusion-timeline-2024';

-- =============================================================================
-- 3. SEED USER SCORES
-- Users: Clark Kent (admin), Evan Meeks, Randy Moncrief, e.van.meeks, fadeto.bass, Evan Meeks CDK
-- Scores 1-5 per metric. HIGH targets ~4, MIXED ~3, SPECULATIVE ~2.5, MILITARY ~3.5
-- =============================================================================

-- Helper: Insert scores for a user+target with base score and variance
-- We'll use DO blocks with arrays for compactness

DO $$
DECLARE
    u_clark UUID := '132fdb5d-3a06-406c-a87b-570b56028a4a';
    u_evan UUID := 'd9eb0f55-dea4-4659-b277-e300f6eddbbf';
    u_randy UUID := '05fedb7a-8f5d-40a2-8646-58abb439d1a2';
    u_vanmeeks UUID := '7ddcaff5-b8e0-47cf-b904-3b9a53c37c41';
    u_fadeto UUID := '4f308a61-8fde-4783-b1a6-4f1712061da5';
    u_cdk UUID := 'f9364e53-91f2-4a3d-949f-aefd5f68f1c0';
BEGIN

-- ---- FED RATE (HIGH QUALITY) - 4 scorers ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'fed-rate-2024', 1, 5), (u_clark, 'fed-rate-2024', 2, 4), (u_clark, 'fed-rate-2024', 3, 5),
(u_clark, 'fed-rate-2024', 4, 4), (u_clark, 'fed-rate-2024', 5, 5), (u_clark, 'fed-rate-2024', 6, 3),
(u_clark, 'fed-rate-2024', 7, 4), (u_clark, 'fed-rate-2024', 8, 4), (u_clark, 'fed-rate-2024', 9, 5),
(u_clark, 'fed-rate-2024', 10, 4), (u_clark, 'fed-rate-2024', 11, 4), (u_clark, 'fed-rate-2024', 12, 5),
(u_clark, 'fed-rate-2024', 13, 4), (u_clark, 'fed-rate-2024', 14, 5), (u_clark, 'fed-rate-2024', 15, 4),
(u_clark, 'fed-rate-2024', 16, 3), (u_clark, 'fed-rate-2024', 17, 5), (u_clark, 'fed-rate-2024', 18, 4),
(u_clark, 'fed-rate-2024', 19, 5), (u_clark, 'fed-rate-2024', 20, 4),
(u_evan, 'fed-rate-2024', 1, 4), (u_evan, 'fed-rate-2024', 2, 5), (u_evan, 'fed-rate-2024', 3, 4),
(u_evan, 'fed-rate-2024', 4, 4), (u_evan, 'fed-rate-2024', 5, 4), (u_evan, 'fed-rate-2024', 6, 4),
(u_evan, 'fed-rate-2024', 7, 5), (u_evan, 'fed-rate-2024', 8, 3), (u_evan, 'fed-rate-2024', 9, 4),
(u_evan, 'fed-rate-2024', 10, 5), (u_evan, 'fed-rate-2024', 11, 4), (u_evan, 'fed-rate-2024', 12, 4),
(u_evan, 'fed-rate-2024', 13, 5), (u_evan, 'fed-rate-2024', 14, 4), (u_evan, 'fed-rate-2024', 15, 4),
(u_evan, 'fed-rate-2024', 16, 4), (u_evan, 'fed-rate-2024', 17, 4), (u_evan, 'fed-rate-2024', 18, 5),
(u_evan, 'fed-rate-2024', 19, 4), (u_evan, 'fed-rate-2024', 20, 5),
(u_randy, 'fed-rate-2024', 1, 4), (u_randy, 'fed-rate-2024', 2, 4), (u_randy, 'fed-rate-2024', 3, 4),
(u_randy, 'fed-rate-2024', 4, 3), (u_randy, 'fed-rate-2024', 5, 4), (u_randy, 'fed-rate-2024', 6, 3),
(u_randy, 'fed-rate-2024', 7, 4), (u_randy, 'fed-rate-2024', 8, 4), (u_randy, 'fed-rate-2024', 9, 4),
(u_randy, 'fed-rate-2024', 10, 3), (u_randy, 'fed-rate-2024', 11, 3), (u_randy, 'fed-rate-2024', 12, 4),
(u_randy, 'fed-rate-2024', 13, 4), (u_randy, 'fed-rate-2024', 14, 4), (u_randy, 'fed-rate-2024', 15, 3),
(u_randy, 'fed-rate-2024', 16, 3), (u_randy, 'fed-rate-2024', 17, 4), (u_randy, 'fed-rate-2024', 18, 3),
(u_randy, 'fed-rate-2024', 19, 4), (u_randy, 'fed-rate-2024', 20, 4),
(u_vanmeeks, 'fed-rate-2024', 1, 5), (u_vanmeeks, 'fed-rate-2024', 2, 4), (u_vanmeeks, 'fed-rate-2024', 3, 4),
(u_vanmeeks, 'fed-rate-2024', 4, 5), (u_vanmeeks, 'fed-rate-2024', 5, 4), (u_vanmeeks, 'fed-rate-2024', 6, 4),
(u_vanmeeks, 'fed-rate-2024', 7, 5), (u_vanmeeks, 'fed-rate-2024', 8, 5), (u_vanmeeks, 'fed-rate-2024', 9, 4),
(u_vanmeeks, 'fed-rate-2024', 10, 4), (u_vanmeeks, 'fed-rate-2024', 11, 5), (u_vanmeeks, 'fed-rate-2024', 12, 4),
(u_vanmeeks, 'fed-rate-2024', 13, 4), (u_vanmeeks, 'fed-rate-2024', 14, 5), (u_vanmeeks, 'fed-rate-2024', 15, 4),
(u_vanmeeks, 'fed-rate-2024', 16, 4), (u_vanmeeks, 'fed-rate-2024', 17, 5), (u_vanmeeks, 'fed-rate-2024', 18, 4),
(u_vanmeeks, 'fed-rate-2024', 19, 4), (u_vanmeeks, 'fed-rate-2024', 20, 5)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- ELECTION (HIGH QUALITY) - 4 scorers ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'election-2024', 1, 4), (u_clark, 'election-2024', 2, 4), (u_clark, 'election-2024', 3, 5),
(u_clark, 'election-2024', 4, 3), (u_clark, 'election-2024', 5, 4), (u_clark, 'election-2024', 6, 3),
(u_clark, 'election-2024', 7, 4), (u_clark, 'election-2024', 8, 5), (u_clark, 'election-2024', 9, 4),
(u_clark, 'election-2024', 10, 4), (u_clark, 'election-2024', 11, 4), (u_clark, 'election-2024', 12, 4),
(u_clark, 'election-2024', 13, 3), (u_clark, 'election-2024', 14, 5), (u_clark, 'election-2024', 15, 4),
(u_clark, 'election-2024', 16, 4), (u_clark, 'election-2024', 17, 4), (u_clark, 'election-2024', 18, 3),
(u_clark, 'election-2024', 19, 4), (u_clark, 'election-2024', 20, 4),
(u_evan, 'election-2024', 1, 5), (u_evan, 'election-2024', 2, 4), (u_evan, 'election-2024', 3, 4),
(u_evan, 'election-2024', 4, 4), (u_evan, 'election-2024', 5, 5), (u_evan, 'election-2024', 6, 3),
(u_evan, 'election-2024', 7, 3), (u_evan, 'election-2024', 8, 4), (u_evan, 'election-2024', 9, 5),
(u_evan, 'election-2024', 10, 4), (u_evan, 'election-2024', 11, 3), (u_evan, 'election-2024', 12, 5),
(u_evan, 'election-2024', 13, 4), (u_evan, 'election-2024', 14, 4), (u_evan, 'election-2024', 15, 4),
(u_evan, 'election-2024', 16, 3), (u_evan, 'election-2024', 17, 5), (u_evan, 'election-2024', 18, 4),
(u_evan, 'election-2024', 19, 4), (u_evan, 'election-2024', 20, 4),
(u_fadeto, 'election-2024', 1, 4), (u_fadeto, 'election-2024', 2, 3), (u_fadeto, 'election-2024', 3, 4),
(u_fadeto, 'election-2024', 4, 4), (u_fadeto, 'election-2024', 5, 4), (u_fadeto, 'election-2024', 6, 4),
(u_fadeto, 'election-2024', 7, 4), (u_fadeto, 'election-2024', 8, 3), (u_fadeto, 'election-2024', 9, 4),
(u_fadeto, 'election-2024', 10, 3), (u_fadeto, 'election-2024', 11, 4), (u_fadeto, 'election-2024', 12, 3),
(u_fadeto, 'election-2024', 13, 4), (u_fadeto, 'election-2024', 14, 4), (u_fadeto, 'election-2024', 15, 3),
(u_fadeto, 'election-2024', 16, 4), (u_fadeto, 'election-2024', 17, 4), (u_fadeto, 'election-2024', 18, 4),
(u_fadeto, 'election-2024', 19, 3), (u_fadeto, 'election-2024', 20, 4),
(u_cdk, 'election-2024', 1, 4), (u_cdk, 'election-2024', 2, 5), (u_cdk, 'election-2024', 3, 4),
(u_cdk, 'election-2024', 4, 3), (u_cdk, 'election-2024', 5, 4), (u_cdk, 'election-2024', 6, 3),
(u_cdk, 'election-2024', 7, 5), (u_cdk, 'election-2024', 8, 4), (u_cdk, 'election-2024', 9, 4),
(u_cdk, 'election-2024', 10, 5), (u_cdk, 'election-2024', 11, 4), (u_cdk, 'election-2024', 12, 4),
(u_cdk, 'election-2024', 13, 4), (u_cdk, 'election-2024', 14, 5), (u_cdk, 'election-2024', 15, 4),
(u_cdk, 'election-2024', 16, 3), (u_cdk, 'election-2024', 17, 4), (u_cdk, 'election-2024', 18, 5),
(u_cdk, 'election-2024', 19, 4), (u_cdk, 'election-2024', 20, 5)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- RECESSION (HIGH QUALITY) - 3 scorers ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'recession-2024', 1, 4), (u_clark, 'recession-2024', 2, 5), (u_clark, 'recession-2024', 3, 4),
(u_clark, 'recession-2024', 4, 4), (u_clark, 'recession-2024', 5, 5), (u_clark, 'recession-2024', 6, 3),
(u_clark, 'recession-2024', 7, 4), (u_clark, 'recession-2024', 8, 4), (u_clark, 'recession-2024', 9, 4),
(u_clark, 'recession-2024', 10, 4), (u_clark, 'recession-2024', 11, 5), (u_clark, 'recession-2024', 12, 4),
(u_clark, 'recession-2024', 13, 4), (u_clark, 'recession-2024', 14, 5), (u_clark, 'recession-2024', 15, 4),
(u_clark, 'recession-2024', 16, 3), (u_clark, 'recession-2024', 17, 4), (u_clark, 'recession-2024', 18, 4),
(u_clark, 'recession-2024', 19, 5), (u_clark, 'recession-2024', 20, 4),
(u_randy, 'recession-2024', 1, 3), (u_randy, 'recession-2024', 2, 4), (u_randy, 'recession-2024', 3, 4),
(u_randy, 'recession-2024', 4, 3), (u_randy, 'recession-2024', 5, 4), (u_randy, 'recession-2024', 6, 3),
(u_randy, 'recession-2024', 7, 3), (u_randy, 'recession-2024', 8, 4), (u_randy, 'recession-2024', 9, 3),
(u_randy, 'recession-2024', 10, 4), (u_randy, 'recession-2024', 11, 4), (u_randy, 'recession-2024', 12, 3),
(u_randy, 'recession-2024', 13, 3), (u_randy, 'recession-2024', 14, 4), (u_randy, 'recession-2024', 15, 3),
(u_randy, 'recession-2024', 16, 3), (u_randy, 'recession-2024', 17, 4), (u_randy, 'recession-2024', 18, 3),
(u_randy, 'recession-2024', 19, 3), (u_randy, 'recession-2024', 20, 4),
(u_vanmeeks, 'recession-2024', 1, 4), (u_vanmeeks, 'recession-2024', 2, 4), (u_vanmeeks, 'recession-2024', 3, 5),
(u_vanmeeks, 'recession-2024', 4, 4), (u_vanmeeks, 'recession-2024', 5, 4), (u_vanmeeks, 'recession-2024', 6, 4),
(u_vanmeeks, 'recession-2024', 7, 4), (u_vanmeeks, 'recession-2024', 8, 5), (u_vanmeeks, 'recession-2024', 9, 4),
(u_vanmeeks, 'recession-2024', 10, 4), (u_vanmeeks, 'recession-2024', 11, 4), (u_vanmeeks, 'recession-2024', 12, 5),
(u_vanmeeks, 'recession-2024', 13, 4), (u_vanmeeks, 'recession-2024', 14, 4), (u_vanmeeks, 'recession-2024', 15, 5),
(u_vanmeeks, 'recession-2024', 16, 4), (u_vanmeeks, 'recession-2024', 17, 4), (u_vanmeeks, 'recession-2024', 18, 4),
(u_vanmeeks, 'recession-2024', 19, 4), (u_vanmeeks, 'recession-2024', 20, 4)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- CLIMATE (HIGH QUALITY) - 3 scorers ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_evan, 'climate-temp-2024', 1, 5), (u_evan, 'climate-temp-2024', 2, 4), (u_evan, 'climate-temp-2024', 3, 4),
(u_evan, 'climate-temp-2024', 4, 4), (u_evan, 'climate-temp-2024', 5, 5), (u_evan, 'climate-temp-2024', 6, 3),
(u_evan, 'climate-temp-2024', 7, 5), (u_evan, 'climate-temp-2024', 8, 4), (u_evan, 'climate-temp-2024', 9, 5),
(u_evan, 'climate-temp-2024', 10, 4), (u_evan, 'climate-temp-2024', 11, 4), (u_evan, 'climate-temp-2024', 12, 4),
(u_evan, 'climate-temp-2024', 13, 5), (u_evan, 'climate-temp-2024', 14, 5), (u_evan, 'climate-temp-2024', 15, 4),
(u_evan, 'climate-temp-2024', 16, 3), (u_evan, 'climate-temp-2024', 17, 5), (u_evan, 'climate-temp-2024', 18, 4),
(u_evan, 'climate-temp-2024', 19, 4), (u_evan, 'climate-temp-2024', 20, 5),
(u_fadeto, 'climate-temp-2024', 1, 4), (u_fadeto, 'climate-temp-2024', 2, 4), (u_fadeto, 'climate-temp-2024', 3, 3),
(u_fadeto, 'climate-temp-2024', 4, 4), (u_fadeto, 'climate-temp-2024', 5, 4), (u_fadeto, 'climate-temp-2024', 6, 4),
(u_fadeto, 'climate-temp-2024', 7, 4), (u_fadeto, 'climate-temp-2024', 8, 3), (u_fadeto, 'climate-temp-2024', 9, 4),
(u_fadeto, 'climate-temp-2024', 10, 4), (u_fadeto, 'climate-temp-2024', 11, 3), (u_fadeto, 'climate-temp-2024', 12, 4),
(u_fadeto, 'climate-temp-2024', 13, 4), (u_fadeto, 'climate-temp-2024', 14, 4), (u_fadeto, 'climate-temp-2024', 15, 4),
(u_fadeto, 'climate-temp-2024', 16, 3), (u_fadeto, 'climate-temp-2024', 17, 4), (u_fadeto, 'climate-temp-2024', 18, 4),
(u_fadeto, 'climate-temp-2024', 19, 3), (u_fadeto, 'climate-temp-2024', 20, 4),
(u_cdk, 'climate-temp-2024', 1, 4), (u_cdk, 'climate-temp-2024', 2, 5), (u_cdk, 'climate-temp-2024', 3, 4),
(u_cdk, 'climate-temp-2024', 4, 5), (u_cdk, 'climate-temp-2024', 5, 4), (u_cdk, 'climate-temp-2024', 6, 3),
(u_cdk, 'climate-temp-2024', 7, 4), (u_cdk, 'climate-temp-2024', 8, 4), (u_cdk, 'climate-temp-2024', 9, 4),
(u_cdk, 'climate-temp-2024', 10, 5), (u_cdk, 'climate-temp-2024', 11, 5), (u_cdk, 'climate-temp-2024', 12, 4),
(u_cdk, 'climate-temp-2024', 13, 4), (u_cdk, 'climate-temp-2024', 14, 5), (u_cdk, 'climate-temp-2024', 15, 4),
(u_cdk, 'climate-temp-2024', 16, 4), (u_cdk, 'climate-temp-2024', 17, 5), (u_cdk, 'climate-temp-2024', 18, 4),
(u_cdk, 'climate-temp-2024', 19, 5), (u_cdk, 'climate-temp-2024', 20, 4)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- AGI (MIXED) - 3 scorers, avg ~3 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'agi-timeline-2024', 1, 3), (u_clark, 'agi-timeline-2024', 2, 2), (u_clark, 'agi-timeline-2024', 3, 2),
(u_clark, 'agi-timeline-2024', 4, 4), (u_clark, 'agi-timeline-2024', 5, 3), (u_clark, 'agi-timeline-2024', 6, 3),
(u_clark, 'agi-timeline-2024', 7, 3), (u_clark, 'agi-timeline-2024', 8, 2), (u_clark, 'agi-timeline-2024', 9, 3),
(u_clark, 'agi-timeline-2024', 10, 2), (u_clark, 'agi-timeline-2024', 11, 3), (u_clark, 'agi-timeline-2024', 12, 3),
(u_clark, 'agi-timeline-2024', 13, 4), (u_clark, 'agi-timeline-2024', 14, 3), (u_clark, 'agi-timeline-2024', 15, 3),
(u_clark, 'agi-timeline-2024', 16, 4), (u_clark, 'agi-timeline-2024', 17, 2), (u_clark, 'agi-timeline-2024', 18, 3),
(u_clark, 'agi-timeline-2024', 19, 3), (u_clark, 'agi-timeline-2024', 20, 3),
(u_evan, 'agi-timeline-2024', 1, 3), (u_evan, 'agi-timeline-2024', 2, 3), (u_evan, 'agi-timeline-2024', 3, 3),
(u_evan, 'agi-timeline-2024', 4, 4), (u_evan, 'agi-timeline-2024', 5, 3), (u_evan, 'agi-timeline-2024', 6, 2),
(u_evan, 'agi-timeline-2024', 7, 4), (u_evan, 'agi-timeline-2024', 8, 3), (u_evan, 'agi-timeline-2024', 9, 2),
(u_evan, 'agi-timeline-2024', 10, 3), (u_evan, 'agi-timeline-2024', 11, 3), (u_evan, 'agi-timeline-2024', 12, 4),
(u_evan, 'agi-timeline-2024', 13, 3), (u_evan, 'agi-timeline-2024', 14, 3), (u_evan, 'agi-timeline-2024', 15, 4),
(u_evan, 'agi-timeline-2024', 16, 3), (u_evan, 'agi-timeline-2024', 17, 3), (u_evan, 'agi-timeline-2024', 18, 2),
(u_evan, 'agi-timeline-2024', 19, 3), (u_evan, 'agi-timeline-2024', 20, 3),
(u_cdk, 'agi-timeline-2024', 1, 4), (u_cdk, 'agi-timeline-2024', 2, 3), (u_cdk, 'agi-timeline-2024', 3, 3),
(u_cdk, 'agi-timeline-2024', 4, 5), (u_cdk, 'agi-timeline-2024', 5, 3), (u_cdk, 'agi-timeline-2024', 6, 2),
(u_cdk, 'agi-timeline-2024', 7, 3), (u_cdk, 'agi-timeline-2024', 8, 3), (u_cdk, 'agi-timeline-2024', 9, 3),
(u_cdk, 'agi-timeline-2024', 10, 3), (u_cdk, 'agi-timeline-2024', 11, 4), (u_cdk, 'agi-timeline-2024', 12, 3),
(u_cdk, 'agi-timeline-2024', 13, 4), (u_cdk, 'agi-timeline-2024', 14, 3), (u_cdk, 'agi-timeline-2024', 15, 3),
(u_cdk, 'agi-timeline-2024', 16, 4), (u_cdk, 'agi-timeline-2024', 17, 2), (u_cdk, 'agi-timeline-2024', 18, 3),
(u_cdk, 'agi-timeline-2024', 19, 3), (u_cdk, 'agi-timeline-2024', 20, 3)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- SPACEX (MIXED) - 3 scorers, avg ~3 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_randy, 'spacex-orbital-2024', 1, 4), (u_randy, 'spacex-orbital-2024', 2, 3), (u_randy, 'spacex-orbital-2024', 3, 3),
(u_randy, 'spacex-orbital-2024', 4, 3), (u_randy, 'spacex-orbital-2024', 5, 4), (u_randy, 'spacex-orbital-2024', 6, 2),
(u_randy, 'spacex-orbital-2024', 7, 3), (u_randy, 'spacex-orbital-2024', 8, 3), (u_randy, 'spacex-orbital-2024', 9, 4),
(u_randy, 'spacex-orbital-2024', 10, 2), (u_randy, 'spacex-orbital-2024', 11, 3), (u_randy, 'spacex-orbital-2024', 12, 3),
(u_randy, 'spacex-orbital-2024', 13, 3), (u_randy, 'spacex-orbital-2024', 14, 4), (u_randy, 'spacex-orbital-2024', 15, 3),
(u_randy, 'spacex-orbital-2024', 16, 3), (u_randy, 'spacex-orbital-2024', 17, 3), (u_randy, 'spacex-orbital-2024', 18, 3),
(u_randy, 'spacex-orbital-2024', 19, 3), (u_randy, 'spacex-orbital-2024', 20, 3),
(u_vanmeeks, 'spacex-orbital-2024', 1, 3), (u_vanmeeks, 'spacex-orbital-2024', 2, 3), (u_vanmeeks, 'spacex-orbital-2024', 3, 4),
(u_vanmeeks, 'spacex-orbital-2024', 4, 3), (u_vanmeeks, 'spacex-orbital-2024', 5, 3), (u_vanmeeks, 'spacex-orbital-2024', 6, 3),
(u_vanmeeks, 'spacex-orbital-2024', 7, 4), (u_vanmeeks, 'spacex-orbital-2024', 8, 2), (u_vanmeeks, 'spacex-orbital-2024', 9, 3),
(u_vanmeeks, 'spacex-orbital-2024', 10, 3), (u_vanmeeks, 'spacex-orbital-2024', 11, 3), (u_vanmeeks, 'spacex-orbital-2024', 12, 4),
(u_vanmeeks, 'spacex-orbital-2024', 13, 3), (u_vanmeeks, 'spacex-orbital-2024', 14, 3), (u_vanmeeks, 'spacex-orbital-2024', 15, 3),
(u_vanmeeks, 'spacex-orbital-2024', 16, 2), (u_vanmeeks, 'spacex-orbital-2024', 17, 3), (u_vanmeeks, 'spacex-orbital-2024', 18, 3),
(u_vanmeeks, 'spacex-orbital-2024', 19, 4), (u_vanmeeks, 'spacex-orbital-2024', 20, 3),
(u_fadeto, 'spacex-orbital-2024', 1, 3), (u_fadeto, 'spacex-orbital-2024', 2, 4), (u_fadeto, 'spacex-orbital-2024', 3, 3),
(u_fadeto, 'spacex-orbital-2024', 4, 4), (u_fadeto, 'spacex-orbital-2024', 5, 3), (u_fadeto, 'spacex-orbital-2024', 6, 3),
(u_fadeto, 'spacex-orbital-2024', 7, 3), (u_fadeto, 'spacex-orbital-2024', 8, 3), (u_fadeto, 'spacex-orbital-2024', 9, 3),
(u_fadeto, 'spacex-orbital-2024', 10, 3), (u_fadeto, 'spacex-orbital-2024', 11, 4), (u_fadeto, 'spacex-orbital-2024', 12, 3),
(u_fadeto, 'spacex-orbital-2024', 13, 3), (u_fadeto, 'spacex-orbital-2024', 14, 3), (u_fadeto, 'spacex-orbital-2024', 15, 4),
(u_fadeto, 'spacex-orbital-2024', 16, 3), (u_fadeto, 'spacex-orbital-2024', 17, 4), (u_fadeto, 'spacex-orbital-2024', 18, 3),
(u_fadeto, 'spacex-orbital-2024', 19, 3), (u_fadeto, 'spacex-orbital-2024', 20, 3)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- BITCOIN (SPECULATIVE) - 3 scorers, avg ~2.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_evan, 'bitcoin-eoy-2024', 1, 2), (u_evan, 'bitcoin-eoy-2024', 2, 2), (u_evan, 'bitcoin-eoy-2024', 3, 3),
(u_evan, 'bitcoin-eoy-2024', 4, 2), (u_evan, 'bitcoin-eoy-2024', 5, 2), (u_evan, 'bitcoin-eoy-2024', 6, 3),
(u_evan, 'bitcoin-eoy-2024', 7, 2), (u_evan, 'bitcoin-eoy-2024', 8, 2), (u_evan, 'bitcoin-eoy-2024', 9, 2),
(u_evan, 'bitcoin-eoy-2024', 10, 2), (u_evan, 'bitcoin-eoy-2024', 11, 3), (u_evan, 'bitcoin-eoy-2024', 12, 2),
(u_evan, 'bitcoin-eoy-2024', 13, 2), (u_evan, 'bitcoin-eoy-2024', 14, 3), (u_evan, 'bitcoin-eoy-2024', 15, 2),
(u_evan, 'bitcoin-eoy-2024', 16, 3), (u_evan, 'bitcoin-eoy-2024', 17, 2), (u_evan, 'bitcoin-eoy-2024', 18, 2),
(u_evan, 'bitcoin-eoy-2024', 19, 2), (u_evan, 'bitcoin-eoy-2024', 20, 2),
(u_clark, 'bitcoin-eoy-2024', 1, 3), (u_clark, 'bitcoin-eoy-2024', 2, 2), (u_clark, 'bitcoin-eoy-2024', 3, 3),
(u_clark, 'bitcoin-eoy-2024', 4, 3), (u_clark, 'bitcoin-eoy-2024', 5, 2), (u_clark, 'bitcoin-eoy-2024', 6, 2),
(u_clark, 'bitcoin-eoy-2024', 7, 2), (u_clark, 'bitcoin-eoy-2024', 8, 3), (u_clark, 'bitcoin-eoy-2024', 9, 2),
(u_clark, 'bitcoin-eoy-2024', 10, 2), (u_clark, 'bitcoin-eoy-2024', 11, 2), (u_clark, 'bitcoin-eoy-2024', 12, 3),
(u_clark, 'bitcoin-eoy-2024', 13, 3), (u_clark, 'bitcoin-eoy-2024', 14, 2), (u_clark, 'bitcoin-eoy-2024', 15, 3),
(u_clark, 'bitcoin-eoy-2024', 16, 2), (u_clark, 'bitcoin-eoy-2024', 17, 2), (u_clark, 'bitcoin-eoy-2024', 18, 3),
(u_clark, 'bitcoin-eoy-2024', 19, 2), (u_clark, 'bitcoin-eoy-2024', 20, 3),
(u_fadeto, 'bitcoin-eoy-2024', 1, 2), (u_fadeto, 'bitcoin-eoy-2024', 2, 3), (u_fadeto, 'bitcoin-eoy-2024', 3, 2),
(u_fadeto, 'bitcoin-eoy-2024', 4, 3), (u_fadeto, 'bitcoin-eoy-2024', 5, 3), (u_fadeto, 'bitcoin-eoy-2024', 6, 2),
(u_fadeto, 'bitcoin-eoy-2024', 7, 3), (u_fadeto, 'bitcoin-eoy-2024', 8, 2), (u_fadeto, 'bitcoin-eoy-2024', 9, 3),
(u_fadeto, 'bitcoin-eoy-2024', 10, 2), (u_fadeto, 'bitcoin-eoy-2024', 11, 3), (u_fadeto, 'bitcoin-eoy-2024', 12, 2),
(u_fadeto, 'bitcoin-eoy-2024', 13, 2), (u_fadeto, 'bitcoin-eoy-2024', 14, 3), (u_fadeto, 'bitcoin-eoy-2024', 15, 2),
(u_fadeto, 'bitcoin-eoy-2024', 16, 3), (u_fadeto, 'bitcoin-eoy-2024', 17, 3), (u_fadeto, 'bitcoin-eoy-2024', 18, 2),
(u_fadeto, 'bitcoin-eoy-2024', 19, 3), (u_fadeto, 'bitcoin-eoy-2024', 20, 2)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- PANDEMIC (SPECULATIVE) - 3 scorers, avg ~2.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_randy, 'pandemic-timeline-2024', 1, 3), (u_randy, 'pandemic-timeline-2024', 2, 2), (u_randy, 'pandemic-timeline-2024', 3, 2),
(u_randy, 'pandemic-timeline-2024', 4, 3), (u_randy, 'pandemic-timeline-2024', 5, 3), (u_randy, 'pandemic-timeline-2024', 6, 2),
(u_randy, 'pandemic-timeline-2024', 7, 3), (u_randy, 'pandemic-timeline-2024', 8, 2), (u_randy, 'pandemic-timeline-2024', 9, 2),
(u_randy, 'pandemic-timeline-2024', 10, 3), (u_randy, 'pandemic-timeline-2024', 11, 2), (u_randy, 'pandemic-timeline-2024', 12, 3),
(u_randy, 'pandemic-timeline-2024', 13, 2), (u_randy, 'pandemic-timeline-2024', 14, 3), (u_randy, 'pandemic-timeline-2024', 15, 2),
(u_randy, 'pandemic-timeline-2024', 16, 3), (u_randy, 'pandemic-timeline-2024', 17, 3), (u_randy, 'pandemic-timeline-2024', 18, 2),
(u_randy, 'pandemic-timeline-2024', 19, 2), (u_randy, 'pandemic-timeline-2024', 20, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 1, 2), (u_vanmeeks, 'pandemic-timeline-2024', 2, 3), (u_vanmeeks, 'pandemic-timeline-2024', 3, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 4, 2), (u_vanmeeks, 'pandemic-timeline-2024', 5, 2), (u_vanmeeks, 'pandemic-timeline-2024', 6, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 7, 2), (u_vanmeeks, 'pandemic-timeline-2024', 8, 3), (u_vanmeeks, 'pandemic-timeline-2024', 9, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 10, 2), (u_vanmeeks, 'pandemic-timeline-2024', 11, 3), (u_vanmeeks, 'pandemic-timeline-2024', 12, 2),
(u_vanmeeks, 'pandemic-timeline-2024', 13, 3), (u_vanmeeks, 'pandemic-timeline-2024', 14, 2), (u_vanmeeks, 'pandemic-timeline-2024', 15, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 16, 2), (u_vanmeeks, 'pandemic-timeline-2024', 17, 2), (u_vanmeeks, 'pandemic-timeline-2024', 18, 3),
(u_vanmeeks, 'pandemic-timeline-2024', 19, 3), (u_vanmeeks, 'pandemic-timeline-2024', 20, 2),
(u_evan, 'pandemic-timeline-2024', 1, 3), (u_evan, 'pandemic-timeline-2024', 2, 3), (u_evan, 'pandemic-timeline-2024', 3, 2),
(u_evan, 'pandemic-timeline-2024', 4, 3), (u_evan, 'pandemic-timeline-2024', 5, 2), (u_evan, 'pandemic-timeline-2024', 6, 2),
(u_evan, 'pandemic-timeline-2024', 7, 3), (u_evan, 'pandemic-timeline-2024', 8, 2), (u_evan, 'pandemic-timeline-2024', 9, 3),
(u_evan, 'pandemic-timeline-2024', 10, 2), (u_evan, 'pandemic-timeline-2024', 11, 3), (u_evan, 'pandemic-timeline-2024', 12, 3),
(u_evan, 'pandemic-timeline-2024', 13, 2), (u_evan, 'pandemic-timeline-2024', 14, 3), (u_evan, 'pandemic-timeline-2024', 15, 2),
(u_evan, 'pandemic-timeline-2024', 16, 3), (u_evan, 'pandemic-timeline-2024', 17, 2), (u_evan, 'pandemic-timeline-2024', 18, 2),
(u_evan, 'pandemic-timeline-2024', 19, 3), (u_evan, 'pandemic-timeline-2024', 20, 2)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- FUSION (SPECULATIVE) - 3 scorers, avg ~2.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'fusion-timeline-2024', 1, 3), (u_clark, 'fusion-timeline-2024', 2, 3), (u_clark, 'fusion-timeline-2024', 3, 2),
(u_clark, 'fusion-timeline-2024', 4, 3), (u_clark, 'fusion-timeline-2024', 5, 3), (u_clark, 'fusion-timeline-2024', 6, 2),
(u_clark, 'fusion-timeline-2024', 7, 3), (u_clark, 'fusion-timeline-2024', 8, 2), (u_clark, 'fusion-timeline-2024', 9, 3),
(u_clark, 'fusion-timeline-2024', 10, 2), (u_clark, 'fusion-timeline-2024', 11, 3), (u_clark, 'fusion-timeline-2024', 12, 2),
(u_clark, 'fusion-timeline-2024', 13, 3), (u_clark, 'fusion-timeline-2024', 14, 2), (u_clark, 'fusion-timeline-2024', 15, 3),
(u_clark, 'fusion-timeline-2024', 16, 2), (u_clark, 'fusion-timeline-2024', 17, 3), (u_clark, 'fusion-timeline-2024', 18, 2),
(u_clark, 'fusion-timeline-2024', 19, 2), (u_clark, 'fusion-timeline-2024', 20, 3),
(u_cdk, 'fusion-timeline-2024', 1, 2), (u_cdk, 'fusion-timeline-2024', 2, 2), (u_cdk, 'fusion-timeline-2024', 3, 3),
(u_cdk, 'fusion-timeline-2024', 4, 3), (u_cdk, 'fusion-timeline-2024', 5, 2), (u_cdk, 'fusion-timeline-2024', 6, 3),
(u_cdk, 'fusion-timeline-2024', 7, 2), (u_cdk, 'fusion-timeline-2024', 8, 3), (u_cdk, 'fusion-timeline-2024', 9, 2),
(u_cdk, 'fusion-timeline-2024', 10, 3), (u_cdk, 'fusion-timeline-2024', 11, 2), (u_cdk, 'fusion-timeline-2024', 12, 3),
(u_cdk, 'fusion-timeline-2024', 13, 2), (u_cdk, 'fusion-timeline-2024', 14, 3), (u_cdk, 'fusion-timeline-2024', 15, 2),
(u_cdk, 'fusion-timeline-2024', 16, 3), (u_cdk, 'fusion-timeline-2024', 17, 2), (u_cdk, 'fusion-timeline-2024', 18, 3),
(u_cdk, 'fusion-timeline-2024', 19, 3), (u_cdk, 'fusion-timeline-2024', 20, 2),
(u_vanmeeks, 'fusion-timeline-2024', 1, 3), (u_vanmeeks, 'fusion-timeline-2024', 2, 2), (u_vanmeeks, 'fusion-timeline-2024', 3, 3),
(u_vanmeeks, 'fusion-timeline-2024', 4, 2), (u_vanmeeks, 'fusion-timeline-2024', 5, 3), (u_vanmeeks, 'fusion-timeline-2024', 6, 2),
(u_vanmeeks, 'fusion-timeline-2024', 7, 3), (u_vanmeeks, 'fusion-timeline-2024', 8, 3), (u_vanmeeks, 'fusion-timeline-2024', 9, 2),
(u_vanmeeks, 'fusion-timeline-2024', 10, 3), (u_vanmeeks, 'fusion-timeline-2024', 11, 3), (u_vanmeeks, 'fusion-timeline-2024', 12, 2),
(u_vanmeeks, 'fusion-timeline-2024', 13, 3), (u_vanmeeks, 'fusion-timeline-2024', 14, 3), (u_vanmeeks, 'fusion-timeline-2024', 15, 2),
(u_vanmeeks, 'fusion-timeline-2024', 16, 3), (u_vanmeeks, 'fusion-timeline-2024', 17, 2), (u_vanmeeks, 'fusion-timeline-2024', 18, 3),
(u_vanmeeks, 'fusion-timeline-2024', 19, 2), (u_vanmeeks, 'fusion-timeline-2024', 20, 3)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- GRUSCH (MILITARY) - 4 scorers, avg ~3.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'grusch-2024', 1, 4), (u_clark, 'grusch-2024', 2, 3), (u_clark, 'grusch-2024', 3, 3),
(u_clark, 'grusch-2024', 4, 5), (u_clark, 'grusch-2024', 5, 4), (u_clark, 'grusch-2024', 6, 5),
(u_clark, 'grusch-2024', 7, 3), (u_clark, 'grusch-2024', 8, 4), (u_clark, 'grusch-2024', 9, 4),
(u_clark, 'grusch-2024', 10, 4), (u_clark, 'grusch-2024', 11, 3), (u_clark, 'grusch-2024', 12, 3),
(u_clark, 'grusch-2024', 13, 4), (u_clark, 'grusch-2024', 14, 3), (u_clark, 'grusch-2024', 15, 4),
(u_clark, 'grusch-2024', 16, 3), (u_clark, 'grusch-2024', 17, 3), (u_clark, 'grusch-2024', 18, 4),
(u_clark, 'grusch-2024', 19, 4), (u_clark, 'grusch-2024', 20, 4),
(u_evan, 'grusch-2024', 1, 4), (u_evan, 'grusch-2024', 2, 4), (u_evan, 'grusch-2024', 3, 3),
(u_evan, 'grusch-2024', 4, 4), (u_evan, 'grusch-2024', 5, 3), (u_evan, 'grusch-2024', 6, 4),
(u_evan, 'grusch-2024', 7, 4), (u_evan, 'grusch-2024', 8, 3), (u_evan, 'grusch-2024', 9, 3),
(u_evan, 'grusch-2024', 10, 3), (u_evan, 'grusch-2024', 11, 4), (u_evan, 'grusch-2024', 12, 3),
(u_evan, 'grusch-2024', 13, 3), (u_evan, 'grusch-2024', 14, 4), (u_evan, 'grusch-2024', 15, 3),
(u_evan, 'grusch-2024', 16, 4), (u_evan, 'grusch-2024', 17, 3), (u_evan, 'grusch-2024', 18, 3),
(u_evan, 'grusch-2024', 19, 3), (u_evan, 'grusch-2024', 20, 4),
(u_randy, 'grusch-2024', 1, 3), (u_randy, 'grusch-2024', 2, 3), (u_randy, 'grusch-2024', 3, 4),
(u_randy, 'grusch-2024', 4, 4), (u_randy, 'grusch-2024', 5, 4), (u_randy, 'grusch-2024', 6, 4),
(u_randy, 'grusch-2024', 7, 3), (u_randy, 'grusch-2024', 8, 4), (u_randy, 'grusch-2024', 9, 3),
(u_randy, 'grusch-2024', 10, 3), (u_randy, 'grusch-2024', 11, 3), (u_randy, 'grusch-2024', 12, 4),
(u_randy, 'grusch-2024', 13, 3), (u_randy, 'grusch-2024', 14, 3), (u_randy, 'grusch-2024', 15, 4),
(u_randy, 'grusch-2024', 16, 3), (u_randy, 'grusch-2024', 17, 4), (u_randy, 'grusch-2024', 18, 3),
(u_randy, 'grusch-2024', 19, 4), (u_randy, 'grusch-2024', 20, 3),
(u_fadeto, 'grusch-2024', 1, 3), (u_fadeto, 'grusch-2024', 2, 4), (u_fadeto, 'grusch-2024', 3, 3),
(u_fadeto, 'grusch-2024', 4, 4), (u_fadeto, 'grusch-2024', 5, 3), (u_fadeto, 'grusch-2024', 6, 5),
(u_fadeto, 'grusch-2024', 7, 3), (u_fadeto, 'grusch-2024', 8, 3), (u_fadeto, 'grusch-2024', 9, 4),
(u_fadeto, 'grusch-2024', 10, 4), (u_fadeto, 'grusch-2024', 11, 3), (u_fadeto, 'grusch-2024', 12, 4),
(u_fadeto, 'grusch-2024', 13, 4), (u_fadeto, 'grusch-2024', 14, 3), (u_fadeto, 'grusch-2024', 15, 3),
(u_fadeto, 'grusch-2024', 16, 4), (u_fadeto, 'grusch-2024', 17, 3), (u_fadeto, 'grusch-2024', 18, 4),
(u_fadeto, 'grusch-2024', 19, 3), (u_fadeto, 'grusch-2024', 20, 4)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- NIMITZ (MILITARY) - 4 scorers, avg ~3.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_clark, 'nimitz-2004', 1, 4), (u_clark, 'nimitz-2004', 2, 3), (u_clark, 'nimitz-2004', 3, 3),
(u_clark, 'nimitz-2004', 4, 5), (u_clark, 'nimitz-2004', 5, 4), (u_clark, 'nimitz-2004', 6, 5),
(u_clark, 'nimitz-2004', 7, 4), (u_clark, 'nimitz-2004', 8, 3), (u_clark, 'nimitz-2004', 9, 4),
(u_clark, 'nimitz-2004', 10, 4), (u_clark, 'nimitz-2004', 11, 3), (u_clark, 'nimitz-2004', 12, 3),
(u_clark, 'nimitz-2004', 13, 4), (u_clark, 'nimitz-2004', 14, 4), (u_clark, 'nimitz-2004', 15, 3),
(u_clark, 'nimitz-2004', 16, 3), (u_clark, 'nimitz-2004', 17, 4), (u_clark, 'nimitz-2004', 18, 4),
(u_clark, 'nimitz-2004', 19, 4), (u_clark, 'nimitz-2004', 20, 4),
(u_evan, 'nimitz-2004', 1, 3), (u_evan, 'nimitz-2004', 2, 4), (u_evan, 'nimitz-2004', 3, 4),
(u_evan, 'nimitz-2004', 4, 4), (u_evan, 'nimitz-2004', 5, 3), (u_evan, 'nimitz-2004', 6, 4),
(u_evan, 'nimitz-2004', 7, 3), (u_evan, 'nimitz-2004', 8, 4), (u_evan, 'nimitz-2004', 9, 3),
(u_evan, 'nimitz-2004', 10, 4), (u_evan, 'nimitz-2004', 11, 4), (u_evan, 'nimitz-2004', 12, 3),
(u_evan, 'nimitz-2004', 13, 3), (u_evan, 'nimitz-2004', 14, 4), (u_evan, 'nimitz-2004', 15, 4),
(u_evan, 'nimitz-2004', 16, 3), (u_evan, 'nimitz-2004', 17, 3), (u_evan, 'nimitz-2004', 18, 3),
(u_evan, 'nimitz-2004', 19, 4), (u_evan, 'nimitz-2004', 20, 3),
(u_randy, 'nimitz-2004', 1, 4), (u_randy, 'nimitz-2004', 2, 3), (u_randy, 'nimitz-2004', 3, 3),
(u_randy, 'nimitz-2004', 4, 4), (u_randy, 'nimitz-2004', 5, 4), (u_randy, 'nimitz-2004', 6, 4),
(u_randy, 'nimitz-2004', 7, 3), (u_randy, 'nimitz-2004', 8, 4), (u_randy, 'nimitz-2004', 9, 4),
(u_randy, 'nimitz-2004', 10, 3), (u_randy, 'nimitz-2004', 11, 3), (u_randy, 'nimitz-2004', 12, 4),
(u_randy, 'nimitz-2004', 13, 4), (u_randy, 'nimitz-2004', 14, 3), (u_randy, 'nimitz-2004', 15, 3),
(u_randy, 'nimitz-2004', 16, 4), (u_randy, 'nimitz-2004', 17, 4), (u_randy, 'nimitz-2004', 18, 3),
(u_randy, 'nimitz-2004', 19, 3), (u_randy, 'nimitz-2004', 20, 4),
(u_cdk, 'nimitz-2004', 1, 4), (u_cdk, 'nimitz-2004', 2, 4), (u_cdk, 'nimitz-2004', 3, 3),
(u_cdk, 'nimitz-2004', 4, 5), (u_cdk, 'nimitz-2004', 5, 4), (u_cdk, 'nimitz-2004', 6, 4),
(u_cdk, 'nimitz-2004', 7, 4), (u_cdk, 'nimitz-2004', 8, 3), (u_cdk, 'nimitz-2004', 9, 4),
(u_cdk, 'nimitz-2004', 10, 4), (u_cdk, 'nimitz-2004', 11, 4), (u_cdk, 'nimitz-2004', 12, 3),
(u_cdk, 'nimitz-2004', 13, 4), (u_cdk, 'nimitz-2004', 14, 4), (u_cdk, 'nimitz-2004', 15, 4),
(u_cdk, 'nimitz-2004', 16, 3), (u_cdk, 'nimitz-2004', 17, 4), (u_cdk, 'nimitz-2004', 18, 4),
(u_cdk, 'nimitz-2004', 19, 4), (u_cdk, 'nimitz-2004', 20, 4)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

-- ---- WILSON MEMO (MILITARY) - 3 scorers, avg ~3.5 ----
INSERT INTO user_scores (user_id, target_id, metric_id, score) VALUES
(u_evan, 'wilson-memo', 1, 3), (u_evan, 'wilson-memo', 2, 4), (u_evan, 'wilson-memo', 3, 3),
(u_evan, 'wilson-memo', 4, 5), (u_evan, 'wilson-memo', 5, 3), (u_evan, 'wilson-memo', 6, 5),
(u_evan, 'wilson-memo', 7, 3), (u_evan, 'wilson-memo', 8, 4), (u_evan, 'wilson-memo', 9, 3),
(u_evan, 'wilson-memo', 10, 4), (u_evan, 'wilson-memo', 11, 3), (u_evan, 'wilson-memo', 12, 3),
(u_evan, 'wilson-memo', 13, 4), (u_evan, 'wilson-memo', 14, 3), (u_evan, 'wilson-memo', 15, 4),
(u_evan, 'wilson-memo', 16, 4), (u_evan, 'wilson-memo', 17, 3), (u_evan, 'wilson-memo', 18, 4),
(u_evan, 'wilson-memo', 19, 3), (u_evan, 'wilson-memo', 20, 4),
(u_randy, 'wilson-memo', 1, 4), (u_randy, 'wilson-memo', 2, 3), (u_randy, 'wilson-memo', 3, 4),
(u_randy, 'wilson-memo', 4, 4), (u_randy, 'wilson-memo', 5, 4), (u_randy, 'wilson-memo', 6, 4),
(u_randy, 'wilson-memo', 7, 3), (u_randy, 'wilson-memo', 8, 3), (u_randy, 'wilson-memo', 9, 4),
(u_randy, 'wilson-memo', 10, 3), (u_randy, 'wilson-memo', 11, 4), (u_randy, 'wilson-memo', 12, 3),
(u_randy, 'wilson-memo', 13, 3), (u_randy, 'wilson-memo', 14, 4), (u_randy, 'wilson-memo', 15, 3),
(u_randy, 'wilson-memo', 16, 3), (u_randy, 'wilson-memo', 17, 4), (u_randy, 'wilson-memo', 18, 3),
(u_randy, 'wilson-memo', 19, 4), (u_randy, 'wilson-memo', 20, 3),
(u_fadeto, 'wilson-memo', 1, 3), (u_fadeto, 'wilson-memo', 2, 3), (u_fadeto, 'wilson-memo', 3, 3),
(u_fadeto, 'wilson-memo', 4, 4), (u_fadeto, 'wilson-memo', 5, 3), (u_fadeto, 'wilson-memo', 6, 4),
(u_fadeto, 'wilson-memo', 7, 4), (u_fadeto, 'wilson-memo', 8, 3), (u_fadeto, 'wilson-memo', 9, 3),
(u_fadeto, 'wilson-memo', 10, 4), (u_fadeto, 'wilson-memo', 11, 3), (u_fadeto, 'wilson-memo', 12, 4),
(u_fadeto, 'wilson-memo', 13, 3), (u_fadeto, 'wilson-memo', 14, 3), (u_fadeto, 'wilson-memo', 15, 4),
(u_fadeto, 'wilson-memo', 16, 3), (u_fadeto, 'wilson-memo', 17, 3), (u_fadeto, 'wilson-memo', 18, 4),
(u_fadeto, 'wilson-memo', 19, 3), (u_fadeto, 'wilson-memo', 20, 3)
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET score = EXCLUDED.score;

END $$;

-- =============================================================================
-- 4. SEED COMMUNITY VOTES (subset of targets, 2-3 voters each)
-- =============================================================================

INSERT INTO community_votes (user_id, target_id, metric_id, vote_value, confidence_level, rationale) VALUES
-- Fed Rate votes
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'fed-rate-2024', 1, 5, 'high', 'CME FedWatch provides precise probability distributions'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'fed-rate-2024', 5, 5, 'high', 'Multiple named institutions with track records'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'fed-rate-2024', 14, 5, 'high', 'Fully verifiable via FRED and historical rate data'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'fed-rate-2024', 1, 4, 'high', 'Specific rate predictions with confidence intervals'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'fed-rate-2024', 5, 4, 'medium', 'Well-attributed to known sources'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'fed-rate-2024', 14, 5, 'high', 'Historically verifiable outcomes'),
('05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'fed-rate-2024', 1, 4, 'medium', 'Good specificity but assumptions embedded'),
('05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'fed-rate-2024', 14, 4, 'high', 'Rate decisions are public record'),
-- Election votes
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'election-2024', 1, 4, 'high', 'Polling aggregation is well-established'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'election-2024', 14, 5, 'high', 'Election results are definitively verifiable'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'election-2024', 1, 5, 'medium', 'Multiple data sources with clear methodology'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'election-2024', 7, 3, 'medium', 'Some narrative bias in aggregation methods'),
('f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'election-2024', 14, 5, 'high', 'Binary outcome - fully verifiable'),
-- Grusch votes
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'grusch-2024', 4, 5, 'high', 'First-hand IC whistleblower testimony under oath'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'grusch-2024', 6, 5, 'high', 'Significant personal and career risk taken'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'grusch-2024', 4, 4, 'medium', 'Novel claims but builds on prior disclosures'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'grusch-2024', 6, 4, 'high', 'Career consequences are documented'),
('05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'grusch-2024', 14, 3, 'low', 'Claims are difficult to independently verify'),
('05fedb7a-8f5d-40a2-8646-58abb439d1a2', 'grusch-2024', 6, 5, 'high', 'Undeniable personal risk'),
-- Nimitz votes
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'nimitz-2004', 4, 5, 'high', 'Multiple sensor modalities captured the event'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'nimitz-2004', 6, 5, 'high', 'Military careers at stake for witnesses'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'nimitz-2004', 4, 4, 'high', 'FLIR video is public and authenticated'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'nimitz-2004', 14, 4, 'medium', 'Some radar data still classified'),
-- Bitcoin votes (low confidence)
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'bitcoin-eoy-2024', 1, 2, 'low', 'Wide range of predictions - low specificity'),
('d9eb0f55-dea4-4659-b277-e300f6eddbbf', 'bitcoin-eoy-2024', 14, 3, 'medium', 'Price is verifiable but predictions are vague'),
('4f308a61-8fde-4783-b1a6-4f1712061da5', 'bitcoin-eoy-2024', 7, 2, 'low', 'Heavy narrative and hype influence'),
-- AGI votes
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'agi-timeline-2024', 1, 3, 'low', 'Definition of AGI itself is contested'),
('132fdb5d-3a06-406c-a87b-570b56028a4a', 'agi-timeline-2024', 17, 2, 'low', 'No historical precedent for this prediction'),
('f9364e53-91f2-4a3d-949f-aefd5f68f1c0', 'agi-timeline-2024', 4, 5, 'medium', 'Highly novel topic with significant implications')
ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET vote_value = EXCLUDED.vote_value, confidence_level = EXCLUDED.confidence_level, rationale = EXCLUDED.rationale;

-- =============================================================================
-- 5. VERIFY
-- =============================================================================

-- Counts for verification (will print during execution)
DO $$
DECLARE
    sc INT; vc INT; tc INT;
BEGIN
    SELECT count(*) INTO sc FROM user_scores WHERE target_id IN (SELECT id FROM targets);
    SELECT count(*) INTO vc FROM community_votes WHERE target_id IN (SELECT id FROM targets);
    SELECT count(*) INTO tc FROM targets;
    RAISE NOTICE 'Seed complete: % targets, % scores, % community votes', tc, sc, vc;
END $$;

COMMIT;
