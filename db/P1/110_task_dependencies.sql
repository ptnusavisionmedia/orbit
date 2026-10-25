-- Activates task dependencies ("blocked by") — P1.
--
-- DO NOT copy this into supabase/migrations/ until P1 actually starts.
-- Apply AFTER 100_task_hierarchy.sql. When ready: copy into
-- supabase/migrations/ with a fresh timestamp, then
-- `supabase migration up` / `supabase db push`.

create table if not exists task_dependencies (
  user_id uuid not null,
  task_id uuid not null,
  blocked_by_task_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (task_id, blocked_by_task_id),
  check (task_id <> blocked_by_task_id),
  foreign key (user_id, task_id) references tasks (user_id, id) on delete cascade,
  foreign key (user_id, blocked_by_task_id) references tasks (user_id, id) on delete cascade
);

create index if not exists idx_task_dependencies_by_task on task_dependencies (user_id, task_id);
create index if not exists idx_task_dependencies_by_blocker on task_dependencies (user_id, blocked_by_task_id);

alter table task_dependencies enable row level security;
alter table task_dependencies force row level security;
create policy task_dependencies_select on task_dependencies for select using (user_id = app.current_user_id());
create policy task_dependencies_insert on task_dependencies for insert with check (user_id = app.current_user_id());
create policy task_dependencies_delete on task_dependencies for delete using (user_id = app.current_user_id());

do $$
declare
  v_role text;
begin
  select rolname into v_role from pg_roles where rolname in ('authenticated', 'app_server') limit 1;
  if v_role is null then
    raise exception 'neither "authenticated" nor "app_server" role exists — run the bootstrap migration for your environment first';
  end if;
  execute format('grant select, insert, delete on task_dependencies to %I', v_role);
end;
$$;

-- This is a general DAG, unlike the depth-2-capped parent_task_id
-- hierarchy, so a recursive walk is genuinely needed. Still cheap: the
-- dependency graph per user stays small relative to total task count.
-- Ownership (task and blocked_by_task_id must belong to the same user)
-- is enforced structurally by the composite FKs above — not re-checked
-- here. The advisory lock closes the same TOCTOU window as the task
-- hierarchy guard: two concurrent inserts could otherwise each pass the
-- cycle check before either commits.
create or replace function fn_dependencies_guard_cycle() returns trigger as $$
begin
  if new.task_id = new.blocked_by_task_id then
    raise exception 'self-link tidak diizinkan';
  end if;

  perform pg_advisory_xact_lock(hashtext(new.user_id::text || ':task_dependencies'));

  if exists (
    with recursive chain(node, depth) as (
      select blocked_by_task_id, 1 from task_dependencies
      where task_id = new.blocked_by_task_id and user_id = new.user_id
      union all
      select td.blocked_by_task_id, c.depth + 1
      from task_dependencies td join chain c on td.task_id = c.node
      where td.user_id = new.user_id and c.depth < 200 -- safety cap against pathological data, not a business limit
    )
    select 1 from chain where node = new.task_id
  ) then
    raise exception 'dependency akan membentuk siklus';
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trg_task_dependencies_guard_cycle
  before insert on task_dependencies
  for each row execute function fn_dependencies_guard_cycle();
