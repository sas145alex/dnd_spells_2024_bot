# Known bugs

Issues surfaced while writing the test suite (branch `specs-infra-and-exemplars`). The specs
currently **document the actual (buggy) behaviour** so the suite stays green — fixing any of these
will require updating the corresponding spec expectations.

---

## 1. ~~Search-result keyboards emit a *decorator* GlobalID in `callback_data`~~ — FIXED

**Fixed:** `ApplicationDecorator` now overrides `to_global_id` / `to_gid` / `to_gid_param` to
delegate to the underlying `object`, so every decorated record yields `gid://app/<Model>/<id>`.
Keyboard `callback_data` is now consistent across all commands and round-trips through
`GlobalID::Locator.locate(..., only: <Model>)`. This had two silent consequences before the fix:
selecting a `/spell` search result reported "не найдено" (`SpellSearch#selected_spell` uses
`only: ::Spell`), and `Telegram::SpellMetricsJob` (also `only: Spell`) dropped every spell opened
via `/search`, so `requested_count` never incremented. Regression specs cover both round-trips.

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

## 3. ~~`Telegram::SpellMetricsJob` rejects a `GlobalID` argument~~ — FIXED

**Fixed:** callers now coerce the arg to a String before enqueue —
`perform_later(spell_gid: spell_gid.to_s)` in `app/controllers/telegram_controller.rb` and
`perform_later(spell_gid: record_gid.to_s)` in `app/models/bot_commands/global_search.rb`. ActiveJob
serialises arguments at *enqueue* time and a bare `GlobalID` instance is not a serialisable type, so
the real fix lives at the caller boundary; the in-job
`GlobalID::Locator.locate(spell_gid.to_s, only: Spell)` (`app/jobs/telegram/spell_metrics_job.rb`) is
a defensive guard. The job now enqueues without raising
`ActiveJob::SerializationError: Unsupported argument type: GlobalID` regardless of whether a caller
holds a String or a `GlobalID`. This was latent (prod always passed Strings); a Sentry sweep found no
events for it.

---

## 4. ~~Unhandled action errors return HTTP 500, so Telegram redelivers the update without limit~~ — FIXED

**Fixed:** `set_sentry_context` (`app/controllers/base_telegram_controller.rb`) now reports the error
out-of-band — `Sentry.capture_exception(e)` + `Rails.logger.error(e)` — and **only re-raises when not
in webhook mode** (`raise e unless webhook_mode?`), returning `nil` otherwise so the action completes
**200** and Telegram stops redelivering. The mode check uses the gem's own signal rather than
`Rails.env`: `webhook_mode?` is `webhook_request.present?`, and `webhook_request` is set by
telegram-bot only on the webhook path (nil under the `make bot` poller) — so polling and the test
suite still surface errors by raising, while the production webhook caps delivery at one attempt.
It still only catches `StandardError` (`rescue =>`), so genuinely fatal errors surface. This is a
deliberate **webhook-wide** behaviour change (all action errors become swallowed-and-reported, not
just `/error`); as a side effect it also caps the redelivery amplification for the synchronous-path
errors in bug #5 (whose narrow per-call rescues are still worth doing). Verified that the
swallow path does **not** leak into analytics: `after_action` callbacks (`track_user_activity`,
`remember_history!`) are nested inside the around-action's `yield`, so an errored action still skips
them. Regression spec: `spec/requests/telegram_error_command_spec.rb` (poller-mode still raises;
new webhook-mode context asserts no raise + `Sentry.capture_exception`). The original amplification
was confirmed in `DND-HANDBOOK-3Q` (one `/error` → 189 events, trace
`"http.response.status_code": 500`); the same 500 affected every unhandled action-path exception
(e.g. `DND-HANDBOOK-3H`).

---

## 5. Unrescued outbound Telegram errors on the synchronous webhook path → HTTP 500 → redelivery

**Severity:** high (two of the largest error volumes in the project; because each failing update is
re-sent by Telegram — see bug #4 — a single stuck chat produces thousands of identical events)

**Status:** the `LeaveChat` half is **FIXED** (see below); the `bot_has_admin_right_in_chat?` half
remains **open but mitigated** by bug #4 (returns HTTP 200, no redelivery — only Sentry noise).

**Where:**
- ~~`app/models/telegram_chat/leave_chat.rb:8-17`~~ — **FIXED.** `call` now rescues
  `Telegram::Bot::Error` (was only `Telegram::Bot::Forbidden`), logs a one-liner via
  `Rails.logger.info`, and returns `nil`. Since `Forbidden < Error` and `NotFound < Error`, this
  covers the "need administrator rights in the channel chat" `Error`, `Forbidden`, and `NotFound`
  raised on the farewell send / leave — all expected states (chat already gone / rights revoked).
  Reached synchronously from the `my_chat_member` webhook:
  `app/controllers/base_telegram_controller.rb:34-36` → `MemberChangeProcessor#leave_chat!`
  (`app/models/telegram_chat/member_change_processor.rb:46-48`). It does **not** rescue transient
  network errors (`Errno::ENETUNREACH` / `HTTPClient::ConnectTimeoutError`) — those now surface
  harmlessly capped at HTTP 200 by bug #4. Regression spec:
  `spec/models/telegram_chat/leave_chat_spec.rb` ("when the send raises a non-Forbidden Telegram
  error"). Closes `DND-HANDBOOK-33` (~6.9k events).
- `app/controllers/base_telegram_controller.rb:72-80` — `bot_has_admin_right_in_chat?` calls
  `bot.get_chat_member(...)` inside `client.async(false)` with **no rescue at all**; invoked from the
  `message` action (`base_telegram_controller.rb:49`). **Left as-is on purpose:** this is the admin
  *check* guard, not a leave operation, so rescuing it would force a return value (`false` → fall
  through to `respond_with`/`search!`) and change control flow. Already mitigated by bug #4
  (`DND-HANDBOOK-1S`, ~2.1k events — now HTTP 200, resolve manually later).

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
rescue to `Telegram::Bot::Error` alongside the existing `Forbidden` — **done**, transient network
errors deliberately left to surface under bug #4's HTTP-200 cap. The `bot_has_admin_right_in_chat?`
half was intentionally **not** changed: rescuing it would force a return value and alter the
`message` action's control flow, so it is left to bug #4's webhook-wide safety net
(which would also cover them).

---

### Note on test data
None of the above are caused by the test setup. The suite excludes seed-time execution from coverage
(`spec/rails_helper.rb`) and the bugs reproduce against plain factory data.
