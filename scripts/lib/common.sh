#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

CONFIG_FILE="${CONFIG_FILE:-$PROJECT_ROOT/config/monitor.conf}"
SERVICES_FILE="${SERVICES_FILE:-$PROJECT_ROOT/config/services.conf}"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
fi

INTERVAL_SECONDS="${INTERVAL_SECONDS:-60}"
MAX_RETRIES="${MAX_RETRIES:-3}"
RECOVERY_WAIT_SECONDS="${RECOVERY_WAIT_SECONDS:-5}"
DISK_THRESHOLD_PERCENT="${DISK_THRESHOLD_PERCENT:-80}"
MEMORY_THRESHOLD_PERCENT="${MEMORY_THRESHOLD_PERCENT:-85}"
LOAD_THRESHOLD="${LOAD_THRESHOLD:-4}"
ALERT_EMAIL="${ALERT_EMAIL:-}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
LOG_FILE="${LOG_FILE:-}"
STATE_DIR="${STATE_DIR:-}"

if [[ -z "$LOG_FILE" ]]; then
  LOG_FILE="$PROJECT_ROOT/logs/monitor.log"
fi

if [[ -z "$STATE_DIR" ]]; then
  STATE_DIR="$PROJECT_ROOT/state"
fi

prepare_runtime_dirs() {
  local log_dir
  log_dir="$(dirname "$LOG_FILE")"

  if ! mkdir -p "$log_dir" "$STATE_DIR" 2>/dev/null; then
    LOG_FILE="$PROJECT_ROOT/logs/monitor.log"
    STATE_DIR="$PROJECT_ROOT/state"
    mkdir -p "$(dirname "$LOG_FILE")" "$STATE_DIR"
  fi
}

log_message() {
  local level="$1"
  local message="$2"
  local timestamp

  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '%s [%s] %s\n' "$timestamp" "$level" "$message" | tee -a "$LOG_FILE" >/dev/null
}

sanitize_name() {
  local name="$1"
  printf '%s' "$name" | tr -c 'A-Za-z0-9_.-' '_'
}

retry_file() {
  local service_name
  service_name="$(sanitize_name "$1")"
  printf '%s/%s.retry\n' "$STATE_DIR" "$service_name"
}

get_retry_count() {
  local file
  local value

  file="$(retry_file "$1")"
  if [[ ! -f "$file" ]]; then
    printf '0\n'
    return
  fi

  value="$(<"$file")"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$value"
  else
    printf '0\n'
  fi
}

set_retry_count() {
  local file

  file="$(retry_file "$1")"
  printf '%s\n' "$2" > "$file"
}

reset_retry_count() {
  local file

  file="$(retry_file "$1")"
  if [[ -f "$file" ]]; then
    rm -f "$file"
  fi
}

check_health() {
  local check_type="$1"
  local target="$2"

  case "$check_type" in
    systemd)
      command -v systemctl >/dev/null 2>&1 || return 1
      systemctl is-active --quiet "$target"
      ;;
    process)
      command -v pgrep >/dev/null 2>&1 || return 1
      pgrep -f "$target" >/dev/null 2>&1
      ;;
    port)
      if command -v ss >/dev/null 2>&1; then
        ss -ltn | awk '{print $4}' | grep -Eq "[:.]${target}$"
      elif command -v netstat >/dev/null 2>&1; then
        netstat -ltn | awk '{print $4}' | grep -Eq "[:.]${target}$"
      else
        return 1
      fi
      ;;
    http)
      command -v curl >/dev/null 2>&1 || return 1
      curl -fsS --max-time 5 "$target" >/dev/null
      ;;
    *)
      log_message "ERROR" "Unknown health check type: $check_type"
      return 2
      ;;
  esac
}

prepare_runtime_dirs

