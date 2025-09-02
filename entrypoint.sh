#!/bin/sh
set -e

: "${CRON_SCHEDULE:=0 2 * * *}"  # Default

# Write cron job to current user's crontab
echo "$CRON_SCHEDULE BACKUP_SRC=$BACKUP_SRC BACKUP_DEST=$BACKUP_DEST RETENTION=$RETENTION /backup.sh >> /var/log/backup.log 2>&1" | crontab -

echo "[INFO] Cron job installed: $CRON_SCHEDULE"

mkdir -p /health /var/log
exec crond -f -L /dev/stdout
