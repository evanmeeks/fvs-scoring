import { LEGACY_ORIGIN_MAP } from "~/data/originTypes";
import { LEGACY_CONTEXT_MAP } from "~/data/contextTypes";
import type { DbTarget } from "~/types/database";
/** Resolve a target by slug, case_id, or id (in that order) */
export async function findTargetBySlugFromDb(
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  supabase: { from: (table: string) => any },
  slug: string,
): Promise<DbTarget | null> {
  const { data: bySlug } = await supabase
    .from("targets")
    .select("*")
    .eq("slug", slug)
    .maybeSingle();
  if (bySlug) return bySlug as DbTarget;

  const { data: byCaseId } = await supabase
    .from("targets")
    .select("*")
    .eq("case_id", slug)
    .maybeSingle();
  if (byCaseId) return byCaseId as DbTarget;

  const { data: byId } = await supabase
    .from("targets")
    .select("*")
    .eq("id", slug)
    .maybeSingle();
  return (byId as DbTarget | null) ?? null;
}

type LegacyMap = Record<string, string>;

const normalizeValue = (
  value: string | null | undefined,
  legacyMap: LegacyMap = {},
): string => {
  if (!value) return "";
  if (legacyMap[value]) return legacyMap[value];
  return value;
};

export type NormalizedTarget = {
  id: string;
  name: string;
  caseId: string;
  origin: string;
  context: string;
  verified: boolean;
  description: string;
  claim_date?: string | null;
  primary_source?: string | null;
  source_url?: string | null;
  tags?: string[] | null;
  case_id?: string;
  created_at?: string;
  updated_at?: string;
  slug?: string | null;
};

export const normalizeTarget = (
  target: Partial<DbTarget> | null | undefined,
): NormalizedTarget | null => {
  if (!target || !target.id) return null;
  const targetName =
    target.name ||
    (target as { target_name?: string }).target_name ||
    String(target.id);
  const caseId =
    (target as { caseId?: string }).caseId || target.case_id || "";
  return {
    id: target.id,
    name: targetName,
    caseId,
    origin: normalizeValue(target.origin, LEGACY_ORIGIN_MAP),
    context: normalizeValue(target.context, LEGACY_CONTEXT_MAP),
    verified: Boolean(target.verified),
    description: target.description || "",
    claim_date: target.claim_date ?? null,
    primary_source: target.primary_source ?? null,
    source_url: target.source_url ?? null,
    tags: target.tags ?? null,
    case_id: target.case_id,
    created_at: target.created_at,
    updated_at: target.updated_at,
    slug: target.slug ?? null,
  };
};
