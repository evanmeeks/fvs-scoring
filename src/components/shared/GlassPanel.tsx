/**
 * Glass Panel Component
 * Reusable glass morphism panel with corner markers
 */

import type { ReactNode } from "react";

interface GlassPanelProps {
    children: ReactNode;
    className?: string;
}

export function GlassPanel({ children, className = "" }: GlassPanelProps) {
    return (
        <div
            className={`relative bg-[#0a0a0a]/80 backdrop-blur-sm border border-white/10 shadow-2xl ${className}`}
        >
            {children}
            {/* Decorative corner markers - simplified */}
            <div className="absolute rounded-tl top-0 left-0 w-1.5 h-1.5 border-t-2 border-l-2 border-green-500/40"></div>
            <div className="absolute rounded-tr top-0 right-0 w-1.5 h-1.5 border-t-2 border-r-2 border-green-500/40"></div>
            <div className="absolute rounded-bl bottom-0 left-0 w-1.5 h-1.5 border-b-2 border-l-2 border-green-500/40"></div>
            <div className="absolute rounded-br bottom-0 right-0 w-1.5 h-1.5 border-b-2 border-r-2 border-green-500/40"></div>
        </div>
    );
}

export default GlassPanel;
