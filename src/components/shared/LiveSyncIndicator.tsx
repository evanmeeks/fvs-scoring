/**
 * Live Sync Indicator
 * Shows connection status (simplified version without SyncContext)
 * TODO: Connect to SyncContext in Phase 3
 */

interface LiveSyncIndicatorProps {
    isConnected?: boolean;
    isSyncing?: boolean;
    lastSync?: Date | null;
}

export function LiveSyncIndicator({
    isConnected = true,
    isSyncing = false,
    lastSync = null
}: LiveSyncIndicatorProps) {
    const getStatusText = () => {
        if (isSyncing) return 'SYNCING...';
        if (isConnected) return 'LIVE SYNC';
        return 'OFFLINE';
    };

    const getStatusColor = () => {
        if (isSyncing) return 'text-yellow-500';
        if (isConnected) return 'text-green-500';
        return 'text-red-500';
    };

    return (
        <div className={`flex items-center gap-2 font-mono text-xs ${getStatusColor()}`}>
            {/* Radio wave icon (using span as placeholder for lucide-react) */}
            <span className={`inline-block w-3.5 h-3.5 ${isConnected && !isSyncing ? 'animate-pulse' : ''}`}>
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="14"
                    height="14"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                >
                    <circle cx="12" cy="12" r="2" />
                    <path d="M4.93 4.93a10 10 0 0 1 14.14 0" />
                    <path d="M4.93 19.07a10 10 0 0 0 14.14 0" />
                    <path d="M8.05 8.05a7 7 0 0 1 7.9 0" />
                    <path d="M8.05 15.95a7 7 0 0 0 7.9 0" />
                </svg>
            </span>
            <span>{getStatusText()}</span>
            {lastSync && (
                <span className="text-gray-500 text-[10px]">
                    {lastSync.toLocaleTimeString()}
                </span>
            )}
        </div>
    );
}
