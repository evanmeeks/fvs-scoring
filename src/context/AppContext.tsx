"use client";

import {
  createContext,
  useContext,
  useState,
  useMemo,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import { createClient } from "~/lib/supabase/client";
import { normalizeTarget, type NormalizedTarget } from "~/utils/targets";
import type { DbMetric } from "~/types/database";

/* eslint-disable @typescript-eslint/no-explicit-any */

// ─── Types ───────────────────────────────────────────────────────────

export type ScoringCriterion = {
  score: number;
  label: string;
  description: string;
};

export type Metric = {
  id: number | string;
  name?: string;
  question?: string;
  criteria?: string;
  min?: number;
  max?: number;
  communityScore?: number;
  category?: string;
  scoringCriteria?: ScoringCriterion[];
  lowDescription?: string;
  highDescription?: string;
  [key: string]: unknown;
};

type Target = NormalizedTarget;
type ScoreMap = Record<string | number, number>;

type ScoreInterpretation = {
  text: string;
  style: string;
};

// ─── Context Value Types ─────────────────────────────────────────────

type MetricsContextValue = {
  FVS_METRICS: Metric[];
  isLoadingMetrics: boolean;
};

type TargetContextValue = {
  activeTarget: Target;
  setActiveTarget: React.Dispatch<React.SetStateAction<Target>>;
};

type ScoringContextValue = {
  scores: ScoreMap;
  setScores: React.Dispatch<React.SetStateAction<ScoreMap>>;
  totalScore: number;
  scoreInterpretation: ScoreInterpretation;
  handleScoreChange: (id: string | number, val: number | string) => void;
};

type UIContextValue = {
  selectedMetricId: number | string | null;
  setSelectedMetricId: React.Dispatch<
    React.SetStateAction<number | string | null>
  >;
  isInspectorOpen: boolean;
  setIsInspectorOpen: React.Dispatch<React.SetStateAction<boolean>>;
  submissionModalOpen: boolean;
  setSubmissionModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  targetSelectionModalOpen: boolean;
  setTargetSelectionModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  targetSubmissionModalOpen: boolean;
  setTargetSubmissionModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  authModalOpen: boolean;
  setAuthModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  discussionModalOpen: boolean;
  setDiscussionModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  selectedMetric: Metric | undefined;
  setSelectedMetric: (metric: Metric | null | undefined) => void;
  handleMetricClick: (id: string | number) => void;
};

// ─── Defaults ────────────────────────────────────────────────────────

const defaultTarget: Target = {
  id: "",
  name: "",
  caseId: "",
  origin: "",
  context: "",
  verified: false,
  description: "",
};

// ─── Contexts ────────────────────────────────────────────────────────

const MetricsContext = createContext<MetricsContextValue | undefined>(
  undefined,
);
const TargetContext = createContext<TargetContextValue | undefined>(undefined);
const ScoringContext = createContext<ScoringContextValue | undefined>(
  undefined,
);
const UIContext = createContext<UIContextValue | undefined>(undefined);

// ─── Score Interpretation Helper ─────────────────────────────────────

function getScoreInterpretation(score: number): ScoreInterpretation {
  if (score === 0)
    return {
      text: "Awaiting Data",
      style: "border-text-muted text-text-muted",
    };
  if (score <= 25)
    return {
      text: "Low Confidence",
      style: "border-red-950 text-red-500 bg-red-900/20",
    };
  if (score <= 50)
    return {
      text: "Speculative",
      style: "border-amber-900/30 text-amber-500 bg-amber-900/20",
    };
  if (score <= 75)
    return {
      text: "Credible Forecast",
      style: "border-blue-950 text-blue-400 bg-blue-900/20",
    };
  if (score <= 90)
    return {
      text: "High-Confidence",
      style: "border-green-900/30 text-primary bg-green-900/20",
    };
  return {
    text: "Consensus Forecast",
    style: "border-white text-white bg-white/20 font-bold",
  };
}

// ─── Providers ───────────────────────────────────────────────────────

function MetricsProvider({ children }: { children: ReactNode }) {
  const supabase = createClient();
  const [rawMetrics, setRawMetrics] = useState<DbMetric[]>([]);
  const [loadingMetrics, setLoadingMetrics] = useState(true);

  useEffect(() => {
    const fetch = async () => {
      const { data, error } = await supabase
        .from("metrics")
        .select("*")
        .order("id");
      if (!error && data) setRawMetrics(data as DbMetric[]);
      setLoadingMetrics(false);
    };
    fetch();
  }, [supabase]);

  const normalizedMetrics = useMemo(() => {
    if (!rawMetrics) return [];
    return rawMetrics.map((m: DbMetric) => ({
      id: m.id,
      name: m.name,
      question: m.question,
      criteria: m.criteria,
      min: m.min_val ?? undefined,
      max: m.max_val ?? undefined,
      communityScore: Number(m.community_score),
      category: m.category,
      scoringCriteria: (m as any).scoring_criteria || [],
      lowDescription: (m as any).low_description,
      highDescription: (m as any).high_description,
    }));
  }, [rawMetrics]);

  const value = useMemo(
    () => ({
      FVS_METRICS: normalizedMetrics,
      isLoadingMetrics: loadingMetrics,
    }),
    [normalizedMetrics, loadingMetrics],
  );

  return (
    <MetricsContext.Provider value={value}>{children}</MetricsContext.Provider>
  );
}

function TargetProvider({ children }: { children: ReactNode }) {
  const supabase = createClient();
  const [availableTargets, setAvailableTargets] = useState<any[]>([]);
  const [loadingTargets, setLoadingTargets] = useState(true);
  const [activeTarget, setActiveTarget] = useState<Target>(defaultTarget);

  useEffect(() => {
    const fetch = async () => {
      const { data, error } = await supabase
        .from("targets")
        .select("*")
        .order("created_at", { ascending: false });
      if (!error && data) setAvailableTargets(data);
      setLoadingTargets(false);
    };
    fetch();
  }, [supabase]);

  const normalizedTargets = useMemo(() => {
    if (!availableTargets || availableTargets.length === 0) return [];
    return availableTargets.map(normalizeTarget).filter(Boolean) as Target[];
  }, [availableTargets]);

  // Validate active target against DB
  useEffect(() => {
    if (loadingTargets || normalizedTargets.length === 0) return;
    const currentIsValid = normalizedTargets.find(
      (t) => t.id === activeTarget?.id,
    );
    if (!currentIsValid && normalizedTargets[0]) {
      setActiveTarget(normalizedTargets[0]);
    }
  }, [normalizedTargets, activeTarget?.id, loadingTargets]);

  const value = useMemo(
    () => ({
      activeTarget,
      setActiveTarget,
    }),
    [activeTarget],
  );

  return (
    <TargetContext.Provider value={value}>{children}</TargetContext.Provider>
  );
}

function ScoringProvider({ children }: { children: ReactNode }) {
  const { FVS_METRICS } = useMetrics();
  const { activeTarget } = useTarget();

  const [scores, setScores] = useState<ScoreMap>({});
  const [hasInitializedScores, setHasInitializedScores] = useState(false);

  // Initialize scores when metrics load
  useEffect(() => {
    if (FVS_METRICS.length > 0 && !hasInitializedScores) {
      setScores(
        FVS_METRICS.reduce<ScoreMap>(
          (acc, m) => ({ ...acc, [m.id]: 0 }),
          {},
        ),
      );
      setHasInitializedScores(true);
    }
  }, [FVS_METRICS, hasInitializedScores]);

  // Reset scores when active target changes
  useEffect(() => {
    if (!hasInitializedScores) return;
    setScores((prevScores) => {
      const resetScores = { ...prevScores };
      Object.keys(resetScores).forEach((key) => {
        resetScores[key] = 0;
      });
      return resetScores;
    });
  }, [activeTarget.id, hasInitializedScores]);

  const totalScore = useMemo(
    () => Object.values(scores).reduce((a, b) => a + b, 0),
    [scores],
  );

  const scoreInterpretation = useMemo(
    () => getScoreInterpretation(totalScore),
    [totalScore],
  );

  const handleScoreChange = useCallback(
    (id: string | number, val: number | string) => {
      const parsed = typeof val === "number" ? val : parseInt(val, 10);
      setScores((prev) => ({ ...prev, [id]: isNaN(parsed) ? 0 : parsed }));
    },
    [],
  );

  const value = useMemo(
    () => ({
      scores,
      setScores,
      totalScore,
      scoreInterpretation,
      handleScoreChange,
    }),
    [scores, totalScore, scoreInterpretation, handleScoreChange],
  );

  return (
    <ScoringContext.Provider value={value}>{children}</ScoringContext.Provider>
  );
}

function UIProvider({ children }: { children: ReactNode }) {
  const { FVS_METRICS } = useMetrics();

  const [selectedMetricId, setSelectedMetricId] = useState<
    number | string | null
  >(null);
  const [isInspectorOpen, setIsInspectorOpen] = useState(false);
  const [submissionModalOpen, setSubmissionModalOpen] = useState(false);
  const [targetSelectionModalOpen, setTargetSelectionModalOpen] =
    useState(false);
  const [targetSubmissionModalOpen, setTargetSubmissionModalOpen] =
    useState(false);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [discussionModalOpen, setDiscussionModalOpen] = useState(false);

  const selectedMetric = useMemo(
    () => FVS_METRICS.find((m) => m.id === selectedMetricId),
    [selectedMetricId, FVS_METRICS],
  );

  const setSelectedMetric = useCallback(
    (metric: Metric | null | undefined) => {
      setSelectedMetricId(
        (metric?.id as number | string | undefined) ?? null,
      );
    },
    [],
  );

  const handleMetricClick = useCallback(
    (id: string | number) => {
      if (selectedMetricId === id && isInspectorOpen) {
        setIsInspectorOpen(false);
        setSelectedMetricId(null);
      } else {
        setSelectedMetricId(id);
        setIsInspectorOpen(true);
      }
    },
    [selectedMetricId, isInspectorOpen],
  );

  const value = useMemo(
    () => ({
      selectedMetricId,
      setSelectedMetricId,
      isInspectorOpen,
      setIsInspectorOpen,
      submissionModalOpen,
      setSubmissionModalOpen,
      targetSelectionModalOpen,
      setTargetSelectionModalOpen,
      targetSubmissionModalOpen,
      setTargetSubmissionModalOpen,
      authModalOpen,
      setAuthModalOpen,
      discussionModalOpen,
      setDiscussionModalOpen,
      selectedMetric,
      setSelectedMetric,
      handleMetricClick,
    }),
    [
      selectedMetricId,
      isInspectorOpen,
      submissionModalOpen,
      targetSelectionModalOpen,
      targetSubmissionModalOpen,
      authModalOpen,
      discussionModalOpen,
      selectedMetric,
      setSelectedMetric,
      handleMetricClick,
    ],
  );

  return <UIContext.Provider value={value}>{children}</UIContext.Provider>;
}

// ─── Combined Provider ───────────────────────────────────────────────

export const AppContextProvider = ({ children }: { children: ReactNode }) => {
  return (
    <MetricsProvider>
      <TargetProvider>
        <ScoringProvider>
          <UIProvider>{children}</UIProvider>
        </ScoringProvider>
      </TargetProvider>
    </MetricsProvider>
  );
};

// ─── Focused Hooks (use these for performance) ───────────────────────

export const useMetrics = () => {
  const context = useContext(MetricsContext);
  if (!context)
    throw new Error("useMetrics must be used within AppContextProvider");
  return context;
};

export const useTarget = () => {
  const context = useContext(TargetContext);
  if (!context)
    throw new Error("useTarget must be used within AppContextProvider");
  return context;
};

export const useScoring = () => {
  const context = useContext(ScoringContext);
  if (!context)
    throw new Error("useScoring must be used within AppContextProvider");
  return context;
};

export const useUI = () => {
  const context = useContext(UIContext);
  if (!context)
    throw new Error("useUI must be used within AppContextProvider");
  return context;
};

// Backward-compatible hook — subscribes to ALL contexts, so any change
// in any context triggers a re-render. Prefer focused hooks above.
export const useApp = () => {
  const metrics = useMetrics();
  const target = useTarget();
  const scoring = useScoring();
  const ui = useUI();
  return { ...metrics, ...target, ...scoring, ...ui };
};
