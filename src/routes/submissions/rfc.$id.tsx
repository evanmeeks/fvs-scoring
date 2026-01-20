import { createFileRoute, useParams, useNavigate } from '@tanstack/react-router';
import { useEffect, useState } from 'react';
import { supabase } from '../../utils/supabase';
import { createRFCHeadConfig } from '../../utils/seo';
import GlassPanel from '../../components/shared/GlassPanel';
import Icon from '../../components/Icon';
import ShareButton from '../../components/shared/ShareButton';

interface RFCProposal {
  id: string;
  proposal_type: 'modify_existing' | 'new_metric';
  rationale: string;
  proposed_name: string | null;
  proposed_question: string | null;
  proposed_min_criteria: string | null;
  proposed_max_criteria: string | null;
  proposed_category: string | null;
  rich_entries: string | null;
  status: string;
  created_at: string;
  user_id: string;
  reviewed_at: string | null;
  review_notes: string | null;
  profiles?: {
    display_name: string | null;
    username: string | null;
    full_name: string | null;
  } | null;
}

interface RFCVote {
  id: string;
  vote: 'approve' | 'reject' | 'abstain';
  notes: string | null;
  created_at: string;
}

/**
 * Shareable RFC Proposal Page
 * Public view of a contributor's RFC proposal
 */
export const Route = createFileRoute('/submissions/rfc/$id')({
  loader: async ({ params }) => {
    const { id } = params

    // Fetch RFC details
    const { data: rfc } = await supabase
      .from('rfc_proposals')
      .select(`
        id,
        proposal_type,
        rationale,
        proposed_name,
        status,
        user_id,
        profiles:user_id (
          display_name,
          username,
          full_name
        )
      `)
      .eq('id', id)
      .single()

    // Fetch vote counts
    const { data: votes } = await supabase
      .from('rfc_votes')
      .select('vote')
      .eq('rfc_id', id)

    const votesFor = votes?.filter(v => v.vote === 'approve').length || 0
    const votesAgainst = votes?.filter(v => v.vote === 'reject').length || 0

    // Get author name
    const typedRfc = rfc as unknown as RFCProposal
    const author = typedRfc?.profiles?.display_name
      || typedRfc?.profiles?.full_name
      || typedRfc?.profiles?.username
      || 'Anonymous'

    return {
      rfc,
      votesFor,
      votesAgainst,
      author,
    }
  },

  head: ({ loaderData }) => {
    if (!loaderData?.rfc) {
      return createRFCHeadConfig()
    }

    const { rfc, votesFor, votesAgainst, author } = loaderData
    const title = rfc.proposed_name || `${rfc.proposal_type === 'new_metric' ? 'New' : 'Modify'} Metric Proposal`

    return createRFCHeadConfig({
      title,
      description: rfc.rationale?.substring(0, 160) || 'FVS metric RFC proposal',
      status: rfc.status || 'pending',
      author,
      votesFor,
      votesAgainst,
    })
  },

  component: RFCProposalPage,
});

function RFCProposalPage() {
  const { id } = useParams({ from: '/submissions/rfc/$id' });
  const navigate = useNavigate();
  const [rfc, setRFC] = useState<RFCProposal | null>(null);
  const [votes, setVotes] = useState<RFCVote[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadRFC = async () => {
      setLoading(true);
      setError(null);

      try {
        // Load RFC
        const { data: rfcData, error: rfcError } = await supabase
          .from('rfc_proposals')
          .select('*')
          .eq('id', id)
          .single();

        if (rfcError) {
          if (rfcError.code === 'PGRST116') {
            setError('RFC proposal not found');
          } else {
            throw rfcError;
          }
          return;
        }

        setRFC(rfcData as unknown as RFCProposal);

        // Load votes
        const { data: votesData, error: votesError } = await supabase
          .from('rfc_votes')
          .select('*')
          .eq('rfc_id', id)
          .order('created_at', { ascending: false });

        if (votesError) throw votesError;
        setVotes((votesData as unknown as RFCVote[]) || []);
      } catch (err) {
        console.error('Error loading RFC:', err);
        setError('Failed to load RFC proposal');
      } finally {
        setLoading(false);
      }
    };

    loadRFC();
  }, [id]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
      case 'implemented':
        return 'text-green-500';
      case 'rejected':
        return 'text-red-500';
      case 'voting':
      case 'open':
        return 'text-yellow-500';
      default:
        return 'text-gray-500';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'approved':
      case 'implemented':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'voting':
      case 'open':
        return 'how_to_vote';
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

  const voteStats = {
    approve: votes.filter((v) => v.vote === 'approve').length,
    reject: votes.filter((v) => v.vote === 'reject').length,
    abstain: votes.filter((v) => v.vote === 'abstain').length,
    total: votes.length,
  };

  const approvalPercentage = voteStats.total > 0
    ? Math.round((voteStats.approve / voteStats.total) * 100)
    : 0;

  if (loading) {
    return (
      <div className="flex-1 p-6 flex items-center justify-center">
        <div className="text-text-muted">Loading RFC proposal...</div>
      </div>
    );
  }

  if (error || !rfc) {
    return (
      <div className="flex-1 p-6">
        <div className="max-w-4xl mx-auto">
          <GlassPanel>
            <div className="text-center py-12">
              <Icon name="error_outline" className="text-6xl text-red-500 mb-4" />
              <h2 className="text-2xl font-bold mb-2">RFC Not Found</h2>
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
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <Icon
                name={getStatusIcon(rfc.status)}
                className={`text-3xl ${getStatusColor(rfc.status)}`}
              />
              <h1 className="text-4xl font-bold">
                {rfc.proposal_type === 'new_metric' ? 'New Metric' : 'Modify Metric'} Proposal
              </h1>
            </div>
            <div className="flex items-center gap-3 text-sm text-text-muted">
              <span className={`uppercase font-bold ${getStatusColor(rfc.status)}`}>
                {rfc.status}
              </span>
              <span>•</span>
              <span>Proposed {formatDate(rfc.created_at)}</span>
            </div>
          </div>
          <ShareButton variant="button" label="Share RFC" />
        </div>

        {/* Main Content */}
        <div className="space-y-6">
          {/* Rationale */}
          <GlassPanel>
            <h2 className="text-xl font-bold mb-3 flex items-center gap-2">
              <Icon name="description" className="text-primary" />
              Rationale
            </h2>
            <p className="text-text-muted leading-relaxed whitespace-pre-wrap">{rfc.rationale}</p>
          </GlassPanel>

          {/* Proposed Changes */}
          {(rfc.proposed_name || rfc.proposed_question || rfc.proposed_category) && (
            <GlassPanel>
              <h2 className="text-xl font-bold mb-3 flex items-center gap-2">
                <Icon name="edit_note" className="text-primary" />
                Proposed Changes
              </h2>
              <div className="space-y-3">
                {rfc.proposed_name && (
                  <div>
                    <span className="text-xs text-text-muted uppercase font-bold">Metric Name:</span>
                    <p className="text-white">{rfc.proposed_name}</p>
                  </div>
                )}
                {rfc.proposed_question && (
                  <div>
                    <span className="text-xs text-text-muted uppercase font-bold">Question:</span>
                    <p className="text-white">{rfc.proposed_question}</p>
                  </div>
                )}
                {rfc.proposed_category && (
                  <div>
                    <span className="text-xs text-text-muted uppercase font-bold">Category:</span>
                    <p className="text-white">{rfc.proposed_category}</p>
                  </div>
                )}
                {rfc.proposed_min_criteria && (
                  <div>
                    <span className="text-xs text-text-muted uppercase font-bold">Min Criteria:</span>
                    <p className="text-white">{rfc.proposed_min_criteria}</p>
                  </div>
                )}
                {rfc.proposed_max_criteria && (
                  <div>
                    <span className="text-xs text-text-muted uppercase font-bold">Max Criteria:</span>
                    <p className="text-white">{rfc.proposed_max_criteria}</p>
                  </div>
                )}
              </div>
            </GlassPanel>
          )}

          {/* Rich Entries */}
          {rfc.rich_entries && (
            <GlassPanel>
              <h2 className="text-xl font-bold mb-3 flex items-center gap-2">
                <Icon name="notes" className="text-primary" />
                Additional Details
              </h2>
              <p className="text-text-muted leading-relaxed whitespace-pre-wrap">{rfc.rich_entries}</p>
            </GlassPanel>
          )}

          {/* Voting Results */}
          <GlassPanel>
            <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
              <Icon name="poll" className="text-primary" />
              Voting Results
            </h2>

            <div className="grid grid-cols-3 gap-4 mb-6">
              <div className="text-center p-4 bg-background rounded border border-border">
                <Icon name="thumb_up" className="text-3xl text-green-500 mb-2" />
                <div className="text-2xl font-bold text-green-500">{voteStats.approve}</div>
                <div className="text-xs text-text-muted uppercase">Approve</div>
              </div>
              <div className="text-center p-4 bg-background rounded border border-border">
                <Icon name="thumb_down" className="text-3xl text-red-500 mb-2" />
                <div className="text-2xl font-bold text-red-500">{voteStats.reject}</div>
                <div className="text-xs text-text-muted uppercase">Reject</div>
              </div>
              <div className="text-center p-4 bg-background rounded border border-border">
                <Icon name="remove" className="text-3xl text-gray-500 mb-2" />
                <div className="text-2xl font-bold text-gray-500">{voteStats.abstain}</div>
                <div className="text-xs text-text-muted uppercase">Abstain</div>
              </div>
            </div>

            {/* Progress Bar */}
            <div className="mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-text-muted">Approval Rate</span>
                <span className="text-sm font-bold">{approvalPercentage}%</span>
              </div>
              <div className="w-full h-4 bg-background rounded-full overflow-hidden border border-border">
                <div
                  className="h-full bg-green-500 transition-all"
                  style={{ width: `${approvalPercentage}%` }}
                />
              </div>
            </div>

            <div className="text-sm text-text-muted">
              <Icon name="people" className="inline mr-2" />
              {voteStats.total} total {voteStats.total === 1 ? 'vote' : 'votes'}
            </div>
          </GlassPanel>

          {/* Vote Rationales */}
          {votes.length > 0 && votes.some((v) => v.notes) && (
            <GlassPanel>
              <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
                <Icon name="comment" className="text-primary" />
                Vote Rationales
              </h2>
              <div className="space-y-3">
                {votes
                  .filter((v) => v.notes)
                  .map((vote) => (
                    <div
                      key={vote.id}
                      className="p-3 bg-background rounded border border-border"
                    >
                      <div className="flex items-center gap-2 mb-2">
                        <Icon
                          name={
                            vote.vote === 'approve'
                              ? 'thumb_up'
                              : vote.vote === 'reject'
                                ? 'thumb_down'
                                : 'remove'
                          }
                          className={`text-sm ${vote.vote === 'approve'
                            ? 'text-green-500'
                            : vote.vote === 'reject'
                              ? 'text-red-500'
                              : 'text-gray-500'
                            }`}
                        />
                        <span className="text-xs text-text-muted uppercase font-bold">
                          {vote.vote}
                        </span>
                        <span className="text-xs text-text-muted">
                          • {formatDate(vote.created_at)}
                        </span>
                      </div>
                      <p className="text-sm text-text-muted">{vote.notes}</p>
                    </div>
                  ))}
              </div>
            </GlassPanel>
          )}

          {/* Status-specific messages */}
          {rfc.status === 'implemented' && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="check_circle" className="text-green-500" />
                <h3 className="font-bold text-green-500">Implemented</h3>
              </div>
              <p className="text-sm text-text-muted">
                This RFC was approved and implemented.
              </p>
            </GlassPanel>
          )}

          {rfc.status === 'rejected' && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="cancel" className="text-red-500" />
                <h3 className="font-bold text-red-500">Rejected</h3>
              </div>
              <p className="text-sm text-text-muted">
                This RFC was rejected by the community.
              </p>
              {rfc.review_notes && (
                <div className="mt-3 p-3 bg-background rounded border border-border">
                  <p className="text-xs text-text-muted mb-1 font-bold">Review Notes:</p>
                  <p className="text-sm">{rfc.review_notes}</p>
                </div>
              )}
            </GlassPanel>
          )}

          {(rfc.status === 'voting' || rfc.status === 'open') && (
            <GlassPanel>
              <div className="flex items-center gap-2 mb-2">
                <Icon name="how_to_vote" className="text-yellow-500" />
                <h3 className="font-bold text-yellow-500">Voting in Progress</h3>
              </div>
              <p className="text-sm text-text-muted mb-4">
                This RFC is currently open for voting. Contributors can vote on this proposal.
              </p>
              <button
                onClick={() => navigate({ to: '/contributors/governance' })}
                className="bg-primary text-black font-bold px-4 py-2 rounded hover:bg-white transition-all flex items-center gap-2"
              >
                <Icon name="how_to_vote" />
                Vote on This RFC
              </button>
            </GlassPanel>
          )}
        </div>

        {/* Footer CTA */}
        <div className="mt-8 text-center">
          <button
            onClick={() => navigate({ to: '/contributors/governance' })}
            className="bg-panel border border-border text-white font-bold px-6 py-3 rounded hover:border-primary transition-all"
          >
            View All RFCs
          </button>
        </div>
      </div>
    </div>
  );
}
