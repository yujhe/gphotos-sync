FROM dorowu/ubuntu-desktop-lxde-vnc

# Setup environment variables
ENV HOME=/home/abc \
    USER=abc \
    PGID=1000 \
    PUID=1000

RUN \
    # Create a non-root user
    addgroup abc --gid "${PGID}" --quiet \
    && adduser abc --uid "${PUID}" --gid "${PGID}" --disabled-password --gecos "" --quiet \
    && echo 'abc ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

COPY startup2.sh /startup2.sh

ENTRYPOINT [ "/startup2.sh" ]