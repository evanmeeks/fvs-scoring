"use client";

import { LandingView } from "./LandingView";
import { CurrentTargetsView } from "./landing/CurrentTargetsView";

export function LandingPage() {
  return (
    <LandingView>
      <CurrentTargetsView />
    </LandingView>
  );
}
