FROM golang:1.23-bookworm AS build
# ENV GO111MODULE=on

RUN go install github.com/spraot/gphotos-cdp@322ec982

FROM debian:bookworm-slim

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV CHROME_PACKAGE=google-chrome-stable_current_amd64.deb
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
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
