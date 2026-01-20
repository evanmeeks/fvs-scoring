import { createFileRoute } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import PreferencesSettings from '../../components/views/PreferencesSettings';

/**
 * Preferences Settings Page
 * Notification settings and UI preferences
 *
 * Settings:
 * - Email notifications
 * - Activity notifications
 * - Display preferences
 * - Accessibility options
 */
export const Route = createFileRoute('/profile/preferences')({
  head: () =>
    createHeadConfig({
      title: 'Preferences',
      description: 'Manage your notification and display preferences.',
      path: '/profile/preferences',
      noindex: true,
    }),
  component: PreferencesSettingsPage,
});

function PreferencesSettingsPage() {
  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <h1 className="text-3xl font-bold mb-6">Preferences</h1>

      <div className="bg-glass-dark rounded-lg border border-white/10 p-6">
        <h2 className="text-xl font-semibold mb-4">
          Notification & Display Preferences
        </h2>
        <p className="text-muted mb-6">
          Manage how you receive updates and customize your experience.
        </p>

        <PreferencesSettings />
      </div>
    </div>
  );
}
