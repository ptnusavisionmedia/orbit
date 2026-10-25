-- Row Level Security.
--
-- PORTABLE: byte-identical on Supabase and self-hosted Postgres. Every
-- policy reads app.current_user_id(), defined per-environment in the
-- bootstrap migration.

alter table profiles enable row level security;
alter table profiles force row level security;
create policy profiles_select on profiles for select using (id = app.current_user_id());
create policy profiles_update on profiles for update using (id = app.current_user_id()) with check (id = app.current_user_id());
-- No insert/delete policy: profiles are created by the server on signup
-- and removed only via account deletion (service_role), never directly by
-- the client.

alter table projects enable row level security;
alter table projects force row level security;
create policy projects_select on projects for select using (user_id = app.current_user_id());
create policy projects_insert on projects for insert with check (user_id = app.current_user_id());
create policy projects_update on projects for update using (user_id = app.current_user_id()) with check (user_id = app.current_user_id());
create policy projects_delete on projects for delete using (user_id = app.current_user_id());

alter table tasks enable row level security;
alter table tasks force row level security;
create policy tasks_select on tasks for select using (user_id = app.current_user_id());
create policy tasks_insert on tasks for insert with check (user_id = app.current_user_id());
create policy tasks_update on tasks for update using (user_id = app.current_user_id()) with check (user_id = app.current_user_id());
create policy tasks_delete on tasks for delete using (user_id = app.current_user_id());

alter table focus_ignored enable row level security;
alter table focus_ignored force row level security;
create policy focus_ignored_select on focus_ignored for select using (user_id = app.current_user_id());
create policy focus_ignored_insert on focus_ignored for insert with check (user_id = app.current_user_id());
create policy focus_ignored_delete on focus_ignored for delete using (user_id = app.current_user_id());
-- No update policy: a dismissal is created or removed (undo), never edited in place.

alter table ai_connection_status enable row level security;
alter table ai_connection_status force row level security;
create policy ai_connection_status_select on ai_connection_status for select using (user_id = app.current_user_id());
-- No client insert/update/delete: this table is written only by the
-- private.* gateway functions (running as service_role), kept in sync
-- with private.ai_connections.

alter table ai_requests enable row level security;
alter table ai_requests force row level security;
create policy ai_requests_select on ai_requests for select using (user_id = app.current_user_id());
-- No client insert: ai_requests rows are written only by
-- fn_check_and_record_ai_request() / fn_record_ai_request_outcome() as
-- part of the atomic rate-limit check — see 20261025090400_triggers.sql.

-- private.ai_connections: RLS here is defense-in-depth ONLY. The real
-- boundary is that no role except service_role (Supabase) / app_server
-- (self-hosted) has any grant on this table at all, and even that role is
-- meant to go through the gateway functions below — never SELECT/UPDATE
-- this table directly from application code.
--
-- IMPORTANT CAVEAT: on Supabase, service_role carries BYPASSRLS, so this
-- RLS policy does NOT protect against misuse via the service_role
-- connection itself. It only guards against anon/authenticated ever being
-- granted access by mistake. On self-hosted Postgres, where app_server is
-- NOT given BYPASSRLS, this becomes a real second layer of defense.
alter table private.ai_connections enable row level security;
alter table private.ai_connections force row level security;
revoke all on private.ai_connections from public, anon, authenticated;

alter table private.security_events enable row level security;
alter table private.security_events force row level security;
revoke all on private.security_events from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- Base table grants for the client-facing role.
--
-- RLS policies only filter ROWS; without an explicit base grant, the
-- role has no privilege to run the statement at all. The role name
-- itself is the one thing that differs between environments
-- (`authenticated` on Supabase, `app_server` on self-hosted Postgres —
-- see db/selfhosted-bootstrap/000_bootstrap_selfhosted.sql), so this
-- block detects which role exists and grants accordingly, keeping this
-- file itself identical on both platforms. private.ai_connections and
-- private.security_events are deliberately excluded — see 20261025090400_triggers.sql.
-- ---------------------------------------------------------------------

do $$
declare
  v_role text;
begin
  select rolname into v_role from pg_roles where rolname in ('authenticated', 'app_server') limit 1;
  if v_role is null then
    raise exception 'neither "authenticated" nor "app_server" role exists — run the bootstrap migration for your environment first';
  end if;

  execute format('grant select, update on profiles to %I', v_role);
  execute format('grant select, insert, update, delete on projects to %I', v_role);
  execute format('grant select, insert, update, delete on tasks to %I', v_role);
  execute format('grant select, insert, delete on focus_ignored to %I', v_role);
  execute format('grant select on ai_connection_status to %I', v_role);
  execute format('grant select on ai_requests to %I', v_role);
end;
$$;
