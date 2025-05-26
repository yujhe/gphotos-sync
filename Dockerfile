FROM golang:1.24-bookworm AS build

ENV DEFAULT_GPHOTOS_CDP_VERSION=github.com/yujhe/gphotos-cdp@1.0.1
ENV GO111MODULE=on

ARG GPHOTOS_CDP_VERSION=$DEFAULT_GPHOTOS_CDP_VERSION
RUN go install $GPHOTOS_CDP_VERSION

FROM debian:bookworm-slim

ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CHROME_PACKAGE=google-chrome-stable_current_amd64.deb \
    DEBIAN_FRONTEND=noninteractive \
    ALBUMS= \
    WORKER_COUNT=6 \
    GPHOTOS_CDP_ARGS=

# FIXME: remove unused packages
RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        exiftool \
        wget \
        sudo \
    --no-install-recommends && \
    wget https://dl.google.com/linux/direct/$CHROME_PACKAGE && \
    apt install -y ./$CHROME_PACKAGE && \
    rm ./$CHROME_PACKAGE && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /go/bin/gphotos-cdp /usr/bin/
COPY scripts /app
RUN chmod +x /app/*.sh

ENTRYPOINT ["gphotos-cdp"]
CMD ["-h"]
