# Docker secrets (local only - never commit the `.txt` files here)

`docker-compose.yml` mounts these as files inside the `app` container at `/run/secrets/<name>`,
which `Program.cs` reads into configuration at startup. This keeps the real values out of
`environment:` entries, which are visible to anyone who can run `docker inspect` or
`docker compose config` on this host.

Create these two files in this folder (both are gitignored via `eHairdressers/secrets/*.txt`):

- `stripe_secret_key.txt` - your Stripe **secret** key (`sk_test_...` / `sk_live_...`). Get it from
  the Stripe Dashboard under Developers > API keys.
- `stripe_webhook_secret.txt` - your webhook endpoint's signing secret (`whsec_...`). Get it from
  the Stripe Dashboard under Developers > Webhooks (or from `stripe listen` output if testing
  locally with the Stripe CLI).

Each file should contain just the raw key value, nothing else (a trailing newline is fine, it's
trimmed on read).

If either file is missing, the app falls back to whatever is in `appsettings.json` (empty by
default), and the corresponding Stripe endpoint will return a clear "not configured" error instead
of failing silently.
