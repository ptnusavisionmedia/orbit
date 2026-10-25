-- ORBIT bootstrap — self-hosted Postgres variant.
--
-- Counterpart to supabase/migrations/20261025090000_bootstrap_supabase.sql.
-- Run this INSTEAD of that file when deploying to a self-hosted Postgres
-- server. Every other migration in supabase/migrations/ is reused as-is —
-- see db/README.md for the exact run order.

create schema if not exists app;
create schema if not exists private;

-- No auth.users / JWT claims on self-hosted Postgres. The application
-- server must run every per-request database query inside a transaction
-- that starts with:
--
--   BEGIN;
--   SET LOCAL app.current_user_id = '<uuid>';
--   ... query ...
--   COMMIT;
--
-- missing_ok=true (the `, true` argument) makes this fail CLOSED, not
-- open: if a code path forgets to SET LOCAL, current_setting returns
-- NULL instead of raising, and every RLS policy comparing
-- `user_id = app.current_user_id()` then rejects all rows, rather than
-- accidentally exposing them.
--
-- IMPORTANT: with a transaction-mode connection pooler (PgBouncer /
-- Supavisor in transaction mode), SET LOCAL only applies within the same
-- transaction as the query that follows it. Centralize this in ONE
-- server-side wrapper (e.g. withUserContext(userId, fn)) and never allow
-- a raw query path outside that wrapper — this is the single place to
-- re-audit when migrating off Supabase.
create or replace function app.current_user_id()
returns uuid
language sql
stable
as $$
  select nullif(current_setting('app.current_user_id', true), '')::uuid
$$;

-- Create a dedicated low-privilege role for the application server,
-- analogous to Supabase's `service_role` — but WITHOUT an equivalent of
-- BYPASSRLS, so RLS on private.ai_connections is a real second layer of
-- defense here (unlike on Supabase, see 20261025090300_rls.sql).
-- Uncomment and set a strong password via your secrets manager:
-- create role app_server login password '<set via secrets manager>';
--
-- Self-hosted deployments do NOT need a separate `authenticated` role —
-- that split only exists because Supabase/PostgREST expose the database
-- directly to end-user HTTP requests under different JWT-derived roles.
-- Here, the Next.js server is the only thing that ever opens a DB
-- connection; it always connects as app_server and sets
-- app.current_user_id per request. RLS still isolates each end-user
-- correctly, because policies check current_user_id(), not which
-- Postgres role is connected.

grant usage on schema app to app_server;
grant execute on function app.current_user_id() to app_server;

revoke all on schema private from public;
grant usage on schema private to app_server;
