#!/bin/bash

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

result=$(exiftool "-datetimeoriginal<FileModifyDate" -P -overwrite_original_in_place -if 'not $DateTimeOriginal' "$1" 2>&1)

# If exit code is 2, it just means that this operation didn't make any change. Other exit codes should be propagated
status=$?
if [ $status -eq 2 ]; then
  exit 0
elif [ $status -ne 0 ]; then
  echo "exiftool failed:"
  echo "$result"
  exit $status
fi

echo "{\"level\": \"INFO\", \"message\": \"Added missing date in exif data for file: $(basename "$1")\", \"dt\": \"$(date '+%FT%T.%3N%:z')\"}"