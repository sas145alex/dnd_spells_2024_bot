# Project Skills — TODO

Ideas for project-level skills to add under `.claude/skills/`. This codebase is highly
convention-driven with a lot of parallel, near-identical boilerplate, which is exactly where
project skills pay off. Priorities below reflect frequency of use × error-proneness × time saved.

| Priority | Skill | Effort to build | Status |
| --- | --- | --- | --- |
| **P0** | `new-bot-command` | Medium | Not started |
| **P1** | `new-content-type` | High | Not started |
| **P2** | `run-bot-local` | Low | Not started |
| — | ~~`reindex-search`~~ | — | Skip (see below) |
| — | ~~`spec-style`~~ | — | Skip (see below) |

---

## P0 — `new-bot-command`

**Highest value.** Most frequent action, and the conventions are crisp enough to nail on the
first try (the `*_search.rb` commands prove the template is stable).

Scaffolds a new `BotCommands::X < BaseCommand`, the matching `TelegramController` action +
callback routing, and a spec in the house style.

Should bake in the easy-to-get-wrong details:
- Override `callback_prefix` (otherwise raises `NotImplementedError`).
- Return an **array of message hashes** (`:message` / `:edit` / `:reply`).
- `options.in_groups_of(2, false)` + `go_back_button` + `reply_markup` shape.
- `.decorate` before sending to Telegram.
- `remember_history!` inclusion/exclusion.
- Spec style: subject per `describe`, vary args via `let`-overrides per example (not inline literals).

Model it on `arcane_shots_search.rb` (the simplest two-state flow).

## P1 — `new-content-type`

**Biggest footprint / most error-prone copy-paste.** One D&D content type touches ~6 layers,
all following a fixed convention. More involved to build well, but the biggest time-saver.

Fans out a full new content type end-to-end:
- Model with shared concerns (`Multisearchable`, `Publishable`, `Mentionable`, `Segmentable`,
  `WhoDidItable` as applicable).
- `*Decorator < ApplicationDecorator` with `description_for_telegram`, `title`, etc.
- ActiveAdmin registration (`app/admin/*.rb`).
- FactoryBot factory.
- Specs using `it_behaves_like "publishable"` and the house spec style.
- `Importers::Import*` stub.
- Reminder to regenerate the search index after seeding (the two-call gotcha).

## P2 — `run-bot-local`

**Medium value.** Thin skill capturing how to actually exercise a command locally so you don't
fall into the webhook-vs-polling / async-only-in-prod confusion.

- `make web` (Puma dev), `make bot` (polling, **dev-only**), `make jobs` (SolidQueue worker).
- `BOT_USE_LOCALHOST=1` to point at a local server.
- How to feed a fake update to a command.
- Note: async outbound sends are **production-only**; synchronous in dev/test.

The built-in `/run` and `/verify` are generic; a project skill that knows the Make targets and
the webhook-vs-polling split is faster.

---

## Skipped (deliberately)

- **`reindex-search`** — real gotcha (`Multisearchable.regenerate_all_searchable_columns!` +
  `regenerate_all_multisearchables!`), but it's two console lines already in CLAUDE.md. Better as
  a one-liner rake task than a skill.
- **`spec-style`** — the strict subject/`let`-override convention is already covered by CLAUDE.md,
  a saved memory, and the built-in `/code-review` + `/simplify`. A skill would just duplicate it.
