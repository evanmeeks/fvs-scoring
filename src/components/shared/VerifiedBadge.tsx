import { useState } from 'react';
import Icon from '../Icon';

export interface VerifiedBadgeProps {
  /**
   * Timestamp when verification was completed
   */
  verifiedAt?: string | null;

  /**
   * Size variant
   * - sm: 12px (w-3 h-3) for inline text
   * - md: 16px (w-4 h-4) for normal display (default)
   * - lg: 20px (w-5 h-5) for prominent display
   */
  size?: 'sm' | 'md' | 'lg';

  /**
   * Whether to show tooltip on hover
   */
  showTooltip?: boolean;

  /**
   * Custom className for additional styling
   */
  className?: string;
}

/**
 * VerifiedBadge Component
 *
 * Displays a verified checkmark badge for OAuth-verified contributors.
 * Does NOT show which OAuth provider was used to avoid platform bias.
 *
 * Usage:
 * ```tsx
 * {profile?.oauth_verified && !profile?.anonymous && (
 *   <VerifiedBadge verifiedAt={profile.oauth_verified_at} />
 * )}
 * ```
 */
export function VerifiedBadge({
  verifiedAt,
  size = 'md',
  showTooltip = true,
  className = '',
}: VerifiedBadgeProps) {
  const [showTooltipState, setShowTooltipState] = useState(false);

  // Size classes
  const sizeClasses = {
    sm: 'text-xs',   // ~12px
    md: 'text-base', // ~16px
    lg: 'text-xl',   // ~20px
  };

  const sizeClass = sizeClasses[size];

  // Format verification date
  const formattedDate = verifiedAt
    ? new Date(verifiedAt).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      })
    : null;

  return (
    <span
      className={`inline-flex items-center relative ${className}`}
      onMouseEnter={() => setShowTooltipState(true)}
      onMouseLeave={() => setShowTooltipState(false)}
      aria-label="Verified account"
    >
      <Icon
        name="verified"
        className={`${sizeClass} text-primary inline-block`}
      />

      {/* Tooltip */}
      {showTooltip && showTooltipState && (
        <div
          className="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-3 py-2 bg-surface border border-border rounded shadow-lg z-50 whitespace-nowrap"
          role="tooltip"
        >
          <div className="text-xs">
            <div className="font-bold mb-1 text-white">Verified Account</div>
            <div className="text-text-muted">
              Authenticated via OAuth provider
              {formattedDate && (
                <>
                  {' • '}
                  {formattedDate}
                </>
              )}
            </div>
          </div>
          {/* Tooltip arrow */}
          <div className="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-4 border-r-4 border-t-4 border-l-transparent border-r-transparent border-t-border" />
        </div>
      )}
    </span>
  );
}

/**
 * VerifiedBadgeInline Component
 *
 * Inline variant without tooltip, optimized for compact spaces.
 *
 * Usage:
 * ```tsx
 * <span>@username <VerifiedBadgeInline /></span>
 * ```
 */
export function VerifiedBadgeInline({ size = 'sm' }: { size?: 'sm' | 'md' }) {
  const sizeClasses = {
    sm: 'text-xs',
    md: 'text-base',
  };

  return (
    <Icon
      name="verified"
      className={`${sizeClasses[size]} text-primary inline-block ml-1`}
      aria-label="Verified"
    />
  );
}

export default VerifiedBadge;
