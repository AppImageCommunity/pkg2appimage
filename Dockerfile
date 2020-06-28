# Beware: only meant for use with pkg2appimage-with-docker

FROM ubuntu:trusty

MAINTAINER "TheAssassin <theassassin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKER_BUILD=1

RUN sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y apt-transport-https libcurl3-gnutls libarchive13 wget curl desktop-file-utils aria2 fuse gnupg2 build-essential file libglib2.0-bin git && \
    install -m 0777 -d /workspace

RUN adduser --system --uid 1000 test

WORKDIR /workspace
