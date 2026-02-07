"use client";

import { useEffect, useState } from "react";
import { createClient } from "~/lib/supabase/client";
import { useTarget } from "~/context/AppContext";
import { normalizeTarget, findTargetBySlugFromDb } from "~/utils/targets";
import { AuditScorer } from "~/components/views/landing/AuditScorer";
import type { DbTarget } from "~/types/database";

export function AuditTargetPage({ slug }: { slug: string }) {
  const supabase = createClient();
  const [target, setTarget] = useState<DbTarget | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const { setActiveTarget } = useTarget();

  useEffect(() => {
    const fetch = async () => {
      const found = await findTargetBySlugFromDb(supabase, slug);
      setTarget(found);
      setIsLoading(false);
    };
    fetch();
  }, [slug, supabase]);

  // Set the active target in AppContext when it loads
  useEffect(() => {
    if (target) {
      const normalized = normalizeTarget(target);
      if (normalized) {
        setActiveTarget(normalized);
      }
    }
  }, [target, setActiveTarget]);

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-ops-accent"></div>
          <p className="text-ops-text-dim text-sm mt-4 font-mono">
            Loading audit target...
          </p>
        </div>
      </div>
    );
  }

  if (!target) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <div className="text-center">
          <h1 className="mb-2 text-2xl font-bold text-white">
            Target Not Found
          </h1>
          <p className="text-ops-text-dim">
            The audit target &quot;{slug}&quot; could not be found.
          </p>
          <a
            href="/"
            className="mt-4 inline-block text-ops-accent hover:underline"
          >
            Return home
          </a>
        </div>
      </div>
    );
  }

  return <AuditScorer />;
}
