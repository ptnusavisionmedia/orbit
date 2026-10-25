-- Links profiles to Supabase Auth.
--
-- This is the SECOND (and last) file in this migration set that differs
-- between Supabase and self-hosted Postgres — see
-- db/selfhosted-bootstrap/015_profiles_identity_selfhosted.sql for the
-- counterpart. Every other migration file is shared as-is.

alter table profiles
  add constraint profiles_id_fkey_auth_users
  foreign key (id) references auth.users (id) on delete cascade;
