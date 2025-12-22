FROM alpine:3.23.2

# Install rdiff-backup and cron
RUN apk add --no-cache rdiff-backup bash curl tzdata

# Copy scripts
COPY backup.sh /backup.sh
COPY restore.sh /restore.sh
COPY list_backups.sh /list_backups.sh
COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /backup.sh /restore.sh /list_backups.sh /entrypoint.sh /healthcheck.sh
RUN mkdir -p /health
RUN chmod a+rwx /health

# Environment variables
ENV BACKUP_SRC=/data \
    BACKUP_DEST=/backups \
    RETENTION=6M \
    CRON_SCHEDULE="0 2 * * *"

HEALTHCHECK --interval=5m --timeout=10s --start-period=1m CMD /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
