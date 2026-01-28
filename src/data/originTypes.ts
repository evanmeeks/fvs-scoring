/**
 * Origin Types Reference Data
 * Authoritative list of disclosure origin types
 */

export interface OriginType {
  slug: string;
  label: string;
  abbreviation: string;
  description: string;
  sortOrder: number;
}

export const ORIGIN_TYPES: OriginType[] = [
  {
    slug: "ic_national",
    label: "US Intelligence Community",
    abbreviation: "IC",
    description: "ODNI, CIA, NSA, NGA, NRO, DIA products or briefings.",
    sortOrder: 10,
  },
  {
    slug: "dod_joint",
    label: "DoD Joint/OSD",
    abbreviation: "DOD",
    description: "Joint Staff, OSD, combatant commands, or cross-service task forces.",
    sortOrder: 20,
  },
  {
    slug: "dod_usaf_ussf",
    label: "USAF/USSF",
    abbreviation: "USAF",
    description: "Air and Space Force programs, labs, or operational channels.",
    sortOrder: 21,
  },
  {
    slug: "dod_usn",
    label: "US Navy",
    abbreviation: "USN",
    description: "Navy platforms, ONR, NAVAIR, NAVSEA, or fleet channels.",
    sortOrder: 22,
  },
  {
    slug: "dod_usa",
    label: "US Army",
    abbreviation: "USA",
    description: "Army commands, labs, or service-owned programs.",
    sortOrder: 23,
  },
  {
    slug: "nasa_civil_space",
    label: "NASA",
    abbreviation: "NASA",
    description: "Civil space agency missions, payloads, or directorates.",
    sortOrder: 30,
  },
  {
    slug: "federal_civil_agency",
    label: "Federal Civil Agency",
    abbreviation: "CIV",
    description: "Non-defense agencies (NOAA, FAA, DOE, DHS, etc.).",
    sortOrder: 35,
  },
  {
    slug: "state_local_govt",
    label: "State/Local Government",
    abbreviation: "STATE",
    description: "State or local government officials or agencies.",
    sortOrder: 40,
  },
  {
    slug: "foreign_govt_allied",
    label: "Allied Foreign Government",
    abbreviation: "ALLY",
    description: "Five Eyes, NATO, or other treaty partners.",
    sortOrder: 50,
  },
  {
    slug: "foreign_govt_other",
    label: "Other Foreign Government",
    abbreviation: "FOR",
    description: "Non-allied or neutral state actors.",
    sortOrder: 60,
  },
  {
    slug: "private_defense",
    label: "Private Defense Contractor",
    abbreviation: "DEF",
    description: "Aerospace, defense, or classified R&D vendors.",
    sortOrder: 70,
  },
  {
    slug: "private_commercial",
    label: "Private Commercial Entity",
    abbreviation: "COM",
    description: "Non-defense commercial organizations or startups.",
    sortOrder: 80,
  },
  {
    slug: "academic_institution",
    label: "Academic Institution",
    abbreviation: "ACAD",
    description: "Universities, research institutes, or labs.",
    sortOrder: 90,
  },
  {
    slug: "media_journalist",
    label: "Media/Journalist",
    abbreviation: "MEDIA",
    description: "Professional journalism or media outlets.",
    sortOrder: 100,
  },
  {
    slug: "independent_researcher",
    label: "Independent Researcher",
    abbreviation: "IND",
    description: "Self-funded or citizen researchers.",
    sortOrder: 110,
  },
  {
    slug: "advocacy_nonprofit",
    label: "Advocacy/Nonprofit",
    abbreviation: "NGO",
    description: "Transparency orgs, watchdog groups, or advocacy networks.",
    sortOrder: 120,
  },
  {
    slug: "anonymous_whistleblower",
    label: "Anonymous Whistleblower",
    abbreviation: "ANON",
    description: "Unverified or pseudonymous sources.",
    sortOrder: 130,
  },
  {
    slug: "public_individual",
    label: "Public Individual",
    abbreviation: "PUB",
    description: "Private citizens with no institutional affiliation.",
    sortOrder: 140,
  },
  {
    slug: "international_org",
    label: "International Organization",
    abbreviation: "INTL",
    description: "UN bodies, IGOs, or multilateral agencies.",
    sortOrder: 150,
  },
  // Legacy compatibility entry
  {
    slug: "unspecified",
    label: "Unspecified / Other",
    abbreviation: "UNK",
    description: "Origin not specified or does not fit existing categories.",
    sortOrder: 999,
  },
];

export const LEGACY_ORIGIN_MAP: Record<string, string> = {
  Government: "federal_civil_agency",
  Military: "dod_joint",
  Intelligence: "ic_national",
  Private: "private_commercial",
  Academic: "academic_institution",
  Media: "media_journalist",
  Anonymous: "anonymous_whistleblower",
  Other: "unspecified",
};

/**
 * Get origin label from slug
 */
export const getOriginLabel = (slug?: string | null): string => {
  if (!slug) return "Unknown";
  const originType = ORIGIN_TYPES.find((ot) => ot.slug === slug);
  return originType?.label || slug;
};

/**
 * Get origin abbreviation from slug
 */
export const getOriginAbbreviation = (slug?: string | null): string => {
  if (!slug) return "UNK";
  const originType = ORIGIN_TYPES.find((ot) => ot.slug === slug);
  return originType?.abbreviation || "UNK";
};

/**
 * Get all origin types sorted by sort order
 */
export const getAllOriginTypes = (): OriginType[] => {
  return ORIGIN_TYPES.sort((a, b) => a.sortOrder - b.sortOrder);
};

/**
 * Pre-sorted origin types for UI selection (excludes legacy entries)
 */
export const SORTED_ORIGIN_TYPES = ORIGIN_TYPES
  .filter((ot) => ot.slug !== "unspecified")
  .sort((a, b) => a.sortOrder - b.sortOrder);
