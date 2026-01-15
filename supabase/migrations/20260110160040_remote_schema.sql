drop extension if exists "pg_net";
create schema if not exists "api";
create sequence "public"."protocol_config_id_seq";
alter table "public"."user_score_history" drop constraint "fk_user_score";
create table "public"."protocol_config" (
    "id" integer not null default nextval('public.protocol_config_id_seq'::regclass),
    "config_key" text not null,
    "config_value" text not null,
    "description" text,
    "updated_at" timestamp with time zone default now(),
    "updated_by" uuid
      );
alter table "public"."protocol_config" enable row level security;
alter table "public"."metrics" alter column "community_score" set not null;
alter table "public"."metrics" enable row level security;
alter sequence "public"."protocol_config_id_seq" owned by "public"."protocol_config"."id";
CREATE UNIQUE INDEX protocol_config_config_key_key ON public.protocol_config USING btree (config_key);
CREATE UNIQUE INDEX protocol_config_pkey ON public.protocol_config USING btree (id);
alter table "public"."protocol_config" add constraint "protocol_config_pkey" PRIMARY KEY using index "protocol_config_pkey";
alter table "public"."protocol_config" add constraint "protocol_config_config_key_key" UNIQUE using index "protocol_config_config_key_key";
alter table "public"."protocol_config" add constraint "protocol_config_updated_by_fkey" FOREIGN KEY (updated_by) REFERENCES auth.users(id) not valid;
alter table "public"."protocol_config" validate constraint "protocol_config_updated_by_fkey";
set check_function_bodies = off;
CREATE OR REPLACE FUNCTION public.update_protocol_version(new_version text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    -- Validate format (must be 3 digits)
    IF new_version !~ '^\d{3}$' THEN
        RAISE EXCEPTION 'Protocol version must be exactly 3 digits (e.g., 001, 002, 003)';
    END IF;

    -- Update protocol version
    UPDATE protocol_config
    SET
        config_value = new_version,
        updated_at = NOW(),
        updated_by = auth.uid()
    WHERE config_key = 'protocol_version';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Protocol version configuration not found';
    END IF;
END;
$function$;
CREATE OR REPLACE FUNCTION public.approve_target_submission(submission_id_param uuid, target_id_param text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    submission_record RECORD;
BEGIN
    SELECT * INTO submission_record
    FROM target_submissions
    WHERE id = submission_id_param;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Submission not found';
    END IF;

    INSERT INTO approved_targets (
        id, name, case_id, origin, context, description,
        source_url, claim_date, primary_source, verified, submission_id
    ) VALUES (
        target_id_param, submission_record.target_name, submission_record.case_id,
        submission_record.origin, submission_record.context, submission_record.description,
        submission_record.source_url, submission_record.claim_date,
        submission_record.primary_source, true, submission_id_param
    );

    UPDATE target_submissions
    SET status = 'approved', reviewed_by = auth.uid(), reviewed_at = NOW()
    WHERE id = submission_id_param;
END;
$function$;
CREATE OR REPLACE FUNCTION public.auto_generate_case_id()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NEW.case_id IS NULL OR NEW.case_id = '' THEN
        NEW.case_id := generate_case_id(NEW.origin, NEW.context);
    END IF;
    RETURN NEW;
END;
$function$;
CREATE OR REPLACE FUNCTION public.generate_case_id(origin_param text, context_param text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    origin_abbr TEXT;
    protocol_number TEXT;
    ref_number TEXT;
    case_id TEXT;
BEGIN
    -- Get current protocol version from config
    SELECT config_value INTO protocol_number
    FROM protocol_config
    WHERE config_key = 'protocol_version';

    -- Fallback to '001' if not found
    IF protocol_number IS NULL THEN
        protocol_number := '001';
    END IF;

    -- Map origin to abbreviation
    origin_abbr := CASE origin_param
        WHEN 'IC/NGA' THEN 'IC'
        WHEN 'DoD/DIA' THEN 'DOD'
        WHEN 'USN' THEN 'USN'
        WHEN 'USAF' THEN 'USAF'
        WHEN 'NASA' THEN 'NASA'
        WHEN 'Congressional' THEN 'CONG'
        WHEN 'Private Sector' THEN 'PRIV'
        WHEN 'Academic' THEN 'ACAD'
        WHEN 'Other' THEN 'OTH'
        ELSE 'UNK'
    END;

    -- Get next reference number (zero-padded to 4 digits)
    ref_number := LPAD(nextval('case_id_ref_seq')::TEXT, 4, '0');

    -- Construct case ID: FVS-PROTOCOL#-ORIGIN-REF
    case_id := 'FVS-' || protocol_number || '-' || origin_abbr || '-' || ref_number;

    RETURN case_id;
END;
$function$;
CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    INSERT INTO public.user_profiles (user_id, role, full_name)
    VALUES (NEW.id, 'user', COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)));
    RETURN NEW;
END;
$function$;
grant delete on table "public"."protocol_config" to "anon";
grant insert on table "public"."protocol_config" to "anon";
grant references on table "public"."protocol_config" to "anon";
grant select on table "public"."protocol_config" to "anon";
grant trigger on table "public"."protocol_config" to "anon";
grant truncate on table "public"."protocol_config" to "anon";
grant update on table "public"."protocol_config" to "anon";
grant delete on table "public"."protocol_config" to "authenticated";
grant insert on table "public"."protocol_config" to "authenticated";
grant references on table "public"."protocol_config" to "authenticated";
grant select on table "public"."protocol_config" to "authenticated";
grant trigger on table "public"."protocol_config" to "authenticated";
grant truncate on table "public"."protocol_config" to "authenticated";
grant update on table "public"."protocol_config" to "authenticated";
grant delete on table "public"."protocol_config" to "service_role";
grant insert on table "public"."protocol_config" to "service_role";
grant references on table "public"."protocol_config" to "service_role";
grant select on table "public"."protocol_config" to "service_role";
grant trigger on table "public"."protocol_config" to "service_role";
grant truncate on table "public"."protocol_config" to "service_role";
grant update on table "public"."protocol_config" to "service_role";
create policy "Enable delete for authenticated users only"
  on "public"."metrics"
  as permissive
  for delete
  to public
using ((auth.role() = 'authenticated'::text));
create policy "Enable insert for authenticated users only"
  on "public"."metrics"
  as permissive
  for insert
  to public
with check ((auth.role() = 'authenticated'::text));
create policy "Enable read access for all users"
  on "public"."metrics"
  as permissive
  for select
  to public
using (true);
create policy "Enable update for authenticated users only"
  on "public"."metrics"
  as permissive
  for update
  to public
using ((auth.role() = 'authenticated'::text));
create policy "Admins can update protocol config"
  on "public"."protocol_config"
  as permissive
  for update
  to public
using (((((auth.jwt() ->> 'raw_user_meta_data'::text))::jsonb ->> 'role'::text) = 'admin'::text))
with check (((((auth.jwt() ->> 'raw_user_meta_data'::text))::jsonb ->> 'role'::text) = 'admin'::text));
create policy "Anyone can read protocol config"
  on "public"."protocol_config"
  as permissive
  for select
  to public
using (true);
