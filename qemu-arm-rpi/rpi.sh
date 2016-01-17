#!/bin/bash
# Run the raw arch image in QEMU
# SSH port of image is redirected to port 2222 of host machine

qemu-system-arm -kernel kernel-qemu -M versatilepb -cpu arm1176 -m 256 \
  -no-reboot -net nic -net user -redir tcp:2222::22 \
  -drive file=../piratebox-rpi.img,index=0,media=disk,format=raw \
  -append "root=/dev/sda2 rootfstype=ext4 rw panic=1"
