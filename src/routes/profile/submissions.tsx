import { createFileRoute } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import MySubmissionsView from '../../components/views/MySubmissionsView';

/**
 * Profile Submissions Page
 * Shows user's submitted targets, scores, and RFCs
 * Migrated from /my/submissions
 */
export const Route = createFileRoute('/profile/submissions')({
  head: () =>
    createHeadConfig({
      title: 'Submissions',
      description: 'View your submitted targets, scores, and RFC proposals.',
      path: '/profile/submissions',
      noindex: true, // Private page, don't index
    }),
  component: ProfileSubmissionsPage,
});

function ProfileSubmissionsPage() {
  return <MySubmissionsView />;
}
