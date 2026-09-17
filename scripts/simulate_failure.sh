#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

action="${1:-}"
target="${2:-}"

show_usage() {
  cat <<'USAGE'
Usage:
  ./scripts/simulate_failure.sh test-alert
  sudo ./scripts/simulate_failure.sh stop-service <service-name>
  sudo ./scripts/simulate_failure.sh start-service <service-name>
  sudo ./scripts/simulate_failure.sh kill-process <process-name>

Examples:
  ./scripts/simulate_failure.sh test-alert
  sudo ./scripts/simulate_failure.sh stop-service nginx
  sudo ./scripts/simulate_failure.sh start-service nginx
USAGE
}

case "$action" in
  test-alert)
    "$SCRIPT_DIR/alert.sh" \
      "Test alert from self-healing monitor" \
      "This is a test alert. No real incident happened."
    ;;
  stop-service)
    if [[ -z "$target" ]]; then
      show_usage
      exit 2
    fi
    log_message "WARN" "Stopping service for simulation: $target"
    systemctl stop "$target"
    ;;
  start-service)
    if [[ -z "$target" ]]; then
      show_usage
      exit 2
    fi
    log_message "INFO" "Starting service after simulation: $target"
    systemctl start "$target"
    ;;
  kill-process)
    if [[ -z "$target" ]]; then
      show_usage
      exit 2
    fi
    log_message "WARN" "Killing process for simulation: $target"
    pkill -f "$target"
    ;;
  *)
    show_usage
    exit 2
    ;;
esac

