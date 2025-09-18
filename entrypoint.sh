#!/bin/sh
set -e

: "${CRON_SCHEDULE:=0 2 * * *}"  # default schedule

CRON_FILE=/tmp/cronjob
STATUS_FILE="/health/last_status"

# Write cron job to a file
echo "$CRON_SCHEDULE BACKUP_SRC=$BACKUP_SRC BACKUP_PATH=$BACKUP_PATH RETENTION=$RETENTION /backup.sh >> /var/log/backup.log 2>&1" > $CRON_FILE
echo "[INFO] Cron job installed: $CRON_SCHEDULE"

# Write initial status to health file
echo "ok" > "$STATUS_FILE"

# Start cron, pointing to the temp directory
exec crond -f -L /dev/stdout -c /tmp
