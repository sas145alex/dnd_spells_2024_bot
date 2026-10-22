#!/usr/bin/env bash
# Post-backup hook for the `backup` Kamal accessory (nfrastack/db-backup 5.x).
# Wired via DB01_POST_COMMAND and run after EVERY backup with metadata in env vars (no args):
#   DBB_KIND (backup|maintain)  DBB_STATUS (ok|failed)  DBB_NAME  DBB_HOST  DBB_FILENAME
# The container env (BACKUP_* secrets) is inherited.
#
# It POSTs a Discord embed (green ok / red fail) to $BACKUP_DISCORD_WEBHOOK and, when
# $BACKUP_HEALTHCHECK_URL is set, pings healthchecks.io ($URL on success, $URL/fail on failure)
# as a dead-man's-switch — the one failure mode a post-hook can't self-report is "the
# backup never ran at all", which healthchecks catches.
#
# DBB_STATUS starts as `failed` and flips to `ok` only after dump + upload both succeed, so it alone
# covers a failed upload (4.x needed a separate upload exit code for that).
set -u

# Maintenance runs fire post hooks too; only backups should post an embed.
[ "${DBB_KIND:-backup}" = "backup" ] || exit 0

status="${DBB_STATUS:-failed}"
db_name="${DBB_NAME:-?}"
filename="${DBB_FILENAME:-?}"

if [ "$status" = "ok" ]; then
  title="✅ DB backup OK"
  color=5763719
  hc_suffix=""
  desc="DB: ${db_name}\\nFile: ${filename}"
else
  title="❌ DB backup FAILED"
  color=15548997
  hc_suffix="/fail"
  desc="DB: ${db_name}\\nStatus: ${status}\\nCheck: kamal accessory logs backup"
fi

if [ -n "${BACKUP_DISCORD_WEBHOOK:-}" ]; then
  payload=$(printf '{"embeds":[{"title":"%s","description":"%s","color":%s}]}' "$title" "$desc" "$color")
  curl -fsS -m 15 -H "Content-Type: application/json" -d "$payload" "$BACKUP_DISCORD_WEBHOOK" >/dev/null 2>&1 || true
fi

if [ -n "${BACKUP_HEALTHCHECK_URL:-}" ]; then
  curl -fsS -m 15 "${BACKUP_HEALTHCHECK_URL}${hc_suffix}" >/dev/null 2>&1 || true
fi

exit 0
