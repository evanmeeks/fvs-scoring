-- =====================================================================
-- Add expanded context types for comprehensive disclosure taxonomy
-- Migration: 20260119220000_add_expanded_context_types.sql
-- =====================================================================

DO $$
BEGIN
    -- Only proceed if context_types table exists
    IF EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'context_types'
    ) THEN
        INSERT INTO public.context_types (slug, label, description, sort_order, is_active)
        VALUES
            -- Academic/Research contexts (already exists: academic_symposium, scientific_paper)
            ('academic_thesis', 'Academic Thesis', 'Graduate-level research or dissertations on related topics', 25, true),
            ('research_grant_proposal', 'Research Grant Proposal', 'Funding requests outlining studies on phenomena', 27, true),

            -- Witness/Testimony contexts (already exists: witness_testimony, whistleblower_account, legal_deposition)
            ('eyewitness_sketch', 'Eyewitness Sketch', 'Drawings or descriptions from direct observers', 205, true),

            -- Social Media/Viral contexts (already exists: social_media, viral_narrative)
            ('social_media_post', 'Social Media Post', 'Individual or threaded posts amplifying claims', 275, true),
            ('forum_discussion', 'Forum Discussion', 'Online community threads (e.g., Reddit or specialized sites)', 285, true),

            -- Anonymous/Leaked contexts (already exists: fourchan_leak, anon_hack_and_release)
            ('leaked_media', 'Leaked Media', 'Hacked or anonymously released files (focus on analysis, not acquisition)', 295, true),
            ('hacked_and_leaked', 'Hacked and Leaked', 'Hacked or anonymously released files (focus on analysis, not acquisition)', 297, true),
            ('anonymous_forum_leak', 'Anonymous Forum Leak', 'Anonymous postings on imageboards involving unverified insider claims about UAPs or NHI', 282, true)

        ON CONFLICT (slug) DO UPDATE
        SET
            label = EXCLUDED.label,
            description = EXCLUDED.description,
            sort_order = EXCLUDED.sort_order,
            is_active = EXCLUDED.is_active,
            updated_at = NOW();

        -- Update sort orders to maintain proper grouping
        -- Existing contexts remain unchanged, new ones slot into appropriate positions
        EXECUTE 'COMMENT ON TABLE public.context_types IS ''Authoritative list of disclosure contexts - expanded taxonomy for UAP/NHI research''';
        
        RAISE NOTICE '✅ Expanded context types added successfully';
    ELSE
        RAISE NOTICE '⚠️  Skipping context types expansion - table does not exist yet';
    END IF;
END $$;
