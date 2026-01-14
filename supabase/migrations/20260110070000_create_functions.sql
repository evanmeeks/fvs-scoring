-- =====================================================================
-- SUPABASE FUNCTIONS FOR USER INPUT STORAGE
-- Migration: 20260110_07_create_functions.sql
-- =====================================================================
-- This migration creates all the Supabase RPC functions needed to
-- store and retrieve user control data throughout the application.
-- =====================================================================

-- =====================================================================
-- 1. COMMUNITY VOTING FUNCTIONS
-- =====================================================================

-- Submit or update a community vote
CREATE OR REPLACE FUNCTION public.upsert_community_vote(
  p_target_id TEXT,
  p_metric_id INTEGER,
  p_vote_value INTEGER,
  p_confidence_level TEXT,
  p_rationale TEXT DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  v_vote_id UUID;
  v_is_new BOOLEAN;
BEGIN
  -- Validate inputs
  IF p_vote_value NOT BETWEEN 1 AND 5 THEN
    RAISE EXCEPTION 'vote_value must be between 1 and 5';
  END IF;

  IF p_confidence_level NOT IN ('low', 'medium', 'high') THEN
    RAISE EXCEPTION 'confidence_level must be low, medium, or high';
  END IF;

  -- Upsert vote
  INSERT INTO public.community_votes (
    user_id, target_id, metric_id, vote_value, confidence_level, rationale
  ) VALUES (
    auth.uid(), p_target_id, p_metric_id, p_vote_value, p_confidence_level, p_rationale
  )
  ON CONFLICT (user_id, target_id, metric_id) DO UPDATE SET
    vote_value = EXCLUDED.vote_value,
    confidence_level = EXCLUDED.confidence_level,
    rationale = EXCLUDED.rationale,
    updated_at = NOW()
  RETURNING id, (xmax = 0) INTO v_vote_id, v_is_new;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, target_id, metric_id, description, metadata
  ) VALUES (
    auth.uid(),
    'vote',
    p_target_id,
    p_metric_id,
    CASE WHEN v_is_new THEN 'Submitted community vote' ELSE 'Updated community vote' END,
    jsonb_build_object(
      'vote_value', p_vote_value,
      'confidence_level', p_confidence_level,
      'is_new', v_is_new
    )
  );

  RETURN jsonb_build_object(
    'success', true,
    'vote_id', v_vote_id,
    'is_new', v_is_new,
    'message', CASE WHEN v_is_new THEN 'Vote submitted' ELSE 'Vote updated' END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.upsert_community_vote TO authenticated;
COMMENT ON FUNCTION public.upsert_community_vote IS 'Submit or update a community vote with confidence level';
-- Get user's votes for a specific target
CREATE OR REPLACE FUNCTION public.get_user_votes_for_target(
  p_target_id TEXT
)
RETURNS TABLE(
  metric_id INTEGER,
  metric_name TEXT,
  vote_value INTEGER,
  confidence_level TEXT,
  rationale TEXT,
  voted_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cv.metric_id,
    m.name as metric_name,
    cv.vote_value,
    cv.confidence_level,
    cv.rationale,
    cv.created_at as voted_at
  FROM public.community_votes cv
  JOIN public.metrics m ON m.id = cv.metric_id
  WHERE cv.user_id = auth.uid()
    AND cv.target_id = p_target_id
  ORDER BY cv.metric_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_user_votes_for_target TO authenticated;
COMMENT ON FUNCTION public.get_user_votes_for_target IS 'Get all votes by current user for a specific target';
-- =====================================================================
-- 2. RFC PROPOSAL FUNCTIONS
-- =====================================================================

-- Submit RFC proposal
CREATE OR REPLACE FUNCTION public.submit_rfc_proposal(
  p_metric_id INTEGER,
  p_proposal_type TEXT,
  p_proposed_name TEXT DEFAULT NULL,
  p_proposed_question TEXT DEFAULT NULL,
  p_proposed_min_criteria TEXT DEFAULT NULL,
  p_proposed_max_criteria TEXT DEFAULT NULL,
  p_proposed_category TEXT DEFAULT NULL,
  p_rich_entries TEXT DEFAULT NULL,
  p_rationale TEXT DEFAULT NULL
)
RETURNS jsonb AS $$
DECLARE
  v_rfc_id UUID;
BEGIN
  -- Validate proposal type
  IF p_proposal_type NOT IN ('modify_existing', 'new_metric') THEN
    RAISE EXCEPTION 'proposal_type must be modify_existing or new_metric';
  END IF;

  -- For modify_existing, metric_id is required
  IF p_proposal_type = 'modify_existing' AND p_metric_id IS NULL THEN
    RAISE EXCEPTION 'metric_id is required for modify_existing proposals';
  END IF;

  -- Rationale is required
  IF p_rationale IS NULL OR p_rationale = '' THEN
    RAISE EXCEPTION 'rationale is required';
  END IF;

  -- Insert RFC proposal
  INSERT INTO public.rfc_proposals (
    user_id, metric_id, proposal_type,
    proposed_name, proposed_question, proposed_min_criteria, proposed_max_criteria, proposed_category,
    rich_entries, rationale
  ) VALUES (
    auth.uid(), p_metric_id, p_proposal_type,
    p_proposed_name, p_proposed_question, p_proposed_min_criteria, p_proposed_max_criteria, p_proposed_category,
    p_rich_entries, p_rationale
  )
  RETURNING id INTO v_rfc_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, metric_id, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'rfc_submit', p_metric_id, v_rfc_id,
    'Submitted RFC proposal',
    jsonb_build_object('proposal_type', p_proposal_type, 'metric_id', p_metric_id)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', v_rfc_id,
    'message', 'RFC proposal submitted successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.submit_rfc_proposal TO authenticated;
COMMENT ON FUNCTION public.submit_rfc_proposal IS 'Submit an RFC proposal to modify or create a metric';
-- Review RFC proposal (Admin only)
CREATE OR REPLACE FUNCTION public.review_rfc_proposal(
  p_rfc_id UUID,
  p_status TEXT,
  p_review_notes TEXT DEFAULT NULL
)
RETURNS jsonb AS $$
BEGIN
  -- Check admin permission
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Admin access required';
  END IF;

  -- Validate status
  IF p_status NOT IN ('approved', 'rejected', 'under_review') THEN
    RAISE EXCEPTION 'status must be approved, rejected, or under_review';
  END IF;

  -- Update RFC status
  UPDATE public.rfc_proposals
  SET
    status = p_status,
    reviewed_by = auth.uid(),
    reviewed_at = NOW(),
    review_notes = p_review_notes,
    updated_at = NOW()
  WHERE id = p_rfc_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'RFC proposal not found';
  END IF;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'admin_action', p_rfc_id,
    'Reviewed RFC proposal',
    jsonb_build_object('rfc_id', p_rfc_id, 'new_status', p_status)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', p_rfc_id,
    'status', p_status,
    'message', 'RFC proposal reviewed successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.review_rfc_proposal TO authenticated;
COMMENT ON FUNCTION public.review_rfc_proposal IS 'Admin-only function to review and update RFC proposal status';
-- Implement approved RFC (Admin only)
CREATE OR REPLACE FUNCTION public.implement_rfc(
  p_rfc_id UUID
)
RETURNS jsonb AS $$
DECLARE
  v_rfc RECORD;
  v_new_metric_id INTEGER;
BEGIN
  -- Check admin permission
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Permission denied: Admin access required';
  END IF;

  -- Get RFC
  SELECT * INTO v_rfc
  FROM public.rfc_proposals
  WHERE id = p_rfc_id AND status = 'approved';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'RFC proposal not found or not approved';
  END IF;

  -- Handle new metric creation
  IF v_rfc.proposal_type = 'new_metric' THEN
    INSERT INTO public.metrics (name, category, question, criteria, community_score)
    VALUES (
      v_rfc.proposed_name,
      v_rfc.proposed_category,
      v_rfc.proposed_question,
      v_rfc.proposed_min_criteria || ' to ' || v_rfc.proposed_max_criteria,
      2.5 -- Default neutral score
    )
    RETURNING id INTO v_new_metric_id;

  -- Handle metric modification
  ELSIF v_rfc.proposal_type = 'modify_existing' THEN
    -- Update metric (only fields that were proposed)
    UPDATE public.metrics
    SET
      name = COALESCE(v_rfc.proposed_name, name),
      category = COALESCE(v_rfc.proposed_category, category),
      question = COALESCE(v_rfc.proposed_question, question),
      criteria = COALESCE(
        v_rfc.proposed_min_criteria || ' to ' || v_rfc.proposed_max_criteria,
        criteria
      ),
      updated_at = NOW()
    WHERE id = v_rfc.metric_id;
  END IF;

  -- Mark RFC as implemented
  UPDATE public.rfc_proposals
  SET status = 'implemented', updated_at = NOW()
  WHERE id = p_rfc_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, metric_id, rfc_id, description, metadata
  ) VALUES (
    auth.uid(), 'admin_action', COALESCE(v_new_metric_id, v_rfc.metric_id), p_rfc_id,
    'Implemented RFC proposal',
    jsonb_build_object('rfc_id', p_rfc_id, 'proposal_type', v_rfc.proposal_type)
  );

  RETURN jsonb_build_object(
    'success', true,
    'rfc_id', p_rfc_id,
    'new_metric_id', v_new_metric_id,
    'message', 'RFC implemented successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.implement_rfc TO authenticated;
COMMENT ON FUNCTION public.implement_rfc IS 'Admin-only function to implement an approved RFC proposal';
-- =====================================================================
-- 3. USER PREFERENCES FUNCTIONS
-- =====================================================================

-- Update user preferences
CREATE OR REPLACE FUNCTION public.update_user_preferences(
  p_preferences JSONB
)
RETURNS jsonb AS $$
DECLARE
  v_updated RECORD;
BEGIN
  -- Upsert preferences
  INSERT INTO public.user_preferences (user_id)
  VALUES (auth.uid())
  ON CONFLICT (user_id) DO UPDATE SET
    last_viewed_tab = COALESCE((p_preferences->>'last_viewed_tab')::TEXT, user_preferences.last_viewed_tab),
    sidebar_collapsed = COALESCE((p_preferences->>'sidebar_collapsed')::BOOLEAN, user_preferences.sidebar_collapsed),
    theme = COALESCE((p_preferences->>'theme')::TEXT, user_preferences.theme),
    saved_filters = COALESCE((p_preferences->'saved_filters')::JSONB, user_preferences.saved_filters),
    email_notifications = COALESCE((p_preferences->>'email_notifications')::BOOLEAN, user_preferences.email_notifications),
    discussion_notifications = COALESCE((p_preferences->>'discussion_notifications')::BOOLEAN, user_preferences.discussion_notifications),
    rfc_notifications = COALESCE((p_preferences->>'rfc_notifications')::BOOLEAN, user_preferences.rfc_notifications),
    items_per_page = COALESCE((p_preferences->>'items_per_page')::INTEGER, user_preferences.items_per_page),
    show_consensus_overlay = COALESCE((p_preferences->>'show_consensus_overlay')::BOOLEAN, user_preferences.show_consensus_overlay),
    updated_at = NOW()
  RETURNING * INTO v_updated;

  RETURN jsonb_build_object(
    'success', true,
    'preferences', row_to_json(v_updated),
    'message', 'Preferences updated successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.update_user_preferences TO authenticated;
COMMENT ON FUNCTION public.update_user_preferences IS 'Update user UI/UX preferences';
-- Get user preferences
CREATE OR REPLACE FUNCTION public.get_user_preferences()
RETURNS jsonb AS $$
DECLARE
  v_preferences RECORD;
BEGIN
  SELECT * INTO v_preferences
  FROM public.user_preferences
  WHERE user_id = auth.uid();

  IF NOT FOUND THEN
    -- Create default preferences
    INSERT INTO public.user_preferences (user_id)
    VALUES (auth.uid())
    RETURNING * INTO v_preferences;
  END IF;

  RETURN row_to_json(v_preferences);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_user_preferences TO authenticated;
COMMENT ON FUNCTION public.get_user_preferences IS 'Get current user preferences, creating defaults if needed';
-- =====================================================================
-- 4. ACTIVITY LOG FUNCTIONS
-- =====================================================================

-- Get user activity feed
CREATE OR REPLACE FUNCTION public.get_user_activity_feed(
  p_limit INTEGER DEFAULT 50,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE(
  id UUID,
  activity_type TEXT,
  description TEXT,
  target_name TEXT,
  metric_name TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    al.id,
    al.activity_type,
    al.description,
    t.name as target_name,
    m.name as metric_name,
    al.metadata,
    al.created_at
  FROM public.activity_log al
  LEFT JOIN public.targets t ON t.id = al.target_id
  LEFT JOIN public.metrics m ON m.id = al.metric_id
  WHERE al.user_id = auth.uid()
  ORDER BY al.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_user_activity_feed TO authenticated;
COMMENT ON FUNCTION public.get_user_activity_feed IS 'Get activity feed for current user';
-- Get system-wide activity feed
CREATE OR REPLACE FUNCTION public.get_system_activity_feed(
  p_limit INTEGER DEFAULT 100,
  p_offset INTEGER DEFAULT 0,
  p_activity_types TEXT[] DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  user_name TEXT,
  activity_type TEXT,
  description TEXT,
  target_name TEXT,
  metric_name TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    al.id,
    up.full_name as user_name,
    al.activity_type,
    al.description,
    t.name as target_name,
    m.name as metric_name,
    al.metadata,
    al.created_at
  FROM public.activity_log al
  LEFT JOIN public.user_profiles up ON up.user_id = al.user_id
  LEFT JOIN public.targets t ON t.id = al.target_id
  LEFT JOIN public.metrics m ON m.id = al.metric_id
  WHERE (p_activity_types IS NULL OR al.activity_type = ANY(p_activity_types))
  ORDER BY al.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_system_activity_feed TO authenticated, anon;
COMMENT ON FUNCTION public.get_system_activity_feed IS 'Get system-wide activity feed with optional filtering';
-- =====================================================================
-- 5. ASSESSMENT NOTES FUNCTIONS
-- =====================================================================

-- Submit assessment note
CREATE OR REPLACE FUNCTION public.submit_assessment_note(
  p_target_id TEXT,
  p_metric_id INTEGER,
  p_note_text TEXT,
  p_note_type TEXT DEFAULT 'assessment',
  p_is_public BOOLEAN DEFAULT true
)
RETURNS jsonb AS $$
DECLARE
  v_note_id UUID;
BEGIN
  -- Validate note_type
  IF p_note_type NOT IN ('assessment', 'verification', 'context', 'correction') THEN
    RAISE EXCEPTION 'note_type must be assessment, verification, context, or correction';
  END IF;

  -- Insert note
  INSERT INTO public.assessment_notes (
    user_id, target_id, metric_id, note_text, note_type, is_public
  ) VALUES (
    auth.uid(), p_target_id, p_metric_id, p_note_text, p_note_type, p_is_public
  )
  RETURNING id INTO v_note_id;

  -- Log activity
  INSERT INTO public.activity_log (
    user_id, activity_type, target_id, metric_id, description, metadata
  ) VALUES (
    auth.uid(), 'comment', p_target_id, p_metric_id,
    'Added assessment note',
    jsonb_build_object('note_type', p_note_type, 'note_id', v_note_id)
  );

  RETURN jsonb_build_object(
    'success', true,
    'note_id', v_note_id,
    'message', 'Assessment note submitted successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.submit_assessment_note TO authenticated;
COMMENT ON FUNCTION public.submit_assessment_note IS 'Submit an assessment note for a target metric';
-- Get assessment notes
CREATE OR REPLACE FUNCTION public.get_assessment_notes(
  p_target_id TEXT,
  p_metric_id INTEGER DEFAULT NULL
)
RETURNS TABLE(
  id UUID,
  user_name TEXT,
  note_text TEXT,
  note_type TEXT,
  is_public BOOLEAN,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    an.id,
    up.full_name as user_name,
    an.note_text,
    an.note_type,
    an.is_public,
    an.created_at
  FROM public.assessment_notes an
  JOIN public.user_profiles up ON up.user_id = an.user_id
  WHERE an.target_id = p_target_id
    AND (p_metric_id IS NULL OR an.metric_id = p_metric_id)
    AND (an.is_public = true OR an.user_id = auth.uid())
  ORDER BY an.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_assessment_notes TO authenticated;
COMMENT ON FUNCTION public.get_assessment_notes IS 'Get assessment notes for a target, optionally filtered by metric';
-- =====================================================================
-- 6. SEARCH FUNCTIONS
-- =====================================================================

-- Save a search
CREATE OR REPLACE FUNCTION public.save_search(
  p_search_query TEXT,
  p_search_context TEXT,
  p_saved_name TEXT
)
RETURNS jsonb AS $$
DECLARE
  v_search_id UUID;
BEGIN
  -- Upsert saved search
  INSERT INTO public.search_history (
    user_id, search_query, search_context, is_saved, saved_name
  ) VALUES (
    auth.uid(), p_search_query, p_search_context, true, p_saved_name
  )
  RETURNING id INTO v_search_id;

  RETURN jsonb_build_object(
    'success', true,
    'search_id', v_search_id,
    'message', 'Search saved successfully'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.save_search TO authenticated;
COMMENT ON FUNCTION public.save_search IS 'Save a search for quick access';
-- Get saved searches
CREATE OR REPLACE FUNCTION public.get_saved_searches()
RETURNS TABLE(
  id UUID,
  search_query TEXT,
  search_context TEXT,
  saved_name TEXT,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    sh.id,
    sh.search_query,
    sh.search_context,
    sh.saved_name,
    sh.created_at
  FROM public.search_history sh
  WHERE sh.user_id = auth.uid()
    AND sh.is_saved = true
  ORDER BY sh.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.get_saved_searches TO authenticated;
COMMENT ON FUNCTION public.get_saved_searches IS 'Get all saved searches for current user';
-- =====================================================================
-- 7. SESSION TRACKING FUNCTIONS
-- =====================================================================

-- Track session activity
CREATE OR REPLACE FUNCTION public.track_session_activity(
  p_session_id TEXT,
  p_page_view BOOLEAN DEFAULT false
)
RETURNS jsonb AS $$
BEGIN
  -- Update or insert session
  INSERT INTO public.user_sessions (
    user_id, session_id, page_views, actions_count
  ) VALUES (
    auth.uid(), p_session_id, CASE WHEN p_page_view THEN 1 ELSE 0 END, 1
  )
  ON CONFLICT (session_id) DO UPDATE SET
    last_activity_at = NOW(),
    page_views = user_sessions.page_views + CASE WHEN p_page_view THEN 1 ELSE 0 END,
    actions_count = user_sessions.actions_count + 1;

  RETURN jsonb_build_object(
    'success', true,
    'message', 'Session activity tracked'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION public.track_session_activity TO authenticated;
COMMENT ON FUNCTION public.track_session_activity IS 'Track user session activity and page views';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ All Supabase functions created successfully!';
  RAISE NOTICE 'Function categories:';
  RAISE NOTICE '  - Community Voting (2 functions)';
  RAISE NOTICE '  - RFC Proposals (3 functions)';
  RAISE NOTICE '  - User Preferences (2 functions)';
  RAISE NOTICE '  - Activity Log (2 functions)';
  RAISE NOTICE '  - Assessment Notes (2 functions)';
  RAISE NOTICE '  - Search (2 functions)';
  RAISE NOTICE '  - Session Tracking (1 function)';
  RAISE NOTICE 'Total: 14 new functions';
END $$;
