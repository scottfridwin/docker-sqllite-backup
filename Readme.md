# SQLite Backup Container

This project provides a simple containerized solution for backing up a SQLite database (or any file/directory) using `rdiff-backup`. Backups are scheduled via cron, verified for integrity, and configurable with environment variables.

## Features

* **Incremental backups** using `rdiff-backup`
* **Configurable schedule** via cron
* **Retention policy** for old backups
* **Automatic verification** of each backup
* **Healthcheck** to monitor backup status and cron
* **Restore and list scripts** for easy recovery

---

## Usage

### 1. Build the Docker Image

```sh
docker build -t sqlite-backup .
```

### 2. Run the Container

Mount your SQLite database and backup destination as volumes:

```sh
docker run -d \
  -v /path/to/your/database:/data:ro \
  -v /path/to/backup/location:/backups \
  -e BACKUP_SRC=/data \
  -e BACKUP_DEST=/backups \
  -e RETENTION=6M \
  -e CRON_SCHEDULE="0 2 * * *" \
  --name sqlite-backup \
  sqlite-backup
```

> **Note:**
>
> * The database is mounted **read-only** for safety.
> * The backup destination must be **writable** and ideally persistent (local disk or network mount).

---

### 3. Environment Variables

| Variable        | Description                                                                       | Default     |
| --------------- | --------------------------------------------------------------------------------- | ----------- |
| `BACKUP_SRC`    | Path to source data (file or directory)                                           | `/data`     |
| `BACKUP_DEST`   | Path to backup repository                                                         | `/backups`  |
| `RETENTION`     | How long to keep old backups (e.g., `6M` for 6 months)                            | `6M`        |
| `CRON_SCHEDULE` | Cron schedule for backups                                                         | `0 2 * * *` |
| `MAX_AGE`       | Optional. Maximum allowed seconds since last backup before container is unhealthy | (unset)     |

---

### 4. Scripts

* **`backup.sh`**: Performs backup and prunes old increments.
* **`restore.sh`**: Restores backup to a specified location.
* **`list_backups.sh`**: Lists available restore points.
* **`healthcheck.sh`**: Checks backup status, cron, and optionally backup age.

> **Logs:**
>
> * Backup logs → `/var/log/backup.log`
> * Healthcheck logs → `/var/log/backup_health.log`

---

### 5. List Available Backups

```sh
docker exec -e BACKUP_PATH=/backups sqlite-backup /list_backups.sh
```

---

### 6. Restore a Backup

Restore the latest backup:

```sh
docker exec -e BACKUP_PATH=/backups -e RESTORE_PATH=/restore/path sqlite-backup /restore.sh
```

Restore a specific date:

```sh
docker exec -e BACKUP_PATH=/backups -e RESTORE_PATH=/restore/path -e RESTORE_DATE="2025-09-01T02:00:00" sqlite-backup /restore.sh
```

> **Note:** Timestamps follow rdiff-backup ISO format.

---

### 7. Healthcheck

The container includes a healthcheck that verifies:

1. Cron is running
2. The last backup completed successfully
3. Optionally, the last backup is recent (if `MAX_AGE` is set)

```yaml
HEALTHCHECK --interval=5m --timeout=10s --start-period=1m CMD /healthcheck.sh
```

---

### 8. Docker Compose Example

```yaml
services:
  sqlite-backup:
    image: sqlite-backup
    environment:
      BACKUP_SRC: /data
      BACKUP_DEST: /backups
      RETENTION: 6M
      CRON_SCHEDULE: "0 2 * * *"
      MAX_AGE: 21600   # Optional, 6h
    volumes:
      - /path/to/database:/data:ro
      - /path/to/backups:/backups
```

---

### Notes

* Ensure the container user has **read access** to the database and **write access** to the backup destination.
* Adjust the **cron schedule** and **retention** according to your backup policy.
* The healthcheck ensures that failures or cron stoppages are detected automatically.
