import { useEffect, useMemo } from 'react'
import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { createAuditTargetHeadConfig } from '../utils/seo'
import { AuditScorer } from '../components/views/landing/AuditScorer'
import { useTargetsWithScores } from '../hooks/useTargetsWithScores'
import { generateTargetSlug, findTargetBySlug } from '../utils/urlSlug'
import { normalizeTarget } from '../utils/targets'
import { useApp } from '../context/AppContext'
import { supabase } from '../utils/supabase'

export const Route = createFileRoute('/_landing/audit-target/$slug')({
    loader: async ({ params }) => {
        try {
            // Fetch targets to get the target data
            const { data: targets, error: targetsError } = await supabase
                .from("targets")
                .select("*")
                .order("created_at", { ascending: false });

            if (targetsError) throw targetsError;
            if (!targets || targets.length === 0) return null;

            // Find target by slug
            const target = findTargetBySlug(targets, params.slug);
            if (!target) return null;

            return {
                targetName: target.name,
                caseId: target.case_id,
                author: target.author,
            };
        } catch (error) {
            console.error("Error loading target data:", error);
            return null;
        }
    },
    head: ({ params, loaderData }) => {
        return createAuditTargetHeadConfig({
            slug: params.slug,
            targetName: loaderData?.targetName,
            caseId: loaderData?.caseId,
            author: loaderData?.author,
        });
    },
    component: AuditTargetComponent,
})

function AuditTargetComponent() {
    const { slug } = Route.useParams();
    const navigate = useNavigate();
    const { data: targets } = useTargetsWithScores();
    const { setActiveTarget } = useApp();

    // Find target by slug
    const targetFromSlug = useMemo(() => {
        if (!slug || !targets || targets.length === 0) return null;
        return findTargetBySlug(targets, slug);
    }, [slug, targets]);



    // Sync URL slug to AppContext activeTarget
    useEffect(() => {
        if (targetFromSlug) {
            const normalized = normalizeTarget(targetFromSlug);
            if (normalized) {
                setActiveTarget(normalized);
            }
        }
    }, [targetFromSlug, setActiveTarget]);

    // Redirect to first target if slug is invalid
    useEffect(() => {
        if (!slug || (!targetFromSlug && Array.isArray(targets) && targets.length > 0)) {
            const fallback = targets?.[0];
            if (fallback) {
                const fallbackSlug = generateTargetSlug(fallback);
                console.warn(`Invalid or missing slug '${slug}'. Redirecting to ${fallbackSlug}`);
                navigate({
                    to: '/audit-target/$slug',
                    params: { slug: fallbackSlug },
                    replace: true,
                });
            }
        }
    }, [slug, targetFromSlug, targets, navigate]);

    return (
        <AuditScorer />
    )
}
