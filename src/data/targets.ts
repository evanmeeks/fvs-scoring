import type { DbTarget } from "../types/database";

/**
 * Fallback target data for local development / testing
 * These match the seed data from the database migrations
 */
export const FALLBACK_TARGETS: DbTarget[] = [
  {
    id: "fed-rate-2024",
    name: "Fed_Rate_Prediction_2024",
    case_id: "FVS-ECON-RATE-0001",
    origin: "academic_institution",
    context: "economic_forecast",
    description: "Federal Reserve interest rate trajectory prediction for 2024",
    claim_date: "2024-01-15",
    primary_source: "Polymarket / Kalshi",
    source_url: null,
    slug: "fed-rate-prediction-2024",
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: "election-2024",
    name: "US_Election_Forecast_2024",
    case_id: "FVS-POL-ELEC-0002",
    origin: "media_journalist",
    context: "political_forecast",
    description: "US Presidential Election outcome predictions and polling aggregation",
    claim_date: "2024-03-01",
    primary_source: "538 / Metaculus",
    source_url: null,
    slug: "us-election-forecast-2024",
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
  {
    id: "ai-agi-timeline",
    name: "AGI_Timeline_Forecast",
    case_id: "FVS-TECH-AGI-0003",
    origin: "private_commercial",
    context: "technology_forecast",
    description: "Artificial General Intelligence development timeline predictions",
    claim_date: "2024-02-20",
    primary_source: "Metaculus / AI Researchers",
    source_url: null,
    slug: "agi-timeline-forecast",
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  },
];
