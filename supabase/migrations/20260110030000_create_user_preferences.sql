-- =====================================================================
-- USER PREFERENCES TABLE
-- Migration: 20260110_03_create_user_preferences.sql
-- =====================================================================
-- This migration creates a table to store user UI/UX preferences,
-- including view state, theme, filters, and notification settings.
-- =====================================================================

-- Create user_preferences table
CREATE TABLE IF NOT EXISTS public.user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,

  -- UI Preferences
  last_viewed_tab TEXT CHECK (last_viewed_tab IN ('standards', 'scoring', 'voting', 'activity')),
  sidebar_collapsed BOOLEAN DEFAULT false,
  theme TEXT DEFAULT 'dark' CHECK (theme IN ('light', 'dark', 'auto')),

  -- Filter Preferences (JSONB for flexibility)
  saved_filters JSONB DEFAULT '{}'::jsonb,
  -- Example structure:
  -- {
  --   "standardsReview": {"category": "CORE", "search": ""},
  --   "targetFilter": "grusch-2024"
  -- }

  -- Notification Preferences
  email_notifications BOOLEAN DEFAULT true,
  discussion_notifications BOOLEAN DEFAULT true,
  rfc_notifications BOOLEAN DEFAULT true,

  -- Display Preferences
  items_per_page INTEGER DEFAULT 20 CHECK (items_per_page BETWEEN 10 AND 100),
  show_consensus_overlay BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);
-- Create index
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);
-- Enable Row Level Security
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
-- RLS Policies
-- Users can view their own preferences
CREATE POLICY "Users can view their own preferences"
  ON public.user_preferences
  FOR SELECT
  USING (auth.uid() = user_id);
-- Users can insert their own preferences
CREATE POLICY "Users can insert their own preferences"
  ON public.user_preferences
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
-- Users can update their own preferences
CREATE POLICY "Users can update their own preferences"
  ON public.user_preferences
  FOR UPDATE
  USING (auth.uid() = user_id);
-- Users can delete their own preferences
CREATE POLICY "Users can delete their own preferences"
  ON public.user_preferences
  FOR DELETE
  USING (auth.uid() = user_id);
-- Create updated_at trigger
CREATE TRIGGER set_user_preferences_updated_at
  BEFORE UPDATE ON public.user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
-- Create function to auto-create preferences when user profile is created
CREATE OR REPLACE FUNCTION public.create_user_preferences()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_preferences (user_id)
  VALUES (NEW.user_id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- Attach trigger to user_profiles table
CREATE TRIGGER on_user_profile_created_preferences
  AFTER INSERT ON public.user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.create_user_preferences();
-- Comments
COMMENT ON TABLE public.user_preferences IS 'User UI/UX preferences and settings';
COMMENT ON COLUMN public.user_preferences.saved_filters IS 'JSONB object containing saved filter states';
COMMENT ON COLUMN public.user_preferences.theme IS 'UI theme: light, dark, or auto (system)';
COMMENT ON COLUMN public.user_preferences.items_per_page IS 'Number of items to display per page (10-100)';
-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ User preferences table created successfully!';
  RAISE NOTICE 'New table: public.user_preferences';
  RAISE NOTICE 'Features: UI state, theme, filters, notifications, display settings';
  RAISE NOTICE 'Auto-creation: Preferences created automatically when user profile is created';
END $$;
