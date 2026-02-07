import { type Metadata } from "next";
import { createClient } from "~/lib/supabase/server";
import { findTargetBySlugFromDb } from "~/utils/targets";
import { AuditTargetPage } from "./AuditTargetPage";

type Props = {
  params: Promise<{ slug: string }>;
};

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;

  // Fetch target data server-side for SEO
  let targetName = slug;
  let caseId = slug;
  try {
    const supabase = await createClient();
    const target = await findTargetBySlugFromDb(supabase, slug);
    if (target) {
      targetName = target.name;
      caseId = target.case_id ?? slug;
    }
  } catch {
    // Fall back to slug if target not found
  }

  const title = `Audit Target: ${caseId}`;
  const description = `Submit forecast audit scores using the 10-metric framework. Evaluate specificity, attribution, actionability, and forecast utility for ${targetName}.`;

  return {
    title,
    description,
    openGraph: {
      title: `${title} | Forecast Audit`,
      description,
      type: "article",
      url: `/audit-target/${slug}`,
    },
    twitter: {
      card: "summary_large_image",
      title: `${title} | Forecast Audit`,
      description,
    },
  };
}

export default async function Page({ params }: Props) {
  const { slug } = await params;
  return <AuditTargetPage slug={slug} />;
}
