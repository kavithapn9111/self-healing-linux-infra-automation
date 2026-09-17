#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

log_message "INFO" "Starting continuous monitor loop with interval ${INTERVAL_SECONDS}s"

while true; do
  "$SCRIPT_DIR/monitor_services.sh" || true
  "$SCRIPT_DIR/monitor_system.sh" || true
  sleep "$INTERVAL_SECONDS"
done

