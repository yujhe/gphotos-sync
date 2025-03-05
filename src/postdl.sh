#!/bin/bash

set -e

if [ -z "$1" ];then
  echo "File argument required"
  exit 1
fi

exiftool "-datetimeoriginal<FileModifyDate" -P -overwrite_original_in_place -if 'not $DateTimeOriginal' "$1"