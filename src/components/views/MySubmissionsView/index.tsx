import { useEffect, useState } from 'react';
import { supabase } from '../../../utils/supabase';
import { useAuth } from '../../../context/AuthContext';
import GlassPanel from '../../shared/GlassPanel';
import Icon from '../../Icon';
import ShareButton from '../../shared/ShareButton';
import { Link } from '@tanstack/react-router';

interface TargetSubmission {
  id: string;
  target_name: string;
  case_id: string | null;
  origin: string | null;
  description: string;
  status: 'pending' | 'approved' | 'rejected';
  submitted_at: string;
  reviewed_at: string | null;
  review_notes: string | null;
}

interface UserScore {
  id: string;
  target_id: string;
  metric_id: string;
  vote_value: number;
  confidence_level: string | null;
  rationale: string | null;
  created_at: string;
  // Joined data
  target_name?: string;
  metric_name?: string;
}

interface RFCProposal {
  id: string;
  title: string;
  description: string;
  status: string;
  created_at: string;
  votes_for?: number;
  votes_against?: number;
}

export default function MySubmissionsView() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<'targets' | 'scores' | 'rfcs'>('targets');
  const [targetSubmissions, setTargetSubmissions] = useState<TargetSubmission[]>([]);
  const [userScores, setUserScores] = useState<UserScore[]>([]);
  const [rfcProposals, setRFCProposals] = useState<RFCProposal[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;

    const loadSubmissions = async () => {
      setLoading(true);
      try {
        // Load target submissions
        const { data: targets, error: targetsError } = await supabase
          .from('target_submissions')
          .select('*')
          .eq('submitted_by', user.id)
          .order('submitted_at', { ascending: false });

        if (targetsError) throw targetsError;
        if (targetsError) throw targetsError;
        setTargetSubmissions((targets as unknown as TargetSubmission[]) || []);

        // Load user scores with target and metric names
        const { data: scores, error: scoresError } = await supabase
          .from('community_votes')
          .select(`
              id,
              target_id,
              metric_id,
              vote_value,
              confidence_level,
              rationale,
              created_at,
              targets:target_id (name),
              metrics:metric_id (name)
            `)
          .eq('user_id', user.id)
          .order('created_at', { ascending: false });

        if (scoresError) throw scoresError;

        // Transform the data to flatten nested objects
        /* eslint-disable @typescript-eslint/no-explicit-any */
        const transformedScores = (scores || []).map((score: any) => ({
          id: score.id,
          target_id: score.target_id,
          metric_id: score.metric_id,
          vote_value: score.vote_value,
          confidence_level: score.confidence_level,
          rationale: score.rationale,
          created_at: score.created_at,
          target_name: score.targets?.name,
          metric_name: score.metrics?.name,
        }));
        setUserScores(transformedScores);

        // Load RFC proposals
        const { data: rfcs, error: rfcsError } = await supabase
          .from('rfc_proposals')
          .select(`
              id,
              proposal_type,
              rationale,
              status,
              created_at,
              rfc_votes (vote)
            `)
          .eq('user_id', user.id)
          .order('created_at', { ascending: false });

        if (rfcsError) throw rfcsError;

        // Count votes
        const transformedRFCs = (rfcs || []).map((rfc: any) => {
          const votes = rfc.rfc_votes || [];
          return {
            id: rfc.id,
            title: `${rfc.proposal_type === 'new_metric' ? 'New Metric' : 'Modify Metric'} Proposal`,
            description: rfc.rationale,
            status: rfc.status,
            created_at: rfc.created_at,
            votes_for: votes.filter((v: any) => v.vote === 'approve').length,
            votes_against: votes.filter((v: any) => v.vote === 'reject').length,
          };
        });
        /* eslint-enable @typescript-eslint/no-explicit-any */
        setRFCProposals(transformedRFCs);
      } catch (error) {
        console.error('Error loading submissions:', error);
      } finally {
        setLoading(false);
      }
    };

    loadSubmissions();
  }, [user]);

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'approved':
        return 'text-green-500';
      case 'rejected':
        return 'text-red-500';
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
      case 'rejected':
        return 'cancel';
      case 'pending':
        return 'schedule';
      default:
        return 'help';
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  return (
    <div className="flex-1 p-6 overflow-y-auto">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-3xl font-bold mb-2 flex items-center gap-3">
            <Icon name="folder_open" className="text-primary" />
            Submissions
          </h1>
          <p className="text-text-muted">
            View and manage your submitted targets, scores, and RFC proposals.
          </p>
        </div>

        {/* Tabs */}
        <div className="flex gap-2 mb-6 border-b border-border">
          <button
            onClick={() => setActiveTab('targets')}
            className={`px-4 py-2 font-medium transition-all ${activeTab === 'targets'
              ? 'text-white border-b-2 border-primary'
              : 'text-text-muted hover:text-white'
              }`}
          >
            <Icon name="flag" className="inline mr-2" />
            Target Proposals ({targetSubmissions.length})
          </button>
          <button
            onClick={() => setActiveTab('scores')}
            className={`px-4 py-2 font-medium transition-all ${activeTab === 'scores'
              ? 'text-white border-b-2 border-primary'
              : 'text-text-muted hover:text-white'
              }`}
          >
            <Icon name="star" className="inline mr-2" />
            Scores ({userScores.length})
          </button>
          <button
            onClick={() => setActiveTab('rfcs')}
            className={`px-4 py-2 font-medium transition-all ${activeTab === 'rfcs'
              ? 'text-white border-b-2 border-primary'
              : 'text-text-muted hover:text-white'
              }`}
          >
            <Icon name="description" className="inline mr-2" />
            RFCs ({rfcProposals.length})
          </button>
        </div>

        {/* Content */}
        {loading ? (
          <GlassPanel>
            <div className="flex items-center justify-center py-12">
              <div className="text-text-muted">Loading submissions...</div>
            </div>
          </GlassPanel>
        ) : (
          <>
            {/* Target Submissions */}
            {activeTab === 'targets' && (
              <div className="space-y-4">
                {targetSubmissions.length === 0 ? (
                  <GlassPanel>
                    <div className="text-center py-12 text-text-muted">
                      <Icon name="inbox" className="text-6xl mb-4 opacity-50" />
                      <p>No target submissions yet.</p>
                      <p className="text-sm mt-2">Submit your first target to get started!</p>
                    </div>
                  </GlassPanel>
                ) : (
                  targetSubmissions.map((submission) => (
                    <GlassPanel key={submission.id}>
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <Icon
                              name={getStatusIcon(submission.status)}
                              className={`text-2xl ${getStatusColor(submission.status)}`}
                            />
                            <h3 className="text-xl font-bold">{submission.target_name}</h3>
                            {submission.case_id && (
                              <span className="mono text-xs text-text-muted bg-panel px-2 py-1 rounded">
                                {submission.case_id}
                              </span>
                            )}
                          </div>
                          <p className="text-sm text-text-muted mb-3">{submission.description}</p>
                          <div className="flex items-center gap-4 text-xs text-text-muted">
                            {submission.origin && (
                              <span className="flex items-center gap-1">
                                <Icon name="business" className="text-sm" />
                                {submission.origin}
                              </span>
                            )}
                            <span className="flex items-center gap-1">
                              <Icon name="schedule" className="text-sm" />
                              Submitted {formatDate(submission.submitted_at)}
                            </span>
                            <span className={`uppercase font-bold ${getStatusColor(submission.status)}`}>
                              {submission.status}
                            </span>
                          </div>
                          {submission.review_notes && (
                            <div className="mt-3 p-3 bg-background rounded border border-border">
                              <p className="text-xs text-text-muted mb-1 font-bold">Review Notes:</p>
                              <p className="text-sm">{submission.review_notes}</p>
                            </div>
                          )}
                        </div>
                        <div className="flex flex-col gap-2">
                          <ShareButton
                            variant="button"
                            label="Share"
                            url={`${window.location.origin}/submissions/target/${submission.id}`}
                            disabled={submission.status === 'rejected'}
                            disabledReason="Cannot share rejected submissions"
                          />
                        </div>
                      </div>
                    </GlassPanel>
                  ))
                )}
              </div>
            )}

            {/* User Scores */}
            {activeTab === 'scores' && (
              <div className="space-y-4">
                {userScores.length === 0 ? (
                  <GlassPanel>
                    <div className="text-center py-12 text-text-muted">
                      <Icon name="inbox" className="text-6xl mb-4 opacity-50" />
                      <p>No scores submitted yet.</p>
                      <p className="text-sm mt-2">Start scoring targets to see your submissions here!</p>
                    </div>
                  </GlassPanel>
                ) : (
                  userScores.map((score) => (
                    <GlassPanel key={score.id}>
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <div className="flex items-center justify-center w-12 h-12 bg-primary text-black rounded-full font-bold text-xl">
                              {score.vote_value}
                            </div>
                            <div>
                              <h3 className="text-lg font-bold">{score.target_name}</h3>
                              <p className="text-sm text-text-muted">{score.metric_name}</p>
                            </div>
                          </div>
                          {score.rationale && (
                            <p className="text-sm text-text-muted mb-3 pl-15">{score.rationale}</p>
                          )}
                          <div className="flex items-center gap-4 text-xs text-text-muted pl-15">
                            {score.confidence_level && (
                              <span className="flex items-center gap-1">
                                <Icon name="verified" className="text-sm" />
                                Confidence: {score.confidence_level}
                              </span>
                            )}
                            <span className="flex items-center gap-1">
                              <Icon name="schedule" className="text-sm" />
                              {formatDate(score.created_at)}
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-col gap-2">
                          <Link
                            to="/audit-target/$slug"
                            params={{ slug: score.target_id }}
                            className="bg-panel border border-border text-white font-bold px-4 py-2 rounded text-xs hover:border-primary transition-all flex items-center gap-2"
                          >
                            <Icon name="edit" className="text-sm" />
                            Edit Score
                          </Link>
                        </div>
                      </div>
                    </GlassPanel>
                  ))
                )}
              </div>
            )}

            {/* RFC Proposals */}
            {activeTab === 'rfcs' && (
              <div className="space-y-4">
                {rfcProposals.length === 0 ? (
                  <GlassPanel>
                    <div className="text-center py-12 text-text-muted">
                      <Icon name="inbox" className="text-6xl mb-4 opacity-50" />
                      <p>No RFC proposals yet.</p>
                      <p className="text-sm mt-2">Propose metric changes to see them here!</p>
                    </div>
                  </GlassPanel>
                ) : (
                  rfcProposals.map((rfc) => (
                    <GlassPanel key={rfc.id}>
                      <div className="flex items-start justify-between">
                        <div className="flex-1">
                          <div className="flex items-center gap-3 mb-2">
                            <Icon name="description" className="text-2xl text-primary" />
                            <h3 className="text-xl font-bold">{rfc.title}</h3>
                            <span className="mono text-xs text-text-muted bg-panel px-2 py-1 rounded uppercase">
                              {rfc.status}
                            </span>
                          </div>
                          <p className="text-sm text-text-muted mb-3">{rfc.description}</p>
                          <div className="flex items-center gap-4 text-xs text-text-muted">
                            <span className="flex items-center gap-1">
                              <Icon name="thumb_up" className="text-sm text-green-500" />
                              {rfc.votes_for || 0} For
                            </span>
                            <span className="flex items-center gap-1">
                              <Icon name="thumb_down" className="text-sm text-red-500" />
                              {rfc.votes_against || 0} Against
                            </span>
                            <span className="flex items-center gap-1">
                              <Icon name="schedule" className="text-sm" />
                              Proposed {formatDate(rfc.created_at)}
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-col gap-2">
                          <ShareButton
                            variant="button"
                            label="Share"
                            url={`${window.location.origin}/submissions/rfc/${rfc.id}`}
                          />
                        </div>
                      </div>
                    </GlassPanel>
                  ))
                )}
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
