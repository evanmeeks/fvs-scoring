import { supabase } from './supabase';

type ScoreMap = Record<number, number>;
type ScoreRow = { metric_id: number | null; score: number | null };

/**
 * Load user scores for a specific target
 * @param {string} userId - The authenticated user's ID
 * @param {string} targetId - The target ID
 * @returns {Object} Score object keyed by metric ID
 */
export async function loadUserScores(userId: string | null | undefined, targetId: string): Promise<ScoreMap> {
    if (!userId) {
        // Return empty scores if not authenticated
        return {};
    }

    const { data, error } = await supabase
        .from('user_scores')
        .select('metric_id, score, notes')
        .eq('user_id', userId)
        .eq('target_id', targetId);

    if (error) {
        console.error('Error loading scores:', error);
        return {};
    }

    // Convert array to object keyed by metric_id
    return (data as ScoreRow[] | null)?.reduce<ScoreMap>((acc, item) => {
        if (item.metric_id == null || item.score == null) {
            return acc;
        }
        acc[item.metric_id] = item.score;
        return acc;
    }, {}) ?? {};
}

/**
 * Save or update a user's score for a metric on a target
 * @param {string} userId - The authenticated user's ID
 * @param {string} targetId - The target ID
 * @param {number} metricId - The metric ID
 * @param {number} score - The score value (0-5)
 * @param {string} notes - Optional notes
 */
export async function saveUserScore(
    userId: string,
    targetId: string,
    metricId: number,
    score: number,
    notes: string | null = null
) {
    if (!userId) {
        throw new Error('User must be authenticated to save scores');
    }

    const { data, error } = await supabase
        .from('user_scores')
        .upsert(
            {
                user_id: userId,
                target_id: targetId,
                metric_id: metricId,
                score,
                notes
            },
            {
                onConflict: 'user_id,target_id,metric_id'
            }
        )
        .select();

    if (error) {
        console.error('Error saving score:', error);
        throw error;
    }

    return data;
}

/**
 * Save multiple scores at once (bulk operation)
 * @param {string} userId - The authenticated user's ID
 * @param {string} targetId - The target ID
 * @param {Object} scores - Object keyed by metric ID with score values
 */
export async function saveAllUserScores(userId: string, targetId: string, scores: Record<string, number>) {
    if (!userId) {
        throw new Error('User must be authenticated to save scores');
    }

    // Convert scores object to array of records
    const scoreRecords = Object.entries(scores)
        .filter(([, score]) => score > 0) // Only save non-zero scores
        .map(([metricId, score]) => ({
            user_id: userId,
            target_id: targetId,
            metric_id: parseInt(metricId, 10),
            score
        }));

    if (scoreRecords.length === 0) {
        return [];
    }

    const { data, error } = await supabase
        .from('user_scores')
        .upsert(scoreRecords, {
            onConflict: 'user_id,target_id,metric_id'
        })
        .select();

    if (error) {
        console.error('Error saving scores:', error);
        throw error;
    }

    return data;
}

/**
 * Load all available targets
 */
export async function loadTargets() {
    const { data, error } = await supabase
        .from('targets')
        .select('*')
        .order('created_at', { ascending: true });

    if (error) {
        console.error('Error loading targets:', error);
        return [];
    }

    return data;
}

/**
 * Submit an RFC or contribution
 */
export async function submitContribution(
    userId: string,
    metricId: number,
    submissionType: string,
    title: string,
    content: string
) {
    if (!userId) {
        throw new Error('User must be authenticated to submit contributions');
    }

    const { data, error } = await supabase
        .from('submissions')
        .insert({
            user_id: userId,
            metric_id: metricId,
            submission_type: submissionType,
            title,
            content,
            status: 'pending'
        })
        .select();

    if (error) {
        console.error('Error submitting contribution:', error);
        throw error;
    }

    return data;
}

/**
 * Get aggregated scores for a target across all users
 */
export async function getTargetAggregates(targetId: string) {
    const { data, error } = await supabase
        .from('target_score_aggregates')
        .select('*')
        .eq('target_id', targetId);

    if (error) {
        console.error('Error loading aggregates:', error);
        return [];
    }

    return data;
}
