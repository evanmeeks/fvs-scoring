/**
 * FVS Scoring System - TypeScript Type Definitions
 * All core interfaces and types for the application
 */

export type MetricCategory = 'CORE' | 'INTEGRITY' | 'IMPACT';

export type ScoreValue = 1 | 2 | 3 | 4 | 5;

export type ActivityType = 'score' | 'vote' | 'comment' | 'edit' | 'verification' | 'system' | 'alert' | 'default';

export type TargetStatus = 'pending' | 'in_review' | 'completed';

export type ConfidenceLevel = 'low' | 'medium' | 'high';

export type UserRole = 'viewer' | 'contributor' | 'admin';

export type AuthStatus = 'unauthenticated' | 'authenticating' | 'authenticated' | 'unauthorized';

/**
 * Scoring criteria for a specific score value (1-5)
 */
export interface ScoringCriterion {
    score: ScoreValue;
    label: string;
    description: string;
}

/**
 * Core metric definition
 */
export interface Metric {
    id: string;
    category: MetricCategory;
    name: string;
    coreQuestion: string;
    description: string;
    scoringCriteria: ScoringCriterion[];
    weight: number; // For weighted scoring calculations
    communityScore?: number; // Optional community consensus score
}

/**
 * Target/case being scored
 */
export interface Target {
    id: string;
    name: string;
    description: string;
    category: string;
    status: TargetStatus;
    createdAt: string;
    completeness: number; // Percentage 0-100
}

/**
 * Individual user score for a metric
 */
export interface Score {
    id: string;
    targetId: string;
    metricId: string;
    userId: string; // User ID or anonymous session ID
    score: ScoreValue;
    timestamp: string;
    comment?: string;
    sessionId: string;
}

/**
 * Community vote for a metric
 */
export interface Vote {
    id: string;
    targetId: string;
    metricId: string;
    userId: string; // User ID or anonymous session ID
    vote: ScoreValue;
    timestamp: string;
    confidence: ConfidenceLevel;
    rationale?: string;
}

/**
 * Vote distribution for a specific score
 */
export interface VoteDistribution {
    1: number;
    2: number;
    3: number;
    4: number;
    5: number;
}

/**
 * Aggregated community consensus for a metric
 */
export interface CommunityConsensus {
    targetId: string;
    metricId: string;
    mean: number;
    median: number;
    mode: number;
    totalVotes: number;
    distribution: VoteDistribution;
    lastUpdated: string;
}

/**
 * Activity feed item
 */
export interface ActivityItem {
    id?: string;
    userId: string;
    userName: string;
    action: string;
    targetId?: string;
    metricId?: string;
    timestamp?: string;
    time?: string; // Alternative to timestamp for display
    type?: ActivityType;
    metadata?: Record<string, unknown>;
}

/**
 * User session
 */
export interface UserSession {
    sessionId: string;
    firstSeen: string;
    lastSeen: string;
    contributionCount: number;
}

/**
 * Authenticated user
 */
export interface AuthenticatedUser {
    email: string;
    name?: string;
    role: UserRole;
    approvedAt?: string;
    sessionId?: string;
}

/**
 * Login request payload
 */
export interface LoginRequest {
    email: string;
    accessCode: string;
}

/**
 * Login response
 */
export interface LoginResponse {
    success: boolean;
    user?: AuthenticatedUser;
    message?: string;
}

/**
 * API Response wrapper
 */
export interface ApiResponse<T> {
    status: number;
    data: T;
    message?: string;
    error?: string;
}

/**
 * Score submission payload
 */
export interface ScoreSubmission {
    targetId: string;
    metricId: string;
    userId: string;
    userName?: string;
    score: ScoreValue;
    comment?: string;
    sessionId?: string;
}

/**
 * Vote submission payload
 */
export interface VoteSubmission {
    targetId: string;
    metricId: string;
    userId: string;
    userName?: string;
    vote: ScoreValue;
    confidence?: ConfidenceLevel;
    rationale?: string;
    sessionId?: string;
}

/**
 * Activity log payload
 */
export interface ActivityLogPayload {
    userId: string;
    userName: string;
    action: string;
    targetId?: string;
    metricId?: string;
    type: ActivityType;
    metadata?: Record<string, unknown>;
}

/**
 * Supabase User type (simplified)
 */
export interface User {
    id: string;
    email?: string;
    user_metadata?: {
        name?: string;
        avatar_url?: string;
    };
}
