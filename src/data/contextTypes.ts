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
  { slug: "prediction_market", label: "Prediction Market", isActive: true, sortOrder: 5 },
  { slug: "economic_forecast", label: "Economic Forecast", isActive: true, sortOrder: 6 },
  { slug: "political_forecast", label: "Political Forecast", isActive: true, sortOrder: 7 },
  { slug: "technology_forecast", label: "Technology Forecast", isActive: true, sortOrder: 8 },
  { slug: "financial_forecast", label: "Financial Forecast", isActive: true, sortOrder: 9 },
  { slug: "scientific_forecast", label: "Scientific Forecast", isActive: true, sortOrder: 10 },
  { slug: "epidemiological_forecast", label: "Epidemiological Forecast", isActive: true, sortOrder: 11 },
  { slug: "academic_symposium", label: "Academic Symposium", isActive: true, sortOrder: 20 },
  { slug: "scientific_paper", label: "Scientific Paper", isActive: true, sortOrder: 30 },
  { slug: "academic_thesis", label: "Academic Thesis", isActive: true, sortOrder: 35 },
  { slug: "media_broadcast", label: "Media Broadcast", isActive: true, sortOrder: 40 },
  { slug: "public_statement", label: "Public Statement", isActive: true, sortOrder: 50 },
  { slug: "analyst_report", label: "Analyst Report", isActive: true, sortOrder: 55 },
  { slug: "podcast_episode", label: "Podcast Episode", isActive: true, sortOrder: 80 },
  { slug: "press_conference", label: "Press Conference", isActive: true, sortOrder: 90 },
  { slug: "government_report", label: "Government Report", isActive: true, sortOrder: 110 },
  { slug: "congressional_hearing", label: "Congressional Hearing", isActive: true, sortOrder: 140 },
  { slug: "legal_filing", label: "Legal Filing", isActive: true, sortOrder: 180 },
  { slug: "witness_testimony", label: "Witness Testimony", isActive: true, sortOrder: 190 },
  { slug: "whistleblower_account", label: "Whistleblower Account", isActive: true, sortOrder: 200 },
  { slug: "visual_evidence", label: "Visual Evidence", isActive: true, sortOrder: 220 },
  { slug: "viral_narrative", label: "Viral Narrative", isActive: true, sortOrder: 260 },
  { slug: "social_media", label: "Social Media", isActive: true, sortOrder: 270 },
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

export const getContextLabel = (slug?: string | null): string => {
  if (!slug) return "Unknown";
  const contextType = CONTEXT_TYPES.find((ct) => ct.slug === slug);
  return contextType?.label || slug;
};
