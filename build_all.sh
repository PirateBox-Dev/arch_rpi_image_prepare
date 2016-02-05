#!/bin/sh
# Build images for:
# * RPi 1
# * RPi 2

make ARCH=rpi
make clean
make ARCH=rpi2
make clean
