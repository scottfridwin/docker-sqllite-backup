#!/bin/sh
set -e

# Default cron schedule (can be overridden)
: "${CRON_SCHEDULE:=0 2 * * *}"  # Every day at 2 AM by default

CRON_FILE=/etc/crontabs/root

# Write cron job
echo "$CRON_SCHEDULE BACKUP_SRC=$BACKUP_SRC BACKUP_DEST=$BACKUP_DEST RETENTION=$RETENTION /backup.sh >> /var/log/backup.log 2>&1" > $CRON_FILE

echo "[INFO] Cron job installed: $CRON_SCHEDULE"

# Ensure health dir exists
mkdir -p /health

# Start cron in foreground
exec crond -f -L /dev/stdout
