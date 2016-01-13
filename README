# Arch RPI Image Prepare
This repository contains tools to create a 2GB SD card image based upon latest arch sources.

## Required Tools
To create an image you will need to have the following tools available on your system:
* sudo environment
* losetup from util-linux 2.2  (at least)
* mkfs.vfat
* mkfs.ext4
* wget
* fdisk
* bc

## Build the image
Run the following make target to acquire all dependencies and build the image:
```Bash
make create_arch_image
```

Step 2:
	Run make create_arch_image

Step 3:
	Create a woring qemu image once.
		# Need to be done once
		cd qemu-arm-rpi
		cp ../raw_arch_image_file  install_qemu_image
		./run_qemu.sh  #need X

	The first bootup will fail. So we fix the fstab entry for that
	(maintenance password: root)
		echo "" > /etc/fstab
		reboot
	Rerun
		./run_qemu.sh	Rerun

	Enable network after login (root/root)
	dhcpcd eth0

Step 4:
	Run  inside the running and working qemu
