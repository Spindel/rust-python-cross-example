# These steps don't seem to work if we use it in CI.
# I would prefer to use this, but sadly, that doesn't happen.
#FROM docker.io/library/debian AS armhf-lib
#RUN  apt-get update \
#  && apt-get install -y --no-install-recommends qemu-user-static fakeroot debootstrap
#
#RUN fakeroot qemu-debootstrap --arch=armhf --include=python3-minimal --variant=minbase buster /armhf-lib
#

FROM docker.io/library/rust AS builder
#COPY --from=armhf-lib  /armhf-lib
COPY armhf-lib /armhf-lib
ENV PYO3_CROSS_LIB_DIR /armhf-lib/usr/lib/

# Need to do separate calls to apt-get to prevent debian from expanding the
# dependency graphs, as packages in the command line are not considered when
# resolving dependencies.
RUN dpkg --add-architecture armhf \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends curl git build-essential \
	&& apt-get install -y --no-install-recommends libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf

# Rust deps
RUN rustup target add armv7-unknown-linux-gnueabihf \
	&& cargo install maturin \
	&& rm -rf /usr/local/cargo/registry
