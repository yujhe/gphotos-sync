#!/bin/bash

if [ -z "$1" ];then
  echo "file argument required"
  exit 1
fi

# Run exiftool and capture only stderr
result=$(exiftool "-datetimeoriginal<FileModifyDate" -P -overwrite_original_in_place -if 'not $DateTimeOriginal' "$1" 2>&1 >/dev/null)

# If exit code is 2, it just means that this operation didn't make any change. Other exit codes should be propagated
status=$?
if [ $status -eq 2 ]; then
  echo "{\"level\": \"debug\", \"message\": \"file already has date in exif data: $(basename "$1")\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"
elif [ $status -ne 0 ]; then
  # ignore error if result contains "too large" or "invalid atom size"
  if [[ "$result" == *"too large"* || "$result" == *"invalid atom size"* ]]; then
    echo "{\"level\": \"info\", \"message\": \"skipping date update in exif data for $(basename "$1"), exiftool does not support this file\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"
  fi
  while read line; do
    echo "{\"level\": \"error\", \"message\": \"exiftool: $line\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"
  done <<< "$result"
fi

echo "{\"level\": \"info\", \"message\": \"added missing date in exif data for $(basename "$1")\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"