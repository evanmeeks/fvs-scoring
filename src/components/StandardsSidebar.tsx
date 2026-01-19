import ActivityLog from './ActivityLog';

const StandardsSidebar = () => {
    return (
        <aside className="w-72 bg-panel border-r border-border flex flex-col shrink-0 hidden lg:flex h-full">
            <div className="p-5 border-b border-border bg-background/50">
                <h2 className="text-[10px] font-bold text-text-muted uppercase tracking-widest mb-4">Workspace Context</h2>
                <div className="space-y-5 animate-fade-in">
                    <div className="bg-surface border border-border p-4 rounded shadow-sm">
                        <div className="text-[10px] text-text-muted mb-1 uppercase tracking-wide">Standard Version</div>
                        <div className="font-bold text-white text-sm flex items-center justify-between">FVS Metric Set v1.0<span
                            className="w-2 h-2 rounded-full bg-green-500"></span></div>
                    </div>
                    <div>
                        <div className="text-xs text-text-muted mb-2 flex justify-between font-mono"><span>Consensus
                            Progress</span><span>85%</span></div>
                        <div className="h-1 bg-border rounded-full overflow-hidden">
                            <div className="h-full bg-primary w-[85%] shadow-[0_0_10px_rgba(0,255,65,0.4)]"></div>
                        </div>
                    </div>
                    <div
                        className="text-xs text-text-muted leading-relaxed p-3 bg-blue-900/10 border border-blue-900/30 rounded text-blue-200/80">
                        <strong className="text-blue-400 block mb-1">Objective:</strong>Refine metrics to distinguish high-value
                        intelligence from narrative occupation.</div>
                </div>
            </div>
            <div className="flex-1 overflow-hidden flex flex-col">
                <div className="p-4 pb-0">
                    <h3 className="text-[10px] font-bold text-text-muted uppercase tracking-widest">Recent Activity</h3>
                </div>
                <div className="flex-1 overflow-y-auto p-4 custom-scrollbar">
                    <ActivityLog />
                </div>
            </div>
        </aside>
    );
};

export default StandardsSidebar;
