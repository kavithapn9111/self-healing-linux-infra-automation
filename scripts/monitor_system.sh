#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

status=0

log_message "INFO" "Starting system health checks"

disk_usage="$(df -P / | awk 'NR==2 {gsub(/%/, "", $5); print $5}')"
if [[ "$disk_usage" =~ ^[0-9]+$ ]] && (( disk_usage >= DISK_THRESHOLD_PERCENT )); then
  "$SCRIPT_DIR/alert.sh" \
    "High disk usage" \
    "Root filesystem is at ${disk_usage}%, threshold is ${DISK_THRESHOLD_PERCENT}%."
  status=1
else
  log_message "INFO" "Disk usage OK: ${disk_usage}%"
fi

if command -v free >/dev/null 2>&1; then
  memory_usage="$(free | awk '/Mem:/ {printf "%d", ($3 * 100) / $2}')"
  if [[ "$memory_usage" =~ ^[0-9]+$ ]] && (( memory_usage >= MEMORY_THRESHOLD_PERCENT )); then
    "$SCRIPT_DIR/alert.sh" \
      "High memory usage" \
      "Memory usage is ${memory_usage}%, threshold is ${MEMORY_THRESHOLD_PERCENT}%."
    status=1
  else
    log_message "INFO" "Memory usage OK: ${memory_usage}%"
  fi
else
  log_message "WARN" "free command not found. Skipping memory check."
fi

if [[ -r /proc/loadavg ]]; then
  load_average="$(awk '{print $1}' /proc/loadavg)"
  if awk -v load="$load_average" -v limit="$LOAD_THRESHOLD" 'BEGIN { exit !(load >= limit) }'; then
    "$SCRIPT_DIR/alert.sh" \
      "High system load" \
      "Current load average is ${load_average}, threshold is ${LOAD_THRESHOLD}."
    status=1
  else
    log_message "INFO" "System load OK: $load_average"
  fi
else
  log_message "WARN" "/proc/loadavg not found. Skipping load check."
fi

if [[ "$status" -eq 0 ]]; then
  log_message "INFO" "System health checks completed"
fi

exit "$status"

