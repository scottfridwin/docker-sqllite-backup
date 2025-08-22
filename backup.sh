#!/bin/bash
set -euo pipefail

# Required environment variables
: "${DB_PATH:?DB_PATH must be set}"
: "${BACKUP_DEST:?BACKUP_DEST must be set}"
: "${BACKUP_TYPE:?BACKUP_TYPE must be set (incremental|full)}"
: "${RETENTION:?RETENTION must be set}"

HEALTHCHECK_URL="${HEALTHCHECK_URL:-}"

SNAPSHOT="/tmp/backup.sqlite"

echo "[INFO] Creating SQLite snapshot..."
sqlite3 "$DB_PATH" ".backup '$SNAPSHOT'"

echo "[INFO] Running $BACKUP_TYPE backup to $BACKUP_DEST..."
if rdiff-backup "$SNAPSHOT" "$BACKUP_DEST"; then
    echo "[INFO] Backup successful"
    echo "[INFO] Pruning backups older than $RETENTION..."
    rdiff-backup --remove-older-than "$RETENTION" --force "$BACKUP_DEST"

    if [ -n "$HEALTHCHECK_URL" ]; then
        curl -fsS -m 10 --retry 3 "$HEALTHCHECK_URL" > /dev/null || true
    fi
else
    echo "[ERROR] Backup failed, skipping pruning"
fi

rm -f "$SNAPSHOT"
