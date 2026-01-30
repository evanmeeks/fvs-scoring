-- Seed public forecast targets for prediction market verification
-- Adds sample targets with auto-generated case IDs
-- All entries will have 0 scores initially (no user_scores entries)
-- Uses slug values for origin and context that match the reference tables

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
    SELECT user_id INTO admin_user_id FROM user_profiles WHERE role = 'admin' LIMIT 1;

    -- Federal Reserve Interest Rate Prediction (HIGH QUALITY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        fed_rate_id, 'Fed Rate Trajectory 2024', 'academic_institution', 'economic_forecast',
        'Prediction of Federal Reserve interest rate decisions through 2024', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Verified prediction market data',
        '2024-01-15', 'Polymarket / Kalshi'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('fed-rate-2024', fed_rate_id, 'Fed Rate Trajectory 2024', NULL, 'academic_institution', 'economic_forecast', 'Prediction of Federal Reserve interest rate decisions through 2024', '2024-01-15', 'Polymarket / Kalshi', true)
    ON CONFLICT (id) DO NOTHING;

    -- US Presidential Election 2024 (HIGH QUALITY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        election_2024_id, 'US Presidential Election 2024', 'media_journalist', 'political_forecast',
        'Aggregated polling and prediction market forecasts for 2024 presidential election', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Multi-source aggregation',
        '2024-03-01', '538 / Metaculus / PredictIt'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('election-2024', election_2024_id, 'US Presidential Election 2024', NULL, 'media_journalist', 'political_forecast', 'Aggregated polling and prediction market forecasts for 2024 presidential election', '2024-03-01', '538 / Metaculus / PredictIt', true)
    ON CONFLICT (id) DO NOTHING;

    -- AGI Timeline Forecast (MIXED QUALITY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        agi_timeline_id, 'AGI Development Timeline', 'private_commercial', 'technology_forecast',
        'Expert and market predictions on Artificial General Intelligence development timeline', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Aggregated expert forecasts',
        '2024-02-20', 'Metaculus / AI Impacts Survey'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('agi-timeline-2024', agi_timeline_id, 'AGI Development Timeline', NULL, 'private_commercial', 'technology_forecast', 'Expert and market predictions on Artificial General Intelligence development timeline', '2024-02-20', 'Metaculus / AI Impacts Survey', false)
    ON CONFLICT (id) DO NOTHING;

    -- US Recession Probability (HIGH QUALITY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        recession_id, 'US Recession Probability 2024-2025', 'academic_institution', 'economic_forecast',
        'Economic models and market predictions for US recession probability', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Federal Reserve model data',
        '2024-01-01', 'NY Fed / Bloomberg Survey'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('recession-2024', recession_id, 'US Recession Probability 2024-2025', NULL, 'academic_institution', 'economic_forecast', 'Economic models and market predictions for US recession probability', '2024-01-01', 'NY Fed / Bloomberg Survey', true)
    ON CONFLICT (id) DO NOTHING;

    -- Climate Temperature Forecast (SCIENTIFIC)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        climate_id, 'Global Temperature Anomaly 2024', 'academic_institution', 'scientific_forecast',
        'Climate model predictions for 2024 global mean temperature anomaly', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Peer-reviewed climate models',
        '2024-01-01', 'NOAA / NASA GISS'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('climate-temp-2024', climate_id, 'Global Temperature Anomaly 2024', NULL, 'academic_institution', 'scientific_forecast', 'Climate model predictions for 2024 global mean temperature anomaly', '2024-01-01', 'NOAA / NASA GISS', true)
    ON CONFLICT (id) DO NOTHING;

    -- SpaceX Starship Orbital (TECHNOLOGY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        spacex_id, 'SpaceX Starship Orbital Success', 'private_commercial', 'technology_forecast',
        'Predictions on SpaceX Starship achieving successful orbital flight', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Industry analyst predictions',
        '2024-02-01', 'Metaculus / Space Industry Analysts'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('spacex-orbital-2024', spacex_id, 'SpaceX Starship Orbital Success', NULL, 'private_commercial', 'technology_forecast', 'Predictions on SpaceX Starship achieving successful orbital flight', '2024-02-01', 'Metaculus / Space Industry Analysts', false)
    ON CONFLICT (id) DO NOTHING;

    -- Bitcoin Price Prediction (FINANCIAL)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        bitcoin_id, 'Bitcoin Price EOY 2024', 'private_commercial', 'financial_forecast',
        'Market predictions for Bitcoin price at end of 2024', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Aggregated market predictions',
        '2024-01-01', 'Polymarket / Crypto Analysts'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('bitcoin-eoy-2024', bitcoin_id, 'Bitcoin Price EOY 2024', NULL, 'private_commercial', 'financial_forecast', 'Market predictions for Bitcoin price at end of 2024', '2024-01-01', 'Polymarket / Crypto Analysts', false)
    ON CONFLICT (id) DO NOTHING;

    -- Pandemic Preparedness (PUBLIC HEALTH)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        pandemic_id, 'Next Pandemic Timeline', 'academic_institution', 'epidemiological_forecast',
        'Epidemiological models predicting probability of next pandemic-scale outbreak', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'Academic research aggregation',
        '2024-01-15', 'Johns Hopkins / Metaculus'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('pandemic-timeline-2024', pandemic_id, 'Next Pandemic Timeline', NULL, 'academic_institution', 'epidemiological_forecast', 'Epidemiological models predicting probability of next pandemic-scale outbreak', '2024-01-15', 'Johns Hopkins / Metaculus', false)
    ON CONFLICT (id) DO NOTHING;

    -- Fusion Energy Breakthrough (ENERGY)
    INSERT INTO public.target_submissions (
        id, target_name, origin, context, description, status,
        submitted_by, submitted_at, reviewed_by, reviewed_at, review_notes,
        claim_date, primary_source
    ) VALUES (
        fusion_id, 'Commercial Fusion Timeline', 'academic_institution', 'technology_forecast',
        'Expert predictions on timeline for first commercial fusion power plant', 'approved',
        admin_user_id, NOW(), admin_user_id, NOW(), 'DOE and industry forecasts',
        '2024-02-01', 'DOE / Fusion Industry Association'
    );

    INSERT INTO public.approved_targets (id, submission_id, name, case_id, origin, context, description, claim_date, primary_source, verified)
    VALUES ('fusion-timeline-2024', fusion_id, 'Commercial Fusion Timeline', NULL, 'academic_institution', 'technology_forecast', 'Expert predictions on timeline for first commercial fusion power plant', '2024-02-01', 'DOE / Fusion Industry Association', false)
    ON CONFLICT (id) DO NOTHING;

END $$;
-- Note: case_id will be auto-generated via trigger using the format: FVS-ORIGIN-CONTEXT-XXXX
-- Note: No user_scores entries are created - all targets start with 0 scores (unaudited)
-- Examples of generated case_ids:
--   FVS-ACAD-ECON-0001 (Fed Rate)
--   FVS-MEDIA-POL-0002 (Election 2024)
--   FVS-PRIV-TECH-0003 (AGI Timeline);
