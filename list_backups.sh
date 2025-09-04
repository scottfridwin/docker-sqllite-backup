#!/bin/sh
set -e

if [ -z "$BACKUP_PATH" ]; then
  echo "[ERROR] BACKUP_PATH must be set"
  exit 1
fi

echo "[INFO] Listing available restore points in $BACKUP_PATH"
rdiff-backup --list-increments "$BACKUP_PATH/sqllite-backup"
