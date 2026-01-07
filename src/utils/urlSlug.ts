import type { DbTarget } from '../types/database';

/**
 * Generates a URL slug from target data
 *
 * ⚠️ DEPRECATED: Slug generation is now handled by the database.
 * Use the `slug` field from the database instead.
 * This function is kept for backwards compatibility only.
 *
 * Format: [Case ID]-Target_Name
 * Example: "FVS-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar"
 */
export function generateTargetSlug(target: DbTarget): string {
  // Return the database-generated slug if available
  if (target.slug) {
    return target.slug;
  }

  // Fallback for old data without slug column (shouldn't happen with GENERATED column)
  const caseId = target.case_id || 'FVS-000';
  const targetName = target.name
    .trim()
    .replace(/\s+/g, '_')
    .replace(/[^a-zA-Z0-9_-]/g, '')
    .replace(/^[_-]+|[_-]+$/g, '');

  return `${caseId}-${targetName}`;
}

/**
 * Finds a target by matching the slug
 * Now uses the database-generated slug column for exact matching
 */
export function findTargetBySlug<T extends DbTarget>(targets: T[], slug: string): T | null {
  // First try exact slug match (most reliable)
  const exactMatch = targets.find(t => t.slug === slug);
  if (exactMatch) return exactMatch;

  // Fallback: try to extract case_id and match on that
  // This handles legacy URLs that might not match the new slug format exactly
  const caseId = parseCaseIdFromSlug(slug);
  if (caseId) {
    return targets.find(t => t.case_id === caseId) || null;
  }

  return null;
}

/**
 * Parses a URL slug to extract the case ID
 *
 * Handles the new format: FVS-ORIGIN-CONTEXT-REF-Target_Name
 * Example: FVS-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar → FVS-DOD-ACADEMIC_SYMPOSIUM-0002
 *
 * Strategy: Case IDs always end with -NNNN (4 digits)
 * Everything from the start to the last -NNNN is the case_id
 */
export function parseCaseIdFromSlug(slug: string): string | null {
  // Match pattern: Start to the last -NNNN followed by a hyphen and capital letter
  // This handles the new format: FVS-DOD-ACADEMIC_SYMPOSIUM-0002-Bob_Lazar
  const match = slug.match(/^(.+?-\d{4})-[A-Z]/);

  if (match) {
    return match[1];
  }

  // Fallback for legacy formats
  const legacyMatch = slug.match(/^([A-Z0-9.-]+(?:-[A-Z0-9.-]+)*)-/);
  return legacyMatch ? legacyMatch[1] : null;
}
