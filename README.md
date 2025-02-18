Inspired by / based on https://github.com/JakeWharton/docker-gphotos-sync (thanks Jake!)

Example docker compose definition:

```yaml
  gphotos-sync:
    build:
      context: https://github.com/spraot/gphotos-sync.git
      # I recommend using a specific commit instead though:
      # context: https://github.com/spraot/gphotos-sync.git#{FULL_GIT_HASH}
      # Optionally override the version of gphotos-cdp to use (requires rebuilding the docker image):
      # args:
      #   - GPHOTOS_CDP_VERSION=github.com/spraot/gphotos-cdp@0e64b699
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

RESTART_SCHEDULE sets how ofen you start the sync from the beginning in order to check for files that were uploaded with an older date. Normally sync will only download files with a newer "date taken" than the most recently downloaded file. This works by deleting the .lastdone file and restarting the sync.

## Downloading an album

Set ALBUMS to a comma seperated list of album IDs, where the album URL is:

```
https://photos.google.com/album/{ALBUM_ID}
```

## Regarding language

It may be necessary to set your account language to "English (United States)" for this to work (see [#2](https://github.com/spraot/gphotos-sync/issues/2)). This is the likely cause if you see date parsing errors or similar.
