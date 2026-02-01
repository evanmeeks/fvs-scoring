"use client";

import Icon from "../Icon";

export interface AuthTeaserProps {
  action: string;
  description?: string;
  icon?: string;
  onLogin: () => void;
  className?: string;
  variant?: "banner" | "card" | "inline";
}

export default function AuthTeaser({
  action,
  description,
  icon = "login",
  onLogin,
  className = "",
  variant = "card",
}: AuthTeaserProps) {
  if (variant === "banner") {
    return (
      <div
        className={`bg-gradient-to-r from-primary/20 to-primary/10 border border-primary/30 rounded-lg p-6 ${className}`}
      >
        <div className="flex items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Icon name={icon} className="text-4xl text-primary" />
            <div>
              <h3 className="text-xl font-bold mb-1">{action}</h3>
              {description && (
                <p className="text-sm text-text-muted">{description}</p>
              )}
            </div>
          </div>
          <button
            onClick={onLogin}
            className="bg-primary text-black font-bold px-6 py-3 rounded hover:bg-white transition-all flex items-center gap-2 whitespace-nowrap"
          >
            <Icon name="login" />
            Log In to Get Started
          </button>
        </div>
      </div>
    );
  }

  if (variant === "inline") {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        <Icon name="lock" className="text-sm text-text-muted" />
        <span className="text-sm text-text-muted">
          <button
            onClick={onLogin}
            className="text-primary hover:text-white transition-all underline font-medium"
          >
            Log in
          </button>{" "}
          to {action.toLowerCase()}
        </span>
      </div>
    );
  }

  return (
    <div
      className={`bg-panel border border-border rounded-lg p-6 text-center ${className}`}
    >
      <Icon name={icon} className="text-6xl text-primary mb-4 opacity-80" />
      <h3 className="text-2xl font-bold mb-2">{action}</h3>
      {description && (
        <p className="text-sm text-text-muted mb-6 max-w-md mx-auto">
          {description}
        </p>
      )}
      <button
        onClick={onLogin}
        className="bg-primary text-black font-bold px-6 py-3 rounded hover:bg-white transition-all flex items-center gap-2 mx-auto"
      >
        <Icon name="login" />
        Log In to Continue
      </button>
      <p className="text-xs text-text-muted mt-4">
        Don&apos;t have an account? Logging in will create one automatically.
      </p>
    </div>
  );
}
