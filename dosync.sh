#!/usr/bin/env bash
set -e
set -o pipefail

work_dir=$(dirname "$(readlink -f "$0")")
repo=$(basename "$work_dir")

docker build . --tag gphotos-sync || exit 1

rm -f "${work_dir}/profile/Singleton*"

sync_args=(
  # note: paths in docker container
  "-profile /tmp/gphotos-cdp" # user-provided profile dir
  "-dldir /download"          # where to write the downloads

  "-headless"      # Start chrome browser in headless mode
  "-loglevel info" # log level: debug, info, warn, error, fatal, panic
  "-workers 6"     # number of concurrent downloads allowed
  "-batchsize 1"   # number of photos to download in one batch

  "-run /app/update_exif.sh" # the program to run on each downloaded item, right after it is dowloaded

  # uncomment this, if you want to sync album
  # "-album id"        # ID of album to download, has no effect if lastdone file is found or if -start contains full URL
  # "-albumtype album" # type of album to download (as seen in URL), has no effect if lastdone file is found or if -start contains full URL

  # uncomment this, if you want to get removed photos
  # "-removed"     # save list of files found locally that appear to be deleted from Google Photos

  # uncomment this, if you want to sync photos before/after the date (inclusive)
  # "-from yyyy-mm-dd"   # earliest date to sync (YYYY-MM-DD)
  # "-to yyyy-mm-dd"     # latest date to sync (YYYY-MM-DD)
)

docker run --rm \
  --name "gphotos-sync-${repo}" \
  -v "${work_dir}/profile":/tmp/gphotos-cdp \
  -v "${work_dir}/photos":/download \
  gphotos-sync:latest \
  ${sync_args[*]}

rm -f "${work_dir}/profile/Singleton*"
