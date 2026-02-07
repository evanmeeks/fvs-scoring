import { type Metadata } from "next";
import { ScorecardPage } from "./ScorecardPage";

export const metadata: Metadata = {
  title: "Scorecard",
  description:
    "View aggregated scores and community consensus for forecast targets.",
  openGraph: {
    title: "Scorecard | Forecast Audit",
    description:
      "View aggregated scores and community consensus for forecast targets.",
    type: "website",
    url: "/scorecard",
  },
};

export default function Page() {
  return <ScorecardPage />;
}
