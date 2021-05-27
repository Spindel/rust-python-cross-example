# Spid is testing out things


## Generate a python3 armv7 root

LIBDIR=$(mktemp --directory)

podman run -ti --arch=arm --variant=v7 -v $(LIBDIR):/armhf-lib:rw,Z docker.io/arm32v7/debian:10  
        apt-get update
        apt-get install -y --no-install-recommends  python3-minimal 
        cp -r /usr /armhf-lib/


## Build a python wheel


podman run -ti --rm -v $LIBDIR:/armhf-lib:rw,Z -v $(pwd):/build:rw,Z    docker.io/library/rust

### Prepare the build environment ( this could be a container)
	dpkg --add-architecture armhf
	apt-get update
	apt-get install -y curl git build-essential
	apt-get install -y --no-install-recommends libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf
	rustup target add armv7-unknown-linux-gnueabihf
	cargo install maturin

### Build the stuff
	cd /build
	PYO3_CROSS_LIB_DIR=/armhf-lib/usr/lib/ cargo build --target armv7-unknown-linux-gnueabihf
	PYO3_CROSS_LIB_DIR=/armhf-lib/usr/lib/ maturin build  --target armv7-unknown-linux-gnueabihf
