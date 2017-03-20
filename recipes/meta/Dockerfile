FROM ubuntu:latest

MAINTAINER "TheAssassin <theassassin@users.noreply.github.com>"

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/archive.ubuntu.com/ftp.fau.de/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y libarchive13 wget desktop-file-utils aria2 fuse gnupg2 build-essential file && \
    mkdir /workspace

ADD . /workspace

WORKDIR /workspace
