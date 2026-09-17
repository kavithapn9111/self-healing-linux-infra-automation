#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

failures=0

if [[ ! -f "$SERVICES_FILE" ]]; then
  log_message "ERROR" "Services file not found: $SERVICES_FILE"
  exit 1
fi

log_message "INFO" "Starting service health checks"

while IFS='|' read -r name check_type check_target restart_target description || [[ -n "${name:-}" ]]; do
  if [[ -z "${name// }" || "${name:0:1}" == "#" ]]; then
    continue
  fi

  description="${description:-No description}"

  if check_health "$check_type" "$check_target"; then
    reset_retry_count "$name"
    log_message "INFO" "Healthy: $name - $description"
  else
    log_message "WARN" "Unhealthy: $name - $description"
    if "$SCRIPT_DIR/self_heal.sh" "$name" "$check_type" "$check_target" "$restart_target"; then
      log_message "INFO" "Recovery succeeded for $name"
    else
      failures=$((failures + 1))
      log_message "ERROR" "Recovery failed for $name"
    fi
  fi
done < "$SERVICES_FILE"

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

log_message "INFO" "Service health checks completed"

