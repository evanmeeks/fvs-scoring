-- Promote Evan Meeks (new account) to contributor directly
-- This bypasses the RPC logic to ensure it works during migration execution
UPDATE public.user_profiles
SET role = 'contributor'
WHERE user_id = 'acca822b-738c-4b7d-bc2f-fed01478a864';
