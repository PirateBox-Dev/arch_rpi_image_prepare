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
* qemu-user-static
* pv

## Build The RPi Image
Running **make** will acqurie all dependencies, install PirateBox and package the image for distribution:
```Bash
make
```

By default this target builds the image for the *RPi 1* to build the image for *RPi 2* simply pass the *ARCH* variable:

```Bash
make ARCH=rpi2
```

There is a script in place that will build the images for *RPi 1 and RPi 2*, simply invoke:
```Bash
./build_all.sh
```

## Accessing Image via chroot
To access the image via chroot simply mount the image by invoking
```Bash
make mount_image
```

In case you need network access within the chroot mount proc to the mounted image:
```Bash
sudo mount -t proc proc /mount/root/proc/
```

Then chroot into the environment:
```Bash
sudo chroot /mount/root/
```

Do not forget to unmount the image when you are done:
```Bash
make umount_image
```

## Testing via Qemu
After the image is build it may be run in QEMU by invoking the helper script:
```Bash
cd qemu-arm-rpi
./rpi.sh
```
This only works with the RPi 1 image.

## Dumping image to SD card
To dump the raw image to an SD card run:
```Bash
sudo dd if=piratebox-rpi.img bs=2048 | pv | sudo dd of=/dev/mmcblk0 bs=2048
sync
```

## Supported Platforms by image
There are only two images needed to support all different Raspberry Pi boards.

### piratebox-rpi.img
* Raspberry Pi 1 A
* Raspberry Pi 1 A+
* Raspberry Pi 1 B
* Raspberry Pi 1 B+
* Raspberry Pi Zero

### piratebox-rpi2.img
* Raspberry Pi 2 B
