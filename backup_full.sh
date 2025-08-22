#!/bin/bash
set -euo pipefail

SOURCE="${SOURCE:-/data/source}"       # The SQLite file or directory
STAGING="${STAGING:-/tmp/staging}"     # Local staging path
BACKUP_DIR="${BACKUP_DIR:-/backups}"   # Final backup archive

# 1. Clear contents of staging, but keep the directory itself
mkdir -p "$STAGING"
rm -rf "$STAGING"/*

# 2. Perform full backup into staging
rdiff-backup --force "$SOURCE" "$STAGING"

# 3. Move (archive) staging into backup directory with timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
FINAL_DEST="$BACKUP_DIR/full-$TIMESTAMP"
mkdir -p "$BACKUP_DIR"
cp -a "$STAGING" "$FINAL_DEST"

echo "Full backup complete: $FINAL_DEST"
