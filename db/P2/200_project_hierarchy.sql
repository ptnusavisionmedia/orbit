-- Activates project parent-child (parent project, one level) — P2.
--
-- DO NOT copy this into supabase/migrations/ until P2 actually starts.
-- When ready: copy into supabase/migrations/ with a fresh timestamp,
-- then `supabase migration up` / `supabase db push`.
--
-- The parent_project_id column already exists from P0 (see
-- 20261025090100_schema.sql) and has been unused until now. This
-- migration only adds the FK — ownership and "one level only" (a project
-- that already has a parent cannot itself become a parent) should be
-- enforced the same way as fn_tasks_guard_hierarchy if this phase is
-- ever built: reuse that pattern rather than re-deriving it.

alter table projects
  add constraint fk_project_parent
  foreign key (user_id, parent_project_id) references projects (user_id, id) on delete set null;

create index if not exists idx_projects_user_parent on projects (user_id, parent_project_id);
