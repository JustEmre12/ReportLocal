# ReportLocal

**See it. Report it. Track it.**

ReportLocal is a responsive community-reporting web app that combines a familiar social/community interface with a structured report workflow.

## Current implementation

- 10,171 U.S. police-department directory records
- Responsive desktop/mobile UI and installable PWA shell
- Light/dark mode
- Public community feed and department profiles
- Search/filter by department name, city, county, state, and agency type
- Report creation with title, description, category, location, department, visibility, and media
- Separate **Import from device** and **Use camera** attachment controls
- Persistent user accounts using server-side password hashing and HttpOnly session cookies
- Persistent reports stored in Cloudflare D1
- Persistent media attachments stored in Cloudflare R2
- Public/private report access control
- User-owned **My Reports** view restored after sign-in on another/reopened device
- Agency-role server authorization for official status changes and updates
- Status lifecycle: **Submitted → Received → Investigating → Closed**

## Architecture

The production-ready source is arranged for Cloudflare Workers:

- `public/` — ReportLocal frontend and department directory
- `worker/index.js` — same-origin API + static asset worker
- `migrations/` — D1 database schema
- `wrangler.toml` — Worker, D1, R2, and static-asset bindings

The original root frontend files are kept for easier inspection, but deployment serves `public/`.

## Local development

Install dependencies:

```bash
npm install
```

Create a D1 database and R2 bucket, then update the D1 database ID in `wrangler.toml`:

```bash
npx wrangler d1 create reportlocal
npx wrangler r2 bucket create reportlocal-media
```

Apply the schema locally:

```bash
npm run db:migrate:local
```

Run locally:

```bash
npm run dev
```

## Deploy

1. Create the Cloudflare D1 database and R2 bucket if they do not exist.
2. Replace `REPLACE_WITH_D1_DATABASE_ID` in `wrangler.toml` with the D1 database ID returned by Cloudflare.
3. Authenticate Wrangler or configure a Cloudflare API token in CI.
4. Apply migrations:

```bash
npm run db:migrate:remote
```

5. Deploy:

```bash
npm run deploy
```

## Account persistence

Accounts are no longer stored in `localStorage`. Passwords are PBKDF2-hashed server-side, sessions are represented by random tokens stored as hashes in D1, and the browser receives an HttpOnly/Secure/SameSite cookie. A session is valid for 30 days unless the user signs out.

## Report persistence

Reports are no longer stored in `localStorage`. Signed-in users create reports through `/api/reports`, which stores them in D1. After sign-in, `My Reports` is rebuilt from the database. Public reports are loaded independently for the community feed.

## Attachments

Images/videos are uploaded after the report record is created. The Worker enforces image/video MIME types and a 25 MB per-file size limit before storing the bytes in R2. Private-report media can only be retrieved by the report owner or an authorized agency/admin account.

## Agency permissions

A normal user cannot self-assign agency privileges. Agency access is controlled by the server using the `role` field plus `agency_memberships`. An administrator can provision a verified agency user by updating the user role to `agency` and inserting the appropriate department key into `agency_memberships`.

## Production checklist still recommended

Before a public launch, ReportLocal should also add email verification/password reset, abuse reporting/moderation, rate limiting, malware scanning, audit logs, formal agency onboarding, notification delivery, legal/privacy review, and a retention policy for sensitive media and coordinates.

## Safety language

Public posts are described as **reported incidents**, not automatically as confirmed crimes. ReportLocal does not determine guilt or criminal responsibility. Emergencies should be handled through local emergency services.