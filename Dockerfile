FROM docker.io/library/rust AS builder
WORKDIR /

# Need to do separate calls to apt-get to prevent debian from expanding the
# dependency graphs, as packages in the command line are not considered when
# resolving dependencies.
RUN dpkg --add-architecture armhf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends fakeroot debootstrap \
	&& apt-get install -y --no-install-recommends curl git build-essential \
	&& apt-get install -y --no-install-recommends libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf

RUN fakeroot debootstrap --arch=armhf --include=python3-minimal --variant=minbase buster /armhf-lib

# Rust deps
RUN rustup target add armv7-unknown-linux-gnueabihf \
	&& cargo install maturin 

ENV PYO3_CROSS_LIB_DIR /armhf-lib/usr/lib/
