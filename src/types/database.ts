/**
 * Database Type Utilities
 * Helper types derived from Supabase-generated schema
 * These provide shorthand access to table types
 */

import type { Database } from './supabase';

/**
 * Shorthand for table row types
 * Usage: Tables<'user_profiles'> instead of Database['public']['Tables']['user_profiles']['Row']
 */
export type Tables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Row'];

/**
 * Shorthand for insert types
 * Usage: Inserts<'user_profiles'> for new record payloads
 */
export type Inserts<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Insert'];

/**
 * Shorthand for update types
 * Usage: Updates<'user_profiles'> for partial update payloads
 */
export type Updates<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Update'];

/**
 * Shorthand for enum types
 */
export type Enums<T extends keyof Database['public']['Enums']> =
  Database['public']['Enums'][T];

// Database-derived types (automatically sync with schema)
export type DbTarget = Tables<'targets'>;
export type DbScore = Tables<'user_scores'>; // Mapped to user_scores table
export type DbMetric = Tables<'metrics'>;
export type DbUserProfile = Tables<'user_profiles'>;
export type DbVote = Tables<'community_votes'>;
export type DbActivityLog = Tables<'activity_log'>;
export type DbDiscussion = Tables<'metric_discussions'>;
export type DbComment = Tables<'metric_discussions'>;
export type DbRFC = Tables<'rfc_proposals'>;
export type DbRFCVote = Tables<'rfc_votes'>;
export type DbCase = Tables<'approved_targets'>;

// Insert types
export type ScoreInsert = Inserts<'community_votes'>;
export type TargetInsert = Inserts<'targets'>;
export type VoteInsert = Inserts<'community_votes'>;
export type CommentInsert = Inserts<'metric_discussions'>;

// Update types
export type ScoreUpdate = Updates<'community_votes'>;
export type TargetUpdate = Updates<'targets'>;
export type UserProfileUpdate = Updates<'user_profiles'>;
