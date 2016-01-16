# Arch RPI Image Prepare
This repository contains tools to create a 2GB SD card image based upon latest arch sources including all dependencies for PirateBox.

## Required Tools
To create an image you will need to have the following tools available on your system:
* sudo environment
* losetup from util-linux 2.2  (at least)
* mkfs.vfat
* mkfs.ext4
* wget
* fdisk
* bc
* qemu-system-arm
* pv

## Build The RPi Image
Running **make** will acqurie all dependencies, install PirateBox and package the image for distribution:
```Bash
make
```

## Testing via Qemu
After the image is build it may be run in QEMU by invoking the helper script:
```Bash
cd qemu-arm-rpi
./rpi.sh
```

## Dumping image to SD card
To dump the raw image to an SD card run:
```Bash
sudo dd if=piratebox-rpi.img bs=2048 | pv | sudo dd of=/dev/mmcblk0 bs=2048
sync
```
