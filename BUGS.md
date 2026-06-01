# Known bugs

Issues surfaced while writing the test suite (branch `specs-infra-and-exemplars`). The specs
currently **document the actual (buggy) behaviour** so the suite stays green — fixing any of these
will require updating the corresponding spec expectations.

---

## 1. Search-result keyboards emit a *decorator* GlobalID in `callback_data`

**Severity:** low–medium (works today by accident; fragile and inconsistent)

**Where:**
- `app/models/bot_commands/spell_search.rb:79-95` (`render_search_results` maps `found_spells`,
  which are already `.decorate`d, then builds `callback_data: "spell:#{item.to_global_id}"`).
- `app/models/bot_commands/base_command.rb:36-44` (`keyboard_options` calls `variant.to_global_id`;
  several commands pass already-decorated variants).
- Same pattern in `arcane_shots_search`, `invocations_search`, `maneuvers_search`,
  `metamagics_search`, `plans_search`, `psionic_powers_search` (all do `scope.map(&:decorate)`),
  and the "Базовый класс"/section-info buttons in `origin_search` / `tool_search` /
  `character_klass_search` that call `selected_object.to_global_id` /
  `BotCommand.x.decorate.to_global_id`.

**Problem:** Draper decorators define their own `to_global_id`, so a decorated record yields
`gid://app/SpellDecorator/1` instead of `gid://app/Spell/1`. The keyboard therefore stores a
`*Decorator` GID in `callback_data`.

**Evidence:**
```ruby
spell.to_global_id            # => gid://app/Spell/2
spell.decorate.to_global_id   # => gid://app/SpellDecorator/2
GlobalID::Locator.locate("gid://app/SpellDecorator/2", only: ::Spell) # => nil
```

**Why it "works" anyway:** Draper overrides `is_a?`/`kind_of?`, so for commands that locate
**without** an `only:` filter the returned decorator passes the `is_a?(::Model)` selection guard and
round-trips. But:
- It is **inconsistent**: sibling commands that build keyboards from *raw* AR records emit plain
  `gid://app/<Model>/<id>`, while the ones above emit `*Decorator` GIDs. The callback_data type is
  accidental and differs across commands.
- It is **brittle**: any consumer that locates with `only: ::Model` (see bug #2-adjacent code) gets
  `nil`. `SpellSearch#selected_spell` itself uses `GlobalID::Locator.locate(spell_gid, only: ::Spell)`
  (`spell_search.rb:97-99`), so a decorator GID would *not* resolve there.

**Suggested fix:** build `callback_data` from the **undecorated** record's GID, e.g. map over raw AR
records and decorate only for display (`item.object.to_global_id`, or don't decorate before taking
the GID). Normalise across all commands so callback_data is always `gid://app/<Model>/<id>`.

---

## 2. The "not found" branch is effectively unreachable for deleted records

**Severity:** low (degraded UX edge case)

**Where:**
- `app/models/bot_commands/base_command.rb:61-67` (`selected_object` → `GlobalID::Locator.locate(gid_value)&.decorate`).
- `app/models/bot_commands/global_search.rb:30-39` (`record_not_found` message branch) and
  `:31` (`record_gid.present? && selected_object.present?`).

**Problem:** `GlobalID::Locator.locate` raises `ActiveRecord::RecordNotFound` for a **valid but
deleted** GID (e.g. `gid://app/Spell/0`) rather than returning `nil`. The `&.decorate` / `.present?`
guard only protects against a `nil` return, which happens only for a **malformed** GID string. So:
- A stale/deleted GID → unhandled `RecordNotFound` (bubbles up / Sentry), not the friendly
  "не найдено" message.
- The `record_not_found` branch only ever fires for malformed input.

**Evidence:** `GlobalID::Locator.locate("gid://app/Spell/0", only: Spell)` raises
`ActiveRecord::RecordNotFound`, whereas `locate("not-a-valid-gid")` returns `nil`.

**Suggested fix:** rescue `ActiveRecord::RecordNotFound` in `selected_object` (return `nil`), or use a
non-raising lookup, so the existing "not found" message handles deleted records too. This is in the
shared `BaseCommand`, so the fix benefits every command using `selected_object`.

---

## 3. `Telegram::SpellMetricsJob` rejects a `GlobalID` argument

**Severity:** low (latent; prod passes a String so it works today)

**Where:**
- `app/jobs/telegram/spell_metrics_job.rb` (`perform(spell_gid:)`).
- Callers: `app/controllers/telegram_controller.rb:76` and
  `app/models/bot_commands/global_search.rb:133` — both currently pass `spell_gid` as a **String**
  (the raw callback value), so the job enqueues fine in production.

**Problem:** ActiveJob can serialise a String GID but **not** a `GlobalID` object. If a caller ever
passes the `GlobalID` instance instead of its `.to_s`, enqueueing raises:
```
ActiveJob::SerializationError: Unsupported argument type: GlobalID
```

**Suggested fix:** normalise to a string at the boundary — `perform_later(spell_gid: gid.to_s)` in
callers, and/or `GlobalID::Locator.locate(spell_gid.to_s, only: Spell)` inside the job — so the job
is robust regardless of caller arg type. (`GlobalID::Locator.locate` accepts either, but the
serializer is the constraint.)

---

## 4. Unhandled action errors return HTTP 500, so Telegram redelivers the update without limit

**Severity:** medium (one failing update is amplified into hundreds of identical events; inflates
Sentry counts and reprocesses the same erroring request repeatedly)

**Where:**
- `app/controllers/base_telegram_controller.rb:86-96` (`set_sentry_context` around-action — captures
  context then `raise e`, with **no `rescue_from` anywhere** in the controllers).
- Webhook entry point: `config/routes.rb:16` (`telegram_webhook TelegramController`).
- Reproducible via the admin `/error` command: `app/controllers/telegram_controller.rb:109-111` →
  `app/models/bot_commands/error.rb:10` (`raise TestError`).

**Problem:** When a bot action raises, the exception escapes the controller (the around-action
re-raises and nothing rescues it), so Rails answers the webhook with **HTTP 500**. Telegram retries
delivery of any update that gets a non-2xx response, so a **single** user action turns into an
ever-growing stream of identical events until Telegram eventually gives up.

**Evidence:** A single production `/error` invocation produced 100+ events and kept climbing
(Sentry issue `DND-HANDBOOK-3Q`). The 500 response is visible in the event's trace context:
```
"http.response.status_code": 500
```
The same 500 appears on unrelated pre-existing issues (e.g. the `NoMethodError` issue
`DND-HANDBOOK-3H`), confirming this affects **every** unhandled action-path exception, not just the
test command.

**Not the cause — the sending job:** the obvious suspect, `BotRequestJob`, is **not** involved here.
The `/error` stacktrace is a pure synchronous web-request path (Puma → Rack → controller → `raise`)
with no ActiveJob/SolidQueue frames — the action raises before any send is enqueued. And the job is
already bounded: `app/jobs/bot_request_job.rb:4` uses `retry_on Exception, attempts: 2` (at most 2
tries, though broad in *what* it catches).

**Suggested fix:** make the webhook always answer 2xx and report errors out-of-band. In
`set_sentry_context`, instead of `raise e`, call `Sentry.capture_exception(e)` and return `nil` so
the action completes 200 and Telegram stops redelivering. This caps delivery at one attempt while
keeping full Sentry visibility. It only catches `StandardError` (`rescue =>`), so genuinely fatal
errors still surface. Note this is a deliberate **webhook-wide** behaviour change (all action errors
become swallowed-and-reported, not just `/error`).

---

### Note on test data
None of the above are caused by the test setup. The suite excludes seed-time execution from coverage
(`spec/rails_helper.rb`) and the bugs reproduce against plain factory data.
