# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working in this repository.

This is a **Rails 8 Telegram bot — a D&D 5e (2024) reference**, with an ActiveAdmin backend for
managing content. Bot replies are in Russian; D&D terms are bilingual (RU title + EN `original_title`).

## Tech stack

| Concern | Choice |
| --- | --- |
| Language / framework | Ruby **3.4.4** (`.ruby-version`), Rails **8.0.2** |
| Database | PostgreSQL 16 |
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
(`Mention::*`, `MessageDistribution::Send`, `TelegramChat::MemberChangeProcessor`, `Presenters::*`,
`Importers::*`) inherit it.

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

## Admin

ActiveAdmin is at `/admin` (Devise login). Content is managed here and made bot-visible by setting
`published_at`. After bulk edits, regenerate the search index (see *Content models & concerns*).
SimpleMDE is wired for Markdown `description` fields.

## Testing

RSpec + FactoryBot, test-prof (`let_it_be`), WebMock, Timecop. Spec layout mirrors `app/`
(`spec/models/`, `spec/decorators/`, `spec/jobs/`, `spec/requests/`).

- Seed data is loaded once before the suite: `rails_helper` runs `before(:suite) { Rails.application.load_seed }`.
- DatabaseCleaner uses the `:transaction` strategy (one `:truncation` before the suite).
- **Testing a command:** call `BotCommands::Foo.call(...)` and assert the returned answer hash/array
  (text, `reply_markup`, `parse_mode`), using `.decorate.description_for_telegram` for expected text.
- **Testing outbound sends:** mock the client — `allow(Telegram.bot).to receive(:send_message)` — then
  assert `have_received(...)`. Discord HTTP is stubbed via WebMock (`require "webmock_helper"`).
- Request specs use Devise `sign_in(admin)` and the `json_body` helper (`spec/support/api_helpers.rb`).

## Seeds & data import

`db/seeds.rb` loads each seeder in `db/seeds/seeders/*.rb`. Bulk D&D content is imported from CSVs in
`db/seeds/data/` via `Importers::*`. Search columns are regenerated at the end of seeding in local envs.

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

## Gotchas

- The Telegram session / `history_stack` is in **solid_cache**, not Redis.
- Rebuilding search needs **two** calls — `regenerate_all_searchable_columns!` *and*
  `regenerate_all_multisearchables!`.
- A new `BotCommands` subclass must override `callback_prefix` or it raises `NotImplementedError`.
- `make bot` is dev-only — production delivery is webhook-based.
