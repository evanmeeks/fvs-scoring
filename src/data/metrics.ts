// FVS Protocol: Standard 20 Metrics for Forecast Verification
// This is the authoritative local definition - matches database schema
// Database is primary source of truth; this serves as fallback/reference

export type MetricDefinition = {
  id: number;
  name: string;
  question: string;
  low: string;
  high: string;
};

export const FVS_METRICS: MetricDefinition[] = [
  { id: 1, name: "Specificity of Claims", question: "Are concrete entities, documents, programs, locations, or mechanisms named?", low: "Pure abstraction, no specifics", high: "Names entities and explains relevance" },
  { id: 2, name: "Causal Direction", question: "Does the claim explain how the information advances understanding?", low: "No causal link", high: "Clear cause → effect → outcome chain" },
  { id: 3, name: "Actionability", question: "Can investigators, journalists, or institutions act on this?", low: "No possible follow-up", high: "Clear next steps (FOIA, hearings)" },
  { id: 4, name: "Information Novelty", question: "Is this meaningfully new intelligence?", low: "Recycled lore / rebranded history", high: "Previously undisclosed / new evidence" },
  { id: 5, name: "Attribution Integrity", question: "Are sources, origins, and prior work properly acknowledged?", low: "Laundered ideas", high: "Clear lineage of ideas" },
  { id: 6, name: "Risk Assumed", question: "Does the claim impose real cost or risk on the speaker?", low: "Zero risk, monetized", high: "Legal/Professional risk" },
  { id: 7, name: "Resistance to Myth", question: "Is the information grounded, or mythologized?", low: "Archetypal, savior/villain framing", high: "Clinical, procedural, non-mythic" },
  { id: 8, name: "Institutional Targeting", question: "Does it challenge real power structures?", low: "Targets abstractions", high: "Names accountable offices/agencies" },
  { id: 9, name: "Timing Coherence", question: "Does timing serve truth, not hype cycles?", low: "Synchronized with media launches", high: "Truth-first timing" },
  { id: 10, name: "Intelligence Discipline", question: "Is operational literacy demonstrated?", low: "No understanding of ops", high: "Demonstrates tradecraft literacy" },
  { id: 11, name: "Contradiction Resolution", question: "Are inconsistencies addressed directly?", low: "Ignores past contradictions", high: "Explicitly reconciles conflict" },
  { id: 12, name: "Incentive Transparency", question: "Are financial interests disclosed or minimized?", low: "Hidden monetization", high: "Clear separation from profit" },
  { id: 13, name: "Information Density", question: "Signal-to-noise ratio?", low: "Long-form vagueness", high: "High-density, low-fluff" },
  { id: 14, name: "External Verifiability", question: "Can third parties validate elements independently?", low: "No verification path", high: "Clear verification vectors" },
  { id: 15, name: "Vector Direction", question: "Does this push toward resolution or perpetual theater?", low: "Endless tease", high: "Collapses ambiguity" },
  { id: 16, name: "Network Dependence", question: "Is credibility borrowed from closed ecosystems?", low: "Circular validation", high: "Independent of influencer networks" },
  { id: 17, name: "History Accuracy", question: "Is intelligence history handled competently?", low: "Naïve/Mythic history", high: "Accurate use of precedents" },
  { id: 18, name: "Pressure Resilience", question: "Does the claim survive adversarial questioning?", low: "Collapses under scrutiny", high: "Strengthens under pressure" },
  { id: 19, name: "Strategic Coherence", question: "Is there an identifiable long-term strategy?", low: "Chaotic/Opportunistic", high: "Coherent long-range arc" },
  { id: 20, name: "Net Information Value", question: "Does this reduce uncertainty or increase it?", low: "Increases confusion", high: "Meaningfully clarifies terrain" }
];

export type QddMetric = (typeof FVS_METRICS)[number];
