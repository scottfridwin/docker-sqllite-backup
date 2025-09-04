#!/bin/sh
set -e

STATUS_FILE="/health/last_status"

# Required environment variables:
#   BACKUP_SRC   - Path to source data (file or directory)
#   BACKUP_PATH  - Path to backup repository
# Optional:
#   RETENTION    - How long to keep increments (e.g. "6M", "30D")

if [ -z "$BACKUP_SRC" ] || [ -z "$BACKUP_PATH" ]; then
    echo "[ERROR] BACKUP_SRC and BACKUP_PATH must be set"
    echo "fail" > "$STATUS_FILE"
    exit 1
fi

# Create temporary directory for rdiff-backup
export RDIFF_TMPDIR=/tmp/rdiff-backup-tmp
mkdir -p $RDIFF_TMPDIR

echo "[INFO] Starting backup of $BACKUP_SRC -> $BACKUP_PATH"

# Run backup
rdiff-backup --new --api-version 201 --tempdir "$RDIFF_TMPDIR" backup "$BACKUP_SRC" "$BACKUP_PATH/sqllite-backup"
RET=$?
if [ $RET -ne 0 ]; then
    echo "[ERROR] rdiff-backup failed with code $RET"
    echo "fail" > "$STATUS_FILE"
    exit 1
fi

# Prune old increments if RETENTION is set
if [ -n "$RETENTION" ]; then
    echo "[INFO] Removing increments older than $RETENTION"
    rdiff-backup --remove-older-than "$RETENTION" --force "$BACKUP_PATH/sqllite-backup"
    RET=$?
    if [ $RET -ne 0 ]; then
        echo "[ERROR] rdiff-backup prune failed with code $RET"
        echo "fail" > "$STATUS_FILE"
        exit 1
    fi
fi

# Verification step
echo "[INFO] Verifying latest backup integrity..."
rdiff-backup --verify "$BACKUP_PATH/sqllite-backup"
RET=$?
if [ $RET -ne 0 ]; then
    echo "[ERROR] Backup verification FAILED with code $RET ❌"
    echo "fail" > "$STATUS_FILE"
    exit 1
else
    echo "[INFO] Backup verification successful ✅"
    echo "ok" > "$STATUS_FILE"
fi

echo "[INFO] Backup complete."
