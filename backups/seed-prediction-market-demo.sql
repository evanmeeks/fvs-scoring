-- =============================================================================
-- FVS Dashboard Demo Data: Prediction Market Forecasts
-- Run this against the remote Supabase database to seed demo data
-- =============================================================================

-- First, clear existing targets (preserve users and metrics)
DELETE FROM public.user_scores;
DELETE FROM public.approved_targets;
DELETE FROM public.target_submissions;

-- Reset sequences
ALTER SEQUENCE IF EXISTS target_submissions_id_seq RESTART WITH 1;

-- Insert prediction market forecast targets
DO $$
DECLARE
    admin_user_id UUID;
    fed_rate_id UUID := gen_random_uuid();
    election_2024_id UUID := gen_random_uuid();
    agi_timeline_id UUID := gen_random_uuid();
    recession_id UUID := gen_random_uuid();
    climate_id UUID := gen_random_uuid();
    spacex_id UUID := gen_random_uuid();
    bitcoin_id UUID := gen_random_uuid();
    pandemic_id UUID := gen_random_uuid();
    fusion_id UUID := gen_random_uuid();
BEGIN
    -- Get admin user ID for submission attribution
    SELECT user_id INTO admin_user_id FROM public.user_profiles WHERE role = 'admin' LIMIT 1;

    -- If no admin, use NULL (will still work)
    IF admin_user_id IS NULL THEN
        RAISE NOTICE 'No admin user found, using NULL for submitted_by';
    END IF;

    -- ==========================================================================
    -- HIGH QUALITY FORECASTS (Verified, High Scores Expected)
    -- ==========================================================================

    -- Federal Reserve Interest Rate Prediction
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        fed_rate_id,
        'Fed Rate Trajectory Q1-Q4 2024',
        'academic_institution',
        'prediction_market',
        'Aggregated prediction market forecasts for Federal Reserve interest rate decisions. Markets predicted 3-4 rate cuts in 2024, with first cut in Q2. Resolution: Fed held rates through Q2, first cut in September.',
        'approved',
        admin_user_id, NOW() - INTERVAL '30 days', admin_user_id, NOW() - INTERVAL '29 days',
        'Verified via Polymarket and Kalshi historical data',
        '2024-01-15',
        'Polymarket / Kalshi / CME FedWatch'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'fed-rate-2024', fed_rate_id,
        'Fed Rate Trajectory Q1-Q4 2024',
        'FVS-ECON-0001',
        'academic_institution',
        'prediction_market',
        'Aggregated prediction market forecasts for Federal Reserve interest rate decisions. Markets predicted 3-4 rate cuts in 2024, with first cut in Q2. Resolution: Fed held rates through Q2, first cut in September.',
        '2024-01-15',
        'Polymarket / Kalshi / CME FedWatch',
        true
    );

    -- US Presidential Election 2024
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        election_2024_id,
        'US Presidential Election 2024',
        'media_journalist',
        'political_forecast',
        'Multi-source aggregation of polling data and prediction markets for 2024 presidential election. 538 final forecast, PredictIt/Polymarket odds, and Metaculus community predictions.',
        'approved',
        admin_user_id, NOW() - INTERVAL '25 days', admin_user_id, NOW() - INTERVAL '24 days',
        'Major aggregators and prediction markets',
        '2024-03-01',
        '538 / Metaculus / PredictIt / Polymarket'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'election-2024', election_2024_id,
        'US Presidential Election 2024',
        'FVS-POL-0002',
        'media_journalist',
        'political_forecast',
        'Multi-source aggregation of polling data and prediction markets for 2024 presidential election. 538 final forecast, PredictIt/Polymarket odds, and Metaculus community predictions.',
        '2024-03-01',
        '538 / Metaculus / PredictIt / Polymarket',
        true
    );

    -- US Recession Probability
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        recession_id,
        'US Recession Probability 2024-2025',
        'academic_institution',
        'economic_forecast',
        'NY Fed recession probability model and Bloomberg economist survey consensus. Model showed 60%+ probability of recession by mid-2024, later revised downward as soft landing became base case.',
        'approved',
        admin_user_id, NOW() - INTERVAL '20 days', admin_user_id, NOW() - INTERVAL '19 days',
        'Federal Reserve Economic Data (FRED)',
        '2024-01-01',
        'NY Fed / Bloomberg Survey / Conference Board'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'recession-2024', recession_id,
        'US Recession Probability 2024-2025',
        'FVS-ECON-0003',
        'academic_institution',
        'economic_forecast',
        'NY Fed recession probability model and Bloomberg economist survey consensus. Model showed 60%+ probability of recession by mid-2024, later revised downward as soft landing became base case.',
        '2024-01-01',
        'NY Fed / Bloomberg Survey / Conference Board',
        true
    );

    -- Climate Temperature Forecast
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        climate_id,
        'Global Temperature Anomaly 2024',
        'academic_institution',
        'scientific_forecast',
        'NOAA and NASA GISS model predictions for 2024 global mean temperature anomaly relative to 1951-1980 baseline. Predicted to be warmest year on record due to El Niño conditions.',
        'approved',
        admin_user_id, NOW() - INTERVAL '15 days', admin_user_id, NOW() - INTERVAL '14 days',
        'Peer-reviewed climate models with >95% historical accuracy',
        '2024-01-01',
        'NOAA / NASA GISS / Copernicus'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'climate-temp-2024', climate_id,
        'Global Temperature Anomaly 2024',
        'FVS-SCI-0004',
        'academic_institution',
        'scientific_forecast',
        'NOAA and NASA GISS model predictions for 2024 global mean temperature anomaly relative to 1951-1980 baseline. Predicted to be warmest year on record due to El Niño conditions.',
        '2024-01-01',
        'NOAA / NASA GISS / Copernicus',
        true
    );

    -- ==========================================================================
    -- MIXED QUALITY FORECASTS (Partial Verification)
    -- ==========================================================================

    -- AGI Timeline Forecast
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        agi_timeline_id,
        'AGI Development Timeline',
        'private_commercial',
        'technology_forecast',
        'Expert survey and prediction market estimates for Artificial General Intelligence development. Metaculus median: 2040. AI Impacts survey: 2060. Notable disagreement between AI researchers and forecasters.',
        'approved',
        admin_user_id, NOW() - INTERVAL '18 days', admin_user_id, NOW() - INTERVAL '17 days',
        'Aggregated from multiple expert surveys',
        '2024-02-20',
        'Metaculus / AI Impacts Survey / Epoch AI'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'agi-timeline-2024', agi_timeline_id,
        'AGI Development Timeline',
        'FVS-TECH-0005',
        'private_commercial',
        'technology_forecast',
        'Expert survey and prediction market estimates for Artificial General Intelligence development. Metaculus median: 2040. AI Impacts survey: 2060. Notable disagreement between AI researchers and forecasters.',
        '2024-02-20',
        'Metaculus / AI Impacts Survey / Epoch AI',
        false
    );

    -- SpaceX Starship
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        spacex_id,
        'SpaceX Starship Orbital Success 2024',
        'private_commercial',
        'technology_forecast',
        'Predictions on SpaceX Starship achieving successful orbital flight and controlled reentry. IFT-3 achieved orbital velocity but lost during reentry. IFT-4 partial success with booster catch attempt.',
        'approved',
        admin_user_id, NOW() - INTERVAL '12 days', admin_user_id, NOW() - INTERVAL '11 days',
        'SpaceX announcements and industry analysis',
        '2024-02-01',
        'Metaculus / SpaceX / Ars Technica'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'spacex-orbital-2024', spacex_id,
        'SpaceX Starship Orbital Success 2024',
        'FVS-TECH-0006',
        'private_commercial',
        'technology_forecast',
        'Predictions on SpaceX Starship achieving successful orbital flight and controlled reentry. IFT-3 achieved orbital velocity but lost during reentry. IFT-4 partial success with booster catch attempt.',
        '2024-02-01',
        'Metaculus / SpaceX / Ars Technica',
        false
    );

    -- ==========================================================================
    -- SPECULATIVE FORECASTS (Lower Verification)
    -- ==========================================================================

    -- Bitcoin Price
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        bitcoin_id,
        'Bitcoin Price EOY 2024',
        'private_commercial',
        'financial_forecast',
        'Prediction market and analyst forecasts for Bitcoin price at end of 2024. Wide range of predictions from $50K to $150K. ETF approval drove early 2024 rally.',
        'approved',
        admin_user_id, NOW() - INTERVAL '10 days', admin_user_id, NOW() - INTERVAL '9 days',
        'High volatility asset - predictions vary widely',
        '2024-01-01',
        'Polymarket / Standard Chartered / Bloomberg'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'bitcoin-eoy-2024', bitcoin_id,
        'Bitcoin Price EOY 2024',
        'FVS-FIN-0007',
        'private_commercial',
        'financial_forecast',
        'Prediction market and analyst forecasts for Bitcoin price at end of 2024. Wide range of predictions from $50K to $150K. ETF approval drove early 2024 rally.',
        '2024-01-01',
        'Polymarket / Standard Chartered / Bloomberg',
        false
    );

    -- Pandemic Timeline
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        pandemic_id,
        'Next Pandemic-Scale Outbreak by 2030',
        'academic_institution',
        'epidemiological_forecast',
        'Epidemiological models predicting probability of next pandemic-scale outbreak (>1M deaths). Metaculus community median: 35% by 2030. Based on historical frequency and increasing zoonotic spillover risk.',
        'approved',
        admin_user_id, NOW() - INTERVAL '8 days', admin_user_id, NOW() - INTERVAL '7 days',
        'Academic research aggregation - long time horizon',
        '2024-01-15',
        'Metaculus / Johns Hopkins / WHO'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'pandemic-2030', pandemic_id,
        'Next Pandemic-Scale Outbreak by 2030',
        'FVS-EPI-0008',
        'academic_institution',
        'epidemiological_forecast',
        'Epidemiological models predicting probability of next pandemic-scale outbreak (>1M deaths). Metaculus community median: 35% by 2030. Based on historical frequency and increasing zoonotic spillover risk.',
        '2024-01-15',
        'Metaculus / Johns Hopkins / WHO',
        false
    );

    -- Fusion Energy
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        fusion_id,
        'Commercial Fusion Power by 2035',
        'academic_institution',
        'technology_forecast',
        'Expert predictions on timeline for first commercial fusion power plant delivering electricity to grid. DOE milestone: 2035 target. Private companies (Commonwealth, TAE) targeting 2030s.',
        'approved',
        admin_user_id, NOW() - INTERVAL '5 days', admin_user_id, NOW() - INTERVAL '4 days',
        'DOE and private sector announcements',
        '2024-02-01',
        'DOE / Fusion Industry Association / Metaculus'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES (
        'fusion-2035', fusion_id,
        'Commercial Fusion Power by 2035',
        'FVS-TECH-0009',
        'academic_institution',
        'technology_forecast',
        'Expert predictions on timeline for first commercial fusion power plant delivering electricity to grid. DOE milestone: 2035 target. Private companies (Commonwealth, TAE) targeting 2030s.',
        '2024-02-01',
        'DOE / Fusion Industry Association / Metaculus',
        false
    );

    RAISE NOTICE 'Successfully seeded 9 prediction market forecast targets';
END $$;

-- Verify the seed
SELECT
    at.name,
    at.case_id,
    at.origin,
    at.context,
    at.verified
FROM public.approved_targets at
ORDER BY at.case_id;
