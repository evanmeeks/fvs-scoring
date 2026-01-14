-- =====================================================================
-- SUPPORTING TABLES
-- Migration: 20260110_05_create_supporting_tables.sql
-- =====================================================================
-- This migration creates supporting tables for:
-- 1. Assessment notes (detailed metric assessments)
-- 2. Metric versions (change tracking)
-- 3. User sessions (enhanced session analytics)
-- 4. Search history (search tracking and saved searches)
-- 5. Target tags (tagging system)
-- =====================================================================

-- =====================================================================
-- 1. ASSESSMENT NOTES TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.assessment_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  target_id TEXT REFERENCES public.targets(id) ON DELETE CASCADE NOT NULL,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE NOT NULL,

  -- Note content
  note_text TEXT NOT NULL,

  -- Note metadata
  note_type TEXT DEFAULT 'assessment' CHECK (note_type IN ('assessment', 'verification', 'context', 'correction')),

  -- Visibility
  is_public BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX idx_assessment_notes_user_id ON public.assessment_notes(user_id);
CREATE INDEX idx_assessment_notes_target_id ON public.assessment_notes(target_id);
CREATE INDEX idx_assessment_notes_metric_id ON public.assessment_notes(metric_id);
CREATE INDEX idx_assessment_notes_created_at ON public.assessment_notes(created_at DESC);
ALTER TABLE public.assessment_notes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view public assessment notes"
  ON public.assessment_notes
  FOR SELECT
  USING (is_public = true OR auth.uid() = user_id);
CREATE POLICY "Users can insert their own notes"
  ON public.assessment_notes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own notes"
  ON public.assessment_notes
  FOR UPDATE
  USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notes"
  ON public.assessment_notes
  FOR DELETE
  USING (auth.uid() = user_id);
CREATE TRIGGER set_assessment_notes_updated_at
  BEFORE UPDATE ON public.assessment_notes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
COMMENT ON TABLE public.assessment_notes IS 'Detailed assessment notes for target metrics';
COMMENT ON COLUMN public.assessment_notes.note_type IS 'Type: assessment, verification, context, or correction';
-- =====================================================================
-- 2. METRIC VERSIONS TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.metric_versions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  metric_id INTEGER REFERENCES public.metrics(id) ON DELETE CASCADE NOT NULL,

  -- Version information
  version_number INTEGER NOT NULL,

  -- Snapshot of metric at this version
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  question TEXT NOT NULL,
  criteria TEXT NOT NULL,
  min_val INTEGER,
  max_val INTEGER,

  -- Change metadata
  changed_by UUID REFERENCES auth.users(id),
  change_reason TEXT,
  rfc_id UUID REFERENCES public.rfc_proposals(id),

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  UNIQUE(metric_id, version_number)
);
CREATE INDEX idx_metric_versions_metric_id ON public.metric_versions(metric_id);
CREATE INDEX idx_metric_versions_created_at ON public.metric_versions(created_at DESC);
CREATE INDEX idx_metric_versions_changed_by ON public.metric_versions(changed_by) WHERE changed_by IS NOT NULL;
CREATE INDEX idx_metric_versions_rfc_id ON public.metric_versions(rfc_id) WHERE rfc_id IS NOT NULL;
ALTER TABLE public.metric_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view metric versions"
  ON public.metric_versions
  FOR SELECT
  USING (true);
CREATE POLICY "System can insert metric versions"
  ON public.metric_versions
  FOR INSERT
  WITH CHECK (true);
COMMENT ON TABLE public.metric_versions IS 'Version history for metric definition changes';
COMMENT ON COLUMN public.metric_versions.version_number IS 'Sequential version number per metric';
-- =====================================================================
-- 3. USER SESSIONS TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.user_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Session identification
  session_id TEXT NOT NULL,

  -- Session metadata
  ip_address INET,
  user_agent TEXT,
  device_type TEXT CHECK (device_type IN ('mobile', 'tablet', 'desktop', 'unknown')),

  -- Activity tracking
  started_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  last_activity_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  ended_at TIMESTAMPTZ,

  -- Session statistics
  page_views INTEGER DEFAULT 0,
  actions_count INTEGER DEFAULT 0,

  UNIQUE(session_id)
);
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX idx_user_sessions_started_at ON public.user_sessions(started_at DESC);
CREATE INDEX idx_user_sessions_session_id ON public.user_sessions(session_id);
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own sessions"
  ON public.user_sessions
  FOR SELECT
  USING (auth.uid() = user_id);
CREATE POLICY "System can manage sessions"
  ON public.user_sessions
  FOR ALL
  USING (true);
COMMENT ON TABLE public.user_sessions IS 'Enhanced session tracking and analytics';
COMMENT ON COLUMN public.user_sessions.session_id IS 'Unique session identifier';
-- =====================================================================
-- 4. SEARCH HISTORY TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.search_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,

  -- Search details
  search_query TEXT NOT NULL,
  search_context TEXT CHECK (search_context IN ('metrics', 'targets', 'discussions', 'global')),

  -- Results metadata
  results_count INTEGER,

  -- Search preferences
  is_saved BOOLEAN DEFAULT false,
  saved_name TEXT,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
CREATE INDEX idx_search_history_user_id ON public.search_history(user_id);
CREATE INDEX idx_search_history_created_at ON public.search_history(created_at DESC);
CREATE INDEX idx_search_history_is_saved ON public.search_history(is_saved) WHERE is_saved = true;
ALTER TABLE public.search_history ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own search history"
  ON public.search_history
  FOR SELECT
  USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own searches"
  ON public.search_history
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own saved searches"
  ON public.search_history
  FOR UPDATE
  USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their own searches"
  ON public.search_history
  FOR DELETE
  USING (auth.uid() = user_id);
COMMENT ON TABLE public.search_history IS 'User search history and saved searches';
COMMENT ON COLUMN public.search_history.is_saved IS 'Whether this search is saved for quick access';
-- =====================================================================
-- 5. TARGET TAGS TABLE
-- =====================================================================

CREATE TABLE IF NOT EXISTS public.target_tags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  target_id TEXT REFERENCES public.targets(id) ON DELETE CASCADE NOT NULL,
  tag_name TEXT NOT NULL,

  -- Tag metadata
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

  UNIQUE(target_id, tag_name)
);
CREATE INDEX idx_target_tags_target_id ON public.target_tags(target_id);
CREATE INDEX idx_target_tags_tag_name ON public.target_tags(tag_name);
CREATE INDEX idx_target_tags_created_by ON public.target_tags(created_by) WHERE created_by IS NOT NULL;
ALTER TABLE public.target_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view target tags"
  ON public.target_tags
  FOR SELECT
  USING (true);
CREATE POLICY "Authenticated users can create tags"
  ON public.target_tags
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Admins can delete tags"
  ON public.target_tags
  FOR DELETE
  USING (public.is_admin());
COMMENT ON TABLE public.target_tags IS 'Tagging system for forecast targets';
COMMENT ON COLUMN public.target_tags.tag_name IS 'Tag name (case-sensitive)';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Supporting tables created successfully!';
  RAISE NOTICE 'New tables:';
  RAISE NOTICE '  - public.assessment_notes';
  RAISE NOTICE '  - public.metric_versions';
  RAISE NOTICE '  - public.user_sessions';
  RAISE NOTICE '  - public.search_history';
  RAISE NOTICE '  - public.target_tags';
END $$;
