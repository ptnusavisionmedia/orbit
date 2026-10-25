-- ORBIT bootstrap — Supabase variant.
--
-- This is ONE of only two files in this migration set that differ between
-- Supabase and self-hosted Postgres (the other is
-- 20261025090200_profiles_identity_supabase.sql). Every other migration in
-- this folder is byte-identical on both platforms — see db/README.md for
-- the full portability explanation and the self-hosted counterparts in
-- db/selfhosted-bootstrap/.

create schema if not exists app;
create schema if not exists private;

-- Portable RLS identity function. Every RLS policy and every trigger in
-- this project calls app.current_user_id() — never auth.uid() directly —
-- so only this function's body needs to change when migrating to
-- self-hosted Postgres (see db/selfhosted-bootstrap/000_bootstrap_selfhosted.sql).
create or replace function app.current_user_id()
returns uuid
language sql
stable
as $$
  select auth.uid();
$$;

grant usage on schema app to anon, authenticated;
grant execute on function app.current_user_id() to anon, authenticated;

-- `private` holds secrets (API keys, security events). No table grants are
-- ever issued here to anon/authenticated — only the SECURITY DEFINER
-- gateway functions defined in 20261025090400_triggers.sql are reachable,
-- and only by service_role.
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to service_role;
