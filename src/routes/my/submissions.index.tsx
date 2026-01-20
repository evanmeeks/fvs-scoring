import { createFileRoute } from '@tanstack/react-router';
import { createHeadConfig } from '../../utils/seo';
import MySubmissionsView from '../../components/views/MySubmissionsView';

/**
 * My Submissions Page
 * Shows user's submitted targets, scores, and RFCs
 */
export const Route = createFileRoute('/my/submissions/')({
  head: () => createHeadConfig({
    title: 'Submissions',
    description: 'View your submitted targets, scores, and RFC proposals.',
    path: '/my/submissions',
    noindex: true, // Private page, don't index
  }),
  component: MySubmissionsPage,
});

function MySubmissionsPage() {
  return <MySubmissionsView />;
}
