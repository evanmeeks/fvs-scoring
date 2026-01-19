 
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLocation } from "@tanstack/react-router";
import StandardsSidebar from "./StandardsSidebar";
import ScoringSidebar from "./ScoringSidebar";

type SidebarProps = {
    totalScore: number;
    scoreInterpretation: { text: string; style: string };
    activeTarget: any;
    onTargetClick?: () => void;
};

const Sidebar = ({ totalScore, scoreInterpretation, activeTarget, onTargetClick }: SidebarProps) => {
    const location = useLocation();
    if (location.pathname === '/') {
        return null;
    }

    // Check for specific routes first
    const isGovernance = location.pathname.includes('/governance');
    const isAdmin = location.pathname.includes('/admin');
    const isReview = location.pathname.includes('/review');

    if (isReview || isGovernance || isAdmin) {
        return <StandardsSidebar />;
    }

    const mode = location.pathname.split('/').filter(Boolean)[0] || 'scoring';

    if (mode === 'scoring') {
        return (
            <ScoringSidebar
                totalScore={totalScore}
                scoreInterpretation={scoreInterpretation}
                activeTarget={activeTarget}
                onTargetClick={onTargetClick}
            />
        );
    }

    // Default fallback for other modes
    return (
        <ScoringSidebar
            totalScore={totalScore}
            scoreInterpretation={scoreInterpretation}
            activeTarget={activeTarget}
            onTargetClick={onTargetClick}
        />
    );
};

export default Sidebar;
