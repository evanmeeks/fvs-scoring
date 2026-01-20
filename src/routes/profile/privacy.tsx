import { createFileRoute } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import PrivacySettings from '../../components/views/PrivacySettings';

/**
 * Privacy Settings Page
 * Control anonymity, verification, and data visibility
 *
 * Settings:
 * - Privacy mode (anonymous/verified/public)
 * - OAuth verification
 * - Public profile toggle
 * - Data visibility controls
 */
export const Route = createFileRoute('/profile/privacy')({
  head: () =>
    createHeadConfig({
      title: 'Privacy Settings',
      description: 'Control your anonymity and data visibility.',
      path: '/profile/privacy',
      noindex: true,
    }),
  component: PrivacySettingsPage,
});

function PrivacySettingsPage() {
  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <h1 className="text-3xl font-bold mb-6">Privacy Settings</h1>

      <div className="bg-glass-dark rounded-lg border border-white/10 p-6">
        <h2 className="text-xl font-semibold mb-4">Privacy Controls</h2>
        <p className="text-muted mb-6">
          Manage your anonymity, verification status, and what others can see.
        </p>

        <PrivacySettings />
      </div>
    </div>
  );
}
