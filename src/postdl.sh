#!/bin/bash

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

# Run exiftool and capture only stderr
result=$(exiftool "-datetimeoriginal<FileModifyDate" -P -overwrite_original_in_place -if 'not $DateTimeOriginal' "$1" 2>&1 >/dev/null)

# If exit code is 2, it just means that this operation didn't make any change. Other exit codes should be propagated
status=$?
if [ $status -eq 2 ]; then
  exit 0
elif [ $status -ne 0 ]; then
  # ignore error if result contains "too large"
  if [[ "$result" == *"too large"* ]]; then
    echo "{\"level\": \"info\", \"message\": \"Cannot update date in exif data for $(basename \"$1\") due to file size limit\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"
    exit 0
  fi
  for line in "$result"; do
    echo "{\"level\": \"error\", \"message\": \"exiftool: $line\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"
  done
  exit $status
fi

echo "{\"level\": \"info\", \"message\": \"Added missing date in exif data for $(basename \"$1\")\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"