#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

subject="${1:-Self-healing infrastructure alert}"
message="${2:-No details provided}"
sent=0

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

log_message "ALERT" "$subject - $message"

if [[ -n "$ALERT_EMAIL" ]] && command -v mail >/dev/null 2>&1; then
  if printf '%s\n' "$message" | mail -s "$subject" "$ALERT_EMAIL"; then
    sent=1
  fi
fi

if [[ -n "$SLACK_WEBHOOK_URL" ]] && command -v curl >/dev/null 2>&1; then
  escaped_subject="$(json_escape "$subject")"
  escaped_message="$(json_escape "$message")"
  payload="{\"text\":\"${escaped_subject}\n${escaped_message}\"}"

  if curl -fsS -X POST -H 'Content-Type: application/json' --data "$payload" "$SLACK_WEBHOOK_URL" >/dev/null; then
    sent=1
  fi
fi

if [[ "$sent" -eq 0 ]]; then
  log_message "INFO" "No external alert destination configured. Alert was written to the log only."
fi

