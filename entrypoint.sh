#!/bin/sh
set -e

: "${CRON_SCHEDULE:=0 2 * * *}"  # default schedule

CRON_FILE=/tmp/cronjob
mkdir -p /var/log /health

# Write cron job to a file
echo "$CRON_SCHEDULE BACKUP_SRC=$BACKUP_SRC BACKUP_DEST=$BACKUP_DEST RETENTION=$RETENTION /backup.sh >> /var/log/backup.log 2>&1" > $CRON_FILE
echo "[INFO] Cron job installed: $CRON_SCHEDULE"

# Start cron, pointing to the temp directory
exec crond -f -L /dev/stdout -c /tmp
