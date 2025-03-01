#!/bin/bash

echo "{\"level\": \"INFO\", \"message\": \"Starting sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

WORKER_COUNT=${WORKER_COUNT:-6}
LOGLEVEL=${LOGLEVEL:-INFO}

rm -f /tmp/gphotos-cdp/Singleton*

if [ -n "$ALBUMS" ]; then
  for ALBUM in $(echo $ALBUMS | tr ',' ' '); do
    gphotos-cdp -dev -headless -dldir "/download/$ALBUM" -date -fix -loglevel $LOGLEVEL -removed -workers $WORKER_COUNT $GPHOTOS_CDP_ARGS -album "$ALBUM"
  done
else
  gphotos-cdp -dev -headless -dldir /download -date -fix -json -loglevel $LOGLEVEL -removed -workers $WORKER_COUNT $GPHOTOS_CDP_ARGS
fi

echo "{\"level\": \"INFO\", \"message\": \"Completed sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
