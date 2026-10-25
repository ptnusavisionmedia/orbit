-- ORBIT schema — P0 (MVP) tables.
--
-- PORTABLE: byte-identical on Supabase and self-hosted Postgres.
--
-- P1/P2 columns (parent_task_id, parent_project_id) are reserved here as
-- nullable with no foreign key yet. Their FK constraints, dependent
-- tables, and indexes are activated later by db/P1/ and db/P2/ migrations
-- — see db/README.md for when/how to run those.

create table if not exists profiles (
  id uuid primary key,
  timezone text not null default 'Asia/Jakarta',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  parent_project_id uuid, -- reserved for P2, FK activated in db/P2/200_project_hierarchy.sql
  name text not null check (char_length(name) between 1 and 120),
  description text check (description is null or char_length(description) <= 2000),
  status text not null default 'active' check (status in ('active', 'archived')),
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, id) -- required: Postgres needs this exact unique target for composite FKs below
);

create table if not exists tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  project_id uuid,
  parent_task_id uuid, -- reserved for P1, FK activated in db/P1/100_task_hierarchy.sql
  title text not null check (char_length(title) between 1 and 200),
  description text check (description is null or char_length(description) <= 2000),
  status text not null default 'inbox' check (status in ('inbox', 'next', 'in_progress', 'done')),
  priority text not null default 'medium' check (priority in ('low', 'medium', 'high')),
  due_date date,
  estimated_minutes int check (estimated_minutes is null or estimated_minutes between 5 and 480),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, id),
  check ((status = 'done') = (completed_at is not null)), -- DB-level mirror of the app-layer invariant (defense in depth)
  foreign key (user_id, project_id) references projects (user_id, id) on delete set null
);

create table if not exists focus_ignored (
  user_id uuid not null,
  task_id uuid not null,
  ignored_on date not null,
  created_at timestamptz not null default now(),
  primary key (user_id, task_id, ignored_on),
  foreign key (user_id, task_id) references tasks (user_id, id) on delete cascade
);

-- BYOK secrets: isolated in its own schema, never exposed to anon/authenticated.
-- See 20261025090300_rls.sql for the revoke policy and
-- 20261025090400_triggers.sql for the gateway functions that are the ONLY
-- supported way to read or write this table from server code.
create table if not exists private.ai_connections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  provider text not null check (provider = 'openai'), -- extended in P1 (multi-provider)
  model text not null,
  encrypted_key bytea not null,
  key_iv bytea not null,
  key_auth_tag bytea not null,
  key_enc_algo text not null default 'aes-256-gcm',
  key_version int not null default 1,
  key_fingerprint text, -- SHA-256 prefix of the plaintext key, non-reversible; lets the UI confirm "same key?" without ever showing it
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, provider)
);

-- Public-safe projection of ai_connections: only what the client is allowed
-- to see. The ciphertext never lives in a table the client role can reach,
-- by construction — not just by query discipline.
create table if not exists ai_connection_status (
  user_id uuid not null references profiles (id) on delete cascade,
  provider text not null,
  status text not null default 'unverified' check (status in ('unverified', 'verified', 'invalid')),
  last_tested_at timestamptz,
  primary key (user_id, provider)
);

create table if not exists ai_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  kind text not null check (kind in ('breakdown', 'test_connection', 'decomposer')), -- decomposer active from P1
  status text not null check (status in ('success', 'error', 'rate_limited')),
  created_at timestamptz not null default now()
  -- Intentionally NO column for prompt/goal text or key material: this
  -- table must never be able to hold that data, by schema design.
);

create table if not exists private.security_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles (id) on delete cascade,
  event_type text not null check (event_type in (
    'ai_connection_created', 'ai_connection_updated', 'ai_connection_deleted',
    'ai_connection_test_success', 'ai_connection_test_failed',
    'ai_key_decrypted', 'account_deletion_requested', 'account_deleted',
    'ai_rate_limit_exceeded'
  )),
  metadata jsonb not null default '{}'::jsonb, -- MUST NEVER contain prompts, keys, or key fragments
  created_at timestamptz not null default now()
);
