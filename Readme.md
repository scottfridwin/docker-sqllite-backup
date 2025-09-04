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

### Environment Variables

| Variable        | Description                                                                       | Default     |
| --------------- | --------------------------------------------------------------------------------- | ----------- |
| `BACKUP_SRC`    | Path to source data (file or directory)                                           | `/data`     |
| `BACKUP_PATH`   | Path to backup repository                                                         | `/backups`  |
| `RETENTION`     | How long to keep old backups (e.g., `6M` for 6 months)                            | `6M`        |
| `CRON_SCHEDULE` | Cron schedule for backups                                                         | `0 2 * * *` |
| `MAX_AGE`       | Optional. Maximum allowed seconds since last backup before container is unhealthy | (unset)     |

> **Notes:**
>
> * A subdirectory named "sqllite-backup" will be created inside the directory specified by `BACKUP_PATH`.

---

#### Docker Run Example

```sh
docker run -d \
  -v /path/to/your/database:/data:ro \
  -v /path/to/backup/location:/backups \
  -e BACKUP_SRC=/data \
  -e BACKUP_PATH=/backups \
  -e RETENTION=6M \
  -e CRON_SCHEDULE="0 2 * * *" \
  --name sqlite-backup \
  fridwin/sqlite-backup
```

#### Docker Compose Example

```yaml
services:
  sqlite-backup:
    image: fridwin/sqlite-backup
    container_name: sqlite-backup
    environment:
      - TZ=${TIME_ZONE}
      - BACKUP_SRC=/data
      - BACKUP_PATH=/backups
      - RETENTION=6M
      - CRON_SCHEDULE=0 */6 * * *
    volumes:
      - /path/to/database:/data:ro
      - /path/to/backups:/backups
    restart: unless-stopped
```

> **Notes:**
>
> * The database is mounted **read-only** for safety.
> * The backup destination must be **writable** and ideally persistent (local disk or network mount).

---

### Scripts

Scripts are provided inside the container to allow for automated or manual execution of backup-related tasks.

* **`backup.sh`**: Performs backup and prunes old increments.
* **`restore.sh`**: Restores backup to a specified location.
* **`list_backups.sh`**: Lists available restore points.
* **`healthcheck.sh`**: Checks backup status, cron, and optionally backup age.

#### Manual backup

```sh
docker exec -e BACKUP_PATH=/backups sqlite-backup /backup.sh
```

#### List available backups

```sh
docker exec -e BACKUP_PATH=/backups sqlite-backup /list_backups.sh
```

#### Restore the latest backup

```sh
docker exec -e BACKUP_PATH=/backups -e RESTORE_PATH=/restore/path sqlite-backup /restore.sh
```

#### Restore a specific backup

```sh
docker exec -e BACKUP_PATH=/backups -e RESTORE_PATH=/restore/path -e RESTORE_DATE="2025-09-01T02:00:00" sqlite-backup /restore.sh
```

> **Note:** Timestamps follow rdiff-backup ISO format.

---

### Healthcheck

The container includes a healthcheck that verifies:

1. Cron is running
2. The last backup completed successfully
3. Optionally, the last backup is recent (if `MAX_AGE` is set)

```yaml
HEALTHCHECK --interval=5m --timeout=10s --start-period=1m CMD /healthcheck.sh
```

---

### Notes

* Ensure the container user has **read access** to the database and **write access** to the backup destination.
* Adjust the **cron schedule** and **retention** according to your backup policy.
* The healthcheck ensures that failures or cron stoppages are detected automatically.
