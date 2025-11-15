#!/bin/bash
set -euo pipefail

INTERVAL_SECONDS="${INTERVAL_SECONDS:-1800}"
LOG_DIR="${MONITOR_LOG_DIR:-/var/log/testapp}"
STATE_DIR="${MONITOR_STATE_DIR:-/var/lib/testapp}"
CPU_LOG="${LOG_DIR}/cpu_usage.log"
VISITS_LOG="${LOG_DIR}/visits.log"
ACCESS_LOG="${ACCESS_LOG:-/var/log/nginx/testapp.access.log}"
ACCESS_OFFSET_FILE="${STATE_DIR}/access.offset"

mkdir -p "$LOG_DIR" "$STATE_DIR"
touch "$CPU_LOG" "$VISITS_LOG"

log_cpu_snapshot() {
  local now
  now="$(date '+%F %T')"
  {
    printf '[%s] Uso de CPU y memoria\n' "$now"
    if command -v mpstat >/dev/null 2>&1; then
      mpstat 1 1
    else
      if read -r load1 load5 load15 _ < /proc/loadavg; then
        printf 'Load average (1m,5m,15m): %s %s %s\n' "$load1" "$load5" "$load15"
      fi
    fi
    echo "Procesos con mayor uso de CPU"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 15
    echo
  } >> "$CPU_LOG"
}

log_new_visits() {
  local now log_size last_pos start_byte
  now="$(date '+%F %T')"

  if [ ! -f "$ACCESS_LOG" ]; then
    {
      printf '[%s] Nuevas visitas registradas en %s\n' "$now" "$ACCESS_LOG"
      echo "No existe el archivo de access log. ¿Nginx está escribiendo en ${ACCESS_LOG}?"
      echo
    } >> "$VISITS_LOG"
    return
  fi

  log_size="$(stat -c%s "$ACCESS_LOG")"
  if [ -f "$ACCESS_OFFSET_FILE" ]; then
    read -r last_pos < "$ACCESS_OFFSET_FILE"
  else
    last_pos=0
  fi

  if [ "$log_size" -lt "${last_pos:-0}" ]; then
    last_pos=0
  fi

  {
    printf '[%s] Nuevas visitas registradas en %s\n' "$now" "$ACCESS_LOG"
    if [ "$log_size" -gt "$last_pos" ]; then
      start_byte=$((last_pos + 1))
      tail -c +"$start_byte" "$ACCESS_LOG"
    else
      echo "No hubo visitas nuevas desde la última captura."
    fi
    echo
  } >> "$VISITS_LOG"

  echo "$log_size" > "$ACCESS_OFFSET_FILE"
}

trap 'exit 0' SIGTERM SIGINT

while true; do
  log_cpu_snapshot
  log_new_visits
  sleep "$INTERVAL_SECONDS"
done
