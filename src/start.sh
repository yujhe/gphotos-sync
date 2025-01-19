#!/bin/bash

set -e

CRON_SCHEDULE=${CRON_SCHEDULE:-0 * * * *}

PUID=${PUID:-1001}
PGID=${PGID:-1001}

addgroup abc --gid "${PGID}" --quiet
adduser abc --uid "${PUID}" --gid "${PGID}" --disabled-password --gecos "" --quiet

echo "Running with user uid: $(id -u abc) and user gid: $(id -g abc)"

chown abc:abc /app

if [[ "$1" == 'no-cron' ]]; then
    sudo -u abc sh /app/sync.sh
else
    echo "Scheduling cron job for: $CRON_SCHEDULE"
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    chmod a+rw $LOGFIFO

    CRON_ENV="CHROMIUM_USER_FLAGS='--no-sandbox'"
    CRON_ENV="$CRON_ENV\nHEALTHCHECK_ID='$HEALTHCHECK_ID'"
    CRON_ENV="$CRON_ENV\nHEALTHCHECK_HOST='$HEALTHCHECK_HOST'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /usr/bin/flock -n /app/sync.lock sh /app/sync.sh > $LOGFIFO 2>&1" | crontab -u abc -

    echo -e '* * * * * echo "test: $(date)" >'" $LOGFIFO 2>&1" | crontab -
    cron
    tail -f "$LOGFIFO"
fi
