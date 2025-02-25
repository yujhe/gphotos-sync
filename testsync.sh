#!/usr/bin/env bash

PROFILE_DIR=${PROFILE_DIR:-./profile}

if [ ! -z "$SKIP_DOCKER_BUILD" ]; then
  docker build . --tag gphotos-sync || exit 1
fi

rm -f ${PROFILE_DIR}/Singleton*

GPHOTOS_CDP_SRC_ARGS=
if [ -n "$GPHOTOS_CDP_SRC" ]; then
    GPHOTOS_CDP_SRC_ARGS="-v $GPHOTOS_CDP_SRC:/gphotos-cdp -e GPHOTOS_CDP_SRC=/gphotos-cdp"
fi

docker run -it \
    -v ./${PROFILE_DIR}:/tmp/gphotos-cdp \
    -v ./photos:/download \
    ${GPHOTOS_CDP_SRC_ARGS} \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    --privileged \
    gphotos-sync:latest \
    no-cron

rm -f ${PROFILE_DIR}/Singleton*