import { type Metadata } from "next";
import { createClient } from "~/lib/supabase/server";
import { findTargetBySlugFromDb } from "~/utils/targets";
import { GlobalConsensusPage } from "./GlobalConsensusPage";

type Props = {
  params: Promise<{ slug: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;

  let targetName = slug;
  let score: number | undefined;
  try {
    const supabase = await createClient();
    const target = await findTargetBySlugFromDb(supabase, slug);
    if (target) {
      targetName = target.name;
    }
  } catch {
    // Fall back to slug
  }

  const title = `Global Consensus: ${targetName}`;
  const description =
    score !== undefined
      ? `Network consensus reveals forecast patterns across all verified audit nodes. ${targetName} - Score: ${score}/100`
      : "Network consensus reveals forecast patterns across all verified audit nodes. View aggregate intelligence and classification distribution.";

  const ogImageUrl = `/api/og/scorecard?targetName=${encodeURIComponent(targetName)}&score=${score ?? 0}`;

  return {
    title,
    description,
    openGraph: {
      title: `${title} | Forecast Audit`,
      description,
      type: "article",
      url: `/global-consensus/${slug}`,
      images: [{ url: ogImageUrl, width: 1200, height: 630 }],
    },
    twitter: {
      card: "summary_large_image",
      title: `${title} | Forecast Audit`,
      description,
      images: [ogImageUrl],
    },
  };
}

export default async function Page({ params }: Props) {
  const { slug } = await params;
  return <GlobalConsensusPage slug={slug} />;
}
