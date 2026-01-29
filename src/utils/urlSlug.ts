import type { DbTarget } from "~/types/database";

/**
 * Generates a URL slug from target data.
 * Slug generation is now handled by the database.
 * This function is kept for backwards compatibility.
 */
export function generateTargetSlug(target: DbTarget): string {
  if (target.slug) {
    return target.slug;
  }

  const caseId = target.case_id || "FVS-000";
  const targetName = target.name
    .trim()
    .replace(/\s+/g, "_")
    .replace(/[^a-zA-Z0-9_-]/g, "")
    .replace(/^[_-]+|[_-]+$/g, "");

  return `${caseId}-${targetName}`;
}

/**
 * Finds a target by matching the slug
 */
export function findTargetBySlug<T extends DbTarget>(
  targets: T[],
  slug: string,
): T | null {
  const exactMatch = targets.find((t) => t.slug === slug);
  if (exactMatch) return exactMatch;

  const caseId = parseCaseIdFromSlug(slug);
  if (caseId) {
    return targets.find((t) => t.case_id === caseId) || null;
  }

  return null;
}

/**
 * Parses a URL slug to extract the case ID
 */
export function parseCaseIdFromSlug(slug: string): string | null {
  const match = slug.match(/^(.+?-\d{4})-[A-Z]/);
  if (match) {
    return match[1];
  }

  const legacyMatch = slug.match(/^([A-Z0-9.-]+(?:-[A-Z0-9.-]+)*)-/);
  return legacyMatch ? legacyMatch[1] : null;
}
