#!/usr/bin/env bash
# Post-backup hook for the `backup` Kamal accessory (tiredofit/db-backup).
# Mounted to /assets/scripts/post/ and run after EVERY backup with positional args:
#   $1 exit_code  $2 db_type  $3 db_host  $4 db_name  $5 start  $6 finish
#   $7 duration_s $8 filename $9 filesize $10 hash    $11 move_exit_code
#
# It POSTs a Discord embed (green ok / red fail) to $BACKUP_DISCORD_WEBHOOK and, when
# $BACKUP_HEALTHCHECK_URL is set, pings healthchecks.io ($URL on success, $URL/fail on failure)
# as a dead-man's-switch — the one failure mode a post-hook can't self-report is "the
# backup never ran at all", which healthchecks catches.
set -u

exit_code="${1:-1}"
db_name="${4:-?}"
duration="${7:-?}"
filename="${8:-?}"
filesize="${9:-?}"

if [ "$exit_code" = "0" ]; then
  title="✅ DB backup OK"
  color=5763719
  hc_suffix=""
  desc="DB: ${db_name}\\nFile: ${filename}\\nSize: ${filesize}\\nDuration: ${duration}s"
else
  title="❌ DB backup FAILED"
  color=15548997
  hc_suffix="/fail"
  desc="DB: ${db_name}\\nExit code: ${exit_code}\\nCheck: kamal accessory logs backup"
fi

if [ -n "${BACKUP_DISCORD_WEBHOOK:-}" ]; then
  payload=$(printf '{"embeds":[{"title":"%s","description":"%s","color":%s}]}' "$title" "$desc" "$color")
  curl -fsS -m 15 -H "Content-Type: application/json" -d "$payload" "$BACKUP_DISCORD_WEBHOOK" >/dev/null 2>&1 || true
fi

if [ -n "${BACKUP_HEALTHCHECK_URL:-}" ]; then
  curl -fsS -m 15 "${BACKUP_HEALTHCHECK_URL}${hc_suffix}" >/dev/null 2>&1 || true
fi

exit 0
