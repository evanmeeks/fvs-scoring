/**
 * Context Types Reference Data
 * Authoritative list of forecast context types
 */

export interface ContextType {
  slug: string;
  label: string;
  isActive: boolean;
  sortOrder: number;
}

export const CONTEXT_TYPES: ContextType[] = [
  // Prediction Market Contexts
  { slug: "prediction_market", label: "Prediction Market", isActive: true, sortOrder: 5 },
  { slug: "economic_forecast", label: "Economic Forecast", isActive: true, sortOrder: 6 },
  { slug: "political_forecast", label: "Political Forecast", isActive: true, sortOrder: 7 },
  { slug: "technology_forecast", label: "Technology Forecast", isActive: true, sortOrder: 8 },
  { slug: "financial_forecast", label: "Financial Forecast", isActive: true, sortOrder: 9 },
  { slug: "scientific_forecast", label: "Scientific Forecast", isActive: true, sortOrder: 10 },
  { slug: "epidemiological_forecast", label: "Epidemiological Forecast", isActive: true, sortOrder: 11 },

  // Academic/Research Contexts
  { slug: "academic_symposium", label: "Academic Symposium", isActive: true, sortOrder: 20 },
  { slug: "scientific_paper", label: "Scientific Paper", isActive: true, sortOrder: 30 },
  { slug: "academic_thesis", label: "Academic Thesis", isActive: true, sortOrder: 35 },
  { slug: "research_grant_proposal", label: "Research Grant Proposal", isActive: true, sortOrder: 37 },
  { slug: "expert_survey", label: "Expert Survey", isActive: true, sortOrder: 38 },
  { slug: "consensus_model", label: "Consensus Model", isActive: true, sortOrder: 39 },

  // Media/Broadcast Contexts
  { slug: "media_broadcast", label: "Media Broadcast", isActive: true, sortOrder: 40 },
  { slug: "public_statement", label: "Public Statement", isActive: true, sortOrder: 50 },
  { slug: "analyst_report", label: "Analyst Report", isActive: true, sortOrder: 55 },
  { slug: "podcast_episode", label: "Podcast Episode", isActive: true, sortOrder: 80 },
  { slug: "press_conference", label: "Press Conference", isActive: true, sortOrder: 90 },
  { slug: "book_publication", label: "Book Publication", isActive: true, sortOrder: 100 },

  // Government/Official Contexts
  { slug: "government_report", label: "Government Report", isActive: true, sortOrder: 110 },
  { slug: "central_bank_forecast", label: "Central Bank Forecast", isActive: true, sortOrder: 115 },
  { slug: "regulatory_filing", label: "Regulatory Filing", isActive: true, sortOrder: 118 },
  { slug: "congressional_hearing", label: "Congressional Hearing", isActive: true, sortOrder: 140 },
  { slug: "press_release", label: "Press Release", isActive: true, sortOrder: 150 },
  { slug: "international_agreement", label: "International Agreement", isActive: true, sortOrder: 160 },
  { slug: "international_statement", label: "International Statement", isActive: true, sortOrder: 170 },

  // Data/Model Contexts
  { slug: "quantitative_model", label: "Quantitative Model", isActive: true, sortOrder: 175 },
  { slug: "machine_learning_model", label: "Machine Learning Model", isActive: true, sortOrder: 176 },
  { slug: "simulation_output", label: "Simulation Output", isActive: true, sortOrder: 177 },

  // Legal Contexts
  { slug: "legal_filing", label: "Legal Filing", isActive: true, sortOrder: 180 },

  // Witness/Testimony Contexts
  { slug: "witness_testimony", label: "Witness Testimony", isActive: true, sortOrder: 190 },
  { slug: "whistleblower_account", label: "Whistleblower Account", isActive: true, sortOrder: 200 },
  { slug: "expert_testimony", label: "Expert Testimony", isActive: true, sortOrder: 205 },
  { slug: "legal_deposition", label: "Legal Deposition", isActive: true, sortOrder: 210 },

  // Evidence Contexts
  { slug: "visual_evidence", label: "Visual Evidence", isActive: true, sortOrder: 220 },
  { slug: "data_analysis", label: "Data Analysis", isActive: true, sortOrder: 225 },

  // Social Media/Viral Contexts
  { slug: "viral_narrative", label: "Viral Narrative", isActive: true, sortOrder: 260 },
  { slug: "social_media", label: "Social Media", isActive: true, sortOrder: 270 },
  { slug: "social_media_post", label: "Social Media Post", isActive: true, sortOrder: 275 },
  { slug: "forum_discussion", label: "Forum Discussion", isActive: true, sortOrder: 285 },

  // Patent/Technical
  { slug: "patent_application", label: "Patent Application", isActive: true, sortOrder: 310 },

  // Legacy compatibility entries (not shown in UI)
  { slug: "internal", label: "Internal", isActive: false, sortOrder: 400 },
  { slug: "operational", label: "Operational", isActive: false, sortOrder: 410 },
  { slug: "media_interview", label: "Media Interview", isActive: false, sortOrder: 420 },
  { slug: "document_release", label: "Document Release", isActive: false, sortOrder: 430 },
  { slug: "unspecified", label: "Unspecified / Other", isActive: false, sortOrder: 999 },
];

export const LEGACY_CONTEXT_MAP: Record<string, string> = {
  Congressional: "congressional_hearing",
  Internal: "internal",
  Operational: "operational",
  "Public Statement": "public_statement",
  "Media Interview": "media_interview",
  "Document Release": "document_release",
  Other: "unspecified",
};

/**
 * Get context label from slug
 */
export const getContextLabel = (slug?: string | null): string => {
  if (!slug) return "Unknown";
  const contextType = CONTEXT_TYPES.find((ct) => ct.slug === slug);
  return contextType?.label || slug;
};

/**
 * Get active context types for UI selection
 */
export const getActiveContextTypes = (): ContextType[] => {
  return CONTEXT_TYPES.filter((ct) => ct.isActive).sort((a, b) => a.sortOrder - b.sortOrder);
};

/**
 * Pre-sorted context types for UI selection (active only)
 */
export const SORTED_CONTEXT_TYPES = CONTEXT_TYPES
  .filter((ct) => ct.isActive)
  .sort((a, b) => a.sortOrder - b.sortOrder);
