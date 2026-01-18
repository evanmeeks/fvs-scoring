import {
  createContext,
  useContext,
  useState,
  useMemo,
  useEffect,
  type ReactNode,
} from "react";
import type { Database } from "../types/supabase";
import {
  useUserVotesForTarget,
  useTargets,
  useMetrics,
} from "../hooks/useSupabase";
import { normalizeTarget, type NormalizedTarget } from "../utils/targets";

type UserVoteRpcResponse = {
  confidence_level: string;
  metric_id: number;
  metric_name: string;
  rationale: string;
  vote_value: number;
  voted_at: string;
};


type MetricFromDB = Database["public"]["Tables"]["metrics"]["Row"] & {
  scoring_criteria?: ScoringCriterion[];
  low_description?: string;
  high_description?: string;
};

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

type AppContextValue = {
  scores: ScoreMap;
  setScores: React.Dispatch<React.SetStateAction<ScoreMap>>;
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
  activeTarget: Target;
  setActiveTarget: React.Dispatch<React.SetStateAction<Target>>;
  selectedMetric: Metric | undefined;
  setSelectedMetric: (metric: Metric | null | undefined) => void;
  totalScore: number;
  scoreInterpretation: ScoreInterpretation;
  handleScoreChange: (id: string | number, val: number | string) => void;
  handleMetricClick: (id: string | number) => void;
  FVS_METRICS: Metric[];
  authModalOpen: boolean;
  setAuthModalOpen: React.Dispatch<React.SetStateAction<boolean>>;
  isLoadingMetrics: boolean;
};

type AppContextProviderProps = {
  children: ReactNode;
  initialMetrics?: Metric[];
};

const AppContext = createContext<AppContextValue | undefined>(undefined);

export const AppContextProvider = ({
  children,
  initialMetrics = [],
}: AppContextProviderProps) => {
  // Fetch metrics from Supabase
  const { data: rawSupabaseMetrics, loading: loadingMetrics } = useMetrics();

  // Normalize Supabase metrics to match internal schema (camelCase)
  const normalizedSupabaseMetrics = useMemo(() => {
    if (!rawSupabaseMetrics) return null;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    return rawSupabaseMetrics.map((m: any) => {
      const metric = m as MetricFromDB;
      return {
        id: metric.id,
        name: metric.name,
        question: metric.question,
        criteria: metric.criteria,
        min: metric.min_val ?? undefined,
        max: metric.max_val ?? undefined,
        communityScore: Number(metric.community_score),
        category: metric.category,
        scoringCriteria: metric.scoring_criteria || [],
        lowDescription: metric.low_description,
        highDescription: metric.high_description,
      };
    });
  }, [rawSupabaseMetrics]);

  // Use Supabase metrics if available, otherwise use initialMetrics passed from loader
  const metrics: Metric[] = normalizedSupabaseMetrics?.length
    ? normalizedSupabaseMetrics
    : initialMetrics;
  const FVS_METRICS: Metric[] = metrics;

  const [scores, setScores] = useState<ScoreMap>(
    metrics.reduce<ScoreMap>((acc, m) => ({ ...acc, [m.id]: 0 }), {})
  );
  const [selectedMetricId, setSelectedMetricId] = useState<
    number | string | null
  >(null);
  const [isInspectorOpen, setIsInspectorOpen] = useState(false);
  const [submissionModalOpen, setSubmissionModalOpen] = useState(false);
  const [targetSelectionModalOpen, setTargetSelectionModalOpen] =
    useState(false);
  const [authModalOpen, setAuthModalOpen] = useState(false);
  const [activeTarget, setActiveTarget] = useState<Target>({
    id: "grusch-2024",
    name: "Grusch_T_2024",
    caseId: "NCI-8.3-XREF-FVS",
    origin: "ic_national",
    context: "congressional_hearing",
    verified: true,
    description: "David Grusch UAP disclosure testimony before Congress",
  });

  // Sync scores with DB
  const { data: userVotesData } = useUserVotesForTarget(activeTarget.id);
  const { data: availableTargets, loading: loadingTargets } = useTargets();

  const normalizedTargets = useMemo(() => {
    if (!availableTargets || availableTargets.length === 0) return [];
    return availableTargets.map(normalizeTarget).filter(Boolean) as Target[];
  }, [availableTargets]);

  // Validate Active Target against DB
  useEffect(() => {
    if (loadingTargets || normalizedTargets.length === 0) {
      return;
    }

    const currentIsValid = normalizedTargets.find(
      (t) => t.id === activeTarget?.id
    );

    if (!currentIsValid) {
      const fallback = normalizedTargets[0];
      console.warn(
        `Active target ${activeTarget?.id} no longer valid. Switching to ${fallback.name}`
      );
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setActiveTarget(fallback);
    } else if (
      JSON.stringify(currentIsValid) !== JSON.stringify(activeTarget)
    ) {
      setActiveTarget(currentIsValid);
    }
  }, [normalizedTargets, activeTarget, loadingTargets]);

  // Initialize scores when metrics load (only once)
  const [hasInitializedScores, setHasInitializedScores] = useState(false);
  useEffect(() => {
    if (normalizedSupabaseMetrics && normalizedSupabaseMetrics.length > 0 && !hasInitializedScores) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setScores(
        normalizedSupabaseMetrics.reduce<ScoreMap>(
          (acc: ScoreMap, m: Metric) => ({ ...acc, [m.id]: 0 }),
          {}
        )
      );
      setHasInitializedScores(true);
    }
  }, [normalizedSupabaseMetrics, hasInitializedScores]);

  // Load user votes for the active target (runs after initialization)
  useEffect(() => {
    if (!userVotesData || !hasInitializedScores) return;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setScores((prevScores) => {
      const newScores = { ...prevScores };
      userVotesData.forEach((v: UserVoteRpcResponse) => {
        if (v.metric_id !== null && v.vote_value !== null) {
          newScores[v.metric_id] = v.vote_value;
        }
      });
      return newScores;
    });
  }, [userVotesData, hasInitializedScores]);

  // Reset scores when active target changes
  useEffect(() => {
    if (!hasInitializedScores) return;
    // Reset all scores to 0 when target changes
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setScores((prevScores) => {
      const resetScores = { ...prevScores };
      Object.keys(resetScores).forEach(key => {
        resetScores[key] = 0;
      });
      return resetScores;
    });
  }, [activeTarget.id, hasInitializedScores]);

  const selectedMetric = useMemo(
    () => FVS_METRICS.find((m) => m.id === selectedMetricId),
    [selectedMetricId, FVS_METRICS]
  );

  const totalScore = Object.values(scores).reduce((a, b) => a + b, 0);

  const getScoreInterpretation = (score: number): ScoreInterpretation => {
    if (score === 0)
      return {
        text: "Awaiting Data",
        style: "border-text-muted text-text-muted",
      };
    if (score <= 25)
      return {
        text: "Narrative Occ.",
        style: "border-red-950 text-red-500 bg-red-900/20",
      };
    if (score <= 50)
      return {
        text: "Ambiguous",
        style: "border-amber-900/30 text-amber-500 bg-amber-900/20",
      };
    if (score <= 75)
      return {
        text: "Verified Forecast",
        style: "border-blue-950 text-blue-400 bg-blue-900/20",
      };
    if (score <= 90)
      return {
        text: "High-Value Forecast",
        style: "border-green-900/30 text-primary bg-green-900/20",
      };
    return {
      text: "Strategic Event",
      style: "border-white text-white bg-white/20 font-bold",
    };
  };

  const scoreInterpretation = getScoreInterpretation(totalScore);

  const handleScoreChange = (id: string | number, val: number | string) => {
    const parsed = typeof val === "number" ? val : parseInt(val, 10);
    // Ensure we don't set NaN values - default to 0
    setScores((prev) => ({ ...prev, [id]: isNaN(parsed) ? 0 : parsed }));
  };

  const handleMetricClick = (id: string | number) => {
    if (selectedMetricId === id && isInspectorOpen) {
      setIsInspectorOpen(false);
      setSelectedMetricId(null);
    } else {
      setSelectedMetricId(id);
      setIsInspectorOpen(true);
    }
  };

  const setSelectedMetric = (metric: Metric | null | undefined) => {
    setSelectedMetricId((metric?.id as number | string | undefined) ?? null);
  };

  const value = {
    scores,
    setScores,
    selectedMetricId,
    setSelectedMetricId,
    isInspectorOpen,
    setIsInspectorOpen,
    submissionModalOpen,
    setSubmissionModalOpen,
    targetSelectionModalOpen,
    setTargetSelectionModalOpen,
    activeTarget,
    setActiveTarget,
    selectedMetric,
    setSelectedMetric,
    totalScore,
    scoreInterpretation,
    handleScoreChange,
    handleMetricClick,
    FVS_METRICS,
    authModalOpen,
    setAuthModalOpen,
    isLoadingMetrics: loadingMetrics,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error("useApp must be used within an AppContextProvider");
  }
  return context;
};
