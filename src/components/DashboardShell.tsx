"use client";

import { usePathname } from "next/navigation";
import { useUI } from "~/context/AppContext";
import { Inspector } from "~/components/Inspector";
import { FloatingActionButton } from "~/components/FloatingActionButton";
import { StandardsSidebar } from "~/components/sidebars/StandardsSidebar";
import { SubmissionModal } from "~/components/modals/SubmissionModal";
import { ForecastTargetSubmissionModal } from "~/components/modals/ForecastTargetSubmissionModal";
import { TargetSelectionModal } from "~/components/modals/TargetSelectionModal";
import { DiscussionModal } from "~/components/modals/DiscussionModal";

export function DashboardShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const {
    isInspectorOpen,
    selectedMetricId,
    submissionModalOpen,
    targetSubmissionModalOpen,
    targetSelectionModalOpen,
    discussionModalOpen,
  } = useUI();
  const isGovernancePage = pathname === "/contributors/governance";

  return (
    <div className="flex flex-1 overflow-hidden">
      {isGovernancePage && <StandardsSidebar />}
      <main className="flex-1 min-w-0 overflow-auto">{children}</main>
      {(isInspectorOpen || selectedMetricId !== null) && <Inspector />}
      {submissionModalOpen && <SubmissionModal />}
      {targetSubmissionModalOpen && <ForecastTargetSubmissionModal />}
      {targetSelectionModalOpen && <TargetSelectionModal />}
      {discussionModalOpen && <DiscussionModal />}
      <FloatingActionButton />
    </div>
  );
}

export default DashboardShell;
