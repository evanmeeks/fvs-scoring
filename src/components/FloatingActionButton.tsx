/* eslint-disable @typescript-eslint/no-explicit-any */
import React from "react";

interface FloatingActionButtonProps {
  onClick: () => void;
  user?: any | null;
  onRequireAuth?: () => void;
}

const FloatingActionButton: React.FC<FloatingActionButtonProps> = ({
  onClick,
  user,
  onRequireAuth,
}) => {
  const handleClick = () => {
    if (!user) {
      if (onRequireAuth) onRequireAuth();
      return;
    }
    onClick();
  };

  return (
    <div className="absolute bottom-8 right-8 flex flex-col items-end gap-3 z-20">
      <button
        onClick={handleClick}
        className="bg-primary text-black font-bold px-4 p-4 text-xs hover:bg-white transition-all flex items-center gap-2 rounded-full justify-center shadow-xl hover:scale-105 active:scale-95"
        title={
          user
            ? "Open New Claim Entry Modal"
            : "Login to create New Claim Entry"
        }
      >
        <span className="material-symbols-outlined text-2xl">add</span>
      </button>
    </div>
  );
};

export default FloatingActionButton;
