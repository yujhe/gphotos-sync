#!/usr/bin/env bash

PROFILE_DIR=${PROFILE_DIR:-./profile}

docker build . --tag gphotos-sync || exit 1

rm -f ${PROFILE_DIR}/Singleton*

docker run -it \
    -v ./${PROFILE_DIR}:/tmp/gphotos-cdp \
    -v ./photos:/download \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    --privileged \
    gphotos-sync:latest \
    no-cron

rm -f ${PROFILE_DIR}/Singleton*