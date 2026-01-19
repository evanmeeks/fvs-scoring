import React from "react";

type ErrorBoundaryState = {
    hasError: boolean;
    error: Error | null;
};

type ErrorBoundaryProps = {
    children: React.ReactNode;
};

class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
    constructor(props: ErrorBoundaryProps) {
        super(props);
        this.state = { hasError: false, error: null };
    }

    static getDerivedStateFromError(error: Error) {
        return { hasError: true, error };
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
        console.error("Uncaught error:", error, errorInfo);
    }

    render() {
        if (this.state.hasError) {
            return (
                <div className="h-screen w-screen bg-[#050505] text-white flex flex-col items-center justify-center p-8 font-mono">
                    <div className="border border-red-500/50 bg-red-900/10 p-6 rounded-lg max-w-2xl w-full">
                        <h1 className="text-xl font-bold text-red-500 mb-4 flex items-center gap-2">
                            <span className="material-symbols-outlined">warning</span>
                            SYSTEM MALFUNCTION
                        </h1>
                        <p className="text-gray-300 mb-4">
                            A critical error has occurred in the rendering pipeline.
                        </p>
                        <div className="bg-black/50 p-4 rounded text-xs text-red-300 overflow-auto max-h-48 border border-white/10">
                            {this.state.error?.toString()}
                        </div>
                        <button
                            onClick={() => window.location.reload()}
                            className="mt-6 bg-red-600 hover:bg-red-500 text-white font-bold py-2 px-4 rounded text-sm uppercase tracking-wider transition-colors"
                        >
                            System Reboot
                        </button>
                    </div>
                </div>
            );
        }

        return this.props.children;
    }
}

export default ErrorBoundary;
