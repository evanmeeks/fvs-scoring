import Icon from "./Icon";
import TargetMetadata from "./TargetMetadata";
import SidebarFooter from "./SidebarFooter";

type ScoringSidebarProps = {
  totalScore: number;
  scoreInterpretation: { text: string; style: string };
  activeTarget?: { name?: string; caseId?: string } | null;
  onTargetClick?: () => void;
};

const ScoringSidebar = ({
  totalScore,
  scoreInterpretation,
  activeTarget,
  onTargetClick,
}: ScoringSidebarProps) => {
  return (
    <aside className="w-72 border-r border-border bg-panel flex flex-col shrink-0">
      <div className="p-6 border-b border-border">
        <div className="text-[10px] text-text-muted mono mb-4">
          ACTIVE_TARGET
        </div>
        <div
          role="button"
          tabIndex={0}
          onClick={onTargetClick}
          onKeyDown={(e) => {
            if (e.key === "Enter" || e.key === " ") {
              e.preventDefault();
              onTargetClick?.();
            }
          }}
          aria-label="Change active target"
          className="bg-background border border-border p-3 rounded-md group hover:border-primary transition-all cursor-pointer"
        >
          <div className="flex justify-between items-center">
            <span className="text-xs font-bold text-white">
              {activeTarget?.name || "No Target Selected"}
            </span>
            <Icon
              name="arrow_forward_ios"
              className="text-xs text-text-muted"
            />
          </div>
          <div className="text-[10px] text-text-muted mt-1 truncate">
            Case ID: {activeTarget?.caseId || "N/A"}
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-6 space-y-6 custom-scrollbar">
        <TargetMetadata />

        <div id="scoring-sidebar-info">
          <div className="text-[10px] text-text-muted mono mb-4 uppercase">
            Live Aggregation
          </div>
          <div className="bg-border/30 rounded p-4 text-center border border-border/50">
            <div className="text-[10px] text-text-muted uppercase mb-1">
              FVS Score
            </div>
            <div className="text-4xl font-bold mono text-white">
              {totalScore}
            </div>
            <div
              className={`text-[9px] mt-2 py-1 px-2 rounded bg-black uppercase ${scoreInterpretation.style.replace("bg-", "text-").replace("border-", "border-transparent ")}`}
            >
              {scoreInterpretation.text}
            </div>
          </div>
        </div>

        <div>
          <div className="text-[10px] text-text-muted mono mb-4 uppercase">
            Legend
          </div>
          <div className="space-y-2 text-[10px] mono text-text-muted">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-red-600"></div> 0-25
              Narrative Occupation
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-amber-500"></div> 26-50
              Ambiguous Utility
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-blue-500"></div> 51-75
              Verified Forecast
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-primary"></div> 76-90
              High-Value Forecast
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-white"></div> 91+
              Strategic Event
            </div>
          </div>
        </div>
      </div>

      <SidebarFooter />
    </aside>
  );
};

export default ScoringSidebar;
