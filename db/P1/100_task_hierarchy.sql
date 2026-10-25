-- Activates task hierarchy (subtasks) — P1.
--
-- DO NOT copy this into supabase/migrations/ until P1 actually starts.
-- When ready: copy this file into supabase/migrations/ with a fresh
-- timestamp greater than every existing migration, then run
-- `supabase migration up` (or `supabase db push`).
--
-- The parent_task_id column and its guard trigger (fn_tasks_guard_hierarchy)
-- already exist from P0 (see 20261025090100_schema.sql and
-- 20261025090400_triggers.sql) and have been a safe no-op until now,
-- since the column was always NULL. This migration only adds the FK —
-- ownership (parent & child must be the same user) is enforced
-- structurally by this composite FK, not by application code — and its
-- supporting index.

alter table tasks
  add constraint fk_task_parent
  foreign key (user_id, parent_task_id) references tasks (user_id, id) on delete set null;

create index if not exists idx_tasks_user_parent on tasks (user_id, parent_task_id);
