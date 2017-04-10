FROM ubuntu:latest

MAINTAINER "TheAssassin <theassassin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y libarchive13 wget desktop-file-utils aria2 fuse gnupg2 build-essential file && \
    mkdir /workspace

ARG UID
ARG GID
RUN addgroup --gid $GID builder && \
    adduser --uid $UID --gid $GID --disabled-login --disabled-password builder && \
    chown $UID.$GID /workspace

USER $UID
WORKDIR /workspace
