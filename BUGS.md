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

## 5. Unrescued outbound Telegram errors on the synchronous webhook path → HTTP 500 → redelivery

**Severity:** high (two of the largest error volumes in the project; because each failing update is
re-sent by Telegram — see bug #4 — a single stuck chat produces thousands of identical events)

**Where:**
- `app/models/telegram_chat/leave_chat.rb:8-17` — `call` runs `client.async(false) { bot.send_message(...); bot.leave_chat(...) }`
  and rescues **only** `Telegram::Bot::Forbidden`. Reached synchronously from the `my_chat_member`
  webhook: `app/controllers/base_telegram_controller.rb:34-36` → `MemberChangeProcessor#leave_chat!`
  (`app/models/telegram_chat/member_change_processor.rb:46-48`).
- `app/controllers/base_telegram_controller.rb:72-80` — `bot_has_admin_right_in_chat?` calls
  `bot.get_chat_member(...)` inside `client.async(false)` with **no rescue at all**; invoked from the
  `message` action (`base_telegram_controller.rb:49`).

**Problem:** outbound Telegram calls made *synchronously* in the webhook request only handle a narrow
exception set, so the common race conditions escape the controller:
- In `LeaveChat`, sending the farewell message raises `Telegram::Bot::Error: Bad Request: need
  administrator rights in the channel chat` when the bot's admin rights were revoked between the
  `my_chat_member` notification and the send — not a `Forbidden`, so it is **not** rescued.
- In `bot_has_admin_right_in_chat?`, `getChatMember` raises `Telegram::Bot::Forbidden: bot is not a
  member of the supergroup chat` when the bot was removed from the group — nothing rescues it.

Either way the exception escapes → Rails answers the webhook with **HTTP 500** → Telegram redelivers
the same update repeatedly (the amplification mechanism documented in bug #4). These are normal,
expected Telegram states (rights revoked / bot removed), not exceptional faults.

**Evidence:**
- `DND-HANDBOOK-33` — `Telegram::Bot::Error: … need administrator rights in the channel chat`,
  **~6.8k events** since 2025-09-21, culprit `leave_chat.rb:12`, synchronous webhook path.
- `DND-HANDBOOK-1S` — `Telegram::Bot::Forbidden: bot is not a member of the supergroup chat`,
  **~2.1k events** since 2025-01-11, culprit `base_telegram_controller.rb:76`.
- The same `leave_chat.rb:12` send also produced one-off `Errno::ENETUNREACH` (`DND-HANDBOOK-3M`) and
  `HTTPClient::ConnectTimeoutError` (`DND-HANDBOOK-3P`) — transient network blips, but they confirm
  that **any** error class raised on that synchronous send escapes and is eligible for redelivery
  amplification.

**Suggested fix:** rescue the expected Telegram conditions at the point of the synchronous send and
treat them as no-ops (the chat is already gone / inaccessible). In `LeaveChat#call`, broaden the
rescue to `Telegram::Bot::Error` (and transient network errors such as `Errno::ENETUNREACH` /
`HTTPClient::ConnectTimeoutError`) alongside the existing `Forbidden`; in
`bot_has_admin_right_in_chat?`, rescue `Telegram::Bot::Forbidden` / `Telegram::Bot::Error` and return
`false`. This stops the 500s for these specific paths even without bug #4's webhook-wide safety net
(which would also cover them).

---

## 6. `BotRequestJob` re-raises every non-whitelisted `Telegram::Bot::Error` (TOPIC_CLOSED storm)

**Severity:** high (the single highest event volume in the project, ~10.7k)

**Where:**
- `app/jobs/bot_request_job.rb:14-25` — the `rescue Telegram::Bot::Error` branch only swallows
  messages matching `"message thread not found"` or `"message is not modified"`; every other message
  hits the `else … raise` at `:24`.
- `app/jobs/bot_request_job.rb:4` — `retry_on Exception, attempts: 2`, so a re-raised error is also
  retried once before the job fails and is reported to Sentry.

**Problem:** sending a message to a forum **topic that has since been closed** raises
`Telegram::Bot::Error: Bad Request: TOPIC_CLOSED`. This runs in the async `BotRequestJob` (not the
webhook, so it is **not** amplified by bug #4), but `TOPIC_CLOSED` is an expected, recurring delivery
failure that is not in the whitelist — so it re-raises, burns both retry attempts, and is reported
every single time. The huge count comes from recurrence across many groups with closed topics,
multiplied by the doubled retry attempts.

**Evidence:** `DND-HANDBOOK-2R` — `Telegram::Bot::Error: Bad Request: TOPIC_CLOSED`, **~10.7k events**
since 2025-04-16, culprit `bot_request_job.rb:8`, async SolidQueue frames; enqueued args show a
`sendMessage` with a `message_thread_id`.

**Suggested fix:** add `TOPIC_CLOSED` (and probably other expected delivery-failure messages such as
`"chat not found"`) to the swallow list in the `Telegram::Bot::Error` branch — log and return `nil`
like the existing `"message thread not found"` / `"message is not modified"` cases — so sends to
closed topics are dropped instead of retried and reported.

---

## 7. `MemberChangeProcessor#current_bot_affected?` crashes on a nil `new_chat_member`

**Severity:** low–medium (only 3 events, but it is a genuine code crash that 500s the webhook and is
then redelivered per bug #4 — which already cites this issue as *evidence*; this entry documents the
underlying cause)

**Where:**
- `app/models/telegram_chat/member_change_processor.rb:50-55` — `current_bot_affected?` calls
  `new_chat_member.dig("user", "is_bot")` (`:51`).
- `app/models/telegram_chat/member_change_processor.rb:77-79` — `new_chat_member` is just
  `payload["new_chat_member"]`, which is `nil` when the key is absent.
- `app/models/telegram_chat/member_change_processor.rb:81-86` — `send_error_to_sentry` has the same
  latent nil deref: it reads `new_chat_member["status"]` for both the raise message and the Sentry
  `extra`.

**Problem:** the `my_chat_member` handler assumes the payload always carries `new_chat_member`. For
an update shape that omits it (or a malformed / partial payload), `new_chat_member` is `nil` and line
51 raises `NoMethodError: undefined method 'dig' for nil`. The exception escapes the controller →
HTTP 500 → redelivery (bug #4).

**Evidence:** `DND-HANDBOOK-3H` — `NoMethodError: undefined method 'dig' for nil`, 3 events, culprit
`member_change_processor.rb:51`, synchronous webhook path. (Also referenced as evidence in bug #4.)

**Suggested fix:** guard early — `return false if new_chat_member.blank?` at the top of
`current_bot_affected?` — so membership updates without a `new_chat_member` are ignored instead of
crashing, and make `send_error_to_sentry` nil-safe for the same reason.

---

## 8. `about!` action arity mismatch with history replay

**Severity:** low (1 event; latent)

**Where:**
- `app/controllers/telegram_controller.rb:79-82` — `def about!` takes **zero** parameters, unlike the
  sibling actions that use `(*args)` / `(input_value = nil, *_args)`.
- `about!` is **not** in the `remember_history!` skip list (`telegram_controller.rb:9-26`), so it is
  recorded in the history stack and later replayed by
  `go_back_callback_query` via `send(history_item[:action], history_item[:input_value])`
  (`telegram_controller.rb:237`), which always passes one argument.

**Problem:** when a user navigates "back" to a remembered `about!` state, the replay calls
`about!("<input_value>")`, raising `ArgumentError: wrong number of arguments (given 1, expected 0)`
→ HTTP 500 → redelivery (bug #4).

**Evidence:** `DND-HANDBOOK-3N` — `ArgumentError: wrong number of arguments (given 1, expected 0)`,
1 event, culprit `telegram_controller.rb:79`, replayed from a `go_back:go_back` callback.

**Suggested fix:** give `about!` the same tolerant signature as the other actions —
`def about!(*_args)` — so history replay can pass an argument harmlessly. (Audit other actions for
the same zero-arity pattern while at it.)

---

### Note on test data
None of the above are caused by the test setup. The suite excludes seed-time execution from coverage
(`spec/rails_helper.rb`) and the bugs reproduce against plain factory data.
