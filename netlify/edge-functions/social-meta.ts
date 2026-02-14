/**
 * Netlify Edge Function: Social Media Meta Tag Injection
 *
 * Detects social media crawler requests and injects server-side rendered
 * Open Graph meta tags for proper preview cards on Twitter, Facebook, LinkedIn, etc.
 *
 * Handles:
 * - /global-consensus/:slug - Shows community consensus scores
 * - /audit-target/:slug - Shows target scoring pages
 */

import type { Context } from "@netlify/edge-functions";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.90.1";

// Social media crawler user agents
const CRAWLER_USER_AGENTS = [
  'twitterbot',
  'facebookexternalhit',
  'LinkedInBot',
  'WhatsApp',
  'TelegramBot',
  'Slackbot',
  'Discordbot',
  'SkypeUriPreview',
];

// Check if request is from a social media crawler
function isCrawler(userAgent: string | null): boolean {
  if (!userAgent) return false;
  const ua = userAgent.toLowerCase();
  return CRAWLER_USER_AGENTS.some(bot => ua.includes(bot.toLowerCase()));
}

// Extract slug from pathname
function extractSlug(pathname: string, prefix: string): string | null {
  const pattern = new RegExp(`^${prefix}/([^/]+)$`);
  const match = pathname.match(pattern);
  return match ? match[1] : null;
}

// Find target by slug (same logic as client-side)
function findTargetBySlug(targets: any[], slug: string): any | null {
  // Try exact slug match first
  const exactMatch = targets.find(t => t.slug === slug);
  if (exactMatch) return exactMatch;

  // Extract case_id from slug pattern [Case_ID]-[Name]
  const caseIdMatch = slug.match(/^([A-Z0-9_-]+)/i);
  if (caseIdMatch) {
    const caseId = caseIdMatch[1];
    const byCase = targets.find(t => t.case_id === caseId);
    if (byCase) return byCase;
  }

  return null;
}

// Calculate consensus score for a target
async function calculateConsensusScore(supabase: any, targetId: string) {
  const { data: votes, error } = await supabase
    .from("community_votes")
    .select("metric_id, vote_value")
    .eq("target_id", targetId);

  if (error || !votes) {
    return { score: 0, totalVotes: 0 };
  }

  // Group votes by metric
  const metricVotes: Record<number, number[]> = {};
  votes.forEach((vote: any) => {
    if (vote.metric_id == null || vote.vote_value == null) return;
    if (!metricVotes[vote.metric_id]) {
      metricVotes[vote.metric_id] = [];
    }
    metricVotes[vote.metric_id].push(vote.vote_value);
  });

  // Calculate average per metric, then overall average
  const metricAverages: number[] = [];
  let totalVoteCount = 0;

  Object.values(metricVotes).forEach((voteValues) => {
    const metricAvg = voteValues.reduce((sum: number, v: number) => sum + v, 0) / voteValues.length;
    metricAverages.push(metricAvg);
    totalVoteCount += voteValues.length;
  });

  const averageScore = metricAverages.length > 0
    ? metricAverages.reduce((sum, avg) => sum + avg, 0) / metricAverages.length
    : 0;

  // Normalize to 0-100 scale (votes are 1-5)
  const normalizedScore = Math.round((averageScore / 5) * 100);

  return { score: normalizedScore, totalVotes: totalVoteCount };
}

// Generate HTML with meta tags
function generateMetaHTML(config: {
  title: string;
  description: string;
  url: string;
  image: string;
  imageAlt: string;
  type?: string;
}): string {
  const { title, description, url, image, imageAlt, type = 'website' } = config;
  const siteName = 'Forecast Audit';

  return `<!DOCTYPE html>
<html lang="en" class="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>

  <!-- SEO Meta Tags -->
  <meta name="description" content="${description}" />
  <link rel="canonical" href="${url}" />

  <!-- OpenGraph Meta Tags -->
  <meta property="og:title" content="${title}" />
  <meta property="og:description" content="${description}" />
  <meta property="og:type" content="${type}" />
  <meta property="og:url" content="${url}" />
  <meta property="og:image" content="${image}" />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta property="og:image:alt" content="${imageAlt}" />
  <meta property="og:site_name" content="${siteName}" />

  <!-- Twitter Card Meta Tags -->
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="${title}" />
  <meta name="twitter:description" content="${description}" />
  <meta name="twitter:image" content="${image}" />
  <meta name="twitter:image:alt" content="${imageAlt}" />

  <script type="text/javascript" src="https://appleid.cdn-apple.com/appleauth/static/jsapi/appleid/1/en_US/appleid.auth.js"></script>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,1,0">
  <link type="text/css" href="https://fonts.googleapis.com/css2?family=Google+Symbols:opsz,wght,FILL,GRAD,ROND@24,400,0,0,50&amp;icon_names=link" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet" />
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>`;
}

export default async (request: Request, context: Context) => {
  const url = new URL(request.url);
  const pathname = url.pathname;
  const userAgent = request.headers.get('user-agent');

  console.log('[Edge Function] Triggered for:', pathname);
  console.log('[Edge Function] User-Agent:', userAgent);
  console.log('[Edge Function] Is crawler:', isCrawler(userAgent));

  // Only process crawler requests
  if (!isCrawler(userAgent)) {
    console.log('[Edge Function] Not a crawler, passing through');
    return context.next();
  }

  console.log('[Edge Function] Processing crawler request');

  // Initialize Supabase client
  const supabaseUrl = Deno.env.get('VITE_SUPABASE_URL');
  const supabaseAnonKey = Deno.env.get('VITE_SUPABASE_KEY');

  if (!supabaseUrl || !supabaseAnonKey) {
    console.error('Missing Supabase environment variables');
    return context.next();
  }

  const supabase = createClient(supabaseUrl, supabaseAnonKey);

  try {
    // Handle /global-consensus/:slug
    const consensusSlug = extractSlug(pathname, '/global-consensus');
    if (consensusSlug) {
      // Fetch all targets
      const { data: targets, error: targetsError } = await supabase
        .from("targets")
        .select("*")
        .order("created_at", { ascending: false });

      if (targetsError || !targets || targets.length === 0) {
        return context.next();
      }

      // Find target by slug
      const target = findTargetBySlug(targets, consensusSlug);
      if (!target) {
        return context.next();
      }

      // Calculate consensus score
      const { score, totalVotes } = await calculateConsensusScore(supabase, target.id);

      // Generate OG image URL
      const ogImageUrl = `${url.origin}/.netlify/functions/og-scorecard?targetName=${encodeURIComponent(target.name)}&score=${score}&totalVotes=${totalVotes}`;

      // Generate HTML with meta tags
      const html = generateMetaHTML({
        title: `Global Consensus: ${target.name} | Forecast Audit`,
        description: `Network consensus reveals forecast patterns across all verified audit nodes. ${target.name} - Score: ${score}/100`,
        url: `${url.origin}${pathname}`,
        image: ogImageUrl,
        imageAlt: `Global Consensus: ${target.name} - Score ${score}/100`,
        type: 'article',
      });

      return new Response(html, {
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'Cache-Control': 'public, max-age=3600, s-maxage=3600',
        },
      });
    }

    // Handle /audit-target/:slug
    const auditSlug = extractSlug(pathname, '/audit-target');
    if (auditSlug) {
      // Fetch all targets
      const { data: targets, error: targetsError } = await supabase
        .from("targets")
        .select("*")
        .order("created_at", { ascending: false });

      if (targetsError || !targets || targets.length === 0) {
        return context.next();
      }

      // Find target by slug
      const target = findTargetBySlug(targets, auditSlug);
      if (!target) {
        return context.next();
      }

      // Generate OG image URL using og-target function
      const ogImageUrl = `${url.origin}/.netlify/functions/og-target?targetName=${encodeURIComponent(target.name)}&caseId=${encodeURIComponent(target.case_id || '')}&author=${encodeURIComponent(target.author || 'FVS Network')}`;

      // Generate HTML with meta tags
      const html = generateMetaHTML({
        title: `Audit Target: ${target.case_id || target.name} | Forecast Audit`,
        description: `Submit forecast audit scores using the 10-metric framework. Evaluate specificity, attribution, actionability, and forecast utility for ${target.name}.`,
        url: `${url.origin}${pathname}`,
        image: ogImageUrl,
        imageAlt: `Audit Target: ${target.case_id || target.name}`,
        type: 'article',
      });

      return new Response(html, {
        headers: {
          'Content-Type': 'text/html; charset=utf-8',
          'Cache-Control': 'public, max-age=3600, s-maxage=3600',
        },
      });
    }

    // Not a recognized route, pass through
    return context.next();

  } catch (error) {
    console.error('Edge function error:', error);
    return context.next();
  }
};
