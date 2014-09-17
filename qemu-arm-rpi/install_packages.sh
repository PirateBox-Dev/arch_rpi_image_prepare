#!/bin/sh

## This script is for running on a PI 
##    - Tested in a QEMU environment.
##    - Mounted the "to-prepare" image at sdb via CLI (see other script)
##    - It requires a working internet connection for downloading the dependencies
##

DEV_NODE=/dev/sdb2
SUDO=""

$SUDO mkdir -p /mnt/image
$SUDO mount $DEV_NODE /mnt/image
$SUDO mount -o bind /proc /mnt/image/proc
$SUDO mount -o bind /dev  /mnt/image/dev

$SUDO pacman --noconfirm -r /mnt/image -Sy
$SUDO pacman --noconfirm -r /mnt/image -U /prebuild/*pkg.tar.xz 


##--- additional wifi stuff
## verify ... $SUDO pacman --noconfirm -r /mnt/image -S dkms-8188eu dkms-8192cu


#-- aquire librarybox package
$SUDO pacman --noconfirm -r /mnt/image -U /prebuild/staging/*pkg.tar.xz 


## cleanup Image
$SUDO pacman --noconfirm -r /mnt/image -Scc


echo "if you are done run:"
echo "umount -R /mnt/image"
