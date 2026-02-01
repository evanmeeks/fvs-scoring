"use client";

import { useState } from "react";
import Icon from "../Icon";
import ShareModal from "./ShareModal";

export interface ShareButtonProps {
  url?: string;
  title?: string;
  disabled?: boolean;
  disabledReason?: string;
  className?: string;
  variant?: "icon" | "button";
  label?: string;
  description?: string;
  image?: string;
  onShare?: (url: string) => void;
  onShowToast?: (
    message: string,
    type: "success" | "error" | "info" | "warning",
  ) => void;
}

export default function ShareButton({
  url,
  title = "this page",
  disabled = false,
  disabledReason = "Sharing is not available for this content",
  className = "",
  variant = "icon",
  label = "Share",
  onShowToast,
  description,
  image,
}: ShareButtonProps) {
  const [showTooltip, setShowTooltip] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleShareClick = () => {
    if (disabled) {
      onShowToast?.(disabledReason, "warning");
      return;
    }
    setIsModalOpen(true);
  };

  const shareUrl =
    url || (typeof window !== "undefined" ? window.location.href : "");

  const baseStyles = disabled
    ? "opacity-50 cursor-not-allowed"
    : "hover:text-white hover:border-primary";

  return (
    <>
      <div className="relative inline-block">
        {variant === "icon" ? (
          <button
            onClick={handleShareClick}
            onMouseEnter={() => disabled && setShowTooltip(true)}
            onMouseLeave={() => setShowTooltip(false)}
            disabled={disabled}
            className={`text-text-muted transition-all flex items-center gap-2 ${baseStyles} ${className}`}
            title={disabled ? disabledReason : "Share Link"}
          >
            <Icon name="share" className="text-xl" />
          </button>
        ) : (
          <button
            onClick={handleShareClick}
            onMouseEnter={() => disabled && setShowTooltip(true)}
            onMouseLeave={() => setShowTooltip(false)}
            disabled={disabled}
            className={`bg-panel border border-border text-white font-bold px-4 py-2 rounded text-xs transition-all flex items-center gap-2 ${baseStyles} ${className}`}
          >
            <Icon name="share" className="text-sm" />
            {label}
          </button>
        )}

        {disabled && showTooltip && (
          <div className="absolute top-full left-1/2 transform -translate-x-1/2 mt-2 px-3 py-2 bg-panel border border-border rounded text-xs text-text-muted whitespace-nowrap z-50">
            {disabledReason}
          </div>
        )}
      </div>

      <ShareModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        url={shareUrl}
        title={title}
        description={description}
        image={image}
      />
    </>
  );
}
