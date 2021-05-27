FROM docker.io/library/rust AS builder
WORKDIR /

RUN dpkg --add-architecture armhf  && apt-get update
RUN apt-get install -y --no-install-recommends fakeroot debootstrap
RUN fakeroot debootstrap --arch=armhf --include=python3-minimal --variant=minbase buster /armhf-lib
RUN ls -la /armhf-lib

WORKDIR /build

RUN apt-get install -y --no-install-recommends curl git build-essential
# Need to do separate to prevent debian from expanding the graph
RUN apt-get install -y --no-install-recommends libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf

# Rust deps
RUN rustup target add armv7-unknown-linux-gnueabihf
RUN cargo install maturin 

ENV PYO3_CROSS_LIB_DIR /armhf-lib/usr/lib/
RUN maturin build --strip --target armv7-unknown-linux-gnueabihf
