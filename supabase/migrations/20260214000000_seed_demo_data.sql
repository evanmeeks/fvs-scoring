-- =====================================================================
-- Seed demo data for portfolio demonstration
-- Migration: 20260214000000_seed_demo_data.sql
--
-- Creates:
--   - 3 demo user accounts (admin, contributor, user)
--   - User scores across 9 targets × 20 metrics
--   - Community votes with confidence levels
--   - 5 RFC proposals with varied statuses
--   - RFC votes from demo users
--   - 15+ metric discussion comments with threading
-- =====================================================================

-- =====================================================================
-- 1. DEMO AUTH USERS
-- =====================================================================
-- On hosted Supabase these were created via Auth Admin API.
-- On local Supabase (db reset) we have full access to auth.users.
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, raw_app_meta_data, raw_user_meta_data)
VALUES
  ('a0000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'demo@forecastaudit.pro', crypt('demo-password-123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '{"provider":"email","providers":["email"]}', '{"display_name":"Demo Admin"}'),
  ('a0000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'analyst@forecastaudit.pro', crypt('demo-password-123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '{"provider":"email","providers":["email"]}', '{"display_name":"Demo Analyst"}'),
  ('a0000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'viewer@forecastaudit.pro', crypt('demo-password-123', gen_salt('bf')), NOW(), NOW(), NOW(), '', '{"provider":"email","providers":["email"]}', '{"display_name":"Demo Viewer"}')
ON CONFLICT (id) DO NOTHING;

-- =====================================================================
-- 2-7. SEED ALL PUBLIC TABLE DATA
-- =====================================================================

DO $$
DECLARE
    demo_admin_id    UUID := 'a0000000-0000-0000-0000-000000000001';
    demo_analyst_id  UUID := 'a0000000-0000-0000-0000-000000000002';
    demo_viewer_id   UUID := 'a0000000-0000-0000-0000-000000000003';

    -- Target IDs (from 20260125000000_seed_public_targets.sql)
    t_fed       TEXT := 'fed-rate-2024';
    t_election  TEXT := 'election-2024';
    t_agi       TEXT := 'agi-timeline-2024';
    t_recession TEXT := 'recession-2024';
    t_climate   TEXT := 'climate-temp-2024';
    t_spacex    TEXT := 'spacex-orbital-2024';
    t_bitcoin   TEXT := 'bitcoin-eoy-2024';
    t_pandemic  TEXT := 'pandemic-timeline-2024';
    t_fusion    TEXT := 'fusion-timeline-2024';

    -- RFC proposal IDs
    rfc1_id UUID := 'b0000000-0000-0000-0000-000000000001';
    rfc2_id UUID := 'b0000000-0000-0000-0000-000000000002';
    rfc3_id UUID := 'b0000000-0000-0000-0000-000000000003';
    rfc4_id UUID := 'b0000000-0000-0000-0000-000000000004';
    rfc5_id UUID := 'b0000000-0000-0000-0000-000000000005';

    -- Discussion IDs
    d1  UUID := 'c0000000-0000-0000-0000-000000000001';
    d2  UUID := 'c0000000-0000-0000-0000-000000000002';
    d3  UUID := 'c0000000-0000-0000-0000-000000000003';
    d4  UUID := 'c0000000-0000-0000-0000-000000000004';
    d5  UUID := 'c0000000-0000-0000-0000-000000000005';
    d6  UUID := 'c0000000-0000-0000-0000-000000000006';
    d7  UUID := 'c0000000-0000-0000-0000-000000000007';
    d8  UUID := 'c0000000-0000-0000-0000-000000000008';
    d9  UUID := 'c0000000-0000-0000-0000-000000000009';
    d10 UUID := 'c0000000-0000-0000-0000-000000000010';
    d11 UUID := 'c0000000-0000-0000-0000-000000000011';
    d12 UUID := 'c0000000-0000-0000-0000-000000000012';
    d13 UUID := 'c0000000-0000-0000-0000-000000000013';
    d14 UUID := 'c0000000-0000-0000-0000-000000000014';
    d15 UUID := 'c0000000-0000-0000-0000-000000000015';
BEGIN

-- =====================================================================
-- 2. CREATE USER PROFILES (bypassing trigger for full control)
-- =====================================================================

INSERT INTO public.user_profiles (
    user_id, role, full_name, contributor_id, pseudonym,
    anonymous, last_pseudonym_change, created_at, updated_at
) VALUES
    (demo_admin_id, 'admin', 'Demo Admin', 'FVS-0901', 'Operator_Alpha',
     false, NOW() - INTERVAL '30 days', NOW() - INTERVAL '30 days', NOW()),
    (demo_analyst_id, 'contributor', 'Dr. Sarah Chen', 'FVS-0902', 'Calibration_Lead',
     false, NOW() - INTERVAL '25 days', NOW() - INTERVAL '25 days', NOW()),
    (demo_viewer_id, 'user', 'Marcus Rivera', 'FVS-0903', 'Signal_Analyst',
     true, NOW() - INTERVAL '20 days', NOW() - INTERVAL '20 days', NOW())
ON CONFLICT (user_id) DO UPDATE SET
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name,
    contributor_id = EXCLUDED.contributor_id,
    pseudonym = EXCLUDED.pseudonym;


-- =====================================================================
-- 3. SEED USER SCORES (populates target_score_aggregates view)
-- =====================================================================
-- Score patterns vary by target quality and user expertise.
-- Scale: 1 (Absent) to 5 (Strong). 0 = not scored.

-- Fed Rate Trajectory — HIGH QUALITY forecast (scores: 3-5)
INSERT INTO public.user_scores (user_id, target_id, metric_id, score, notes) VALUES
    -- Demo Admin scores Fed Rate
    (demo_admin_id, t_fed, 1, 5, 'Precise interest rate predictions with defined thresholds'),
    (demo_admin_id, t_fed, 2, 4, 'Strong causal model linking economic indicators'),
    (demo_admin_id, t_fed, 3, 5, 'Directly actionable for bond traders'),
    (demo_admin_id, t_fed, 4, 3, 'Consensus view, limited novelty'),
    (demo_admin_id, t_fed, 5, 5, 'Fed data + Polymarket odds well-documented'),
    (demo_admin_id, t_fed, 6, 4, 'Polymarket has strong track record'),
    (demo_admin_id, t_fed, 7, 4, 'Data-driven with some narrative framing'),
    (demo_admin_id, t_fed, 8, 5, 'Directly tied to prediction market prices'),
    (demo_admin_id, t_fed, 9, 5, 'Meeting-by-meeting resolution dates'),
    (demo_admin_id, t_fed, 10, 4, 'Transparent methodology from CME FedWatch'),
    (demo_admin_id, t_fed, 11, 4, 'Regular updates with FOMC minutes'),
    (demo_admin_id, t_fed, 12, 3, 'Market maker incentives not fully disclosed'),
    (demo_admin_id, t_fed, 13, 4, 'High signal density from economic data'),
    (demo_admin_id, t_fed, 14, 5, 'Verifiable against actual Fed decisions'),
    (demo_admin_id, t_fed, 15, 5, 'Clear resolution criteria'),
    (demo_admin_id, t_fed, 16, 3, 'Consensus-driven, not contrarian'),
    (demo_admin_id, t_fed, 17, 5, 'Excellent base rate from historical Fed data'),
    (demo_admin_id, t_fed, 18, 4, 'Robust under rate shock scenarios'),
    (demo_admin_id, t_fed, 19, 4, 'Part of systematic macro framework'),
    (demo_admin_id, t_fed, 20, 5, 'High predictive value for fixed income'),
    -- Analyst scores Fed Rate
    (demo_analyst_id, t_fed, 1, 4, NULL),
    (demo_analyst_id, t_fed, 2, 5, NULL),
    (demo_analyst_id, t_fed, 3, 5, NULL),
    (demo_analyst_id, t_fed, 4, 4, NULL),
    (demo_analyst_id, t_fed, 5, 4, NULL),
    (demo_analyst_id, t_fed, 6, 5, NULL),
    (demo_analyst_id, t_fed, 7, 4, NULL),
    (demo_analyst_id, t_fed, 8, 5, NULL),
    (demo_analyst_id, t_fed, 9, 4, NULL),
    (demo_analyst_id, t_fed, 10, 5, NULL),
    (demo_analyst_id, t_fed, 11, 5, NULL),
    (demo_analyst_id, t_fed, 12, 4, NULL),
    (demo_analyst_id, t_fed, 13, 5, NULL),
    (demo_analyst_id, t_fed, 14, 5, NULL),
    (demo_analyst_id, t_fed, 15, 4, NULL),
    (demo_analyst_id, t_fed, 16, 4, NULL),
    (demo_analyst_id, t_fed, 17, 4, NULL),
    (demo_analyst_id, t_fed, 18, 5, NULL),
    (demo_analyst_id, t_fed, 19, 5, NULL),
    (demo_analyst_id, t_fed, 20, 5, NULL),

    -- Election 2024 — HIGH QUALITY (scores: 3-5)
    (demo_admin_id, t_election, 1, 4, 'Clear win/loss resolution criteria'),
    (demo_admin_id, t_election, 2, 3, 'Complex causal chain in elections'),
    (demo_admin_id, t_election, 3, 5, 'Highly actionable for political markets'),
    (demo_admin_id, t_election, 4, 4, 'Unique aggregation methodology'),
    (demo_admin_id, t_election, 5, 5, 'Polling data fully transparent'),
    (demo_admin_id, t_election, 6, 4, '538 has documented calibration'),
    (demo_admin_id, t_election, 7, 3, 'Some partisan framing in sources'),
    (demo_admin_id, t_election, 8, 5, 'PredictIt / Polymarket alignment'),
    (demo_admin_id, t_election, 9, 5, 'Election day is fixed'),
    (demo_admin_id, t_election, 10, 4, 'Bayesian models are published'),
    (demo_admin_id, t_election, 11, 4, 'Daily polling updates'),
    (demo_admin_id, t_election, 12, 3, 'Media outlet biases present'),
    (demo_admin_id, t_election, 13, 4, 'Strong signal from polling averages'),
    (demo_admin_id, t_election, 14, 5, 'Election results are public'),
    (demo_admin_id, t_election, 15, 5, 'Binary outcome'),
    (demo_admin_id, t_election, 16, 4, 'Diverges from individual polls'),
    (demo_admin_id, t_election, 17, 4, 'Historical election data available'),
    (demo_admin_id, t_election, 18, 3, 'Black swan events hard to model'),
    (demo_admin_id, t_election, 19, 4, 'Systematic forecasting program'),
    (demo_admin_id, t_election, 20, 5, 'Very high predictive value'),
    (demo_analyst_id, t_election, 1, 5, NULL),
    (demo_analyst_id, t_election, 2, 4, NULL),
    (demo_analyst_id, t_election, 3, 4, NULL),
    (demo_analyst_id, t_election, 4, 3, NULL),
    (demo_analyst_id, t_election, 5, 5, NULL),
    (demo_analyst_id, t_election, 6, 5, NULL),
    (demo_analyst_id, t_election, 7, 4, NULL),
    (demo_analyst_id, t_election, 8, 4, NULL),
    (demo_analyst_id, t_election, 9, 5, NULL),
    (demo_analyst_id, t_election, 10, 4, NULL),
    (demo_analyst_id, t_election, 11, 5, NULL),
    (demo_analyst_id, t_election, 12, 3, NULL),
    (demo_analyst_id, t_election, 13, 4, NULL),
    (demo_analyst_id, t_election, 14, 5, NULL),
    (demo_analyst_id, t_election, 15, 5, NULL),
    (demo_analyst_id, t_election, 16, 3, NULL),
    (demo_analyst_id, t_election, 17, 5, NULL),
    (demo_analyst_id, t_election, 18, 4, NULL),
    (demo_analyst_id, t_election, 19, 4, NULL),
    (demo_analyst_id, t_election, 20, 4, NULL),

    -- AGI Timeline — MIXED QUALITY (scores: 2-4)
    (demo_admin_id, t_agi, 1, 2, 'Vague definitions of AGI'),
    (demo_admin_id, t_agi, 2, 2, 'Causal mechanisms poorly understood'),
    (demo_admin_id, t_agi, 3, 3, 'Some investment relevance'),
    (demo_admin_id, t_agi, 4, 4, 'Novel expert survey data'),
    (demo_admin_id, t_agi, 5, 3, 'Survey methodology documented'),
    (demo_admin_id, t_agi, 6, 2, 'No historical track record for AGI forecasts'),
    (demo_admin_id, t_agi, 7, 2, 'Heavy narrative bias in AI discourse'),
    (demo_admin_id, t_agi, 8, 3, 'Metaculus markets exist but thin'),
    (demo_admin_id, t_agi, 9, 2, 'Timeline is decades-wide'),
    (demo_admin_id, t_agi, 10, 3, 'Survey methods published'),
    (demo_admin_id, t_agi, 11, 2, 'Infrequent updates'),
    (demo_admin_id, t_agi, 12, 2, 'Commercial AI interests not disclosed'),
    (demo_admin_id, t_agi, 13, 2, 'Low signal among AI hype'),
    (demo_admin_id, t_agi, 14, 2, 'Hard to verify without clear AGI definition'),
    (demo_admin_id, t_agi, 15, 2, 'Fuzzy resolution criteria'),
    (demo_admin_id, t_agi, 16, 3, 'Some independent analysis'),
    (demo_admin_id, t_agi, 17, 1, 'No historical base rate for AGI'),
    (demo_admin_id, t_agi, 18, 2, 'Fragile under definitional scrutiny'),
    (demo_admin_id, t_agi, 19, 2, 'Mostly ad-hoc predictions'),
    (demo_admin_id, t_agi, 20, 2, 'Low net predictive value'),
    (demo_analyst_id, t_agi, 1, 3, NULL),
    (demo_analyst_id, t_agi, 2, 2, NULL),
    (demo_analyst_id, t_agi, 3, 3, NULL),
    (demo_analyst_id, t_agi, 4, 3, NULL),
    (demo_analyst_id, t_agi, 5, 4, NULL),
    (demo_analyst_id, t_agi, 6, 2, NULL),
    (demo_analyst_id, t_agi, 7, 3, NULL),
    (demo_analyst_id, t_agi, 8, 2, NULL),
    (demo_analyst_id, t_agi, 9, 2, NULL),
    (demo_analyst_id, t_agi, 10, 3, NULL),
    (demo_analyst_id, t_agi, 11, 3, NULL),
    (demo_analyst_id, t_agi, 12, 2, NULL),
    (demo_analyst_id, t_agi, 13, 3, NULL),
    (demo_analyst_id, t_agi, 14, 2, NULL),
    (demo_analyst_id, t_agi, 15, 3, NULL),
    (demo_analyst_id, t_agi, 16, 4, NULL),
    (demo_analyst_id, t_agi, 17, 2, NULL),
    (demo_analyst_id, t_agi, 18, 2, NULL),
    (demo_analyst_id, t_agi, 19, 3, NULL),
    (demo_analyst_id, t_agi, 20, 3, NULL),

    -- Recession 2024-2025 — HIGH QUALITY (scores: 3-5)
    (demo_admin_id, t_recession, 1, 4, NULL),
    (demo_admin_id, t_recession, 2, 5, NULL),
    (demo_admin_id, t_recession, 3, 5, NULL),
    (demo_admin_id, t_recession, 4, 3, NULL),
    (demo_admin_id, t_recession, 5, 5, NULL),
    (demo_admin_id, t_recession, 6, 4, NULL),
    (demo_admin_id, t_recession, 7, 4, NULL),
    (demo_admin_id, t_recession, 8, 4, NULL),
    (demo_admin_id, t_recession, 9, 4, NULL),
    (demo_admin_id, t_recession, 10, 5, NULL),
    (demo_admin_id, t_recession, 11, 4, NULL),
    (demo_admin_id, t_recession, 12, 3, NULL),
    (demo_admin_id, t_recession, 13, 4, NULL),
    (demo_admin_id, t_recession, 14, 4, NULL),
    (demo_admin_id, t_recession, 15, 4, NULL),
    (demo_admin_id, t_recession, 16, 4, NULL),
    (demo_admin_id, t_recession, 17, 5, NULL),
    (demo_admin_id, t_recession, 18, 4, NULL),
    (demo_admin_id, t_recession, 19, 5, NULL),
    (demo_admin_id, t_recession, 20, 4, NULL),
    (demo_viewer_id, t_recession, 1, 4, NULL),
    (demo_viewer_id, t_recession, 2, 4, NULL),
    (demo_viewer_id, t_recession, 3, 4, NULL),
    (demo_viewer_id, t_recession, 4, 3, NULL),
    (demo_viewer_id, t_recession, 5, 4, NULL),
    (demo_viewer_id, t_recession, 6, 3, NULL),
    (demo_viewer_id, t_recession, 7, 4, NULL),
    (demo_viewer_id, t_recession, 8, 4, NULL),
    (demo_viewer_id, t_recession, 9, 3, NULL),
    (demo_viewer_id, t_recession, 10, 4, NULL),
    (demo_viewer_id, t_recession, 11, 3, NULL),
    (demo_viewer_id, t_recession, 12, 3, NULL),
    (demo_viewer_id, t_recession, 13, 4, NULL),
    (demo_viewer_id, t_recession, 14, 4, NULL),
    (demo_viewer_id, t_recession, 15, 3, NULL),
    (demo_viewer_id, t_recession, 16, 3, NULL),
    (demo_viewer_id, t_recession, 17, 4, NULL),
    (demo_viewer_id, t_recession, 18, 3, NULL),
    (demo_viewer_id, t_recession, 19, 4, NULL),
    (demo_viewer_id, t_recession, 20, 4, NULL),

    -- Climate — HIGH QUALITY scientific forecast (4-5)
    (demo_analyst_id, t_climate, 1, 5, NULL),
    (demo_analyst_id, t_climate, 2, 5, NULL),
    (demo_analyst_id, t_climate, 3, 4, NULL),
    (demo_analyst_id, t_climate, 4, 3, NULL),
    (demo_analyst_id, t_climate, 5, 5, NULL),
    (demo_analyst_id, t_climate, 6, 5, NULL),
    (demo_analyst_id, t_climate, 7, 5, NULL),
    (demo_analyst_id, t_climate, 8, 3, NULL),
    (demo_analyst_id, t_climate, 9, 4, NULL),
    (demo_analyst_id, t_climate, 10, 5, NULL),
    (demo_analyst_id, t_climate, 11, 4, NULL),
    (demo_analyst_id, t_climate, 12, 4, NULL),
    (demo_analyst_id, t_climate, 13, 4, NULL),
    (demo_analyst_id, t_climate, 14, 5, NULL),
    (demo_analyst_id, t_climate, 15, 5, NULL),
    (demo_analyst_id, t_climate, 16, 4, NULL),
    (demo_analyst_id, t_climate, 17, 5, NULL),
    (demo_analyst_id, t_climate, 18, 4, NULL),
    (demo_analyst_id, t_climate, 19, 5, NULL),
    (demo_analyst_id, t_climate, 20, 4, NULL),

    -- SpaceX — MEDIUM QUALITY (2-4)
    (demo_admin_id, t_spacex, 1, 4, NULL),
    (demo_admin_id, t_spacex, 2, 3, NULL),
    (demo_admin_id, t_spacex, 3, 3, NULL),
    (demo_admin_id, t_spacex, 4, 3, NULL),
    (demo_admin_id, t_spacex, 5, 3, NULL),
    (demo_admin_id, t_spacex, 6, 2, NULL),
    (demo_admin_id, t_spacex, 7, 3, NULL),
    (demo_admin_id, t_spacex, 8, 3, NULL),
    (demo_admin_id, t_spacex, 9, 3, NULL),
    (demo_admin_id, t_spacex, 10, 3, NULL),
    (demo_admin_id, t_spacex, 11, 3, NULL),
    (demo_admin_id, t_spacex, 12, 2, NULL),
    (demo_admin_id, t_spacex, 13, 3, NULL),
    (demo_admin_id, t_spacex, 14, 4, NULL),
    (demo_admin_id, t_spacex, 15, 4, NULL),
    (demo_admin_id, t_spacex, 16, 3, NULL),
    (demo_admin_id, t_spacex, 17, 2, NULL),
    (demo_admin_id, t_spacex, 18, 3, NULL),
    (demo_admin_id, t_spacex, 19, 3, NULL),
    (demo_admin_id, t_spacex, 20, 3, NULL),

    -- Bitcoin — LOWER QUALITY (1-3)
    (demo_viewer_id, t_bitcoin, 1, 3, NULL),
    (demo_viewer_id, t_bitcoin, 2, 2, NULL),
    (demo_viewer_id, t_bitcoin, 3, 3, NULL),
    (demo_viewer_id, t_bitcoin, 4, 2, NULL),
    (demo_viewer_id, t_bitcoin, 5, 2, NULL),
    (demo_viewer_id, t_bitcoin, 6, 1, NULL),
    (demo_viewer_id, t_bitcoin, 7, 1, NULL),
    (demo_viewer_id, t_bitcoin, 8, 3, NULL),
    (demo_viewer_id, t_bitcoin, 9, 3, NULL),
    (demo_viewer_id, t_bitcoin, 10, 2, NULL),
    (demo_viewer_id, t_bitcoin, 11, 2, NULL),
    (demo_viewer_id, t_bitcoin, 12, 1, NULL),
    (demo_viewer_id, t_bitcoin, 13, 2, NULL),
    (demo_viewer_id, t_bitcoin, 14, 3, NULL),
    (demo_viewer_id, t_bitcoin, 15, 3, NULL),
    (demo_viewer_id, t_bitcoin, 16, 2, NULL),
    (demo_viewer_id, t_bitcoin, 17, 1, NULL),
    (demo_viewer_id, t_bitcoin, 18, 1, NULL),
    (demo_viewer_id, t_bitcoin, 19, 1, NULL),
    (demo_viewer_id, t_bitcoin, 20, 2, NULL),

    -- Pandemic Timeline — MEDIUM (2-4)
    (demo_analyst_id, t_pandemic, 1, 3, NULL),
    (demo_analyst_id, t_pandemic, 2, 4, NULL),
    (demo_analyst_id, t_pandemic, 3, 3, NULL),
    (demo_analyst_id, t_pandemic, 4, 4, NULL),
    (demo_analyst_id, t_pandemic, 5, 4, NULL),
    (demo_analyst_id, t_pandemic, 6, 3, NULL),
    (demo_analyst_id, t_pandemic, 7, 4, NULL),
    (demo_analyst_id, t_pandemic, 8, 2, NULL),
    (demo_analyst_id, t_pandemic, 9, 2, NULL),
    (demo_analyst_id, t_pandemic, 10, 4, NULL),
    (demo_analyst_id, t_pandemic, 11, 3, NULL),
    (demo_analyst_id, t_pandemic, 12, 4, NULL),
    (demo_analyst_id, t_pandemic, 13, 3, NULL),
    (demo_analyst_id, t_pandemic, 14, 3, NULL),
    (demo_analyst_id, t_pandemic, 15, 3, NULL),
    (demo_analyst_id, t_pandemic, 16, 4, NULL),
    (demo_analyst_id, t_pandemic, 17, 3, NULL),
    (demo_analyst_id, t_pandemic, 18, 3, NULL),
    (demo_analyst_id, t_pandemic, 19, 3, NULL),
    (demo_analyst_id, t_pandemic, 20, 3, NULL),

    -- Fusion Timeline — LOW QUALITY (1-3)
    (demo_admin_id, t_fusion, 1, 2, NULL),
    (demo_admin_id, t_fusion, 2, 2, NULL),
    (demo_admin_id, t_fusion, 3, 2, NULL),
    (demo_admin_id, t_fusion, 4, 3, NULL),
    (demo_admin_id, t_fusion, 5, 3, NULL),
    (demo_admin_id, t_fusion, 6, 1, NULL),
    (demo_admin_id, t_fusion, 7, 2, NULL),
    (demo_admin_id, t_fusion, 8, 2, NULL),
    (demo_admin_id, t_fusion, 9, 1, NULL),
    (demo_admin_id, t_fusion, 10, 3, NULL),
    (demo_admin_id, t_fusion, 11, 2, NULL),
    (demo_admin_id, t_fusion, 12, 2, NULL),
    (demo_admin_id, t_fusion, 13, 2, NULL),
    (demo_admin_id, t_fusion, 14, 2, NULL),
    (demo_admin_id, t_fusion, 15, 2, NULL),
    (demo_admin_id, t_fusion, 16, 3, NULL),
    (demo_admin_id, t_fusion, 17, 1, NULL),
    (demo_admin_id, t_fusion, 18, 2, NULL),
    (demo_admin_id, t_fusion, 19, 2, NULL),
    (demo_admin_id, t_fusion, 20, 2, NULL)
ON CONFLICT (user_id, target_id, metric_id) DO NOTHING;


-- =====================================================================
-- 4. SEED COMMUNITY VOTES (consensus data for Global Intel page)
-- =====================================================================

INSERT INTO public.community_votes (user_id, target_id, metric_id, vote_value, confidence_level, rationale) VALUES
    -- Fed Rate votes
    (demo_admin_id, t_fed, 1, 5, 'high', 'Precise quantitative thresholds with clear resolution criteria'),
    (demo_admin_id, t_fed, 5, 5, 'high', 'CME FedWatch and Polymarket data fully transparent'),
    (demo_admin_id, t_fed, 9, 5, 'high', 'FOMC meeting dates provide exact resolution windows'),
    (demo_analyst_id, t_fed, 1, 4, 'high', 'Well-defined rate targets'),
    (demo_analyst_id, t_fed, 5, 4, 'medium', 'Good source documentation'),
    (demo_analyst_id, t_fed, 17, 5, 'high', 'Extensive base rate data from Fed history'),
    -- Election votes
    (demo_admin_id, t_election, 1, 4, 'high', 'Binary win/loss outcome'),
    (demo_admin_id, t_election, 9, 5, 'high', 'Fixed election date'),
    (demo_analyst_id, t_election, 6, 5, 'high', '538 has published calibration analysis'),
    (demo_analyst_id, t_election, 14, 5, 'high', 'Results independently verifiable'),
    -- AGI votes (lower confidence)
    (demo_admin_id, t_agi, 1, 2, 'low', 'No agreed definition of AGI makes falsifiability difficult'),
    (demo_analyst_id, t_agi, 7, 2, 'medium', 'AI hype cycle heavily influences forecasts'),
    (demo_viewer_id, t_agi, 17, 1, 'low', 'No historical precedent for AGI'),
    -- Bitcoin votes
    (demo_viewer_id, t_bitcoin, 7, 1, 'low', 'Crypto discourse dominated by narrative and FOMO'),
    (demo_viewer_id, t_bitcoin, 12, 1, 'medium', 'Significant undisclosed financial interests')
ON CONFLICT (user_id, target_id, metric_id) DO NOTHING;


-- =====================================================================
-- 5. SEED RFC PROPOSALS (populates Governance page)
-- =====================================================================

INSERT INTO public.rfc_proposals (
    id, user_id, metric_id, proposal_type,
    proposed_name, proposed_question,
    proposed_min_criteria, proposed_max_criteria,
    proposed_category, rationale, status,
    created_at, updated_at
) VALUES
    -- RFC 1: Approved — Enhance Forecast Specificity
    (rfc1_id, demo_analyst_id, 1, 'modify_existing',
     'Forecast Specificity & Falsifiability',
     'Does the forecast make concrete, falsifiable predictions with measurable resolution criteria?',
     'Vague prediction with no measurable criteria or defined outcomes',
     'Exact measurable criteria, resolution conditions, edge cases defined, with pre-registered methodology',
     'PRECISION',
     'The current metric focuses on specificity but should also require pre-registered resolution criteria to prevent post-hoc rationalization. Adding falsifiability as a core requirement aligns with superforecasting best practices.',
     'approved',
     NOW() - INTERVAL '14 days', NOW() - INTERVAL '7 days'),

    -- RFC 2: Under Review — New Market Liquidity metric
    (rfc2_id, demo_admin_id, NULL, 'new_metric',
     'Market Liquidity Depth',
     'Does the forecast have sufficient prediction market liquidity to reflect genuine price discovery?',
     'No active market or fewer than 10 traders with minimal volume',
     'Deep liquidity with 100+ active traders, tight spreads, and substantial volume confirming price discovery',
     'CALIBRATION',
     'Thin prediction markets can be easily manipulated. A market liquidity metric would help distinguish forecasts backed by genuine crowd wisdom from those with artificially inflated confidence due to low participation.',
     'under_review',
     NOW() - INTERVAL '10 days', NOW() - INTERVAL '3 days'),

    -- RFC 3: Pending — Modify Base Rate Awareness
    (rfc3_id, demo_viewer_id, 17, 'modify_existing',
     'Base Rate Awareness & Reference Class',
     'Are historical base rates and reference class frequencies properly incorporated into the forecast?',
     'Base rate blind: No reference to historical frequency, precedent, or analogous events',
     'Reference class mastery: Rigorous reference class forecasting with multiple historical analogues, base rate adjustment, and documented reasoning',
     'VALUE',
     'The current metric asks about base rates but does not emphasize reference class forecasting methodology. This is critical for avoiding inside view bias.',
     'pending',
     NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),

    -- RFC 4: Rejected — Remove Net Predictive Value
    (rfc4_id, demo_viewer_id, 20, 'modify_existing',
     'Remove Net Predictive Value',
     'N/A — Proposal to remove this metric entirely',
     'N/A', 'N/A',
     'VALUE',
     'This metric overlaps significantly with Forecast Specificity and Actionability. It creates scoring redundancy.',
     'rejected',
     NOW() - INTERVAL '20 days', NOW() - INTERVAL '15 days'),

    -- RFC 5: Pending — New Adversarial Robustness metric
    (rfc5_id, demo_analyst_id, NULL, 'new_metric',
     'Adversarial Robustness',
     'Can the forecast withstand deliberate attempts at manipulation or gaming?',
     'Easily gamed: Single point of failure, no safeguards against manipulation',
     'Manipulation resistant: Multiple independent verification paths, stake-weighted inputs, Sybil resistance',
     'INTEGRITY',
     'As prediction markets grow, forecasts face adversarial manipulation (wash trading, spoofing). We need a metric that evaluates robustness against deliberate gaming.',
     'pending',
     NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days')
ON CONFLICT (id) DO NOTHING;


-- =====================================================================
-- 6. SEED RFC VOTES
-- =====================================================================

INSERT INTO public.rfc_votes (rfc_id, user_id, vote, confidence_level, notes) VALUES
    -- Votes on RFC 1 (approved)
    (rfc1_id, demo_admin_id, 'approve', 'high', 'Strong proposal. Falsifiability is fundamental to forecast quality.'),
    (rfc1_id, demo_viewer_id, 'approve', 'medium', 'Agree with the direction. Pre-registration requirement is important.'),
    -- Votes on RFC 2 (under review)
    (rfc2_id, demo_analyst_id, 'approve', 'high', 'Essential metric. Thin markets are a major source of calibration error.'),
    (rfc2_id, demo_viewer_id, 'abstain', 'low', 'Interesting but may be hard to measure consistently across markets.'),
    -- Votes on RFC 3 (pending)
    (rfc3_id, demo_admin_id, 'approve', 'medium', 'Reference class forecasting is underweighted in the current framework.'),
    -- Votes on RFC 4 (rejected)
    (rfc4_id, demo_admin_id, 'reject', 'high', 'Disagree — Net Predictive Value captures the holistic assessment that other metrics miss.'),
    (rfc4_id, demo_analyst_id, 'reject', 'high', 'This metric serves a unique integrative function.'),
    -- Votes on RFC 5 (pending)
    (rfc5_id, demo_admin_id, 'approve', 'medium', 'Important consideration as markets scale. Needs more concrete scoring criteria.')
ON CONFLICT (rfc_id, user_id) DO NOTHING;


-- =====================================================================
-- 7. SEED METRIC DISCUSSIONS (threaded comments)
-- =====================================================================

INSERT INTO public.metric_discussions (
    id, metric_id, user_id, comment, parent_id, upvotes, downvotes, created_at
) VALUES
    -- Metric 1: Forecast Specificity — 4 comments + 2 replies
    (d1, 1, demo_analyst_id,
     'The distinction between "specific" and "falsifiable" is crucial here. A prediction can be very specific ("Bitcoin will hit $100K by December") but still unfalsifiable if the forecaster adds escape clauses ("unless market conditions change significantly").',
     NULL, 7, 0, NOW() - INTERVAL '12 days'),
    (d2, 1, demo_admin_id,
     'Agreed. We should consider adding a sub-criterion that penalizes hedging language. The best forecasts commit to concrete numbers with defined resolution dates.',
     d1, 4, 0, NOW() - INTERVAL '11 days'),
    (d3, 1, demo_viewer_id,
     'What about probabilistic forecasts? Saying "70% chance of X by Y date" is both specific and properly calibrated, but it''s not falsifiable in the traditional sense with a single observation.',
     d1, 5, 1, NOW() - INTERVAL '10 days'),
    (d4, 1, demo_analyst_id,
     'Good point. Probabilistic forecasts should be evaluated by calibration over many predictions, not individual outcomes. The Brier score handles this well.',
     d3, 3, 0, NOW() - INTERVAL '9 days'),

    -- Metric 6: Forecaster Track Record — 3 comments
    (d5, 6, demo_admin_id,
     'Track record is arguably the single most important metric. A forecaster with a documented Brier score below 0.2 should get an automatic high score here regardless of the specific prediction.',
     NULL, 8, 2, NOW() - INTERVAL '15 days'),
    (d6, 6, demo_analyst_id,
     'I disagree with automatic scoring. Even skilled forecasters can make poor predictions outside their domain. A climate expert''s political forecast shouldn''t inherit their climate calibration.',
     d5, 6, 0, NOW() - INTERVAL '14 days'),
    (d7, 6, demo_viewer_id,
     'We need to distinguish between domain-specific track records and general forecasting ability. Metaculus leaderboard rankings could be a useful reference point.',
     NULL, 3, 0, NOW() - INTERVAL '8 days'),

    -- Metric 7: Resistance to Bias — 2 comments
    (d8, 7, demo_analyst_id,
     'This metric is extremely hard to score objectively. Everyone thinks their analysis is bias-free. We should focus on structural indicators: Does the forecaster use pre-mortem analysis? Do they track calibration? Have they updated against their priors?',
     NULL, 5, 0, NOW() - INTERVAL '7 days'),
    (d9, 7, demo_admin_id,
     'Structural indicators are the right approach. I''d also add: Does the forecast reference contrary evidence? A strong signal of bias resistance is actively engaging with disconfirming data.',
     d8, 4, 0, NOW() - INTERVAL '6 days'),

    -- Metric 16: Independent Analysis — 3 comments + 1 reply
    (d10, 16, demo_viewer_id,
     'How do we distinguish independent analysis from contrarianism for its own sake? Being different from consensus isn''t automatically valuable — it needs to be backed by novel data or reasoning.',
     NULL, 6, 1, NOW() - INTERVAL '13 days'),
    (d11, 16, demo_admin_id,
     'The key test: Does the analysis cite evidence that the consensus view hasn''t incorporated? Novel data sources, alternative models, or documented reasoning chains that diverge from the crowd.',
     d10, 4, 0, NOW() - INTERVAL '12 days'),
    (d12, 16, demo_analyst_id,
     'I''ve been scoring this by looking at whether the forecaster references primary sources vs. just aggregating other forecasters. Original data collection is the strongest signal of independence.',
     NULL, 5, 0, NOW() - INTERVAL '5 days'),

    -- Metric 20: Net Predictive Value — 3 comments
    (d13, 20, demo_admin_id,
     'This is the meta-metric that integrates everything. I score it by asking: "If I had to bet real money based on this forecast, would I?" That gut check captures something the individual metrics miss.',
     NULL, 9, 1, NOW() - INTERVAL '18 days'),
    (d14, 20, demo_analyst_id,
     'The "would I bet on it" heuristic is useful but introduces its own biases (risk aversion, loss aversion). Better framing: "Does this forecast meaningfully reduce my uncertainty about the outcome?"',
     d13, 7, 0, NOW() - INTERVAL '17 days'),
    (d15, 20, demo_viewer_id,
     'I think this metric works best as a sanity check. If the individual metric scores are high but something still feels off about the forecast, Net Predictive Value captures that discrepancy.',
     NULL, 3, 0, NOW() - INTERVAL '4 days')
ON CONFLICT (id) DO NOTHING;


RAISE NOTICE 'Demo data seeded: 3 users, scores for 9 targets, 5 RFC proposals, 15 discussion comments';

END $$;
