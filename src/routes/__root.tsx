/* eslint-disable @typescript-eslint/no-explicit-any */
import { useEffect, useMemo, useState } from "react";
import {
  createRootRoute,
  Outlet,
  useNavigate,
  useLocation,
} from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/react-router-devtools";
import Header from "../components/Header";
import Sidebar from "../components/Sidebar";
import Scanline from "../components/Scanline";
import Inspector from "../components/Inspector";
import SubmissionModal from "../components/SubmissionModal";
import FloatingActionButton from "../components/FloatingActionButton";
import AuthModal from "../components/AuthModal";
import TargetSelectionModal from "../components/TargetSelectionModal";
import ForecastTargetSubmissionModal from "../components/ForecastTargetSubmissionModal";
import DiscussionModal from "../components/DiscussionModal";
import Toast from "../components/Toast";
import { AppContextProvider, useApp } from "../context/AppContext";
import { supabase } from "../utils/supabase";
import { useSubmitRFC, useSubmitTargetSubmission } from "../hooks/useSupabase";
import "../main.css";
import { AuthProvider, useAuth } from "../context/AuthContext";

import type { Database } from "../types/supabase";

type MetricRow = Database["public"]["Tables"]["metrics"]["Row"];
type TargetSubmissionInsert =
  Database["public"]["Tables"]["target_submissions"]["Insert"];

export const Route = createRootRoute({
  loader: async () => {
    const { data, error } = await supabase
      .from("metrics")
      .select("*")
      .order("id", { ascending: true });

    if (error) {
      console.error("Supabase fetch failed for metrics.", error);
      return { metrics: [] };
    }

    if (!data || data.length === 0) {
      return { metrics: [] };
    }

    const metrics = (data as MetricRow[]).map((m) => ({
      id: m.id,
      name: m.name,
      question: m.question,
      criteria: m.criteria,
      min: m.min_val ?? undefined,
      max: m.max_val ?? undefined,
      communityScore: Number(m.community_score),
      category: m.category,
      scoringCriteria: m.scoring_criteria || [],
      lowDescription: m.low_description,
      highDescription: m.high_description,
    }));

    return { metrics };
  },
  component: RootWrapper,
  notFoundComponent: () => (
    <div className="flex items-center justify-center h-screen bg-background">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-primary mb-4">404</h1>
        <p className="text-text-secondary mb-6">Page not found</p>
        <a href="/" className="text-primary hover:underline">
          Return to home
        </a>
      </div>
    </div>
  ),
});

function RootWrapper() {
  const { metrics } = Route.useLoaderData();
  return (
    <AppContextProvider initialMetrics={metrics}>
      <AuthProvider>
        <RootComponent />
      </AuthProvider>
    </AppContextProvider>
  );
}

function RootComponent() {
  const {
    totalScore,
    scoreInterpretation,
    isInspectorOpen,
    selectedMetric,
    setIsInspectorOpen,
    setSubmissionModalOpen,
    submissionModalOpen,
    targetSelectionModalOpen,
    setTargetSelectionModalOpen,
    activeTarget,
    setActiveTarget,
    authModalOpen,
    setAuthModalOpen,
  } = useApp();

  const { user, isAdmin, isContributor, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const isAuthPage = useMemo(
    () => ["/login", "/logout"].includes(location.pathname),
    [location.pathname],
  );

  // Sidebar should only appear on the governance page
  const isGovernancePage = location.pathname === "/contributors/governance";

  const shouldShowSidebar = useMemo(
    () => user && !isAuthPage && isGovernancePage,
    [user, isAuthPage, isGovernancePage],
  );

  // Pages that should have no padding (landing/public pages)
  const isPublicPage =
    ["/", "/manifesto", "/scorecard", "/audit", "/public"].includes(
      location.pathname,
    ) ||
    location.pathname.startsWith("/audit-target") ||
    location.pathname.startsWith("/global-consensus");

  const shouldShowHeader = !isAuthPage;

  const [targetSubmissionModalOpen, setTargetSubmissionModalOpen] =
    useState(false);
  const [discussionModalOpen, setDiscussionModalOpen] = useState(false);
  type ToastState = {
    message: string;
    type?: "success" | "error" | "warning" | "info";
  };
  const [toast, setToast] = useState<ToastState | null>(null);

  const { submitRFC } = useSubmitRFC();
  const { submitTarget } = useSubmitTargetSubmission();

  const handleLogin = () => setAuthModalOpen(true);

  const handleLogout = async () => {
    await logout();
    navigate({ to: "/logout" });
  };

  const handleTargetSelect = (target: any) => {
    if (!target) return;

    // Generate the slug for the target
    const generateSlug = (t: any) => {
      const caseId = t.case_id || t.caseId || "FVS-000";
      const targetName = (t.name || "")
        .replace(/\s+/g, "_")
        .replace(/[^a-zA-Z0-9_-]/g, "");
      return `${caseId}-${targetName}`;
    };

    const slug = generateSlug(target);

    // Navigate to the appropriate route with the new slug
    if (location.pathname.startsWith("/scoring")) {
      navigate({
        to: "/scoring/$targetId",
        params: { targetId: target.id },
        replace: true,
      });
    } else if (location.pathname.startsWith("/audit-target")) {
      navigate({
        to: "/audit-target/$slug",
        params: { slug },
        replace: true,
      });
    } else if (location.pathname.startsWith("/global-consensus")) {
      navigate({
        to: "/global-consensus/$slug",
        params: { slug },
        replace: true,
      });
    } else {
      setActiveTarget(target);
    }
  };

  const handleSubmitRFC = async (formData: any, mode: string) => {
    try {
      if (!user) {
        setToast({ message: "You must be logged in.", type: "error" });
        return;
      }

      let backendProposalType = "new_metric";
      let finalRationale = formData.rationale;

      if (mode === "rfc") {
        backendProposalType = "modify_existing";
        if (formData.richEntries) {
          finalRationale = `${formData.rationale}\n\n${formData.richEntries}`;
        }
      }

      const payload = {
        metricId: parseInt(formData.targetMetric, 10),
        proposalType: backendProposalType,
        proposedName: formData.metricName,
        proposedQuestion: formData.metricQuestion,
        proposedMinCriteria: formData.minCriteria,
        proposedMaxCriteria: formData.maxCriteria,
        rationale: finalRationale,
        richEntries: formData.richEntries || null,
      };

      const result: any = await submitRFC(payload);
      setToast({ message: "Proposal submitted", type: "success" });
      setSubmissionModalOpen(false);

      // Navigate to result page
      // RPC typically returns the ID or the row. Handling both.
      const newId =
        typeof result === "string" ? result : result?.id || result?.[0]?.id;

      if (newId) {
        navigate({
          to: "/submissions/rfc/$id",
          params: { id: newId },
        });
      }
    } catch (err: any) {
      console.error(err);
      setToast({ message: err?.message || "Submission failed", type: "error" });
    }
  };

  const handleSubmitTarget = async (formData: any) => {
    try {
      if (!user) {
        setToast({ message: "You must be logged in.", type: "error" });
        handleLogin();
        return;
      }

      const payload: TargetSubmissionInsert = {
        target_name: formData.targetName,
        case_id: formData.caseId || null,
        origin: formData.origin || null,
        context: formData.context || null,
        description: formData.description,
        source_url: formData.sourceUrl || null,
        claim_date: formData.claimDate,
        primary_source: formData.primarySource || null,
        additional_notes: formData.additionalNotes || null,
        submitted_by: user.id,
        status: "pending",
      };

      const result = await submitTarget(payload);
      setToast({
        message: "Target submitted successfully! It will be reviewed soon.",
        type: "success",
      });
      setTargetSubmissionModalOpen(false);

      // Navigate to result page
      const newId = result?.[0]?.id;
      if (newId) {
        navigate({
          to: "/submissions/target/$id",
          params: { id: newId },
        });
      }
    } catch (err: any) {
      console.error(err);
      setToast({
        message:
          err?.message ||
          "Failed to submit forecast target. Please try again.",
        type: "error",
      });
    }
  };

  useEffect(() => {
    setIsInspectorOpen(Boolean(selectedMetric));
  }, [selectedMetric, setIsInspectorOpen]);

  return (
    <div className="bg-background text-text h-screen overflow-hidden flex flex-col relative">
      <Scanline />

      {shouldShowHeader && (
        <Header
          user={user}
          isAdmin={isAdmin}
          isContributor={isContributor}
          onLogin={handleLogin}
          onLogout={handleLogout}
          onOpenTargetEntry={() => setTargetSubmissionModalOpen(true)}
        />
      )}

      <div className="flex flex-1 overflow-hidden relative">
        {!isAuthPage && shouldShowSidebar && (
          <Sidebar
            activeTarget={activeTarget}
            totalScore={totalScore}
            scoreInterpretation={scoreInterpretation}
            onTargetClick={() => setTargetSelectionModalOpen(true)}
          />
        )}

        <main className="flex-1 min-w-0 overflow-auto">
          <div className={isPublicPage ? "" : "px-6 py-8"}>
            <Outlet />
          </div>
        </main>

        {isInspectorOpen && selectedMetric && (
          <Inspector
            metric={selectedMetric}
            onClose={() => setIsInspectorOpen(false)}
            user={user}
            onRequireAuth={handleLogin}
            onSubmitRFC={() => setSubmissionModalOpen(true)}
            onViewDiscussion={() => setDiscussionModalOpen(true)}
          />
        )}
      </div>

      <SubmissionModal
        isOpen={submissionModalOpen}
        onClose={() => setSubmissionModalOpen(false)}
        onSubmit={handleSubmitRFC}
        user={user}
        onRequireAuth={handleLogin}
        metricId={selectedMetric?.id?.toString()}
      />

      <FloatingActionButton
        onClick={() => setTargetSubmissionModalOpen(true)}
        onRequireAuth={handleLogin}
        user={user}
      />

      <AuthModal
        isOpen={authModalOpen}
        onClose={() => setAuthModalOpen(false)}
      />

      <TargetSelectionModal
        isOpen={targetSelectionModalOpen}
        onClose={() => setTargetSelectionModalOpen(false)}
        currentTarget={activeTarget}
        onSelectTarget={handleTargetSelect}
      />

      <ForecastTargetSubmissionModal
        isOpen={targetSubmissionModalOpen}
        onClose={() => setTargetSubmissionModalOpen(false)}
        onSubmit={handleSubmitTarget}
        user={user}
        onRequireAuth={handleLogin}
      />

      {discussionModalOpen && selectedMetric && (
        <DiscussionModal
          isOpen={discussionModalOpen}
          onClose={() => setDiscussionModalOpen(false)}
          metricId={Number(selectedMetric.id)}
          metricName={selectedMetric.name || "Metric"}
          user={user}
          onRequireAuth={handleLogin}
        />
      )}

      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}

      <TanStackRouterDevtools position="bottom-right" />
    </div>
  );
}
