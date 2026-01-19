import { useState } from 'react';


/**
 * Preferences Settings Component
 * Manage notification and display preferences
 *
 * Note: This is a Phase 1 placeholder. Full notification system
 * will be implemented in Phase 2/3.
 */
export default function PreferencesSettings() {
  // Placeholder state - will be replaced with actual preferences from database
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [activityNotifications, setActivityNotifications] = useState(true);
  const [rfcNotifications, setRfcNotifications] = useState(true);

  const [saving, setSaving] = useState(false);
  const [success, setSuccess] = useState<string | null>(null);

  const handleSave = async () => {
    setSaving(true);

    // Simulate save delay
    await new Promise((resolve) => setTimeout(resolve, 500));

    setSuccess('Preferences saved successfully!');
    setSaving(false);

    setTimeout(() => setSuccess(null), 3000);
  };

  return (
    <div className="space-y-6">
      {/* Success Message */}
      {success && (
        <div className="bg-green-500/10 border border-green-500/30 p-4 rounded text-green-500">
          {success}
        </div>
      )}



      {/* Email Notifications */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Email Notifications</h3>

        <label htmlFor="email-notifications" aria-label="Enable Email Notifications" className="flex items-center justify-between p-4 bg-surface border border-border rounded cursor-pointer hover:border-primary/50 transition-colors">
          <div>
            <p className="font-semibold">Enable Email Notifications</p>
            <p className="text-sm text-muted">
              Receive email updates about your FVS activity
            </p>
          </div>
          <input
            id="email-notifications"
            type="checkbox"
            checked={emailNotifications}
            onChange={(e) => setEmailNotifications(e.target.checked)}
            className="w-5 h-5 accent-primary"
          />
        </label>

        {emailNotifications && (
          <div className="ml-4 space-y-3 border-l-2 border-border pl-4">
            <label htmlFor="activity-notifications" aria-label="Activity Notifications" className="flex items-center justify-between p-3 bg-surface/50 border border-border/50 rounded cursor-pointer hover:border-primary/30 transition-colors">
              <div>
                <p className="text-sm font-medium">Activity Notifications</p>
                <p className="text-xs text-muted">
                  When others vote on or comment on your scores
                </p>
              </div>
              <input
                id="activity-notifications"
                type="checkbox"
                checked={activityNotifications}
                onChange={(e) => setActivityNotifications(e.target.checked)}
                className="w-4 h-4 accent-primary"
              />
            </label>

            <label htmlFor="rfc-notifications" aria-label="RFC Updates" className="flex items-center justify-between p-3 bg-surface/50 border border-border/50 rounded cursor-pointer hover:border-primary/30 transition-colors">
              <div>
                <p className="text-sm font-medium">RFC Updates</p>
                <p className="text-xs text-muted">
                  When RFC proposals you care about are updated or voted on
                </p>
              </div>
              <input
                id="rfc-notifications"
                type="checkbox"
                checked={rfcNotifications}
                onChange={(e) => setRfcNotifications(e.target.checked)}
                className="w-4 h-4 accent-primary"
              />
            </label>
          </div>
        )}
      </div>





      {/* Save Button */}
      <div className="pt-4 border-t border-border">
        <button
          onClick={handleSave}
          disabled={saving}
          className="px-6 py-3 bg-primary text-black font-bold rounded hover:bg-white transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {saving ? 'Saving...' : 'Save Preferences'}
        </button>

      </div>
    </div>
  );
}
