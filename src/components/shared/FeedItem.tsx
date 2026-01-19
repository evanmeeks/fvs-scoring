/**
 * Feed Item Component
 * Activity feed item with type-based styling
 */

import type { ActivityItem } from '../../types';

export function FeedItem({ userName, action, time, type = 'default' }: ActivityItem) {
    const getTypeColor = () => {
        switch (type) {
            case 'alert':
                return 'bg-red-500';
            case 'score':
                return 'bg-green-500/70';
            case 'vote':
                return 'bg-blue-500/70';
            case 'verification':
                return 'bg-yellow-500/70';
            case 'edit':
                return 'bg-purple-500/70';
            default:
                return 'bg-green-500/50';
        }
    };

    return (
        <div className="flex gap-3 py-3 border-b border-white/5 font-mono text-xs hover:bg-white/5 transition-colors px-2">
            <div className={`w-1 h-full min-h-[20px] ${getTypeColor()}`}></div>
            <div className="flex-1">
                <div className="flex justify-between text-gray-400 mb-1">
                    <span className="text-green-400 font-bold">{userName}</span>
                    <span>{time}</span>
                </div>
                <div className="text-gray-300">{action}</div>
            </div>
        </div>
    );
}
