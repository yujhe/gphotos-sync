#!/bin/bash

echo "{\"level\": \"INFO\", \"message\": \"Starting sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

# If worker count is set, add parameter name
if [ -n "$WORKER_COUNT" ]; then
  WORKER_COUNT="-workers $WORKER_COUNT"
fi
LOGLEVEL=${LOGLEVEL:-INFO}

rm -f /tmp/gphotos-cdp/Singleton*
gphotos-cdp -dev -headless -dldir /download -date -json -loglevel $LOGLEVEL $WORKER_COUNT

echo "{\"level\": \"INFO\", \"message\": \"Completed sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
