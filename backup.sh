#!/bin/bash
set -euo pipefail

# ==============================
# Required environment variables
# ==============================
: "${DB_PATH:?DB_PATH must be set (path to sqlite db file inside container volume)}}"
: "${BACKUP_DEST:?BACKUP_DEST must be set (where backups go, e.g. /backups/service)}"
: "${BACKUP_TYPE:?BACKUP_TYPE must be set (incremental|weekly)}"
: "${RETENTION:?RETENTION must be set (e.g. 30D, 6M)}}"

# Optional: healthchecks.io URL
HEALTHCHECK_URL="${HEALTHCHECK_URL:-}"

# ==============================
# Create a consistent SQLite snapshot
# ==============================
SNAPSHOT="/tmp/backup.sqlite"

echo "[INFO] Creating safe SQLite snapshot..."
sqlite3 "$DB_PATH" ".backup '$SNAPSHOT'"

# ==============================
# Run backup
# ==============================
echo "[INFO] Running rdiff-backup to $BACKUP_DEST..."
if rdiff-backup "$SNAPSHOT" "$BACKUP_DEST"; then
    echo "[INFO] Backup successful."
    echo "[INFO] Pruning old backups older than $RETENTION..."
    rdiff-backup --remove-older-than "$RETENTION" --force "$BACKUP_DEST"
    
    # Healthchecks.io ping on success
    if [ -n "$HEALTHCHECK_URL" ]; then
        curl -fsS -m 10 --retry 3 "$HEALTHCHECK_URL" > /dev/null || true
    fi
else
    echo "[ERROR] Backup failed, skipping pruning!"
fi

# Cleanup
rm -f "$SNAPSHOT"
