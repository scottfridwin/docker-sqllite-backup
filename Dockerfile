FROM alpine:3.20

# Install dependencies: rdiff-backup, sqlite3, cron, bash, curl (for healthchecks.io)
RUN apk add --no-cache rdiff-backup sqlite bash curl dcron

# Copy backup scripts
COPY backup.sh /usr/local/bin/backup.sh
COPY crontab.txt /etc/crontabs/root

# Make script executable
RUN chmod +x /usr/local/bin/backup.sh

# Run cron in foreground
CMD ["crond", "-f", "-l", "2"]
