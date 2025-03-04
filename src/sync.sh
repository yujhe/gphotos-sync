#!/bin/bash

echo "{\"level\": \"INFO\", \"message\": \"Starting sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

PROFILE_DIR="${PROFILE_DIR:-/tmp/gphotos-cdp}"
DOWNLOAD_DIR="${DOWNLOAD_DIR:-/download}"
WORKER_COUNT=${WORKER_COUNT:-6}
LOGLEVEL=${LOGLEVEL:-INFO}
GPHOTOS_CDP_ARGS="-profile \"$PROFILE_DIR\" -headless -json -loglevel $LOGLEVEL -removed -workers $WORKER_COUNT $GPHOTOS_CDP_ARGS"

rm -f $PROFILE_DIR/Singleton*

if [ -n "$ALBUMS" ]; then
  for ALBUM in $(echo $ALBUMS | tr ',' ' '); do
    if [ "$ALBUM" = "ALL" ]; then
      eval gphotos-cdp -dldir "$DOWNLOAD_DIR/$ALBUM" $GPHOTOS_CDP_ARGS
    else
      eval gphotos-cdp -dldir "$DOWNLOAD_DIR/$ALBUM" $GPHOTOS_CDP_ARGS -album $ALBUM
    fi
  done
else
  eval gphotos-cdp -dldir "$DOWNLOAD_DIR" $GPHOTOS_CDP_ARGS
fi

echo "{\"level\": \"INFO\", \"message\": \"Completed sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
