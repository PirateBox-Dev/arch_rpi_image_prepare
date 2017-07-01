#!/bin/sh
set -e 
# Build images for:
# * RPi 1
# * RPi 2

mkdir -p images
for arch in "rpi" "rpi2" ; do 
  make dist ARCH=$arch
  sync
  mv *.img.zip images 
  make clean ARCH=$arch
done
