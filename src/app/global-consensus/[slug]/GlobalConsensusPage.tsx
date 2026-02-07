"use client";

import dynamic from "next/dynamic";
import { LandingView } from "~/components/views/LandingView";

const ConsensusView = dynamic(
  () =>
    import("~/components/views/landing/ConsensusView").then(
      (mod) => mod.ConsensusView,
    ),
  {
    loading: () => (
      <div className="flex items-center justify-center py-20">
        <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-ops-accent" />
      </div>
    ),
    ssr: false,
  },
);

export function GlobalConsensusPage({ slug }: { slug: string }) {
  return (
    <LandingView>
      <ConsensusView activeTargetSlug={slug} />
    </LandingView>
  );
}
