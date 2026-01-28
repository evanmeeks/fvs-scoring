import type { DbTarget } from "../types/database";

/**
 * Fallback target data for local development / testing
 * These match the seed data from the database migrations
 */
export const FALLBACK_TARGETS: DbTarget[] = [
  {
    id: "grusch-2024",
    name: "Grusch_T_2024",
    case_id: "NCI-8.3-XREF-FVS",
    origin: "ic_national",
    context: "congressional_hearing",
    description: "David Grusch UAP disclosure testimony before Congress",
    claim_date: "2023-07-26",
    primary_source: "Congressional Record",
    source_url: null,
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    submission_id: null,
  },
  {
    id: "wilson-memo",
    name: "Wilson_Memo_2002",
    case_id: "NCI-7.1-XREF-FVS",
    origin: "ic_national",
    context: "internal",
    description: "Eric Davis notes from Admiral Wilson meeting",
    claim_date: "2002-10-16",
    primary_source: "Eric Davis Notes",
    source_url: null,
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    submission_id: null,
  },
  {
    id: "nimitz-2004",
    name: "Nimitz_Encounter_2004",
    case_id: "NCI-9.2-XREF-FVS",
    origin: "dod_usn",
    context: "operational",
    description: "USS Nimitz carrier strike group UAP encounter",
    claim_date: "2004-11-14",
    primary_source: "US Navy",
    source_url: null,
    tags: null,
    verified: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    submission_id: null,
  },
];
