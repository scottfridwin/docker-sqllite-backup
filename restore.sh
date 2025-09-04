#!/bin/sh
set -e

if [ -z "$BACKUP_PATH" ] || [ -z "$RESTORE_PATH" ]; then
  echo "[ERROR] BACKUP_PATH and RESTORE_PATH must be set"
  exit 1
fi

# If RESTORE_DATE is not set, restore latest
if [ -n "$RESTORE_DATE" ]; then
  echo "[INFO] Restoring backup from $RESTORE_DATE into $RESTORE_PATH"
  rdiff-backup -r "$RESTORE_DATE" "$BACKUP_PATH/sqllite-backup" "$RESTORE_PATH"
else
  echo "[INFO] Restoring latest backup into $RESTORE_PATH"
  rdiff-backup -r now "$BACKUP_PATH/sqllite-backup" "$RESTORE_PATH"
fi

echo "[INFO] Restore complete"
