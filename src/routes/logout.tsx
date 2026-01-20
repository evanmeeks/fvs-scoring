import { createFileRoute, useNavigate } from '@tanstack/react-router'
import { useEffect, useState } from 'react'
import Icon from '../components/Icon'

export const Route = createFileRoute('/logout')({
  component: LogoutComponent,
})

function LogoutComponent() {
  const navigate = useNavigate()
  const [countdown, setCountdown] = useState(5)

  useEffect(() => {
    // Countdown timer
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(countdown - 1), 1000)
      return () => clearTimeout(timer)
    } else {
      // Redirect to home after countdown
      navigate({ to: '/' })
    }
  }, [countdown, navigate])

  return (
    <div className="flex items-center justify-center min-h-screen bg-background">
      <div className="max-w-md w-full mx-4">
        {/* Success Card */}
        <div className="bg-panel border border-border rounded-lg shadow-2xl overflow-hidden animate-slide-up">
          {/* Header with Icon */}
          <div className="bg-surface border-b border-border p-6 text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 bg-primary/20 border-2 border-primary rounded-full mb-4">
              <Icon name="check_circle" className="text-primary text-3xl" />
            </div>
            <h1 className="text-2xl font-bold text-white font-mono">
              Successfully Logged Out
            </h1>
          </div>

          {/* Body */}
          <div className="p-6 space-y-4">
            <p className="text-text-muted text-center text-sm">
              You have been securely logged out of your account. Your session has ended and all authentication tokens have been cleared.
            </p>

            {/* Feature Message */}
            <div className="bg-background border border-border rounded-lg p-4">
              <p className="text-xs text-text-muted text-center">
                While logged out, you can still view metrics and browse the system, but submission features will be disabled.
              </p>
            </div>

            {/* Auto-redirect Notice */}
            <div className="flex items-center justify-center gap-2 text-primary text-sm font-mono">
              <Icon name="schedule" className="text-lg" />
              <span>Redirecting in {countdown}s...</span>
            </div>
          </div>

          {/* Footer Actions */}
          <div className="bg-surface border-t border-border p-4 flex gap-3 justify-center">
            <button
              onClick={() => navigate({ to: '/' })}
              className="px-5 py-2.5 rounded bg-primary text-black font-bold text-xs uppercase tracking-wide hover:bg-white transition-colors shadow-lg shadow-primary/20"
            >
              Go to Home
            </button>
          </div>
        </div>

        {/* Additional Info */}
        <div className="mt-6 text-center">
          <p className="text-xs text-text-muted">
            Need help?{' '}
            <a href="mailto:support@fvs.example" className="text-primary hover:underline">
              Contact Support
            </a>
          </p>
        </div>
      </div>
    </div>
  )
}
