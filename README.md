Inspired by / based on https://github.com/JakeWharton/docker-gphotos-sync (thanks Jake!)

Example docker compose definition:

```yaml
services:
  gphotos-sync:
    build:
      context: https://github.com/spraot/gphotos-sync.git
      # I recommend using a specific commit instead though:
      # context: https://github.com/spraot/gphotos-sync.git#{FULL_GIT_HASH}
      # Optionally override the version of gphotos-cdp to use (requires rebuilding the docker image):
      # args:
      #   - GPHOTOS_CDP_VERSION=github.com/spraot/gphotos-cdp@COMMITISH
    container_name: gphotos-sync
    restart: unless-stopped
    privileged: true # chrome seems to need this to run as 1000:1000
    volumes:
      - ./profile:/tmp/gphotos-cdp
      - ./photos:/download
    environment:
      - PUID=1000  # Set to the current user's uid
      - PGID=1000  # Set to the current user's gid
      - CRON_SCHEDULE=27 * * * *
      - RESTART_SCHEDULE=26 1 * * 0
      - HEALTHCHECK_ID=d6e4a333-ce52-4129-9d3e-6722c3333333
      - LOGLEVEL=info
      - TZ=Europe/Berlin
      - ALBUMS=  # comma separated list of album IDs to sync
```

Clone this repo and use ./doauth.sh to create and authenticated profile dir and ./test.sh to test that it works. Or use ./test.sh to do your initial sync.

RESTART_SCHEDULE sets how ofen you start the sync from the beginning in order to check for files that were uploaded with an older date. Normally sync will only download files with a newer "date taken" than the most recently downloaded file. RESTART_SCHEDULE deletes the .lastdone file so that the next sync will start from the beginning (skipping already downloaded files).

Files deleted on Google Photos after being downloaded will not be deleted locally.

## Downloading an album

Set ALBUMS to a comma seperated list of album IDs, where the album URL is:

```
https://photos.google.com/album/{ALBUM_ID}
```

Note: the album must be sorted newest first, otherwise files added after the initial sync will not be downloaded.

## Regarding language

It may be necessary to set your account language to "English (United States)" for this to work (see [#2](https://github.com/spraot/gphotos-sync/issues/2)). This is the likely cause if you see date parsing errors or similar.

## Issues caused by highlight videos

Google Photos has a feature that automatically generates highlight videos. If you save these to your account, they can cause issues with syncing. Generally they cannot be downloaded or viewed from the browser and they occasionally cause the Google Photos UI (and therefore this sync service) to freeze. I suggest deleting these from your account and restarting the sync service. If you still see issues check that your .lastdone file does not contain the URL to a highlight video.