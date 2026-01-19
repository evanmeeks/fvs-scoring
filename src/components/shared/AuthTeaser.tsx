import Icon from '../Icon';

export interface AuthTeaserProps {
  /**
   * Primary action text (e.g., "Submit a Target", "Score this Target")
   */
  action: string;

  /**
   * Description of what users can do after logging in
   */
  description?: string;

  /**
   * Optional icon name
   */
  icon?: string;

  /**
   * Callback when user clicks login button
   */
  onLogin: () => void;

  /**
   * Custom className for styling
   */
  className?: string;

  /**
   * Variant style
   */
  variant?: 'banner' | 'card' | 'inline';
}

/**
 * Auth Teaser Component
 *
 * Encourages unauthenticated users to log in by showing what they can do.
 * Used on public pages to drive sign-ups and engagement.
 *
 * Best practices:
 * - Use 'banner' variant for prominent CTAs (top of page)
 * - Use 'card' variant for section-level CTAs
 * - Use 'inline' variant for small contextual prompts
 */
export default function AuthTeaser({
  action,
  description,
  icon = 'login',
  onLogin,
  className = '',
  variant = 'card',
}: AuthTeaserProps) {
  if (variant === 'banner') {
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

  if (variant === 'inline') {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        <Icon name="lock" className="text-sm text-text-muted" />
        <span className="text-sm text-text-muted">
          <button
            onClick={onLogin}
            className="text-primary hover:text-white transition-all underline font-medium"
          >
            Log in
          </button>{' '}
          to {action.toLowerCase()}
        </span>
      </div>
    );
  }

  // Default: card variant
  return (
    <div
      className={`bg-panel border border-border rounded-lg p-6 text-center ${className}`}
    >
      <Icon name={icon} className="text-6xl text-primary mb-4 opacity-80" />
      <h3 className="text-2xl font-bold mb-2">{action}</h3>
      {description && (
        <p className="text-sm text-text-muted mb-6 max-w-md mx-auto">{description}</p>
      )}
      <button
        onClick={onLogin}
        className="bg-primary text-black font-bold px-6 py-3 rounded hover:bg-white transition-all flex items-center gap-2 mx-auto"
      >
        <Icon name="login" />
        Log In to Continue
      </button>
      <p className="text-xs text-text-muted mt-4">
        Don't have an account? Logging in will create one automatically.
      </p>
    </div>
  );
}
