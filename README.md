# Cross Compiling a Rust + Python project in GitLab CI


So, this project doesn't do anything magical, but it is an attempt to get a
sustainable CI/CD pipeline set up  targetting  armv7 (arm32, armhf, etc)
Debian, in GitLab CI.

This project uses the following:

[Maturin](https://github.com/PyO3/maturin)
[PyO3](https://github.com/PyO3/pyo3)
[Debian](https://www.debian.org/)

The goal is to build a Python wheel that can be installed on an Debian armhf
system with "pip install".


## Minimal rust code example

	I started with an example crate from the maturin project:
	https://github.com/PyO3/maturin/tree/main/test-crates/pyo3-mixed

## Generate a python3 armv7 root

To build against the python3 setup, we need a chroot with armhf python installation in:

	apt-get update
	apt-get install -y --no-install-recommends fakeroot debootstrap
	fakeroot  debootstrap --arch=armhf --include=python3-minimal --variant=minbase buster  /armhf-lib

On my machine, I have qemu-user-static installed, so the above can be run in a
simple debian container, and it will work.

In CI, that wasn't an option, so the actual steps in my .gitlab-ci.yml differ
slightly, in that it uses qemu-user-static with the qemu-debootstrap wrapper
around debootstrap.

## Get a build environment

To actually build the rust code, with cross compilation, etc. we need a
reliable build container. I followed a similar approach to my [previous
exploration](https://gitlab.com/Spindel/rust-cross-example)

	FROM docker.io/library/rust AS builder
	RUN dpkg --add-architecture armhf
	RUN apt-get update
	RUN apt-get install -y --no-install-recommends curl git build-essential
	RUN apt-get install -y --no-install-recommends libc6-armhf-cross libc6-dev-armhf-cross gcc-arm-linux-gnueabihf
	RUN rustup target add armv7-unknown-linux-gnueabihf
	RUN cargo install maturin

These steps mean I have pretty much all I need available to cross-compile in a
single container. Tee one thing remaining is to get the "armhf-lib" artifact
from the first step into the rust compile container.

In my local tests, that was solved by using volume mounts when running the
container.

    podman run -ti --rm -v /tmp/armhf-lib:/armhf-lb:rw,Z -v $(pwd):/build:rw  rust

However, that isn't a suitable way for CI, so in my gitlab-ci configuration,
I'm simply placing the /armhf-lib in my build container.


## Build the stuff

Building code with maturin was surprisingly simple and easy, once the
cross-compilation environment was available:

	cd /build
	PYO3_CROSS_LIB_DIR=/armhf-lib/usr/lib/ cargo build --target armv7-unknown-linux-gnueabihf
	PYO3_CROSS_LIB_DIR=/armhf-lib/usr/lib/ maturin build  --target armv7-unknown-linux-gnueabihf


### Test execute

And to run the arm code, with podman (on my machine, where qemu-user-static- is installed)


	podman run -ti --arch=arm --variant=v7 -v $(pwd):/build:rw,Z docker.io/arm32v7/debian:10
		apt-get update
		apt-get install -y --no-install-recommends  python3-minimal python3-pip
		python3 -m pip install -U pip
                python3 -m pip install /build/target/wheels/libspidtest-0.1.0-cp37-cp37m-manylinux_2_24_armv7l.whl


And that was pretty much it.
