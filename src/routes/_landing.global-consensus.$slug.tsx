import { useEffect, useMemo } from "react";
import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { createGlobalConsensusHeadConfig } from "../utils/seo";
import { ConsensusView } from "../components/views/landing/ConsensusView";
import { useTargetsWithScores } from "../hooks/useTargetsWithScores";
import { generateTargetSlug, findTargetBySlug } from "../utils/urlSlug";
import { normalizeTarget } from "../utils/targets";
import { useApp } from "../context/AppContext";
import { supabase } from "../utils/supabase";

export const Route = createFileRoute("/_landing/global-consensus/$slug")({
    loader: async ({ params }) => {
        try {
            // Fetch targets with scores to get the target data
            const { data: targets, error: targetsError } = await supabase
                .from("targets")
                .select("*")
                .order("created_at", { ascending: false });

            if (targetsError) throw targetsError;
            if (!targets || targets.length === 0) return null;

            // Find target by slug
            const target = findTargetBySlug(targets, params.slug);
            if (!target) return null;

            // Fetch votes for this specific target to calculate score
            const { data: votes, error: votesError } = await supabase
                .from("community_votes")
                .select("metric_id, vote_value")
                .eq("target_id", target.id);

            if (votesError) {
                console.warn("Failed to fetch votes for target", votesError);
                return {
                    targetName: target.name,
                    score: 0,
                    totalVotes: 0,
                };
            }

            // Calculate average score
            const metricVotes: Record<number, number[]> = {};
            (votes || []).forEach((vote) => {
                if (vote.metric_id == null || vote.vote_value == null) return;
                if (!metricVotes[vote.metric_id]) {
                    metricVotes[vote.metric_id] = [];
                }
                metricVotes[vote.metric_id].push(vote.vote_value);
            });

            const metricAverages: number[] = [];
            let totalVoteCount = 0;

            Object.values(metricVotes).forEach((voteValues) => {
                const metricAvg = voteValues.reduce((sum, v) => sum + v, 0) / voteValues.length;
                metricAverages.push(metricAvg);
                totalVoteCount += voteValues.length;
            });

            const averageScore = metricAverages.length > 0
                ? metricAverages.reduce((sum, avg) => sum + avg, 0) / metricAverages.length
                : 0;

            // Normalize to 0-100 scale for OG image
            const normalizedScore = Math.round((averageScore / 5) * 100);

            return {
                targetName: target.name,
                score: normalizedScore,
                totalVotes: totalVoteCount,
            };
        } catch (error) {
            console.error("Error loading target data:", error);
            return null;
        }
    },
    head: ({ params, loaderData }) => {
        return createGlobalConsensusHeadConfig({
            slug: params.slug,
            targetName: loaderData?.targetName,
            score: loaderData?.score,
            totalVotes: loaderData?.totalVotes,
        });
    },
    component: GlobalConsensusComponent,
});

function GlobalConsensusComponent() {
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
                    to: '/global-consensus/$slug',
                    params: { slug: fallbackSlug },
                    replace: true,
                });
            }
        }
    }, [slug, targetFromSlug, targets, navigate]);

    return (
        <ConsensusView activeTargetSlug={slug} />
    );
}
