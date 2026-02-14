/**
 * SEO Meta Tag Utilities
 * Generates consistent OpenGraph and Twitter Card meta tags for all shareable pages
 */

const SITE_NAME = 'Forecast Audit'
const DEFAULT_DESCRIPTION = 'Forecast Audit — a collaborative framework for evaluating media claims and predictions using key quality metrics.'
const DEFAULT_IMAGE = '/og-image.png' // Placeholder - replace with actual OG image

/**
 * Get the origin URL for canonical links
 */
export function getOrigin() {
    if (typeof window !== 'undefined' && window.location?.origin) {
        return window.location.origin
    }
    return ''
}

export type HeadConfigOptions = {
    title: string;
    description: string;
    path: string;
    image?: string;
    imageAlt?: string;
    type?: string;
    noindex?: boolean;
};

/**
 * Generate head() config for TanStack Router routes
 */
export function createHeadConfig(options: HeadConfigOptions) {
    const {
        title,
        description,
        path,
        image = DEFAULT_IMAGE,
        imageAlt,
        type = 'website',
        noindex = false,
    } = options;
    const origin = getOrigin() || 'https://forecastaudit.pro'
    const fullTitle = `${title} | ${SITE_NAME}`
    const canonicalUrl = origin ? `${origin}${path}` : path
    const imageUrl = image.startsWith('http') ? image : `${origin}${image}`
    const defaultImageAlt = `${title} - Forecast Audit`

    const meta = [
        // Basic meta
        { name: 'description', content: description },

        // OpenGraph
        { property: 'og:title', content: fullTitle },
        { property: 'og:description', content: description },
        { property: 'og:type', content: type },
        { property: 'og:url', content: canonicalUrl },
        { property: 'og:image', content: imageUrl },
        { property: 'og:image:width', content: '1200' },
        { property: 'og:image:height', content: '630' },
        { property: 'og:image:alt', content: imageAlt || defaultImageAlt },
        { property: 'og:site_name', content: SITE_NAME },

        // Twitter Card
        { name: 'twitter:card', content: 'summary_large_image' },
        { name: 'twitter:title', content: fullTitle },
        { name: 'twitter:description', content: description },
        { name: 'twitter:image', content: imageUrl },
        { name: 'twitter:image:alt', content: imageAlt || defaultImageAlt },
    ]

    // Check Netlify context
    // We cast to any because VITE_NETLIFY_CONTEXT is injected via define in vite.config.js
    const netlifyContext = (import.meta as unknown as { env: { VITE_NETLIFY_CONTEXT?: string } }).env.VITE_NETLIFY_CONTEXT;
    const isNonProductionDeploy = netlifyContext === 'deploy-preview' || netlifyContext === 'branch-deploy';

    // Add noindex for private pages OR non-production deploys
    if (noindex || isNonProductionDeploy) {
        meta.push({ name: 'robots', content: 'noindex, nofollow' })
    }

    return {
        title: fullTitle,
        meta,
        links: [
            { rel: 'canonical', href: canonicalUrl },
        ],
    }
}

/**
 * Generate slug from target data
 * Format: [Case ID]-[Target Name]+[Primary Source Name]
 * @param {Object} target
 * @param {string} target.caseId - Case ID (e.g., 'Grusch_T_2024')
 * @param {string} target.name - Target name
 * @param {string} [target.origin] - Primary source name (optional)
 */
export function generateTargetSlug(target: { caseId?: string; name: string; origin?: string | null }) {
    if (!target) return ''

    const { caseId, name, origin } = target

    // Use caseId if available, otherwise sanitize name
    const baseSlug = caseId || sanitizeSlug(name)

    // Append origin if available
    if (origin) {
        return `${baseSlug}+${sanitizeSlug(origin)}`
    }

    return baseSlug
}

/**
 * Sanitize a string for use in URL slug
 * @param {string} str
 */
export function sanitizeSlug(str: string) {
    if (!str) return ''
    return str
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '')
}

/**
 * SEO configs for specific pages
 */
export const PAGE_SEO = {
    home: {
        title: 'Home',
        description: DEFAULT_DESCRIPTION,
        path: '/',
    },
    scorecard: {
        title: 'Scorecard',
        description: 'View aggregated scores and community consensus for forecast targets.',
        path: '/scorecard',
    },
    manifesto: {
        title: 'Manifesto',
        description: 'The Manifesto — principles and methodology behind Forecast Audit.',
        path: '/manifesto',
    },
    governance: {
        title: 'Governance',
        description: 'Contributor governance portal for metric proposals and voting.',
        path: '/contributors/governance',
        noindex: true, // Contributor-only page
    },
    admin: {
        title: 'Admin',
        description: 'Administration Panel',
        path: '/admin',
        noindex: true, // Admin-only page
    },
}

/**
 * Generate OG image URL for shared scorecards
 * @param {Object} params - Scorecard parameters
 */
export function generateScorecardOgImageUrl(params: {
    targetId: string;
    targetName: string;
    userName?: string;
    score?: number;
}): string {
    const origin = getOrigin()
    const baseUrl = origin || 'https://forecastaudit.pro'

    const searchParams = new URLSearchParams({
        targetId: params.targetId,
        targetName: params.targetName,
        userName: params.userName || 'Anonymous',
        score: params.score?.toFixed(2) || '0',
    })

    return `${baseUrl}/.netlify/functions/og-scorecard?${searchParams.toString()}`
}

/**
 * Generate head config for scoring target pages
 * @param {string} targetId - Target ID from URL params
 */
export function createScoringHeadConfig(targetId: string) {
    const slug = targetId || 'grusch-2024';
    const imageText = encodeURIComponent(`Scoring: ${slug}`);
    return createHeadConfig({
        title: `Scoring: ${slug}`,
        description: `Community scoring and consensus tracking for forecast target ${slug}.`,
        path: `/scoring/${slug}`,
        type: 'article',
        image: `https://placehold.co/1200x630/050505/06b6d4?text=${imageText}&font=roboto`,
        imageAlt: `Scorecard for ${slug}`
    })
}

/**
 * Generate head config for shared scorecard pages
 * @param {Object} params - Scorecard parameters
 */
export function createSharedScorecardHeadConfig(params: {
    targetId: string;
    targetName: string;
    userName?: string;
    score?: number;
    userId: string;
}) {
    const title = `${params.targetName} Scorecard`
    const description = params.score
        ? `Score: ${params.score.toFixed(1)} — ${params.targetName} scored by ${params.userName || 'Anonymous'}`
        : `View scorecard for ${params.targetName}`

    return createHeadConfig({
        title,
        description,
        path: `/share/scorecard/${params.targetId}/${params.userId}`,
        type: 'article',
        image: generateScorecardOgImageUrl(params),
        imageAlt: `Scorecard: ${params.targetName} - Score ${params.score?.toFixed(1) || 'N/A'}`
    })
}

/**
 * Generate OG image URL for target submissions
 * @param {Object} params - Target submission parameters
 */
export function generateTargetOgImageUrl(params: {
    targetName: string;
    caseId?: string;
    author?: string;
    origin?: string;
}): string {
    const origin = getOrigin()
    const baseUrl = origin || 'https://forecastaudit.pro'

    const searchParams = new URLSearchParams({
        targetName: params.targetName,
        author: params.author || 'Anonymous',
    })

    if (params.caseId) searchParams.set('caseId', params.caseId)
    if (params.origin) searchParams.set('origin', params.origin)

    return `${baseUrl}/.netlify/functions/og-target?${searchParams.toString()}`
}

/**
 * Generate head config for target submission pages
 * @param {Object} submission - Target submission data
 */
export function createTargetSubmissionHeadConfig(submission?: {
    target_name: string;
    case_id?: string | null;
    description: string;
    author?: string;
    origin?: string;
}) {
    if (!submission) {
        return createHeadConfig({
            title: 'Target Submission',
            description: 'View target submission proposal',
            path: '/submissions/target',
            type: 'article',
        })
    }

    const title = submission.case_id
        ? `${submission.case_id}: ${submission.target_name}`
        : submission.target_name;

    return createHeadConfig({
        title: `Target: ${title}`,
        description: submission.description.substring(0, 160) + (submission.description.length > 160 ? '...' : ''),
        path: '/submissions/target',
        type: 'article',
        image: generateTargetOgImageUrl({
            targetName: submission.target_name,
            caseId: submission.case_id || undefined,
            author: submission.author,
            origin: submission.origin,
        }),
        imageAlt: title
    })
}

/**
 * Generate OG image URL for RFC proposals
 * @param {Object} params - RFC parameters
 */
export function generateRfcOgImageUrl(params: {
    title: string;
    status: string;
    author?: string;
    votesFor?: number;
    votesAgainst?: number;
}): string {
    const origin = getOrigin()
    const baseUrl = origin || 'https://forecastaudit.pro'

    const searchParams = new URLSearchParams({
        title: params.title,
        status: params.status,
        author: params.author || 'Anonymous',
    })

    if (params.votesFor !== undefined) searchParams.set('votesFor', params.votesFor.toString())
    if (params.votesAgainst !== undefined) searchParams.set('votesAgainst', params.votesAgainst.toString())

    return `${baseUrl}/.netlify/functions/og-rfc?${searchParams.toString()}`
}

/**
 * Generate head config for RFC proposal pages
 * @param {Object} rfc - RFC proposal data
 */
export function createRFCHeadConfig(rfc?: {
    title: string;
    description: string;
    status: string;
    author?: string;
    votesFor?: number;
    votesAgainst?: number;
}) {
    if (!rfc) {
        return createHeadConfig({
            title: 'RFC Proposal',
            description: 'View metric RFC proposal and community voting',
            path: '/submissions/rfc',
            type: 'article',
        })
    }

    return createHeadConfig({
        title: `RFC: ${rfc.title}`,
        description: `${rfc.status.toUpperCase()} - ${rfc.description.substring(0, 140)}${rfc.description.length > 140 ? '...' : ''}`,
        path: '/submissions/rfc',
        type: 'article',
        image: generateRfcOgImageUrl({
            title: rfc.title,
            status: rfc.status,
            author: rfc.author,
            votesFor: rfc.votesFor,
            votesAgainst: rfc.votesAgainst,
        }),
        imageAlt: rfc.title
    })
}

/**
 * Generate OG image URL for global consensus pages
 * @param {Object} params - Global consensus parameters
 */
export function generateGlobalConsensusOgImageUrl(params: {
    targetName: string;
    score: number; // 0-100 normalized score
    totalVotes?: number;
}): string {
    const origin = getOrigin()
    const baseUrl = origin || 'https://forecastaudit.pro'

    const searchParams = new URLSearchParams({
        targetName: params.targetName,
        score: params.score.toString(),
    })

    if (params.totalVotes !== undefined) {
        searchParams.set('totalVotes', params.totalVotes.toString())
    }

    return `${baseUrl}/.netlify/functions/og-scorecard?${searchParams.toString()}`
}

/**
 * Generate head config for global consensus pages
 * @param {Object} params - Global consensus parameters
 */
export function createGlobalConsensusHeadConfig(params: {
    slug: string;
    targetName?: string;
    score?: number;
    totalVotes?: number;
}) {
    const title = params.targetName
        ? `Global Consensus: ${params.targetName}`
        : `Global Consensus - ${params.slug}`

    const description = params.score !== undefined
        ? `Network consensus reveals forecast patterns across all verified audit nodes. ${params.targetName} - Score: ${params.score}/100`
        : 'Network consensus reveals forecast patterns across all verified audit nodes. View aggregate intelligence and classification distribution.'

    const image = params.targetName && params.score !== undefined
        ? generateGlobalConsensusOgImageUrl({
            targetName: params.targetName,
            score: params.score,
            totalVotes: params.totalVotes,
        })
        : undefined

    return createHeadConfig({
        title,
        description,
        path: `/global-consensus/${params.slug}`,
        type: 'article',
        image,
        imageAlt: params.targetName
            ? `Global Consensus: ${params.targetName} - Score ${params.score || 'N/A'}/100`
            : undefined,
    })
}

/**
 * Generate head config for audit-target pages
 * @param {Object} params - Audit target parameters
 */
export function createAuditTargetHeadConfig(params: {
    slug: string;
    targetName?: string;
    caseId?: string | null;
    author?: string;
}) {
    const caseIdDisplay = params.caseId || params.slug;
    const title = params.targetName
        ? `Audit Target: ${params.caseId || params.targetName}`
        : `Audit Target - ${caseIdDisplay}`

    const description = params.targetName
        ? `Submit forecast audit scores using the 10-metric framework. Evaluate specificity, attribution, actionability, and forecast utility for ${params.targetName}.`
        : 'Submit forecast audit scores using the 10-metric framework. Evaluate specificity, attribution, actionability, and forecast utility.'

    // No OG image in meta tags for audit pages since scores are dynamic
    // ShareButton generates the OG image dynamically when user clicks share
    const image = undefined

    return createHeadConfig({
        title,
        description,
        path: `/audit-target/${params.slug}`,
        type: 'article',
        image,
        imageAlt: params.targetName
            ? `Audit Target: ${params.caseId || params.targetName}`
            : undefined,
    })
}
