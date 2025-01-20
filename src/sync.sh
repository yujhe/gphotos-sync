#!/bin/bash

echo "{\"level\": \"INFO\", \"message\": \"Starting sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

rm -f /tmp/gphotos-cdp/Singleton*
gphotos-cdp -dev -headless -dldir /download -date

echo "{\"level\": \"INFO\", \"message\": \"Completed sync.sh, pid: $$\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
