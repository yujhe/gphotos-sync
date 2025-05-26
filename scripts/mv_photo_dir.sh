#!/bin/bash
# Moves photos to "YYYY/MM" folder structure on file modified date
#
# Supported env vars
# TARGET_DIR: the destination folder path

# check arguments
if [ -z "$1" ]; then
  error "file argument required"
  exit 1
fi

SOURCE_FILE="$1"
TARGET_DIR=${TARGET_DIR:-/PhotoLibrary}

# create target directory if it does not exist
mkdir -p "$TARGET_DIR"

# Update exif data for the file
# If there's no DateTimeOriginal, it adds it from FileModifyDate.
# If DateTimeOriginal and FileModifyDate are different, it updates it from FileModifyDate.
rs=$(exiftool "-datetimeoriginal<FileModifyDate" -P -overwrite_original_in_place -if 'not $DateTimeOriginal or ($datetimeoriginal gt ${filemodifydate;ShiftTime("1 0")}) or ($filemodifydate gt ${datetimeoriginal;ShiftTime("1 0")})' "$SOURCE_FILE" 2>&1 >/dev/null)
rc=$?
if [ $rc -eq 2 ]; then
  echo "$(basename "$SOURCE_FILE"): exif data no changes"
elif [ $rc -ne 0 ]; then
  # ignore error if result contains "too large" or "invalid atom size"
  if [[ "$rs" == *"too large"* || "$rs" == *"invalid atom size"* ]]; then
    echo "$(basename "$SOURCE_FILE"): skipping update DateTimeOriginal exif data, exiftool not support"
  else
    # unknown error
    while read line; do
      echo "exiftool: $line"
    done <<<"$rs"
    exit 1
  fi
else
  # update DateTimeOriginal exif data from FileModifyDate
  echo "$(basename "$SOURCE_FILE"): updated DateTimeOriginal exif data from FileModifyDate"
fi

# Move the file to the target directory based on DateTimeOriginal
# And add image id to the prefix: ABC_IMG_8251.JPG
img_id=$(dirname "$SOURCE_FILE")
target_path=$(exiftool -d "%Y/%m" -p "${TARGET_DIR}/\${DateTimeOriginal}/${img_id: -6}_\${filename}" "$SOURCE_FILE")
rc=$?
if [ $rc -ne 0 ]; then
  echo "$(basename "$SOURCE_FILE"): failed to get target path"
  exit 1
else
  echo "$(basename "$SOURCE_FILE"): move to $target_path based on DateTimeOriginal"
fi

mkdir -p "$(dirname "$target_path")"
mv -f "$SOURCE_FILE" "$target_path"
rmdir $(dirname "$SOURCE_FILE")
