import { useState, useEffect } from "react";
// import { FVS_METRICS } from '../../../data/metrics'; // Removed
import { useAuth } from "../../../context/AuthContext";
import AuthModal from "../../../components/AuthModal";
import { useApp } from "../../../context/AppContext";

interface VoteState {
  vote?: string;
  comment?: string;
}

export const GovernanceTable = () => {
  const { isAuthenticated } = useAuth();
  const { FVS_METRICS } = useApp();
  const [votes, setVotes] = useState<Record<string, VoteState>>({});
  const [showLoginModal, setShowLoginModal] = useState(false);
  const [pendingAction, setPendingAction] = useState<{
    id: string;
    field: "vote" | "comment";
    value: string;
  } | null>(null);

  // Watch for auth state changes to execute pending actions
  useEffect(() => {
    if (isAuthenticated && pendingAction) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setVotes((prev) => ({
        ...prev,
        [pendingAction.id]: {
          ...prev[pendingAction.id],
          [pendingAction.field]: pendingAction.value,
        },
      }));
      setPendingAction(null);
      setShowLoginModal(false);
    }
  }, [isAuthenticated, pendingAction]);

  const handleVoteChange = (
    id: string,
    field: "vote" | "comment",
    value: string,
  ) => {
    if (!isAuthenticated) {
      setPendingAction({ id, field, value });
      setShowLoginModal(true);
      return;
    }

    setVotes((prev) => ({
      ...prev,
      [id]: { ...prev[id], [field]: value },
    }));
  };

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 animate-fade-in relative">
      <AuthModal
        isOpen={showLoginModal}
        onClose={() => {
          setShowLoginModal(false);
          setPendingAction(null);
        }}
      />

      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-white">
          Protocol Governance Table
        </h2>
        <button
          onClick={() => handleVoteChange("global", "vote", "export")}
          className="px-4 py-2 bg-ops-accent text-black font-bold text-sm font-mono rounded hover:bg-cyan-400 transition-colors"
        >
          Export Contributions
        </button>
      </div>

      <div className="bg-ops-panel border border-ops-border rounded-lg overflow-x-auto">
        <table className="w-full text-left border-collapse min-w-[800px]">
          <thead>
            <tr className="bg-ops-black border-b border-ops-border text-xs font-mono uppercase text-ops-text-dim">
              <th className="p-4 w-12 text-center">Ver</th>
              <th className="p-4 w-1/4">Metric Name</th>
              <th className="p-4 w-1/3">Current Definition</th>
              <th className="p-4 w-48">Action Vote</th>
              <th className="p-4">Notes</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-ops-border text-sm text-gray-300">
            {FVS_METRICS.map((m) => (
              <tr key={m.id} className="hover:bg-white/5 transition-colors">
                <td className="p-4 text-center font-mono">
                  <span className="text-[10px] mono text-ops-text-dim">
                    v1.0
                  </span>
                </td>
                <td className="p-4 font-bold text-white">{m.name}</td>
                <td className="p-4 text-xs text-gray-400">
                  <div className="italic text-white">
                    "{String(m.coreQuestion || m.question || "")}"
                  </div>
                </td>
                <td className="p-4">
                  <select
                    className="bg-ops-black border border-ops-border text-xs rounded p-2 text-white w-full font-mono focus:border-ops-accent focus:outline-none"
                    onChange={(e) =>
                      handleVoteChange(String(m.id), "vote", e.target.value)
                    }
                    value={votes[String(m.id)]?.vote || "keep"}
                  >
                    <option value="keep">KEEP (Endorse)</option>
                    <option value="modify">MODIFY (Edit)</option>
                    <option value="drop">DROP (Remove)</option>
                  </select>
                </td>
                <td className="p-4">
                  <input
                    type="text"
                    placeholder="Add notes..."
                    className="w-full bg-transparent border-b border-transparent focus:border-ops-accent text-white text-xs py-1 outline-none transition-colors"
                    onChange={(e) =>
                      handleVoteChange(String(m.id), "comment", e.target.value)
                    }
                    value={votes[String(m.id)]?.comment || ""}
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
