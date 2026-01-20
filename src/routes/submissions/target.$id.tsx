import { createFileRoute, useParams, useNavigate } from '@tanstack/react-router';
import { useEffect, useState } from 'react';
import { supabase } from '../../utils/supabase';
import { createTargetSubmissionHeadConfig } from '../../utils/seo';
import GlassPanel from '../../components/shared/GlassPanel';
import Icon from '../../components/Icon';
import ShareButton from '../../components/shared/ShareButton';

interface TargetSubmission {
  id: string;
  target_name: string;
  case_id: string | null;
  origin: string | null;
  context: string | null;
  description: string;
  source_url: string | null;
  claim_date: string;
  primary_source: string | null;
  additional_notes: string | null;
  status: 'pending' | 'approved' | 'rejected';
  submitted_at: string;
  submitted_by: string;
  reviewed_at: string | null;
  review_notes: string | null;
}

/**
 * Shareable Target Submission Result Page
 * Public view of a submitted target proposal
 */
export const Route = createFileRoute('/submissions/target/$id')({
  loader: async ({ params }) => {
    const { id } = params

    // Fetch target submission
    const { data: submission } = await supabase
      .from('target_submissions')
      .select(`
        id,
        target_name,
        case_id,
        description,
        origin,
        primary_source,
        status,
        submitted_by,
        profiles:submitted_by (
          display_name,
          username,
          full_name
        )
      `)
      .eq('id', id)
      .single()

    // Get author name
    const author = submission?.profiles?.display_name
      || submission?.profiles?.full_name
      || submission?.profiles?.username
      || 'Anonymous'

    return { submission, author }
  },

  head: ({ loaderData }) => {
    if (!loaderData?.submission) {
      return createTargetSubmissionHeadConfig()
    }

    const { submission, author } = loaderData

    return createTargetSubmissionHeadConfig({
      target_name: submission.target_name,
      case_id: submission.case_id,
      description: submission.description,
      author,
      origin: submission.primary_source || submission.origin || undefined,
    })
  },

  component: TargetSubmissionPage,
});

function TargetSubmissionPage() {
  const { id } = useParams({ from: '/submissions/target/$id' });
  const navigate = useNavigate();
  const [submission, setSubmission] = useState<TargetSubmission | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadSubmission = async () => {
      setLoading(true);
      setError(null);

      try {
        const { data, error: fetchError } = await supabase
          .from('target_submissions')
          .select('*')
          .eq('id', id)
          .single();

        if (fetchError) {
          if (fetchError.code === 'PGRST116') {
            setError('Target submission not found');
          } else {
            throw fetchError;
          }
          return;
        }

        // Check if rejected - don't show rejected submissions publicly
        if (data.status === 'rejected') {
          setError('This submission has been rejected and is not publicly viewable');
          return;
        }

        setSubmission(data as unknown as TargetSubmission);
      } catch (err) {
        console.error('Error loading submission:', err);
        setError('Failed to load target submission');
      } finally {
        setLoading(false);
      }
    };

    loadSubmission();
  }, [id]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return 'text-green-500';
      case 'pending':
        return 'text-yellow-500';
      default:
        return 'text-gray-500';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      default:
        return 'help';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  if (loading) {
    return (
      <div className="flex-1 p-6 flex items-center justify-center">
        <div className="text-text-muted">Loading submission...</div>
      </div>
    );
  }

  if (error || !submission) {
    return (
      <div className="flex-1 p-6">
        <div className="max-w-4xl mx-auto">
          <GlassPanel>
            <div className="text-center py-12">
              <Icon name="error_outline" className="text-6xl text-red-500 mb-4" />
              <h2 className="text-2xl font-bold mb-2">Submission Not Found</h2>
              <p className="text-text-muted mb-6">{error}</p>
              <button
                onClick={() => navigate({ to: '/' })}
                className="bg-primary text-black font-bold px-6 py-2 rounded hover:bg-white transition-all"
              >
                Return to Home
              </button>
            </div>
          </GlassPanel>
        </div>
      </div>
    );
  }

  return (
    <div className="flex-1 p-6 overflow-y-auto">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-6 flex items-start justify-between">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <Icon
                name={getStatusIcon(submission.status)}
                className={`text-3xl ${getStatusColor(submission.status)}`}
              />
              <h1 className="text-4xl font-bold">{submission.target_name}</h1>
            </div>
            <div className="flex items-center gap-3 text-sm text-text-muted">
              {submission.case_id && (
                <span className="mono bg-panel px-3 py-1 rounded border border-border">
                  {submission.case_id}
                </span>
              )}
              <span className={`uppercase font-bold ${getStatusColor(submission.status)}`}>
                {submission.status}
              </span>
              <span>
                Submitted {formatDate(submission.submitted_at)}
              </span>
            </div>
          </div>
          <ShareButton variant="button" label="Share Submission" />
        </div>

        {/* Main Content */}
        <div className="space-y-6">
          {/* Description */}
          <GlassPanel>
            <h2 className="text-xl font-bold mb-3 flex items-center gap-2">
              <Icon name="description" className="text-primary" />
              Description
            </h2>
            <p className="text-text-muted leading-relaxed">{submission.description}</p>
          </GlassPanel>

          {/* Metadata Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Origin */}
            {submission.origin && (
              <GlassPanel>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="business" className="text-primary" />
                  <h3 className="font-bold">Origin</h3>
                </div>
                <p className="text-text-muted">{submission.origin}</p>
              </GlassPanel>
            )}

            {/* Context */}
            {submission.context && (
              <GlassPanel>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="category" className="text-primary" />
                  <h3 className="font-bold">Context</h3>
                </div>
                <p className="text-text-muted">{submission.context}</p>
              </GlassPanel>
            )}

            {/* Date of Disclosure */}
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="event" className="text-primary" />
                <h3 className="font-bold">Date of Disclosure</h3>
              </div>
              <p className="text-text-muted">{formatDate(submission.claim_date)}</p>
            </GlassPanel>

            {/* Primary Source */}
            {submission.primary_source && (
              <GlassPanel>
                <div className="flex items-center gap-2 mb-2">
                  <Icon name="account_circle" className="text-primary" />
                  <h3 className="font-bold">Primary Source</h3>
                </div>
                <p className="text-text-muted">{submission.primary_source}</p>
              </GlassPanel>
            )}
          </div>

          {/* Source URL */}
          {submission.source_url && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="link" className="text-primary" />
                <h3 className="font-bold">Source URL</h3>
              </div>
              <a
                href={submission.source_url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary hover:text-white transition-all break-all"
              >
                {submission.source_url}
              </a>
            </GlassPanel>
          )}

          {/* Additional Notes */}
          {submission.additional_notes && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-3">
                <Icon name="notes" className="text-primary" />
                <h3 className="font-bold">Additional Notes</h3>
              </div>
              <p className="text-text-muted leading-relaxed whitespace-pre-wrap">
                {submission.additional_notes}
              </p>
            </GlassPanel>
          )}

          {/* Review Status */}
          {submission.status === 'approved' && submission.reviewed_at && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="check_circle" className="text-green-500" />
                <h3 className="font-bold text-green-500">Approved</h3>
              </div>
              <p className="text-sm text-text-muted">
                This target was approved on {formatDate(submission.reviewed_at)} and is now available for scoring.
              </p>
              {submission.review_notes && (
                <div className="mt-3 p-3 bg-background rounded border border-border">
                  <p className="text-xs text-text-muted mb-1 font-bold">Review Notes:</p>
                  <p className="text-sm">{submission.review_notes}</p>
                </div>
              )}
            </GlassPanel>
          )}

          {submission.status === 'pending' && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="schedule" className="text-yellow-500" />
                <h3 className="font-bold text-yellow-500">Pending Review</h3>
              </div>
              <p className="text-sm text-text-muted">
                This target submission is currently under review by the FVS Protocol administrators.
              </p>
            </GlassPanel>
          )}
        </div>

        {/* Footer CTA */}
        <div className="mt-8 text-center">
          <button
            onClick={() => navigate({ to: '/' })}
            className="bg-panel border border-border text-white font-bold px-6 py-3 rounded hover:border-primary transition-all"
          >
            View All Targets
          </button>
        </div>
      </div>
    </div>
  );
}
