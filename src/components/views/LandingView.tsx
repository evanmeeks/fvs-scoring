export const LandingView = ({ children }: { children: React.ReactNode }) => {
  return (
    <div className="min-h-[calc(100vh-4rem)] flex flex-col bg-ops-black">
      {/* Global Background Effects */}
      <div
        className="fixed inset-0 pointer-events-none z-0 opacity-15"
        style={{
          background:
            "linear-gradient(to bottom, rgba(255,255,255,0), rgba(255,255,255,0) 50%, rgba(0,0,0,0.1) 50%, rgba(0,0,0,0.1))",
          backgroundSize: "100% 4px",
        }}
      ></div>

      <div className="flex-grow relative z-10 animate-fade-in">{children}</div>
    </div>
  );
};
