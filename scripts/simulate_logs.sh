#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/testapp/test.log"

for i in {1..10}; do
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] Log del día $i" | sudo tee -a "$LOG_FILE" >/dev/null
  sleep 1
done

echo "Logs simulados en $LOG_FILE"
