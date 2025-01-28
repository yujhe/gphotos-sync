FROM golang:1.23-bookworm AS build

ARG GPHOTOS_CDP_VERSION=github.com/spraot/gphotos-cdp@0309ac77
ENV GO111MODULE=on

RUN go install $GPHOTOS_CDP_VERSION

FROM debian:bookworm-slim

ENV \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    CHROME_PACKAGE=google-chrome-stable_current_amd64.deb \
    DEBIAN_FRONTEND=noninteractive \
    LOGLEVEL=INFO \
    HEALTHCHECK_HOST="https://hc-ping.com"

RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        cron \
        wget \
        sudo \
    --no-install-recommends && \
    wget https://dl.google.com/linux/direct/$CHROME_PACKAGE && \
    apt install -y ./$CHROME_PACKAGE && \
    rm ./$CHROME_PACKAGE && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /go/bin/gphotos-cdp /usr/bin/
COPY src ./app/
RUN chmod +x /app/*.sh

USER root
ENTRYPOINT ["/app/start.sh"]
CMD [""]
