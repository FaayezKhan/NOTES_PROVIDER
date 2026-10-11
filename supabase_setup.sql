-- Campus Notes: run this entire script in Supabase SQL Editor.
-- 1) Create the project and run this SQL.
-- 2) Create an admin user in Authentication > Users (Add user).
-- 3) Copy that user's UUID and run the INSERT at the bottom.
-- 4) Create a PUBLIC Storage bucket named `notes` (or uncomment the bucket insert below).

create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.site_content (
  id integer primary key check (id = 1),
  academic_data jsonb not null default '[]'::jsonb,
  settings jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_admins enable row level security;
alter table public.site_content enable row level security;

drop policy if exists "Admins can read their own admin record" on public.app_admins;
create policy "Admins can read their own admin record" on public.app_admins
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Anyone can read published site content" on public.site_content;
create policy "Anyone can read published site content" on public.site_content
for select to anon, authenticated using (true);

drop policy if exists "Admins can insert site content" on public.site_content;
create policy "Admins can insert site content" on public.site_content
for insert to authenticated with check (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Admins can update site content" on public.site_content;
create policy "Admins can update site content" on public.site_content
for update to authenticated using (exists (select 1 from public.app_admins a where a.user_id = auth.uid()))
with check (exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

insert into public.site_content (id, academic_data, settings)
values (1, '[]'::jsonb, '{"siteName":"Campus Notes","accentColor":"#355c4b","heroTitle":"Every Semester.\nEvery Subject. One Place.","tagline":"Your university notes, neatly organized and always within reach. Choose your semester and get straight to studying."}'::jsonb)
on conflict (id) do nothing;

-- Storage bucket for uploaded notes. Public read lets students open/download PDFs;
-- only admin users can upload, update, or delete files.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('notes', 'notes', true, 52428800, array['application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-powerpoint','application/vnd.openxmlformats-officedocument.presentationml.presentation'])
on conflict (id) do nothing;

drop policy if exists "Public can view notes files" on storage.objects;
create policy "Public can view notes files" on storage.objects
for select to anon, authenticated using (bucket_id = 'notes');

drop policy if exists "Admins can upload notes files" on storage.objects;
create policy "Admins can upload notes files" on storage.objects
for insert to authenticated with check (bucket_id = 'notes' and exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Admins can update notes files" on storage.objects;
create policy "Admins can update notes files" on storage.objects
for update to authenticated using (bucket_id = 'notes' and exists (select 1 from public.app_admins a where a.user_id = auth.uid()))
with check (bucket_id = 'notes' and exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

drop policy if exists "Admins can delete notes files" on storage.objects;
create policy "Admins can delete notes files" on storage.objects
for delete to authenticated using (bucket_id = 'notes' and exists (select 1 from public.app_admins a where a.user_id = auth.uid()));

-- AFTER creating the admin in Authentication > Users, replace UUID and run:
-- insert into public.app_admins (user_id) values ('PASTE-ADMIN-USER-UUID-HERE');
