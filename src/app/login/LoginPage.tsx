"use client";

import { createClient } from "~/lib/supabase/client";

export function LoginPage() {
  const supabase = createClient();

  const handleOAuthLogin = async (
    provider: "google" | "apple" | "github" | "azure" | "discord",
  ) => {
    await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    });
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-background">
      <div className="w-full max-w-md rounded-lg border border-ops-border bg-ops-panel p-8">
        <h1 className="mb-2 text-center text-2xl font-bold text-white">
          Sign In
        </h1>
        <p className="mb-8 text-center text-sm text-ops-text-dim">
          Sign in to submit scores and participate in governance
        </p>

        <div className="space-y-3">
          <button
            onClick={() => handleOAuthLogin("google")}
            className="flex w-full items-center justify-center gap-3 rounded-lg border border-ops-border bg-background px-4 py-3 text-sm font-medium text-white transition-colors hover:border-ops-accent/50 hover:bg-ops-panel"
          >
            Continue with Google
          </button>

          <button
            onClick={() => handleOAuthLogin("apple")}
            className="flex w-full items-center justify-center gap-3 rounded-lg border border-ops-border bg-background px-4 py-3 text-sm font-medium text-white transition-colors hover:border-ops-accent/50 hover:bg-ops-panel"
          >
            Continue with Apple
          </button>

          <button
            onClick={() => handleOAuthLogin("github")}
            className="flex w-full items-center justify-center gap-3 rounded-lg border border-ops-border bg-background px-4 py-3 text-sm font-medium text-white transition-colors hover:border-ops-accent/50 hover:bg-ops-panel"
          >
            Continue with GitHub
          </button>

          <button
            onClick={() => handleOAuthLogin("discord")}
            className="flex w-full items-center justify-center gap-3 rounded-lg border border-ops-border bg-background px-4 py-3 text-sm font-medium text-white transition-colors hover:border-ops-accent/50 hover:bg-ops-panel"
          >
            Continue with Discord
          </button>
        </div>

        <div className="mt-6 text-center">
          <a
            href="/"
            className="text-sm text-ops-text-dim hover:text-ops-accent"
          >
            &larr; Back to home
          </a>
        </div>
      </div>
    </div>
  );
}
