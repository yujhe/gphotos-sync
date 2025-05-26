#!/usr/bin/env bash
set -e
set -o pipefail

WORK_DIR=$(dirname "$(readlink -f "$0")")
SYNC_JOB_NAME=${JOB_NAME:-my-gphotos-sync}

docker build . --tag gphotos-sync

rm -f ${WORK_DIR}/profile/Singleton*

PROFILE_DIR="${WORK_DIR}/profile"
DOWNLOADS_DIR="${WORK_DIR}/downloads"
PHOTOS_DIR="${WORK_DIR}/PhotoLibrary"
DB_DIR="${WORK_DIR}/db"

sync_args=(
  # DO NOT CHANGE: paths in docker container
  "-profile /profile"              # user-provided profile dir
  "-download-dir /downloads"       # where to write the downloads
  "-db-file /db/gphotos.db"        # database file

  "-headless"        # Start chrome browser in headless mode
  "-log-level info"   # log level: debug, info, warn, error, fatal, panic

  "-workers 3"       # number of concurrent downloads allowed
  # "-batch-size 10"   # number of photos to be downloaded in one batch

  "-run /app/mv_photo_dir.sh"   # the program to run on each downloaded item, right after it is dowloaded

  # uncomment this, if you want to sync album
  # "-album id"         # ID of album to download, has no effect if lastdone file is found or if -start contains full UR
  # "-album-type album" # type of album to download (as seen in URL)

  # uncomment this, if you want to sync photos after the date (inclusive)
  # "-from yyyy-mm-dd"   # earliest date to sync (YYYY-MM-DD)

  # uncomment this, if you want to skip downloading photos
  # "-skip-download" # skip downloading photos, only update the database
)

docker run --rm \
  --name "gphotos-sync-${SYNC_JOB_NAME}" \
  -v "$PROFILE_DIR":/profile \
  -v "$DOWNLOADS_DIR":/downloads  \
  -v "$PHOTOS_DIR":/PhotoLibrary \
  -v "$DB_DIR":/db \
  gphotos-sync:latest \
  ${sync_args[*]}

rm -f ${WORK_DIR}/profile/Singleton*
