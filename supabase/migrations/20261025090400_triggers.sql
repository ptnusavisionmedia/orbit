-- Triggers & server-facing functions.
--
-- PORTABLE: byte-identical on Supabase and self-hosted Postgres (none of
-- this references auth.users or any Supabase-only extension).

-- ---------------------------------------------------------------------
-- updated_at bookkeeping
-- ---------------------------------------------------------------------

create or replace function fn_set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_profiles_updated_at before update on profiles
  for each row execute function fn_set_updated_at();
create trigger trg_projects_updated_at before update on projects
  for each row execute function fn_set_updated_at();
create trigger trg_tasks_updated_at before update on tasks
  for each row execute function fn_set_updated_at();
create trigger trg_ai_connections_updated_at before update on private.ai_connections
  for each row execute function fn_set_updated_at();

-- ---------------------------------------------------------------------
-- Task hierarchy guard (P1 feature, safe to attach now).
--
-- parent_task_id is always NULL in P0, so this trigger is a no-op until
-- the P1 migration (db/P1/100_task_hierarchy.sql) activates the column's
-- FK. Attaching it now means P1 activation needs no app-logic changes —
-- only a constraint + index.
--
-- Depth is capped at 2 levels, which collapses "no cycles, no self-link,
-- max depth 2" into ONE cheap invariant: a task may only become a parent
-- if it is not itself a child, and may only become a child if it does not
-- already have children. No recursive walk needed. Ownership (parent and
-- child must be the same user) is enforced for free by the composite FK
-- in db/P1/100_task_hierarchy.sql — it is deliberately NOT re-checked here.
-- ---------------------------------------------------------------------

create or replace function fn_tasks_guard_hierarchy() returns trigger as $$
declare
  parent_of_parent uuid;
begin
  if new.parent_task_id is null then
    return new;
  end if;

  if new.parent_task_id = new.id then
    raise exception 'self-link tidak diizinkan: task tidak boleh menjadi parent dirinya sendiri';
  end if;

  -- Serialize hierarchy mutations per user to close the TOCTOU window
  -- where two concurrent requests could each pass validation and
  -- together create an invalid structure.
  perform pg_advisory_xact_lock(hashtext(new.user_id::text || ':task_hierarchy'));

  select parent_task_id into parent_of_parent
  from tasks where id = new.parent_task_id for share;

  if parent_of_parent is not null then
    raise exception 'kedalaman maksimal 2 level: parent yang dipilih sudah menjadi child dari task lain';
  end if;

  if exists (select 1 from tasks where parent_task_id = new.id) then
    raise exception 'task ini sudah memiliki subtask, tidak bisa dijadikan child';
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trg_tasks_guard_hierarchy
  before insert or update of parent_task_id on tasks
  for each row execute function fn_tasks_guard_hierarchy();

-- ---------------------------------------------------------------------
-- Atomic AI rate limiting (10 requests/hour/user).
--
-- Count-then-insert as two separate statements is a TOCTOU race under
-- concurrent requests from the same user. This wraps both in one
-- advisory-locked function so the check is truly atomic without any
-- extra infrastructure (no Redis needed).
--
-- Returns the new ai_requests row id when allowed, or NULL when denied.
-- Caller must later call fn_record_ai_request_outcome() with the actual
-- result once the OpenAI call completes (success/error).
-- ---------------------------------------------------------------------

create or replace function fn_check_and_record_ai_request(p_user_id uuid, p_kind text)
returns uuid as $$
declare
  v_count int;
  v_request_id uuid;
begin
  perform pg_advisory_xact_lock(hashtext(p_user_id::text || ':ai_rate_limit'));

  select count(*) into v_count
  from ai_requests
  where user_id = p_user_id
    and created_at > now() - interval '1 hour';

  if v_count >= 10 then
    insert into private.security_events (user_id, event_type, metadata)
      values (p_user_id, 'ai_rate_limit_exceeded', jsonb_build_object('kind', p_kind));
    return null;
  end if;

  insert into ai_requests (user_id, kind, status)
    values (p_user_id, p_kind, 'success')
    returning id into v_request_id;

  return v_request_id;
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function fn_check_and_record_ai_request(uuid, text) to service_role;

create or replace function fn_record_ai_request_outcome(p_request_id uuid, p_status text)
returns void as $$
begin
  if p_status not in ('success', 'error') then
    raise exception 'status tidak valid untuk outcome: %', p_status;
  end if;
  update ai_requests set status = p_status where id = p_request_id;
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function fn_record_ai_request_outcome(uuid, text) to service_role;

-- ---------------------------------------------------------------------
-- BYOK gateway functions — the ONLY supported way to read or write
-- private.ai_connections. Application code must never SELECT/UPDATE/
-- DELETE this table directly, even from a service_role connection.
--
-- Every call logs a matching row in private.security_events, so key
-- lifecycle events are audited at a single point regardless of which
-- server code path calls them.
--
-- Encryption/decryption itself happens in the Node.js server layer
-- (AES-256-GCM via Node Crypto, per PRD) — these functions only move
-- ciphertext in and out of storage, never plaintext.
-- ---------------------------------------------------------------------

create or replace function private.fn_upsert_ai_connection(
  p_user_id uuid,
  p_provider text,
  p_model text,
  p_encrypted_key bytea,
  p_key_iv bytea,
  p_key_auth_tag bytea,
  p_key_version int,
  p_key_fingerprint text
) returns void as $$
begin
  insert into private.ai_connections (
    user_id, provider, model, encrypted_key, key_iv, key_auth_tag,
    key_version, key_fingerprint
  ) values (
    p_user_id, p_provider, p_model, p_encrypted_key, p_key_iv, p_key_auth_tag,
    p_key_version, p_key_fingerprint
  )
  on conflict (user_id, provider) do update set
    model = excluded.model,
    encrypted_key = excluded.encrypted_key,
    key_iv = excluded.key_iv,
    key_auth_tag = excluded.key_auth_tag,
    key_version = excluded.key_version,
    key_fingerprint = excluded.key_fingerprint,
    updated_at = now();

  insert into ai_connection_status (user_id, provider, status, last_tested_at)
    values (p_user_id, p_provider, 'unverified', null)
  on conflict (user_id, provider) do update set
    status = 'unverified',
    last_tested_at = null;

  insert into private.security_events (user_id, event_type, metadata)
    values (p_user_id, 'ai_connection_created', jsonb_build_object('provider', p_provider));
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function private.fn_upsert_ai_connection(uuid, text, text, bytea, bytea, bytea, int, text) to service_role;

create or replace function private.fn_get_decrypt_material(p_user_id uuid, p_provider text)
returns table (
  encrypted_key bytea,
  key_iv bytea,
  key_auth_tag bytea,
  key_enc_algo text,
  key_version int,
  model text
) as $$
begin
  insert into private.security_events (user_id, event_type, metadata)
    values (p_user_id, 'ai_key_decrypted', jsonb_build_object('provider', p_provider));

  return query
    select c.encrypted_key, c.key_iv, c.key_auth_tag, c.key_enc_algo, c.key_version, c.model
    from private.ai_connections c
    where c.user_id = p_user_id and c.provider = p_provider;
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function private.fn_get_decrypt_material(uuid, text) to service_role;

create or replace function private.fn_delete_ai_connection(p_user_id uuid, p_provider text)
returns void as $$
begin
  delete from private.ai_connections where user_id = p_user_id and provider = p_provider;
  delete from ai_connection_status where user_id = p_user_id and provider = p_provider;

  insert into private.security_events (user_id, event_type, metadata)
    values (p_user_id, 'ai_connection_deleted', jsonb_build_object('provider', p_provider));
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function private.fn_delete_ai_connection(uuid, text) to service_role;

create or replace function private.fn_record_ai_connection_test_result(p_user_id uuid, p_provider text, p_success boolean)
returns void as $$
begin
  update ai_connection_status
    set status = case when p_success then 'verified' else 'invalid' end,
        last_tested_at = now()
    where user_id = p_user_id and provider = p_provider;

  insert into private.security_events (user_id, event_type, metadata)
    values (
      p_user_id,
      case when p_success then 'ai_connection_test_success' else 'ai_connection_test_failed' end,
      jsonb_build_object('provider', p_provider)
    );
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function private.fn_record_ai_connection_test_result(uuid, text, boolean) to service_role;

-- ---------------------------------------------------------------------
-- Generic security-event logger, for lifecycle events that don't belong
-- to the AI gateway functions above (account deletion flow).
-- ---------------------------------------------------------------------

create or replace function private.fn_log_security_event(p_user_id uuid, p_event_type text, p_metadata jsonb default '{}'::jsonb)
returns void as $$
begin
  insert into private.security_events (user_id, event_type, metadata)
    values (p_user_id, p_event_type, p_metadata);
end;
$$ language plpgsql security definer set search_path = public, private;

grant execute on function private.fn_log_security_event(uuid, text, jsonb) to service_role;
