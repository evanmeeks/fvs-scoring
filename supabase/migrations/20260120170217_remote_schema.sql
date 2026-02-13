drop trigger if exists "set_context_types_updated_at" on "public"."context_types";
drop trigger if exists "set_origin_types_updated_at" on "public"."origin_types";
drop policy "Anyone can view context types" on "public"."context_types";
drop policy "Anyone can view origin types" on "public"."origin_types";
revoke delete on table "public"."context_types" from "anon";
revoke insert on table "public"."context_types" from "anon";
revoke references on table "public"."context_types" from "anon";
revoke select on table "public"."context_types" from "anon";
revoke trigger on table "public"."context_types" from "anon";
revoke truncate on table "public"."context_types" from "anon";
revoke update on table "public"."context_types" from "anon";
revoke delete on table "public"."context_types" from "authenticated";
revoke insert on table "public"."context_types" from "authenticated";
revoke references on table "public"."context_types" from "authenticated";
revoke select on table "public"."context_types" from "authenticated";
revoke trigger on table "public"."context_types" from "authenticated";
revoke truncate on table "public"."context_types" from "authenticated";
revoke update on table "public"."context_types" from "authenticated";
revoke delete on table "public"."context_types" from "service_role";
revoke insert on table "public"."context_types" from "service_role";
revoke references on table "public"."context_types" from "service_role";
revoke select on table "public"."context_types" from "service_role";
revoke trigger on table "public"."context_types" from "service_role";
revoke truncate on table "public"."context_types" from "service_role";
revoke update on table "public"."context_types" from "service_role";
revoke delete on table "public"."origin_types" from "anon";
revoke insert on table "public"."origin_types" from "anon";
revoke references on table "public"."origin_types" from "anon";
revoke select on table "public"."origin_types" from "anon";
revoke trigger on table "public"."origin_types" from "anon";
revoke truncate on table "public"."origin_types" from "anon";
revoke update on table "public"."origin_types" from "anon";
revoke delete on table "public"."origin_types" from "authenticated";
revoke insert on table "public"."origin_types" from "authenticated";
revoke references on table "public"."origin_types" from "authenticated";
revoke select on table "public"."origin_types" from "authenticated";
revoke trigger on table "public"."origin_types" from "authenticated";
revoke truncate on table "public"."origin_types" from "authenticated";
revoke update on table "public"."origin_types" from "authenticated";
revoke delete on table "public"."origin_types" from "service_role";
revoke insert on table "public"."origin_types" from "service_role";
revoke references on table "public"."origin_types" from "service_role";
revoke select on table "public"."origin_types" from "service_role";
revoke trigger on table "public"."origin_types" from "service_role";
revoke truncate on table "public"."origin_types" from "service_role";
revoke update on table "public"."origin_types" from "service_role";
alter table "public"."approved_targets" drop constraint "fk_approved_targets_context_types";
alter table "public"."approved_targets" drop constraint "fk_approved_targets_origin_types";
alter table "public"."origin_types" drop constraint "origin_types_abbreviation_key";
alter table "public"."target_submissions" drop constraint "fk_target_submissions_context_types";
alter table "public"."target_submissions" drop constraint "fk_target_submissions_origin_types";
alter table "public"."targets" drop constraint "fk_targets_context_types";
alter table "public"."targets" drop constraint "fk_targets_origin_types";
drop view if exists "public"."target_score_aggregates";
alter table "public"."context_types" drop constraint "context_types_pkey";
alter table "public"."origin_types" drop constraint "origin_types_pkey";
drop index if exists "public"."context_types_pkey";
drop index if exists "public"."origin_types_abbreviation_key";
drop index if exists "public"."origin_types_pkey";
drop table "public"."context_types";
drop table "public"."origin_types";
create or replace view "public"."target_score_aggregates" as  SELECT t.id AS target_id,
    t.name AS target_name,
    m.id AS metric_id,
    m.name AS metric_name,
    count(us.id) FILTER (WHERE (us.score IS NOT NULL)) AS total_votes,
    avg(us.score) FILTER (WHERE (us.score IS NOT NULL)) AS average_score,
    mode() WITHIN GROUP (ORDER BY us.score) FILTER (WHERE (us.score IS NOT NULL)) AS most_common_score,
    count(us.id) FILTER (WHERE (us.action_vote IS NOT NULL)) AS total_governance_votes,
    count(us.id) FILTER (WHERE (us.action_vote = 'keep'::text)) AS keep_votes,
    count(us.id) FILTER (WHERE (us.action_vote = 'modify'::text)) AS modify_votes,
    count(us.id) FILTER (WHERE (us.action_vote = 'drop'::text)) AS drop_votes,
    mode() WITHIN GROUP (ORDER BY us.action_vote) FILTER (WHERE (us.action_vote IS NOT NULL)) AS consensus_action
   FROM ((public.targets t
     CROSS JOIN public.metrics m)
     LEFT JOIN public.user_scores us ON (((us.target_id = t.id) AND (us.metric_id = m.id))))
  GROUP BY t.id, t.name, m.id, m.name;
