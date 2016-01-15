#!/bin/bash
# Run the raw arch image in QEMU
# SSH port of image is redirected to port 2222 of host machine

qemu-system-arm -kernel kernel-qemu-rpi -cpu arm1176 -m 256 \
  -M versatilepb -net nic -net user -redir tcp:2222::22 \
  -no-reboot -serial stdio \
  -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
  -hda ../raw_arch_image_file
