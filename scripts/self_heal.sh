#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

if [[ "$#" -lt 4 ]]; then
  printf 'Usage: %s <name> <check_type> <check_target> <restart_target>\n' "$0" >&2
  exit 2
fi

service_name="$1"
check_type="$2"
check_target="$3"
restart_target="$4"

retry_count="$(get_retry_count "$service_name")"

if (( retry_count >= MAX_RETRIES )); then
  "$SCRIPT_DIR/alert.sh" \
    "Recovery limit reached for $service_name" \
    "Service $service_name is still unhealthy after $retry_count recovery attempts."
  exit 1
fi

next_retry=$((retry_count + 1))
set_retry_count "$service_name" "$next_retry"

log_message "WARN" "Recovery attempt $next_retry/$MAX_RETRIES for $service_name"

if [[ -z "$restart_target" || "$restart_target" == "none" ]]; then
  log_message "ERROR" "No restart target configured for $service_name"
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  log_message "ERROR" "systemctl not found. Cannot restart $restart_target"
  exit 1
fi

if ! systemctl restart "$restart_target"; then
  log_message "ERROR" "Restart command failed for $restart_target"
  exit 1
fi

sleep "$RECOVERY_WAIT_SECONDS"

if check_health "$check_type" "$check_target"; then
  reset_retry_count "$service_name"
  log_message "INFO" "Service recovered successfully: $service_name"
  exit 0
fi

log_message "ERROR" "Service still unhealthy after restart: $service_name"

if (( next_retry >= MAX_RETRIES )); then
  "$SCRIPT_DIR/alert.sh" \
    "Automated recovery failed for $service_name" \
    "Service $service_name failed health check after $next_retry restart attempts. Manual investigation is required."
fi

exit 1

