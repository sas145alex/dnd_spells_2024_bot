# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

This is a **Rails 8 Telegram bot — a D&D 5e (2024) reference**, with an ActiveAdmin backend for
managing content. Bot replies are in Russian; D&D terms are bilingual (RU title + EN `original_title`).

## Tech stack

| Concern | Choice |
| --- | --- |
| Language / framework | Ruby **4.0.5** (`.ruby-version`), Rails **8.1.3** |
| Database | PostgreSQL 18 (prod `postgres:18` accessory; local dev 18) |
| Solid stack | `solid_cache`, `solid_queue`, `solid_cable` — **all on the primary Postgres DB** (`config/database.yml`) |
| Bot | `telegram-bot` (telegram-bot-rb) |
| Search | `pg_search` (Postgres full-text, `russian` dictionary) |
| View formatting | `draper` decorators + `redcarpet` Markdown (`lib/format_changer.rb`) |
| Admin | `activeadmin` + `activeadmin_addons` + `activeadmin_simplemde` |
| Auth (admin) | `devise` |
| Outbound integrations | `httparty` → Discord (feedback), `cloudinary` (images) |
| Errors / sessions | `sentry-ruby`; Telegram session store = **`solid_cache_store`** (`config/application.rb`) |
| i18n | default locale `:ru` (available `:ru`, `:en`) |

## Commands

```bash
make setup      # bundle, cp --update=none .env.test .env, rails db:create db:migrate db:seed
make web        # bin/dev — Puma dev server on :3000
make bot        # bin/rails telegram:bot:poller — DEV-ONLY polling (prod uses webhook, see Deployment)
make jobs       # bin/jobs — SolidQueue worker for background jobs
make test       # bundle exec rspec — full suite
bundle exec rspec spec/path/to/file_spec.rb   # single spec file
```

### Linting

- **Single linter: RuboCop** with the `rubocop-rails-omakase` preset (`.rubocop.yml`), plus the
  `rubocop-rails` / `rubocop-performance` cops it enables. Run `bin/rubocop` to check, `bin/rubocop -A`
  to autocorrect.
- The same RuboCop runs everywhere: the lefthook pre-commit hook autocorrects staged files
  (`bin/rubocop -A --force-exclusion {staged_files}`, `lefthook.yml`), and CI runs `bin/rubocop -f github`
  (`.github/workflows/ci.yml`) plus `bin/brakeman` (security). No StandardRB.

### Commit conventions

- Keep commit messages **short** — a concise one-line summary of the change.
- **Do not** mention Claude, Claude Code, or any other AI agent in commit messages, and **do not** add
  `Co-Authored-By` / "Generated with" trailers for AI tools.
- Preferred merge style is **squash + fast-forward** (`--squash` then a fast-forward merge) — keep
  history linear, no merge commits.

### Comments

- **Do not** comment self-explanatory code — prefer clear names over narration of *what* the code does.
- Reserve comments for things the code can't express: documenting an enum's states/semantics, or
  explaining *why* a non-obvious decision or workaround exists (the reasoning, not the mechanics).

### Plans

- Plans are drafted in `/plan` mode (an ephemeral plan file). **Once a plan is confirmed, ask the user
  whether to save a copy to `docs/PLAN_<plan_name>.md`** and, if yes, write the approved plan there
  verbatim (e.g. `docs/PLAN_DB_DUMP_SETUP.md`). Note `docs/` is gitignored (see Gotchas), so these
  copies are local-only — not committed.

### Migrations

- Prefer **fewer migration files**. Combine related schema operations into a single migration rather
  than splitting them across files — e.g. fold a new table's `searchable_title` column into its
  `create_table` instead of adding a follow-up migration.

## Request flow

Telegram updates arrive via webhook at `telegram_webhook TelegramController` (`config/routes.rb`).
In dev, use `make bot` for polling instead.

`BaseTelegramController` (`< Telegram::Bot::UpdatesController`) handles dispatch, the session, the
history stack, and current-user resolution. `TelegramController` defines every bot command (one
action per command / callback query).

A bot command action follows this shape:
1. The action calls a `BotCommands::*` operation, e.g. `BotCommands::GlobalSearch.call(...)`.
2. The operation returns an **array of message hashes**: `[{type: :message | :edit | :reply, answer: {...}}]`.
3. `AnswerProcessor#process_answer_messages` dispatches each hash to the right Telegram method
   (`:edit`→`edit_message`, `:reply`→`reply_with`, else→`respond_with`), with a `sleep(0.1)` between sends.

### Session & history

`BaseTelegramController` keeps a `history_stack` (max 30 entries) in the session, which is backed by
**solid_cache** (`config.telegram_updates_controller.session_store = :solid_cache_store`) — *not* Redis.
`remember_history!` (after-action) records the current action + input; `go_back_callback_query`
replays the previous state. Actions that must not be remembered are explicitly excluded.
`current_user` finds-or-creates a `TelegramUser` by `payload["from"]["id"]`.
`my_chat_member` updates routes to `TelegramChat::MemberChangeProcessor`.

## BotCommands & ApplicationOperation

`ApplicationOperation` (`app/models/application_operation.rb`) is a 5-line PORO — `self.call(...)` does
`new(...).call`. No dry-transaction / interactor. `BotCommands::*` and many other ops
(`Mention::*`, `MessageDistribution::Enqueue`, `TelegramChat::MemberChangeProcessor`, `Presenters::*`,
`Importers::*`) inherit it.

When an operation or model uses `ActiveModel::Validations`, name the methods registered with
`validate` with a **`check_`** or **`ensure_`** prefix (e.g. `validate :check_audience_present` in
`MessageDistribution::Enqueue`).

All bot commands live in `app/models/bot_commands/` and inherit `BaseCommand < ApplicationOperation`.
`BaseCommand` (`base_command.rb`) provides shared helpers:
- `keyboard_options(variants, forced_callback_prefix: nil, title_method: :title)` →
  `[{text:, callback_data: "<prefix>:<global_id>"}]`. Callback data convention is **`prefix:global_id`**.
- `keyboard_mentions_options(object)` → buttons with `callback_data: "pick_mention:<id>"`.
- `go_back_button` → `{text: "Назад", callback_data: "go_back:go_back"}`.
- `selected_object` → `GlobalID::Locator.locate(gid_value)&.decorate` (already decorated).
- `callback_prefix` **raises `NotImplementedError`** — every subclass must override it.
- `parse_mode` → `"HTML"`, `locale` → `"ru"`.

Filters/state for some commands (e.g. `AllSpells`) are kept in the Rails session, not the DB.

## Content models & concerns

Content models (Spell, Feat, Creature, GlossaryItem, CharacterKlass, Race/Species, Equipment,
MagicItem, Tool, Origin, Invocation, Metamagic, Maneuver, PsionicPower, ArcaneShot, Plan, WildMagic,
…) share these concerns (`app/models/concerns/`):

- **`Multisearchable`** — `pg_search` indexing. `multisearchable against: [:searchable_title]` with
  `tsearch: {dictionary: "russian"}`; `searchable_title` is rebuilt `before_validation`.
  `Multisearchable.format` normalizes text (`downcase`, strip, collapse whitespace, **`ё→е`**).
  `Multisearchable.search` unions a full-text (`tsearch`) query with a `LIKE` fallback over
  `PgSearch::Document`, ordering Spell results first.
- **`Publishable`** — records are visible to the bot only when `published_at` is set. Use scope `.published`.
- **`Mentionable`** — polymorphic cross-references between content types via `Mention` records.
- **`Segmentable`** — links a resource to characteristics via `Segment` (used by Feat).
- **`WhoDidItable`** — `created_by` / `updated_by` (AdminUser).

After bulk content edits, rebuild the search index from a Rails console using **both**:
`Multisearchable.regenerate_all_searchable_columns!` (rebuilds `searchable_title`) **and**
`Multisearchable.regenerate_all_multisearchables!` (rebuilds the pg_search documents).

## Decorators

Each content model has a `*Decorator < ApplicationDecorator` (Draper). Decorators provide
`description_for_telegram` (Markdown→HTML via `FormatChanger`, `lib/format_changer.rb`), `title`,
`global_search_title`, and `parse_mode_for_telegram`. **Always `.decorate` before sending to Telegram.**

## Background jobs

Jobs are SolidQueue-backed (`app/jobs/`). `ApplicationJob` retries `StandardError` twice (5s wait).
- `BotRequestJob` (includes `Telegram::Bot::Async::Job`) — async outbound Telegram sends.
  **Async only in production** (`config/initializers/telegram.rb`); synchronous in dev/test. Rescues
  `Forbidden`/`NotFound` (marks receiver unavailable) and ignores "message thread not found" /
  "message is not modified".
- `Telegram::{User,Chat,Spell}MetricsJob` — activity / popularity counters, fired after bot responses.
- `Feedback::NotificationJob` — forwards feedback to the Discord webhook (`ADVICE_WEBHOOK`).
- `MessageDistribution::DeliveryJob` — runs a mass broadcast (built by `MessageDistribution::Enqueue`;
  one distribution = one send). Resumable (only ever processes `pending` rows), throttled, and
  **serialized to one broadcast at a time** via SolidQueue `limits_concurrency` (Telegram's ~30 msg/sec
  global cap). Records a per-recipient `MessageDelivery` (`status` + `error_reason`); the audience is
  segmented by `MessageDistribution::Audience`.

## Admin

ActiveAdmin is at `/admin` (Devise login). Content is managed here and made bot-visible by setting
`published_at`. After bulk edits, regenerate the search index (see *Content models & concerns*).
SimpleMDE is wired for Markdown `description` fields.

## Testing

RSpec + FactoryBot, test-prof (`let_it_be`), WebMock, Timecop. Spec layout mirrors `app/`
(`spec/models/`, `spec/decorators/`, `spec/jobs/`, `spec/requests/`).

**Spec style** (see `spec/models/bot_commands/wild_magic_search_spec.rb`): each `describe`/`context`
defines its own `subject` directive, and each example varies behaviour by overriding a `let` that
feeds the subject's arguments — **not** by inlining literal arguments inside the `it` block. Put a
default `let` at the top, override it per context/example, and prefer `it { is_expected.to ... }`.
Reusable concern behaviour goes in `spec/support/shared_examples/` (e.g. `it_behaves_like
"publishable", :spell`).

- Seed data is loaded once before the suite: `rails_helper` runs `before(:suite) { Rails.application.load_seed }`.
  **But content seeders are `Rails.env.development?`-guarded** (see *Seeds & data import*), so under
  `test` only the unconditional seeds (admin users, bot commands) load — specs build their own content
  with FactoryBot, not from seeds.
- DatabaseCleaner uses the `:transaction` strategy (one `:truncation` before the suite).
- **Testing a command:** call `BotCommands::Foo.call(...)` and assert the returned answer hash/array
  (text, `reply_markup`, `parse_mode`), using `.decorate.description_for_telegram` for expected text.
- **Testing outbound sends:** mock the client — `allow(Telegram.bot).to receive(:send_message)` — then
  assert `have_received(...)`. Discord HTTP is stubbed via WebMock (`require "webmock_helper"`).
- Request specs use Devise `sign_in(admin)` and the `json_body` helper (`spec/support/api_helpers.rb`).
- **Coverage (SimpleCov):** running specs writes an HTML report to `tmp/coverage/index.html` and prints the
  line/branch % at the end of the run. SimpleCov only counts files exercised by the specs that
  **actually ran**, so the report is accurate **only after the full suite** (`bundle exec rspec`) —
  running a single spec file reports misleading, partial coverage.

## Seeds & data import

`db/seeds.rb` loads each seeder in `db/seeds/seeders/*.rb`. Bulk D&D content is imported from CSVs in
`db/seeds/data/` via `Importers::*`. Search columns are regenerated at the end of seeding in local envs.
Content seeders guard on `Rails.env.development? && Model.count == 0` (idempotent, dev-only).

## Adding a new content entity (+ a `/sections` section)

This is a repeatable recipe — `Bastion` is a complete worked example; mirror the simplest existing
model (`Maneuver`) and wire it in:

1. **Migration** (one file) — `create_<table>` with `title`, `original_title`, `description`,
   (`original_description` if bilingual), enum/`category` columns, `published_at`,
   `created_by`/`updated_by` refs, and **`searchable_title` (`null: false, default: ""`) folded in**
   (the `Multisearchable` callback fills it but does *not* create the column).
2. **Model** `app/models/<name>.rb` — `include Multisearchable, Publishable, Mentionable,
   WhoDidItable`; declare `enum`s; `scope :ordered`; strip callbacks.
3. **Decorator** `app/decorators/<name>_decorator.rb` — usually near-empty;
   `description_for_telegram` / `global_search_title` come from `ApplicationDecorator`.
4. **Locales** `config/locales/models/<name>/{ru,en}.yml` — `activerecord.models.<name>` (needed for
   the search-filters list) + enum translations under the **pluralized** enum key (e.g.
   `attributes.<name>.categories`); `human_enum_names(:category)` reads these.
5. **Admin** `app/admin/<name>s.rb` — copy an existing one (e.g. `maneuvers.rb`), add the new columns
   to index/show/form/filters/`permit_params`.
6. **Bot command** `app/models/bot_commands/<name>_search.rb < BaseCommand` — multi-level navigation
   lives in **one** command, dispatched on `input_value` (blank → top groups; an enum key/token → a
   sub-list; a GlobalID → the card). See `EquipmentSearch`/`FeatSearch`. Build buttons with
   `keyboard_options`, end every screen with `go_back_button`, override `callback_prefix`. Extra menu
   tiers that don't map to a column can be **hardcoded pseudo-layers** (string tokens kept distinct
   from enum keys).
7. **Wire `/sections`** — add `"<prefix>" => "Label"` to `BotCommands::Sections::AVAILABLE_SECTIONS`
   **and** define `<prefix>_callback_query` in `TelegramController` (the gem routes `"<prefix>:…"`
   callbacks there by prefix — no other registration). Update `sections_spec.rb`.
8. **Seeds** — `Importers::Import<Name>s` (CSV → `create!`), `db/seeds/data/<name>s.csv`,
   `db/seeds/seeders/<name>s.rb`, and a `load` line in `db/seeds.rb`.
9. **Specs + factory** — `spec/factories/<name>s.rb` (with traits), model spec (`it_behaves_like` the
   concern shared examples + validations), bot-command spec (one context per nav state), decorator spec.

A new `Multisearchable` model **auto-joins** full-text search, `/search`, and the search-filters UI
(both driven by `Multisearchable.used_klasses`) — no manual registration beyond step 4's
`model_name.human`.

## Deployment & environment

Deployed via Docker (`Dockerfile`, served through Thruster / `bin/thrust`) + **Kamal** (`kamal deploy`).
Production runs in **webhook** mode, not polling:

```bash
bundle exec rails telegram:bot:set_webhook RAILS_ENV=production   # rerun when domain or bot token changes
```

`BOT_USE_LOCALHOST=1` points the bot at a local server for dev polling.

Required env vars (`.env`, seeded from `.env.test` by `make setup`): `BOT_TOKEN`, `BOT_NAME`,
`ADVICE_WEBHOOK` (Discord), `CLOUDINARY_URL`. Production also needs `POSTGRES_*` / `DB_HOST` / `DB_PORT`,
`RAILS_MASTER_KEY`, and optionally `SENTRY_DSN`, `JOB_CONCURRENCY`.

### Monitoring (New Relic)

Two independent NR agents, both in the EU account (`6614130`):

- **APM** — the `newrelic_rpm` gem, configured in `config/newrelic.yml` (app `dnd_handbook`, EU). Baked
  into the Docker image, so it ships with the app automatically — nothing host-specific to do.
  ⚠️ the license key is currently **hardcoded** in `config/newrelic.yml` (not a secret).
- **Infrastructure (host + Docker)** — runs as a **Kamal accessory** (`accessories.newrelic` in
  `deploy.yml`): a privileged `newrelic/infrastructure-bundle` container (`--pid host`, `/:/host:ro`,
  `docker.sock`). Boot/replace it on a host with `bin/kamal accessory boot newrelic`. License key is
  `NRIA_LICENSE_KEY` (1Password → `.kamal/secrets`). Being a Kamal accessory, it travels with the config
  to any new host — not a native apt/systemd install to redo by hand on each migration.
- `.kamal/hooks/post-deploy` records a New Relic **deployment marker** via the local `newrelic-cli`
  (profile `prod_eu_6614130_change_tracking`); it no-ops if the CLI isn't installed on the deploy machine.

### Backups (Backblaze B2)

Off-host DB backups run as the **`backup` Kamal accessory** (`accessories.backup` in `deploy.yml`) —
`tiredofit/db-backup` (image tag **≥ 4.1.99** bundles the PG18 client, auto-selected). It
connects to the `dnd_handbook-db` accessory over the `kamal` network (no `docker exec`), runs a nightly
`pg_dump` of `dnd_handbook_production` → gzip → **Backblaze B2** (S3-compatible, `DB01_S3_*`), **7-day**
retention (`DB01_CLEANUP_TIME`, in minutes). A post-backup hook (`.kamal/backup/notify.sh`, mounted to
`/assets/scripts/post/`; `DB01_POST_SCRIPT_SKIP_X_VERIFY=TRUE`) POSTs a **Discord** embed on every run
(success/failure) and, if `BACKUP_HEALTHCHECK_URL` is set, pings **healthchecks.io** as a dead-man's-switch
(the "never ran at all" case the hook itself can't report).

- Boot/replace on a host: `bin/kamal accessory boot backup` (travels with the config like New Relic —
  no host-side cron/rclone to redo per migration). Logs: `bin/kamal backup-logs`.
- On-demand run: `bin/kamal backup-now` (alias) or `bin/kamal accessory exec backup "backup-now"`.
- Restore (break-glass / verify): `bin/db-restore-local <dump.sql.gz> [db]` (into your local Postgres)
  or `bin/db-restore-remote <dump.sql.gz> [db] [ssh_host]` (onto the prod host via SSH). Restore into a
  **scratch** DB first to confirm a backup is good (an untested backup isn't a backup). A **local**
  restore needs your local PG ≥ the dump's server major (modern Postgres dumps emit newer syntax like
  `SET transaction_timeout` that older servers reject).
- Secrets via 1Password (`DND_BOTS/DND_HANDBOOK`): `B2_KEY_ID`, `B2_APP_KEY`, `BACKUP_DISCORD_WEBHOOK`
  (+ optional `BACKUP_HEALTHCHECK_URL`); `DB01_PASS` reuses `POSTGRES_PASSWORD`. ⚠️ add the 1Password fields
  **before** referencing them in `.kamal/secrets` (else every secret-reading kamal command fails).
- Full setup walkthrough (B2 bucket, Discord webhook, healthchecks.io): `docs/PLAN_DB_DUMP_SETUP.md`.

## MCP servers

`.mcp.json` (committed) configures the Model Context Protocol servers available to Claude Code in
this repo.

- **`sentry`** — the official Sentry remote MCP (`mcp.sentry.dev`), with the URL **pinned to this
  project's org/project slug** so every tool call is scoped to *this* project only. Gives read access
  to production issues, stack traces, events, and Seer root-cause analysis. **First use is
  interactive:** run `/mcp`, pick `sentry`, complete the one-time OAuth sign-in in the browser.
  Read-only / interactive — not wired for unattended (cron/CI) runs.
- **`newrelic`** — the official New Relic remote MCP, on the **EU endpoint** (`mcp.eu.newrelic.com`, to
  match the EU account `6614130` — the US URL won't work). HTTP transport, OAuth; **first use is
  interactive:** `/mcp` → `newrelic` → one-time browser sign-in. Exposes NRQL + entity/alert tools
  (tags `data-access` / `discovery` / `alerting`), so metrics **and** logs (`FROM Log`) and traces are
  queryable for incident investigation. The server doesn't enforce read-only — sign in as a
  least-privilege (read-only) NR user. Interactive — not wired for unattended (cron/CI) runs.

## Skills

Project skills live in `.claude/skills/` (committed); `skills-lock.json` pins the installed versions
(managed via `npx skills`).

- **`sentry-fix-issues`** — a structured debug→root-cause→fix workflow for production errors. It sits
  **on top of** the `sentry` MCP (it calls those tools), so the MCP above must be connected first.
  Ask things like "find the root cause of this Sentry issue and fix it."

## Gotchas

- **`docs/` is gitignored on purpose** — everything under it (plan copies like `PLAN_*.md`, runbooks
  like `HOSTING_MIGRATION.md`) is local-only working notes, **not** in git history; don't `git add` it.
- A **Postgres major upgrade** (e.g. 18→19) is **not** just bumping the `db` accessory image tag:
  `postgres:N` won't start on an older major's data dir (`accessories.db` → `directories: data:…`). It
  needs a logical migration — `pg_dump` from the old major → boot the new image on an **empty** data
  dir → restore. The `backup` accessory / `bin/db-restore-*` are exactly this tooling. Runbook for the
  procedure: `docs/UPGRADING_POSTGRES.md`.
- **`postgres:18`+ changed the data-dir mount convention** (docker-library PR #1259): the volume must
  mount at **`/var/lib/postgresql`** (the image then stores the cluster in a version subdir,
  `…/18/docker`), **NOT** at `/var/lib/postgresql/data` as pre-18 images used — mounting at the old path makes the
  image refuse to start in a **restart loop**. Prod `accessories.db` is `directories: - data:/var/lib/postgresql`
  (host cluster lives in `dnd_handbook-db/data/18/docker`). This bites every future major bump too.
- The Telegram session / `history_stack` is in **solid_cache**, not Redis.
- Rebuilding search needs **two** calls — `regenerate_all_searchable_columns!` *and*
  `regenerate_all_multisearchables!`.
- A new `BotCommands` subclass must override `callback_prefix` or it raises `NotImplementedError`.
- A new table's `searchable_title` column is **yours to create** (fold it into `create_table`); the
  `Multisearchable` `before_validation` only *populates* it.
- `DISTINCT … pluck` on a `Multisearchable` model collides with the `ordered` scope's `ORDER BY title`
  (PG: *"ORDER BY expressions must appear in select list"*) — pluck off an unordered scope.
- Multi-database app: `db:migrate:redo` (and similar) need the namespace, e.g.
  `bin/rails db:migrate:redo:primary VERSION=…`.
- `make bot` is dev-only — production delivery is webhook-based.
- Outbound Telegram sends go through `BotRequestJob` **async in production**, so `Telegram.bot.send_message`
  returns immediately and you can't observe its result/error. To send synchronously and capture the
  outcome (e.g. per-recipient delivery tracking), wrap it in `Telegram.bot.async(false) { ... }`.
- `.kamal/secrets` fetches **all** referenced secrets from the 1Password item (`DND_BOTS/DND_HANDBOOK`)
  in one `kamal secrets fetch`. Adding a name there (e.g. `NRIA_LICENSE_KEY`) requires that field to
  exist in the item, or **every** secret-reading kamal command (including `deploy`) fails — add the
  1Password field first.
- Kamal **hooks run on the deploy machine, not the servers**: `.kamal/hooks/docker-setup` SSHes into the
  host to do remote setup, and `post-deploy` shells out to the local `newrelic-cli`.
