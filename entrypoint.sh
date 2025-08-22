#!/bin/bash
set -euo pipefail

# Required vars
: "${DB_PATH:?Must set DB_PATH}"
: "${BACKUP_DEST:?Must set BACKUP_DEST}"
: "${BACKUP_TYPE:?Must set BACKUP_TYPE (incremental|full)}"
: "${RETENTION:?Must set RETENTION (e.g. 30D, 6M)}"
: "${SCHEDULE:?Must set SCHEDULE (cron format, e.g. '0 */6 * * *')}"

CRON_FILE="/etc/crontabs/root"

echo "[INFO] Configuring backup schedule..."
echo "$SCHEDULE BACKUP_TYPE=$BACKUP_TYPE /usr/local/bin/backup.sh" > "$CRON_FILE"

echo "[INFO] Starting cron with schedule: $SCHEDULE"
exec crond -f -l 2
