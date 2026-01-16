-- Recreate origin_types and context_types tables that were dropped by remote_schema
-- SKIPPED: This migration appears to conflict with 20260115000000_update_origin_reference.sql which already 
-- establishes these tables authoritative. To avoid unique constraint violations on abbreviations (e.g. DOD),
-- we rely on the implementation in 20260115.

-- NO-OP
SELECT 1;
