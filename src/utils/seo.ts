/**
 * SEO Utilities (adapted for Next.js)
 * OG image URL generators for shareable pages
 */

function getOrigin() {
  if (typeof window !== "undefined" && window.location?.origin) {
    return window.location.origin;
  }
  return "https://forecastaudit.pro";
}

export function generateScorecardOgImageUrl(params: {
  targetId: string;
  targetName: string;
  userName?: string;
  score?: number;
}): string {
  const baseUrl = getOrigin();
  const searchParams = new URLSearchParams({
    targetId: params.targetId,
    targetName: params.targetName,
    userName: params.userName || "Anonymous",
    score: params.score?.toFixed(2) || "0",
  });

  return `${baseUrl}/api/og/scorecard?${searchParams.toString()}`;
}

export function generateGlobalConsensusOgImageUrl(params: {
  targetName: string;
  score: number;
  totalVotes?: number;
}): string {
  const baseUrl = getOrigin();
  const searchParams = new URLSearchParams({
    targetName: params.targetName,
    score: params.score.toString(),
  });

  if (params.totalVotes !== undefined) {
    searchParams.set("totalVotes", params.totalVotes.toString());
  }

  return `${baseUrl}/api/og/scorecard?${searchParams.toString()}`;
}

export function generateTargetOgImageUrl(params: {
  targetName: string;
  caseId?: string;
  author?: string;
  origin?: string;
}): string {
  const baseUrl = getOrigin();
  const searchParams = new URLSearchParams({
    targetName: params.targetName,
    author: params.author || "Anonymous",
  });

  if (params.caseId) searchParams.set("caseId", params.caseId);
  if (params.origin) searchParams.set("origin", params.origin);

  return `${baseUrl}/api/og/target?${searchParams.toString()}`;
}

export function generateRfcOgImageUrl(params: {
  title: string;
  status: string;
  author?: string;
  votesFor?: number;
  votesAgainst?: number;
}): string {
  const baseUrl = getOrigin();
  const searchParams = new URLSearchParams({
    title: params.title,
    status: params.status,
    author: params.author || "Anonymous",
  });

  if (params.votesFor !== undefined)
    searchParams.set("votesFor", params.votesFor.toString());
  if (params.votesAgainst !== undefined)
    searchParams.set("votesAgainst", params.votesAgainst.toString());

  return `${baseUrl}/api/og/rfc?${searchParams.toString()}`;
}
