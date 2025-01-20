Inspired by / based on https://github.com/JakeWharton/docker-gphotos-sync (thanks Jake!)

Example docker compose definition:

```yaml
  gphotos-sync:
    build:
      context: https://github.com/spraot/gphotos-sync.git#d62f1891d6cb2371feaac1a0c859194d83f5cc1b # set to latest commit
      # args:
      #   - GPHOTOS_CDP_VERSION=github.com/spraot/gphotos-cdp@4821f280 # Override the version of gphotos-cdp to use
    container_name: gphotos-sync
    restart: unless-stopped
    privileged: true # chrome seems to need this to run as 1000:1000
    volumes:
      - ./profile:/tmp/gphotos-cdp
      - ./photos:/download
    environment:
      - PUID=1000
      - PGID=1000
      - CRON_SCHEDULE=27 * * * *
      - RESTART_SCHEDULE=26 1 * * 0
```

Clone this repo and use ./doauth.sh to create and authenticated profile dir and ./test.sh to test that it works. Or use ./test.sh to do your initial sync.

RESTART_SCHEDULE sets how ofen you start the sync from the beginning in order to check for files that were uploaded with an older date. Normally sync will only download files with a newer "date taken" than the most recently downloaded file.
