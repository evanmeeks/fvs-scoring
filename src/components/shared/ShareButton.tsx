import { useState } from 'react';
import Icon from '../Icon';
import ShareModal from './ShareModal';

export interface ShareButtonProps {
  /**
   * URL to share. If not provided, shares current page URL.
   */
  url?: string;

  /**
   * Title for the share modal
   */
  title?: string;

  /**
   * Whether sharing is allowed for this content
   */
  disabled?: boolean;

  /**
   * Explanation shown when disabled
   */
  disabledReason?: string;

  /**
   * Success message shown in toast
   */
  successMessage?: string;

  /**
   * Custom className for styling
   */
  className?: string;

  /**
   * Button variant
   */
  variant?: 'icon' | 'button';

  /**
   * Button label (for 'button' variant)
   */
  label?: string;

  /**
   * Description for social preview
   */
  description?: string;

  /**
   * Image URL for social preview
   */
  image?: string;

  /**
   * Callback when share is successful
   */
  onShare?: (url: string) => void;

  /**
   * Toast callback
   */
  onShowToast?: (message: string, type: 'success' | 'error' | 'info' | 'warning') => void;
}

/**
 * Unified Share Button Component
 *
 * Features:
 * - Opens ShareModal for rich sharing options
 * - Permission-aware (can be disabled with explanation)
 * - Supports icon-only or button with label
 * - Consistent across all shareable pages
 */
export default function ShareButton({
  url,
  title = "this page",
  disabled = false,
  disabledReason = 'Sharing is not available for this content',
  className = '',
  variant = 'icon',
  label = 'Share',
  onShowToast,
  description,
  image,
}: ShareButtonProps) {
  const [showTooltip, setShowTooltip] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const handleShareClick = () => {
    if (disabled) {
      onShowToast?.(disabledReason, 'warning');
      return;
    }
    setIsModalOpen(true);
  };

  const shareUrl = url || (typeof window !== 'undefined' ? window.location.href : '');

  const baseStyles = disabled
    ? 'opacity-50 cursor-not-allowed'
    : 'hover:text-white hover:border-primary';

  return (
    <>
      <div className="relative inline-block">
        {variant === 'icon' ? (
          <button
            onClick={handleShareClick}
            onMouseEnter={() => disabled && setShowTooltip(true)}
            onMouseLeave={() => setShowTooltip(false)}
            disabled={disabled}
            className={`text-text-muted transition-all flex items-center gap-2 ${baseStyles} ${className}`}
            title={disabled ? disabledReason : 'Share Link'}
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

        {/* Tooltip for disabled state */}
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
