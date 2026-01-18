
/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * Central Supabase Hook Architecture
 *
 * This file provides a centralized hook-based interface to all Supabase operations.
 * Instead of calling Supabase SDK directly throughout the app, components use these hooks.
 *
 * Benefits:
 * - Type-safe database operations using Supabase-generated types
 * - Consistent error handling
 * - Loading states management
 * - Easy to test and mock
 * - Single source of truth for data operations
 */

import { useState, useEffect, useCallback, useRef } from 'react';
import { supabase, getURL } from '../utils/supabase';
import type { Session, User } from '@supabase/supabase-js';
import { SORTED_ORIGIN_TYPES } from '../data/originTypes';
import { SORTED_CONTEXT_TYPES } from '../data/contextTypes';

// Import database types from our type utilities
// These are derived from Supabase-generated schema (src/types/supabase.ts)
import type {
  Inserts,
  DbUserProfile,
  DbMetric,
  DbTarget,
  DbScore,
  DbVote,
  DbDiscussion,
  DbRFC,
} from '../types/database';

/**
 * TYPE SAFETY PATTERN
 *
 * This file follows Supabase-first type conventions:
 *
 * 1. All database types are derived from generated Supabase schema
 * 2. Use DbTable types (e.g., DbMetric, DbTarget) for exact database rows
 * 3. For joined queries, define local composite types:
 *    type ScoreWithMetric = DbScore & { metrics: DbMetric | null };
 * 4. Always specify return types for hooks using useSupabaseQuery<Type>()
 * 5. Return empty arrays [] instead of null for consistency
 *
 * Benefits:
 * - Automatic type updates when schema changes
 * - Compile-time errors for breaking changes
 * - IntelliSense autocomplete for all database fields
 * - No manual type maintenance required
 *
 * See TYPE_CONVENTIONS.md for detailed guidelines.
 */

// ============================================================================
// UTILITY HOOKS
// ============================================================================

/**
 * Base hook for Supabase operations with loading and error states
 */
export function useSupabaseQuery<T>(queryFn: () => Promise<T>, dependencies: any[] = []) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<any>(null);
  const [refreshKey, setRefreshKey] = useState(0);

  // Use a ref to store the latest queryFn to avoid dependency cycles works
  // while ensuring we always call the latest version of the function
  const queryFnRef = useRef(queryFn);

  // Update ref when queryFn changes
  useEffect(() => {
    queryFnRef.current = queryFn;
  }, [queryFn]);

  const refetch = useCallback(() => {
    setRefreshKey((prev) => prev + 1);
  }, []);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      try {
        setLoading(true);
        setError(null);
        // Use the ref to call the function
        const result = await queryFnRef.current();
        if (!cancelled) {
          setData(result);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err);
          console.error('Supabase query error:', err);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      cancelled = true;
    };
    // safe to ignore queryFnRef rule here as we manage it manually
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...dependencies, refreshKey]);

  return { data, loading, error, refetch };
}

/**
 * Hook for Supabase mutations (insert, update, delete)
 */
export function useSupabaseMutation<T = any>() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<any>(null);

  const mutate = useCallback(async (mutationFn: () => Promise<T>) => {
    try {
      setLoading(true);
      setError(null);
      const result = await mutationFn();
      return result;
    } catch (err) {
      setError(err);
      console.error('Supabase mutation error:', err);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  return { mutate, loading, error };
}

// ============================================================================
// REFERENCE DATA HOOKS
// ============================================================================

/**
 * Hook: useOriginTypes
 * Fetches active origin reference entries from Supabase, with local fallback.
 * NOTE: Currently using local fallback data until origin_types table is created.
 */
export function useOriginTypes() {
  return useSupabaseQuery(
    async () => {
      // TODO: Uncomment when origin_types table is created in migration
      // const { data, error } = await supabase
      //   .from('origin_types')
      //   .select('*')
      //   .eq('is_active', true)
      //   .order('sort_order', { ascending: true });
      //
      // // If table doesn't exist (PGRST205) or other errors, fall back to local data
      // if (error) {
      //   console.warn('origin_types table not found, using local fallback data');
      //   return SORTED_ORIGIN_TYPES;
      // }
      // return data && data.length > 0 ? data : SORTED_ORIGIN_TYPES;

      // Temporary: return local data directly
      return SORTED_ORIGIN_TYPES;
    },
    []
  );
}

/**
 * Hook: useContextTypes
 * Fetches active context reference entries from Supabase, with local fallback.
 * NOTE: Currently using local fallback data until context_types table is created.
 */
export function useContextTypes() {
  return useSupabaseQuery(
    async () => {
      // TODO: Uncomment when context_types table is created in migration
      // const { data, error } = await supabase
      //   .from('context_types')
      //   .select('*')
      //   .eq('is_active', true)
      //   .order('sort_order', { ascending: true });
      //
      // if (error) {
      //   console.warn('context_types table not found, using local fallback data');
      //   return SORTED_CONTEXT_TYPES;
      // }
      // return data && data.length > 0 ? data : SORTED_CONTEXT_TYPES;

      // Temporary: return local data directly
      return SORTED_CONTEXT_TYPES;
    },
    []
  );
}

// ============================================================================
// 1. AUTHENTICATION & USER MANAGEMENT HOOKS
// ============================================================================

/**
 * Hook: useAuth
 * Manages authentication state and operations
 */
export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      setLoading(false);
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setUser(session?.user ?? null);
    });

    return () => subscription.unsubscribe();
  }, []);

  const signIn = useCallback(async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw error;
    return data;
  }, []);

  const signUp = useCallback(async (email: string, password: string, metadata: Record<string, any> = {}) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: metadata,
      },
    });
    if (error) throw error;
    return data;
  }, []);

  const signOut = useCallback(async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
  }, []);

  const signInWithOAuth = useCallback(async (provider: 'google' | 'apple' | 'github' | 'azure', options?: { redirectTo?: string, scopes?: string, queryParams?: { [key: string]: string } }) => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: getURL(),
        ...options
      }
    });
    if (error) throw error;
    return data;
  }, []);

  return {
    user,
    session,
    loading,
    signIn,
    signUp,
    signOut,
    signInWithOAuth,
  };
}

/**
 * Hook: useUserProfile
 * Manages user profile data and RBAC
 */
export function useUserProfile(userId: string | undefined) {
  const { data: profile, loading, error } = useSupabaseQuery<DbUserProfile | null>(
    async () => {
      if (!userId) return null;
      const { data, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', userId)
        .single();
      if (error) throw error;
      return data;
    },
    [userId]
  );

  return { profile, loading, error };
}

/**
 * Hook: useCurrentUserProfile
 * Gets the current logged-in user's profile
 */
export function useCurrentUserProfile() {
  const { user } = useAuth();
  return useUserProfile(user?.id);
}

/**
 * Hook: useUserRole
 * Gets the current user's role (user | admin)
 */
export function useUserRole() {
  const { profile, loading } = useCurrentUserProfile();
  return {
    role: profile?.role || 'user',
    isAdmin: profile?.role === 'admin',
    loading,
  };
}

// ============================================================================
// 2. METRIC SCORING HOOKS
// ============================================================================

/**
 * Hook: useMetrics
 * Fetches all metrics
 */
export function useMetrics() {
  return useSupabaseQuery<DbMetric[]>(async () => {
    const { data, error } = await supabase
      .from('metrics')
      .select('*')
      .order('id');
    if (error) throw error;
    return data || [];
  });
}

/**
 * Hook: useTargets
 * Fetches all forecast targets, with fallback data for local development
 */
export function useTargets() {
  return useSupabaseQuery<DbTarget[]>(async () => {
    const { data, error } = await supabase
      .from('targets')
      .select('*')
      .order('created_at', { ascending: false });

    // If error or no data, return fallback targets for local development
    if (error || !data || data.length === 0) {
      const { FALLBACK_TARGETS } = await import('../data/targets');
      return FALLBACK_TARGETS;
    }

    return data;
  });
}

/**
 * Hook: useUserScores
 * Fetches user scores for a specific target
 */
export function useUserScores(userId: string | undefined, targetId: string) {
  type UserScoreWithMetric = DbScore & { metrics: DbMetric | null };

  return useSupabaseQuery<UserScoreWithMetric[]>(
    async () => {
      if (!userId) return [];
      const { data, error } = await supabase
        .from('user_scores')
        .select('*, metrics(*)')
        .eq('user_id', userId)
        .eq('target_id', targetId);
      if (error) throw error;
      return data || [];
    },
    [userId, targetId]
  );
}

/**
 * Hook: useSubmitScore
 * Submits or updates a user's score for a metric
 */
export function useSubmitScore() {
  const { mutate, loading, error } = useSupabaseMutation<DbScore[]>();

  const submitScore = useCallback(
    async (targetId: string, metricId: number, score: number, notes = '', scoreType = 'slider') => {
      return mutate(async () => {
        const userData = await supabase.auth.getUser();
        if (!userData.data.user) throw new Error('User not authenticated');

        const { data, error } = await supabase
          .from('user_scores')
          .upsert(
            {
              user_id: userData.data.user.id,
              target_id: targetId,
              metric_id: metricId,
              score,
              notes,
              score_type: scoreType,
              updated_at: new Date().toISOString(),
            },
            {
              onConflict: 'user_id,target_id,metric_id',
            }
          )
          .select();
        if (error) throw error;
        return data || [];
      });
    },
    [mutate]
  );

  return { submitScore, loading, error };
}

// ============================================================================
// 3. COMMUNITY VOTING HOOKS
// ============================================================================

/**
 * Hook: useCommunityVotes
 * Fetches community votes for a target
 */
export function useCommunityVotes(targetId: string) {
  type VoteWithMetric = DbVote & { metrics: DbMetric | null };

  return useSupabaseQuery<VoteWithMetric[]>(
    async () => {
      const { data, error } = await supabase
        .from('community_votes')
        .select('*, metrics(*)')
        .eq('target_id', targetId);
      if (error) throw error;
      return data || [];
    },
    [targetId]
  );
}

/**
 * Hook: useSubmitCommunityVote
 * Submits a community vote with confidence level and rationale
 */
export function useSubmitCommunityVote() {
  const { mutate, loading, error } = useSupabaseMutation();

  const submitVote = useCallback(
    async (targetId: string, metricId: number, voteValue: number, confidenceLevel: string, rationale = '') => {
      return mutate(async () => {
        const { data, error } = await supabase.rpc('upsert_community_vote', {
          p_target_id: targetId,
          p_metric_id: metricId,
          p_vote_value: voteValue,
          p_confidence_level: confidenceLevel,
          p_rationale: rationale,
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { submitVote, loading, error };
}

/**
 * Hook: useUserVotesForTarget
 * Gets the current user's votes for a specific target
 */
export function useUserVotesForTarget(targetId: string) {
  return useSupabaseQuery(
    async () => {
      const { data: sessionData } = await supabase.auth.getSession();
      if (!sessionData?.session?.user) {
        return [];
      }
      const { data, error } = await supabase.rpc('get_user_votes_for_target', {
        p_target_id: targetId,
      });
      if (error) throw error;
      return data;
    },
    [targetId]
  );
}

/**
 * Hook: usePublicUserVotesForTarget
 * Gets a specific user's votes for a specific target (publicly viewable)
 */
export function usePublicUserVotesForTarget(targetId: string, userId: string) {
  type VoteWithMetric = DbVote & { metrics: DbMetric | null };

  return useSupabaseQuery<VoteWithMetric[]>(
    async () => {
      if (!targetId || !userId) return [];

      const { data, error } = await supabase
        .from('community_votes')
        .select('*, metrics(*)')
        .eq('target_id', targetId)
        .eq('user_id', userId);

      if (error) throw error;
      return data || [];
    },
    [targetId, userId]
  );
}

// ============================================================================
// 4. RFC & SUBMISSION HOOKS
// ============================================================================

/**
 * Hook: useSubmitRFC
 * Submits an RFC proposal for metric changes
 */
export function useSubmitRFC() {
  const { mutate, loading, error } = useSupabaseMutation();

  const submitRFC = useCallback(
    async (rfcData: {
      metricId: number;
      proposalType: string;
      proposedName?: string;
      proposedQuestion?: string;
      proposedMinCriteria?: string;
      proposedMaxCriteria?: string;
      proposedCategory?: string;
      richEntries?: any;
      rationale: string;
    }) => {
      const {
        metricId,
        proposalType,
        proposedName,
        proposedQuestion,
        proposedMinCriteria,
        proposedMaxCriteria,
        proposedCategory,
        richEntries,
        rationale,
      } = rfcData;

      return mutate(async () => {
        const { data, error } = await supabase.rpc('submit_rfc_proposal', {
          p_metric_id: metricId,
          p_proposal_type: proposalType,
          p_proposed_name: proposedName,
          p_proposed_question: proposedQuestion,
          p_proposed_min_criteria: proposedMinCriteria,
          p_proposed_max_criteria: proposedMaxCriteria,
          p_proposed_category: proposedCategory,
          p_rich_entries: richEntries,
          p_rationale: rationale,
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { submitRFC, loading, error };
}

/**
 * Hook: useRFCProposals
 * Fetches RFC proposals (optionally filtered by status)
 */
export function useRFCProposals(status: string | null = null) {
  type RFCWithMetric = DbRFC & { metrics: DbMetric | null };

  return useSupabaseQuery<RFCWithMetric[]>(async () => {
    let query = supabase
      .from('rfc_proposals')
      .select('*, metrics(*)')
      .order('created_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data || [];
  }, [status]);
}

/**
 * Hook: useRFCVotes
 * Fetches votes for a specific RFC proposal (or all if rfcId is null, though usually per RFC)
 * JOINs with user profiles to get voter names if needed.
 */

/**
 * Hook: useRFCVotes
 * Fetches votes for a specific RFC proposal (or all if rfcId is null, though usually per RFC)
 * JOINs with user profiles to get voter names if needed.
 */
export function useRFCVotes(rfcId: string | null = null) {
  return useSupabaseQuery(
    async () => {
      if (!rfcId) return [];
      const { data, error } = await supabase
        .from('rfc_votes')
        .select('*, user_profiles(full_name)')
        .eq('rfc_id', rfcId);

      if (error) throw error;
      return data || [];
    },
    [rfcId]
  );
}

/**
 * Hook: useUpsertRFCVote
 * Upserts a vote/note on an RFC proposal
 */
export function useUpsertRFCVote() {
  const { mutate, loading, error } = useSupabaseMutation();

  const upsertVote = useCallback(
    async (rfcId: string, vote: string, confidenceLevel: string = 'medium', notes: string = '') => {
      return mutate(async () => {
        const { data, error } = await (supabase as any).rpc('upsert_rfc_vote', {
          p_rfc_id: rfcId,
          p_vote: vote,
          p_confidence_level: confidenceLevel,
          p_notes: notes
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { upsertVote, loading, error };
}

/**
 * Hook: useSubmitTargetSubmission
 * Submits a new target disclosure
 */
export function useSubmitTargetSubmission() {
  const { mutate, loading, error } = useSupabaseMutation();

  const submitTarget = useCallback(
    async (targetData: Inserts<'target_submissions'>) => {
      return mutate(async () => {
        const { data, error } = await supabase
          .from('target_submissions')
          .insert([targetData])
          .select();
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { submitTarget, loading, error };
}

// ============================================================================
// 5. DISCUSSION & COMMENTS HOOKS
// ============================================================================

/**
 * Hook: useDiscussions
 * Fetches discussions for a metric with vote counts and user profiles
 */
export function useDiscussions(metricId: number, refreshKey = 0) {
  type DiscussionWithProfile = Omit<DbDiscussion, 'upvotes' | 'downvotes'> & {
    upvotes: number;
    downvotes: number;
    user_profiles: { user_id: string; full_name: string | null; role: string } | null;
  };

  return useSupabaseQuery<DiscussionWithProfile[]>(
    async () => {
      // Guard against undefined metric ID (prevents 400 Bad Request)
      if (!metricId) return [];

      // 1. Fetch discussions (without join, as FK relationship is missing for auto-join)
      const { data: discussions, error: discussionError } = await supabase
        .from('metric_discussions')
        .select('*')
        .eq('metric_id', metricId)
        // Removed .is('parent_id', null) to fetch all comments including replies
        .order('created_at', { ascending: false });

      if (discussionError) throw discussionError;
      if (!discussions || discussions.length === 0) return [];

      const discussionIds = [
        ...new Set(discussions.map(d => d.id).filter(Boolean))
      ];
      let voteCounts: Record<string, { upvotes: number; downvotes: number }> = {};

      if (discussionIds.length > 0) {
        const { data: votes, error: votesError } = await supabase
          .from('discussion_votes')
          .select('discussion_id, vote_type')
          .in('discussion_id', discussionIds);

        if (votesError) {
          console.warn('Failed to fetch discussion votes', votesError);
        } else {
          voteCounts = (votes || []).reduce((acc: any, vote) => {
            if (vote.discussion_id) {
              const entry = acc[vote.discussion_id] || { upvotes: 0, downvotes: 0 };
              if (vote.vote_type === 'upvote') {
                entry.upvotes += 1;
              } else if (vote.vote_type === 'downvote') {
                entry.downvotes += 1;
              }
              acc[vote.discussion_id] = entry;
            }
            return acc;
          }, {});
        }
      }

      // 2. Fetch profiles for these users
      const userIds = [...new Set(discussions.map(d => d.user_id).filter(Boolean) as string[])];

      if (userIds.length > 0) {
        const { data: profiles, error: profileError } = await supabase
          .from('user_profiles')
          .select('user_id, full_name, role') // avatar_url not in schema, removed
          .in('user_id', userIds);

        if (profileError) {
          console.warn("Failed to fetch profiles for discussions", profileError);
          // Return discussions without profile data rather than failing
          return discussions.map(d => {
            const counts = d.id ? voteCounts[d.id] : undefined;
            return {
              ...d,
              upvotes: counts ? counts.upvotes : d.upvotes || 0,
              downvotes: counts ? counts.downvotes : d.downvotes || 0,
              user_profiles: null
            };
          });
        }

        // 3. Merge profiles into discussions
        const profileMap = (profiles || []).reduce((acc: any, p) => {
          acc[p.user_id] = p;
          return acc;
        }, {});

        return discussions.map(d => {
          const counts = d.id ? voteCounts[d.id] : undefined;
          return {
            ...d,
            upvotes: counts ? counts.upvotes : d.upvotes || 0,
            downvotes: counts ? counts.downvotes : d.downvotes || 0,
            user_profiles: (d.user_id && profileMap[d.user_id]) || null
          };
        });
      }

      return discussions.map(d => {
        const counts = d.id ? voteCounts[d.id] : undefined;
        return {
          ...d,
          upvotes: counts ? counts.upvotes : d.upvotes || 0,
          downvotes: counts ? counts.downvotes : d.downvotes || 0,
          user_profiles: null
        };
      });
    },
    [metricId, refreshKey]
  );
}

/**
 * Hook: useSubmitComment
 * Submits a comment or reply
 */
export function useSubmitComment() {
  const { mutate, loading, error } = useSupabaseMutation<DbDiscussion[]>();

  const submitComment = useCallback(
    async (metricId: number, comment: string, parentId: string | null = null) => {
      return mutate(async () => {
        const userData = await supabase.auth.getUser();
        if (!userData.data.user) throw new Error('User not authenticated');

        const { data, error } = await supabase
          .from('metric_discussions')
          .insert([
            {
              metric_id: metricId,
              user_id: userData.data.user.id,
              comment,
              parent_id: parentId,
            },
          ])
          .select();
        if (error) throw error;
        return data || [];
      });
    },
    [mutate]
  );

  return { submitComment, loading, error };
}

/**
 * Hook: useVoteOnComment
 * Upvote or downvote a comment
 */
export function useVoteOnComment() {
  const { mutate, loading, error } = useSupabaseMutation();

  const voteOnComment = useCallback(
    async (discussionId: string, voteType: 'upvote' | 'downvote') => {
      return mutate(async () => {
        const userData = await supabase.auth.getUser();
        if (!userData.data.user) throw new Error('User not authenticated');

        const { data, error } = await supabase.from('discussion_votes').upsert(
          {
            discussion_id: discussionId,
            user_id: userData.data.user.id,
            vote_type: voteType,
          },
          {
            onConflict: 'discussion_id,user_id',
          }
        );
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { voteOnComment, loading, error };
}

// ============================================================================
// 6. ADMIN REVIEW HOOKS
// ============================================================================

/**
 * Hook: useTargetSubmissions
 * Fetches target submissions (for admin review)
 */
export function useTargetSubmissions(status: string | null = null) {
  return useSupabaseQuery(async () => {
    let query = supabase
      .from('target_submissions')
      .select('*')
      .order('submitted_at', { ascending: false });

    if (status) {
      query = query.eq('status', status);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }, [status]);
}

/**
 * Hook: useApproveTargetSubmission
 * Approves a target submission (admin only)
 */
export function useApproveTargetSubmission() {
  const { mutate, loading, error } = useSupabaseMutation();

  const approveSubmission = useCallback(
    async (submissionId: string, targetId: string) => {
      return mutate(async () => {
        const { data, error } = await supabase.rpc(
          'approve_target_submission',
          {
            submission_id_param: submissionId,
            target_id_param: targetId,
          }
        );
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { approveSubmission, loading, error };
}

/**
 * Hook: useRejectSubmission
 * Rejects a target submission (admin only)
 */
export function useRejectSubmission() {
  const { mutate, loading, error } = useSupabaseMutation();

  const rejectSubmission = useCallback(
    async (submissionId: string, reviewNotes: string) => {
      return mutate(async () => {
        const userData = await supabase.auth.getUser();
        if (!userData.data.user) throw new Error('User not authenticated');

        const { data, error } = await supabase
          .from('target_submissions')
          .update({
            status: 'rejected',
            reviewed_by: userData.data.user.id,
            reviewed_at: new Date().toISOString(),
            review_notes: reviewNotes,
          })
          .eq('id', submissionId)
          .select();
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { rejectSubmission, loading, error };
}

/**
 * Hook: useRevokeTargetSubmission
 * Revokes an approved submission back to pending (admin only)
 */
export function useRevokeTargetSubmission() {
  const { mutate, loading, error } = useSupabaseMutation();

  const revokeSubmission = useCallback(
    async (submissionId: string, reviewNotes = "") => {
      return mutate(async () => {
        // Call the RPC function to handle full revocation (removing target + resetting submission)
        const { data, error } = await supabase.rpc('revoke_target_submission', {
          submission_id_param: submissionId,
          review_notes_param: reviewNotes || ""
        });

        if (error) {
          console.error("RPC revoke failed", error);
          throw error;
        }
        return data;
      });
    },
    [mutate]
  );

  return { revokeSubmission, loading, error };
}

// ============================================================================
// 7. USER PREFERENCES HOOKS
// ============================================================================

/**
 * Hook: useUserPreferences
 * Fetches user preferences
 */
export function useUserPreferences() {
  const { user } = useAuth();

  return useSupabaseQuery(
    async () => {
      if (!user) return null;

      const { data, error } = await supabase.rpc('get_user_preferences');
      if (error) throw error;
      return data;
    },
    [user?.id]
  );
}

/**
 * Hook: useUpdatePreferences
 * Updates user preferences
 */
export function useUpdatePreferences() {
  const { mutate, loading, error } = useSupabaseMutation();

  const updatePreferences = useCallback(
    async (preferences: Record<string, any>) => {
      return mutate(async () => {
        const { data, error } = await supabase.rpc('update_user_preferences', {
          p_preferences: preferences,
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { updatePreferences, loading, error };
}

// ============================================================================
// 8. ACTIVITY FEED HOOKS
// ============================================================================

/**
 * Hook: useUserActivityFeed
 * Fetches user's activity feed
 */
export function useUserActivityFeed(limit = 50, offset = 0) {
  return useSupabaseQuery(
    async () => {
      const { data, error } = await supabase.rpc('get_user_activity_feed', {
        p_limit: limit,
        p_offset: offset,
      });
      if (error) throw error;
      return data;
    },
    [limit, offset]
  );
}

/**
 * Hook: useSystemActivityFeed
 * Fetches system-wide activity feed
 */
export function useSystemActivityFeed(activityTypes: any = null, limit = 100) {
  return useSupabaseQuery(
    async () => {
      const { data, error } = await supabase.rpc('get_system_activity_feed', {
        p_limit: limit,
        p_offset: 0,
        p_activity_types: activityTypes,
      });
      if (error) throw error;
      return data;
    },
    [activityTypes, limit]
  );
}

// ============================================================================
// 9. GOVERNANCE VOTING HOOKS
// ============================================================================

/**
 * Hook: useGovernanceVote
 * Submits governance vote (Keep, Modify, Drop)
 */
export function useGovernanceVote() {
  const { mutate, loading, error } = useSupabaseMutation();

  const submitGovernanceVote = useCallback(
    async (targetId: string, metricId: number, actionVote: string | null, actionNotes = '') => {
      return mutate(async () => {
        const user = (await supabase.auth.getUser()).data.user;
        if (!user) throw new Error("User not authenticated");

        // 1. Check if a record exists for this user/target/metric
        const { data: existing, error: fetchError } = await supabase
          .from('user_scores')
          .select('score')
          .eq('user_id', user.id)
          .eq('target_id', targetId)
          .eq('metric_id', metricId)
          .maybeSingle();

        if (fetchError) throw fetchError;

        const timestamp = new Date().toISOString();

        if (existing) {
          // Update existing record (preserving score)
          const { data, error } = await supabase
            .from('user_scores')
            .update({
              action_vote: actionVote || null,
              action_notes: actionNotes,
              updated_at: timestamp
            })
            .eq('user_id', user.id)
            .eq('target_id', targetId)
            .eq('metric_id', metricId)
            .select();

          if (error) throw error;
          return data;
        } else {
          // Insert new record (defaulting score to 0)
          const { data, error } = await supabase
            .from('user_scores')
            .insert({
              user_id: user.id,
              target_id: targetId,
              metric_id: metricId,
              score: 0,
              score_type: 'slider', // Defaults for required fields
              action_vote: actionVote || null,
              action_notes: actionNotes,
              updated_at: timestamp
            })
            .select();

          if (error) {
            // Handle race condition: check for unique constraint violation (duplicate key)
            if (error.code === '23505') {
              // Record was created between check and insert time.
              // Fallback to update to preserve the score that was just inserted/existing.
              const { data: retryData, error: retryError } = await supabase
                .from('user_scores')
                .update({
                  action_vote: actionVote || null,
                  action_notes: actionNotes,
                  updated_at: timestamp
                })
                .eq('user_id', user.id)
                .eq('target_id', targetId)
                .eq('metric_id', metricId)
                .select();

              if (retryError) throw retryError;
              return retryData;
            }
            throw error;
          }
          return data;
        }
      });
    },
    [mutate]
  );

  return { submitGovernanceVote, loading, error };
}

/**
 * Hook: useGovernanceSummary
 * Gets governance vote summary for a target/metric
 */
export function useGovernanceSummary(targetId: string, metricId: number) {
  return useSupabaseQuery(
    async () => {
      const { data, error } = await supabase.rpc('get_governance_summary', {
        target_id_param: targetId,
        metric_id_param: metricId,
      });
      if (error) throw error;
      return data;
    },
    [targetId, metricId]
  );
}

// ============================================================================
// 10. ASSESSMENT NOTES HOOKS
// ============================================================================

/**
 * Hook: useSubmitAssessmentNote
 * Submits an assessment note
 */
export function useSubmitAssessmentNote() {
  const { mutate, loading, error } = useSupabaseMutation();

  const submitNote = useCallback(
    async (targetId: string, metricId: number, noteText: string, noteType = 'assessment', isPublic = true) => {
      return mutate(async () => {
        const { data, error } = await supabase.rpc('submit_assessment_note', {
          p_target_id: targetId,
          p_metric_id: metricId,
          p_note_text: noteText,
          p_note_type: noteType,
          p_is_public: isPublic,
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { submitNote, loading, error };
}

/**
 * Hook: useAssessmentNotes
 * Fetches assessment notes for a target
 */
export function useAssessmentNotes(targetId: string, metricId?: number | null) {
  return useSupabaseQuery(
    async () => {
      const { data, error } = await supabase.rpc('get_assessment_notes', {
        p_target_id: targetId,
        p_metric_id: metricId ?? undefined,
      });
      if (error) throw error;
      return data;
    },
    [targetId, metricId]
  );
}

// ============================================================================
// 11. SEARCH HOOKS
// ============================================================================

/**
 * Hook: useSaveSearch
 * Saves a search query
 */
export function useSaveSearch() {
  const { mutate, loading, error } = useSupabaseMutation();

  const saveSearch = useCallback(
    async (searchQuery: string, searchContext: string, savedName: string) => {
      return mutate(async () => {
        const { data, error } = await supabase.rpc('save_search', {
          p_search_query: searchQuery,
          p_search_context: searchContext,
          p_saved_name: savedName,
        });
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { saveSearch, loading, error };
}

/**
 * Hook: useSavedSearches
 * Fetches user's saved searches
 */
export function useSavedSearches() {
  return useSupabaseQuery(async () => {
    const { data, error } = await supabase.rpc('get_saved_searches');
    if (error) throw error;
    return data;
  });
}

/**
 * Hook: useUserSubmissions
 * Fetches all submissions (Targets, RFCs, Scores) for a user
 */
export function useUserSubmissions(userId: string | undefined) {
  return useSupabaseQuery(async () => {
    if (!userId) return { targets: [], rfcs: [], scoredTargets: [] };

    const [targetsRes, rfcsRes, votesRes] = await Promise.all([
      supabase.from('target_submissions').select('*').eq('submitted_by', userId).order('submitted_at', { ascending: false }),
      supabase.from('rfc_proposals').select('*').eq('user_id', userId).order('created_at', { ascending: false }),
      supabase.from('community_votes').select('target_id, created_at').eq('user_id', userId)
    ]);

    // Process votes to get unique targets
    const votedTargetsMap = new Map();
    (votesRes.data || []).forEach((vote: any) => {
      if (!votedTargetsMap.has(vote.target_id)) {
        votedTargetsMap.set(vote.target_id, {
          targetId: vote.target_id,
          lastVoted: vote.created_at
        });
      }
    });

    const uniqueTargetIds = Array.from(votedTargetsMap.keys());
    let targetDetails: any[] = [];
    if (uniqueTargetIds.length > 0) {
      const { data } = await supabase.from('targets').select('id, name, case_id').in('id', uniqueTargetIds);
      targetDetails = data || [];
    }

    const scoredTargets = targetDetails.map(t => ({
      ...t,
      lastVoted: votedTargetsMap.get(t.id)?.lastVoted
    }));

    return {
      targets: targetsRes.data || [],
      rfcs: rfcsRes.data || [],
      scoredTargets
    };
  }, [userId]);
}

/**
 * Hook: useUpdateTargetSubmission
 * Updates an existing target submission (e.g. for edits)
 */
export function useUpdateTargetSubmission() {
  const { mutate, loading, error } = useSupabaseMutation();

  const updateTarget = useCallback(
    async (id: string, updates: Partial<Inserts<'target_submissions'>>) => {
      return mutate(async () => {
        const { data, error } = await supabase
          .from('target_submissions')
          .update(updates)
          .eq('id', id)
          .select();
        if (error) throw error;
        return data;
      });
    },
    [mutate]
  );

  return { updateTarget, loading, error };
}
