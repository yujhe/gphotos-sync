#!/bin/bash

echo "INFO: Starting sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null "$HEALTHCHECK_HOST/$HEALTHCHECK_ID/start"
fi

set -e

rm -f /tmp/gphotos-cdp/Singleton*
gphotos-cdp -v -dev -headless -dldir /download -date

echo "INFO: Completed sync.sh PID $$ $(date)"

if [ -n "$HEALTHCHECK_ID" ]; then
  curl -sS -X POST -o /dev/null --fail "$HEALTHCHECK_HOST/$HEALTHCHECK_ID"
fi
