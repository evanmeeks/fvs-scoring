import Icon from "./Icon";
import { useApp } from "../context/AppContext";

type ModalProps = {
  isOpen: boolean;
  onClose: () => void;
};

const Modal = ({ isOpen, onClose }: ModalProps) => {
    const { FVS_METRICS } = useApp();
    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-md z-50 flex items-center justify-center p-4 animate-fade-in">
            <div className="bg-panel w-full max-w-2xl border border-border rounded-lg shadow-2xl flex flex-col max-h-[90vh] scale-100 animate-slide-up">
                <div className="p-4 border-b border-border flex justify-between items-center bg-surface rounded-t-lg">
                    <div className="flex items-center gap-2 text-white">
                        <Icon name="add_comment" className="text-primary" />
                        <h3 className="font-bold text-lg font-mono">Submit Contribution</h3>
                    </div>
                    <button className="text-text-muted hover:text-white" onClick={onClose}>
                        <Icon name="close" />
                    </button>
                </div>

                <div className="p-6 overflow-y-auto space-y-5">
                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label htmlFor="modal-target-metric" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">Target Metric</label>
                            <select id="modal-target-metric" className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all">
                                {FVS_METRICS.map(m => <option key={m.id} value={m.id}>{m.id} - {m.category}</option>)}
                            </select>
                        </div>
                        <div>
                            <label htmlFor="modal-contribution-type" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">Contribution Type</label>
                            <select id="modal-contribution-type" className="w-full bg-background border border-border text-white p-2.5 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary transition-all">
                                <option>RFC (Request for Comment)</option>
                                <option>Score Verification</option>
                                <option>Context Addendum</option>
                            </select>
                        </div>
                    </div>

                    <div>
                        <label htmlFor="modal-rationale" className="block text-[10px] font-bold text-text-muted uppercase mb-1.5">Rationale / Data</label>
                        <textarea
                            id="modal-rationale"
                            className="w-full h-40 bg-background border border-border text-white p-3 rounded text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary font-mono leading-relaxed transition-all resize-none"
                            placeholder="Enter your analysis, citing specific timestamps or documents where applicable..."
                        ></textarea>
                    </div>
                </div>

                <div className="p-4 border-t border-border bg-surface rounded-b-lg flex justify-end gap-3">
                    <button className="px-5 py-2.5 rounded border border-border text-text-muted hover:text-white text-xs font-bold uppercase tracking-wide transition-colors" onClick={onClose}>Cancel</button>
                    <button className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20" onClick={onClose}>Submit to Ledger</button>
                </div>
            </div>
        </div>
    );
};

export default Modal;
