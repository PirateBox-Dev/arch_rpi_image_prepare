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

## Build The Base Image
Invoke the **create_arch_image** target to acquire all dependencies and build the image:
```Bash
make create_arch_image
```

## Install Dependencies and PirateBox
After the above step is completed you are left with a base Arch Linux image. Now we need to install all dependencies for PirateBox and piratebox itself. This is done by invoking the **chroot** target:
```Bash
make chroot
```

After this is through you are left with an image you can simply dump on your SD card and boot your RPI.

## All In One
For your convenience there is an **all** target to build the base image and install the dependencies:
```Bash
make all
```
or simply:
```Bash
make
```

## Testing via Qemu
After the image is build it may be run in QEMU by invoking the helper script:
```Bash
cd qemu-arm-rpi
./run_qemu-rpi.sh
```

## Dumping image to SD card
To dump the raw image to an SD card run:
```Bash
sudo dd if=raw_arch_image_file bs=512 | pv | sudo dd of=/dev/mmcblk0 bs=512
sync
```

## Compressing the image for upload
For uploading we want to achieve the smallest size possible. A lot of the available image space is not used, so we can simply compress it:
```Bash
tar -cvzf image.tar.gz raw_arch_image_file
```
