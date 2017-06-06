FROM ubuntu

RUN apt update && \
	apt install -qy \
		curl \
		ruby-dev ruby-bundler \
		make gcc \
	&& \
	apt clean
