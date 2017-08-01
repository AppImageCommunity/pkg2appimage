FROM ubuntu:latest

MAINTAINER "TheAssassin <theassassin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y libarchive13 wget desktop-file-utils aria2 fuse gnupg2 build-essential file && \
    mkdir /workspace

ARG UID
ARG GID
#The root user is already present; this causes adduser to fail if the image is built as root,
#which is always the case if the docker client is invoked as root on the host
#That's why the "|| true" is needed
RUN addgroup --gid $GID builder || true && \
    adduser --uid $UID --gid $GID --disabled-login --disabled-password builder || true && \
    chown $UID.$GID /workspace

USER $UID
WORKDIR /workspace
