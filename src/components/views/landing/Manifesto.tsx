export const Manifesto = () => {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 animate-fade-in">
      <div className="prose prose-invert prose-cyan max-w-none">
        <h1 className="font-mono border-b border-ops-border pb-4 mb-8">
          The FVS Philosophy
        </h1>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div className="bg-ops-panel p-6 border-l-2 border-ops-accent">
            <h3 className="mt-0 font-mono text-ops-accent uppercase text-sm">
              Purpose
            </h3>
            <p className="text-sm">
              To evaluate whether a media claim, forecast, or public statement
              materially advances understanding or merely occupies narrative
              space.
            </p>
          </div>
          <div className="bg-ops-panel p-6 border-l-2 border-red-500">
            <h3 className="mt-0 font-mono text-red-500 uppercase text-sm">
              Anti-Goal
            </h3>
            <p className="text-sm">
              To reject performative claims, narrative laundering, and
              confirmatory repetition that lacks verification vectors.
            </p>
          </div>
        </div>

        <h3 className="text-white font-mono">Core Interrogation</h3>
        <blockquote className="text-xl font-light italic border-l-4 border-gray-700 pl-4 my-6 text-gray-300">
          &quot;Does this claim move us closer to verifiable truth,
          accountability, or material insight — or does it stall, redirect,
          monetize, or mythologize?&quot;
        </blockquote>

        <h3 className="text-white font-mono mt-12">Methodology</h3>
        <p>
          FVS applies forecast verification principles to evaluate
          <em> information quality</em> in media claims and prediction markets.
          The framework measures directional value — whether a claim advances
          understanding or adds noise.
        </p>
        <ul className="list-disc pl-5 space-y-2 text-gray-400">
          <li>
            <strong>High FVS:</strong> Specific, verifiable, actionable claims
            with clear causal reasoning.
          </li>
          <li>
            <strong>Low FVS:</strong> Vague assertions, unfalsifiable
            predictions, or recycled narratives without new information.
          </li>
          <li>
            The scoring system tracks contributor credibility over time, similar
            to prediction market reputation systems.
          </li>
        </ul>

        <div className="mt-12 pt-8 border-t border-ops-border text-center text-xs text-gray-600 font-mono">
          <p>FORECAST VERIFICATION FRAMEWORK // PROTOTYPE V1.0</p>
        </div>
      </div>
    </div>
  );
};
