#!/bin/sh
set -e

STATUS_FILE="/health/last_status"

# 1. Check if cron is running
if ! pgrep crond >/dev/null 2>&1; then
    echo "[ERROR] cron is not running"
    exit 1
fi

# 2. Check if status file exists and is 'ok'
if [ ! -f "$STATUS_FILE" ] || [ "$(cat $STATUS_FILE)" != "ok" ]; then
    echo "[ERROR] Last backup failed or status missing"
    exit 1
fi

echo "[INFO] Backup container healthy"
exit 0
