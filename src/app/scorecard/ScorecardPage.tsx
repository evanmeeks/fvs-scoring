"use client";

import dynamic from "next/dynamic";
import { LandingView } from "~/components/views/LandingView";

const ScorecardPanel = dynamic(
  () =>
    import("~/components/views/landing/ScorecardPanel").then(
      (mod) => mod.ScorecardPanel,
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

export function ScorecardPage() {
  return (
    <LandingView>
      <ScorecardPanel />
    </LandingView>
  );
}
