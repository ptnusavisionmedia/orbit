-- Required indexes for P0.
--
-- PORTABLE: byte-identical on Supabase and self-hosted Postgres.
-- P1/P2 indexes (tasks.parent_task_id, task_dependencies, projects.parent_project_id)
-- live in db/P1/ and db/P2/ alongside the constraints they support.

create index if not exists idx_tasks_user_status_due on tasks (user_id, status, due_date);
create index if not exists idx_tasks_user_project on tasks (user_id, project_id);
create index if not exists idx_projects_user on projects (user_id);
create index if not exists idx_focus_ignored_lookup on focus_ignored (user_id, ignored_on);
create index if not exists idx_ai_requests_user_created on ai_requests (user_id, created_at desc);
create index if not exists idx_security_events_user_created on private.security_events (user_id, created_at desc);
