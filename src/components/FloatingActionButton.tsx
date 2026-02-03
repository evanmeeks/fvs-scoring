"use client";

/* eslint-disable @typescript-eslint/no-explicit-any */
import { useState, useEffect } from "react";
import { useUI } from "~/context/AppContext";
import { createClient } from "~/lib/supabase/client";

export function FloatingActionButton() {
  const { setTargetSubmissionModalOpen } = useUI();
  const supabase = createClient();
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setUser(data.user));
  }, [supabase.auth]);

  const handleClick = () => {
    if (!user) {
      // Redirect to login if not authenticated
      window.location.href = "/login";
      return;
    }
    setTargetSubmissionModalOpen(true);
  };

  return (
    <div className="fixed bottom-8 right-8 flex flex-col items-end gap-3 z-20">
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
}

export default FloatingActionButton;
