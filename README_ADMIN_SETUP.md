# Campus Notes — Admin setup

This is a static front end with Supabase providing authentication, a shared JSON content store, and PDF/file storage. Visitors browse notes without logging in. Administrators can click **Admin** in the public website navigation to open the login and dashboard in an in-page panel. The `admin.html` file is loaded inside that panel; it can also be opened directly for testing.

## Files
- `index.html` — public notes website.
- `admin.html` — admin login and dashboard to add/remove/rename semesters, subjects, units and resources; upload files; change site name, hero headline, tagline, and accent color.
- `config.js` — public Supabase project URL and publishable/anon key placeholders.
- `seed-data.js` — sample semester/subject/unit structure used as starter content for the admin dashboard.
- `supabase_setup.sql` — database tables, Row Level Security policies, and the `notes` storage bucket.

## Setup (one-time)
1. Create a project at https://supabase.com/.
2. Open **SQL Editor**, paste the contents of `supabase_setup.sql`, and run it.
3. In **Project Settings → API** (or **Connect**), copy the project URL and publishable/anon key. Put them in `config.js` as `url` and `anonKey`. Never use a `service_role` key in browser code.
4. In **Authentication → Users**, create the admin user with email/password.
5. Copy that user's UUID. In SQL Editor, run `insert into public.app_admins (user_id) values ('PASTE-ADMIN-USER-UUID-HERE');` with the real UUID.
6. Open `index.html` and `admin.html` through a local web server or deploy the entire folder to a static host (e.g. Netlify, Vercel static hosting, or GitHub Pages). Keeping both files and `config.js` in the same deployed folder is important. Some browsers restrict network/module behavior when opening files directly, so use a local server for testing.
7. Open the public website and click **Admin** in the top navigation. Sign in in the panel. Upload notes in **Upload PDF**, then go to **Academic content** and attach the generated URL to a selected unit. Save changes. Public content updates from the shared database.

## Security notes
- Supabase Auth verifies admin credentials. The `app_admins` table is the allowlist; being a registered auth user alone does not grant dashboard write access.
- RLS policies protect database writes and Storage uploads/deletes. Public users can read the published content and download files from the public `notes` bucket.
- The dashboard supports files up to 50 MB; the bucket has the same limit.
- `site_content.academic_data` uses the same nested JSON shape as the sample data in the public website.
- Initial content row is empty. To publish sample content, sign in to the admin dashboard and add your semesters/subjects/units. Existing example semesters in the HTML are only a local fallback until the remote database contains content.
- The Google Fonts stylesheet and Supabase client library use external CDNs.
