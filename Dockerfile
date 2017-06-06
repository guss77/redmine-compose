FROM ubuntu

RUN apt update && \
	apt install -qy \
		curl git \
		ruby-dev ruby-bundler \
		make gcc \
	&& \
	apt clean
