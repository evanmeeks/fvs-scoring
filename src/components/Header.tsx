
/* eslint-disable @typescript-eslint/no-explicit-any */
import { useLocation, Link, useParams } from "@tanstack/react-router";
import Icon from "./Icon";
import { useApp } from "../context/AppContext";
import { generateTargetSlug } from "../utils/urlSlug";

interface HeaderProps {
  user: any; // Using any for now to match other components, ideally typed properly
  isAdmin: boolean;
  isContributor: boolean;
  onLogin: () => void;
  onLogout: () => void;
  onOpenTargetEntry?: () => void;
}

const Header = ({ user, isAdmin, isContributor, onLogin, onLogout, onOpenTargetEntry }: HeaderProps) => {
  const location = useLocation();
  const currentPath = location.pathname;
  const { activeTarget } = useApp();

  // Try to extract slug from URL params (for routes with $slug)
  const params = useParams({ strict: false }) as { slug?: string };
  const currentSlug = params.slug || generateTargetSlug(activeTarget);

  const isManifesto = currentPath === "/manifesto";

  const landingTabs = [
    { id: "targets", label: "CURRENT TARGETS", icon: "target", path: "/" },
    { id: "consensus", label: "GLOBAL INTEL", icon: "public", path: `/global-consensus/${currentSlug}` },
    { id: "audit", label: "EXECUTE AUDIT", icon: "verified_user", path: `/audit-target/${currentSlug}` },
    { id: "governance", label: "PROTOCOL GOVERNANCE", icon: "table_chart", path: "/contributors/governance" },
    { id: "profile", label: "PROFILE", icon: "person", path: "/profile" },
    { id: "admin", label: "ADMIN", icon: "admin_panel_settings", path: "/admin" },
    { id: "manifesto", label: "MANIFESTO", icon: "policy", path: "/manifesto" },
  ];






  return (
    <header className="border-b border-border bg-background z-10 shrink-0">
      {/* Hero Section - Only on Manifesto */}
      {isManifesto && (
        <div className="border-b border-ops-border bg-ops-black">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-4">
              <div>
                <div className="flex items-center gap-2 text-ops-accent mb-1">
                  <span className="material-symbols-outlined text-sm">
                    terminal
                  </span>
                  <span className="text-xs font-mono uppercase tracking-widest">
                    System Active // V1.0 PROTOTYPE
                  </span>
                </div>
                <h1 className="text-3xl md:text-5xl font-black font-mono tracking-tighter text-white cursor-default">
                  FVS<span className="text-ops-accent">_</span>SCORING
                </h1>
                <p className="text-ops-text-dim mt-2 max-w-2xl text-sm md:text-base">
                  Forecast Verification Scoring System.
                  <span className="block mt-1 opacity-70">
                    Verification and evaluation for forecasts in media claims and prediction markets.
                  </span>
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Landing Tabs Navigation with Mini Logo */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <nav aria-label="Main navigation" className="flex items-center space-x-1 overflow-x-auto hide-scrollbar">
          {/* Mini Logo - When not on Manifesto */}
          {!isManifesto && (
            <Link to="/manifesto" className="flex items-center gap-2 hover:opacity-80 transition-opacity mr-4 py-3">
              <Icon name="terminal" className="text-primary text-2xl" />
              <span className="font-bold tracking-tighter text-base">
                FVS<span className="text-primary">_</span>
              </span>
            </Link>
          )}

          {landingTabs.map((tab) => {
            // Determine if tab should be visible based on user permissions
            const shouldShow =
              (tab.id === "governance" && user && (isContributor || isAdmin)) ||
              (tab.id === "admin" && user && isAdmin) ||
              (tab.id === "profile" && user) ||
              (!["governance", "admin", "profile"].includes(tab.id));

            if (!shouldShow) return null;

            const isActive = tab.id === "targets"
              ? currentPath === "/"
              : tab.id === "manifesto"
                ? currentPath === "/manifesto"
                : tab.id === "governance"
                  ? currentPath === "/contributors/governance"
                  : tab.id === "profile"
                    ? currentPath.startsWith("/profile")
                    : tab.id === "admin"
                      ? currentPath.startsWith("/admin")
                      : currentPath.startsWith(`/${tab.id === "consensus" ? "global-consensus" : "audit-target"}`);

            return (
              <Link
                key={tab.id}
                to={tab.path}
                className={`whitespace-nowrap py-3 px-6 border-b-2 font-mono text-sm font-medium transition-colors flex items-center gap-2 outline-none
                  ${isActive
                    ? "border-ops-accent text-ops-accent bg-ops-accent/5"
                    : "border-transparent text-ops-text-dim hover:text-ops-accent hover:border-ops-border"
                  }
                `}
              >
                <span className="material-symbols-outlined text-[18px]">
                  {tab.icon}
                </span>
                {tab.label}
              </Link>
            );
          })}
        </nav>
      </div>

      {/* User Actions Section */}
      <div className="h-16 border-t border-border flex items-center justify-end px-4 md:px-6">
        <div className="flex gap-4 h-16 items-center">
          {user ? (
            <div className="flex items-center gap-4 h-full">
              <button
                onClick={onOpenTargetEntry}
                className="flex items-center gap-2 px-3 py-1.5 bg-background border border-border rounded hover:bg-surface hover:border-primary transition-all text-sm font-medium group"
              >
                <Icon name="add" className="text-primary group-hover:scale-110 transition-transform" />
                <span className="text-text-muted hover:text-white">New Claim Entry</span>
              </button>

              <div className="flex flex-col items-center gap-2">
                <span className="text-[10px] text-text-muted mono">
                  NETWORK_STATUS:
                </span>
                <span className="text-[10px] text-left text-primary mono">
                  AUTHENTICATED
                </span>
              </div>

              {/* Simplified Profile for now */}
              <div className="flex items-center gap-2">
                <button
                  onClick={onLogout}
                  className="text-[10px] text-text-muted hover:text-white uppercase mono"
                >
                  Logout
                </button>
              </div>
            </div>
          ) : (
            <div className="flex items-center gap-4 m-2">
              <div className="flex flex-col items-end mr-4">
                <span className="text-[10px] text-text-muted mono">
                  NETWORK_STATUS:
                </span>
                <span className="text-[10px] text-red-500 mono font-bold">
                  DISCONNECTED
                </span>
              </div>
              <button
                onClick={onLogin}
                className="bg-primary text-black font-bold px-4 py-2 rounded text-xs hover:bg-white transition-all flex items-center gap-2"
              >
                <Icon name="login" /> LOGIN
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;
