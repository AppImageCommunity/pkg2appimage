FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get install -y \
		libcurl3 \
		libfuse2 \
		libgconf-2-4 \
		libglib2.0 \
		librtmp0 \
		libxss1 \
		openssl \
		wget

ADD Recipe /Recipe

VOLUME /out

ENTRYPOINT ["bash", "-ex", "/Recipe"]
