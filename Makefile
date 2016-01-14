ARCH?=rpi

ifeq ($(ARCH),rpi)
## based on http://archlinuxarm.org/platforms/armv6/raspberry-pi
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
ARCH_FILE:=ArchLinuxARM-rpi-latest.tar.gz
endif

ifeq ($(ARCH),rpi2)
## based on http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
ARCH_FILE:=ArchLinuxARM-rpi-2-latest.tar.gz
endif

# Staging packages
SERVICE_PIRATEBOX_URL:=https://raw.githubusercontent.com/PirateBox-Dev/PirateBoxScripts_Webserver/master/BuildScripts/piratebox.service
SERVICE_TIMESAVE_URL:=https://raw.githubusercontent.com/PirateBox-Dev/PirateBoxScripts_Webserver/master/BuildScripts/timesave.service
MOTD_URL:=https://raw.githubusercontent.com/PirateBox-Dev/PirateBoxScripts_Webserver/master/BuildScripts/RPi_motd.txt

# Name of the generated image file
IMAGE_FILENAME=./raw_arch_image_file

# Mount points
MOUNT_FOLDER:=./mount
BOOT_FOLDER:=$(MOUNT_FOLDER)/boot
ROOT_FOLDER:=$(MOUNT_FOLDER)/root

SRC_PACKAGE_FOLDER:="./pre_build_packages"
TGT_PACKAGE_FOLDER:=$(ROOT_FOLDER)/prebuild

# LibraryBox Specific pacakges
SRC_STAGING_FOLDER:="./staging_packages"
TGT_STAGING_FOLDER:=$(TGT_PACKAGE_FOLDER)/staging

# Image_Prepare-Script
IMAGE_PREPARE=./qemu-arm-rpi/install_packages.sh
IMAGE_FINALIZE=./qemu-arm-rpi/piratebox_install.sh

# in Byte ; 2GiB * 1024 MiB    1024 KiB    1024 Byte
IMAGESIZE:=$(shell echo  2*1024*1024*1024 | bc)
BLOCKSIZE=512
NEEDED_SECTOR_COUNT=$(shell echo ${IMAGESIZE} / ${BLOCKSIZE} | bc )

DEV_FLAT_FILE=./dev_node_name
LO_DEVICE=

all: $(IMAGE_FILENAME) partitions get_lodevice format prepare_environment \
	install_files chroot chroot_cleanup umount free_lo

$(MOUNT_FOLDER) $(BOOT_FOLDER) $(ROOT_FOLDER):
	mkdir -p  $@

$(IMAGE_FILENAME):
	@echo "## Creating image file"
	@echo "* Filename\t$(IMAGE_FILENAME)"
	@echo "* Blocksize\t$(BLOCKSIZE)"
	@echo "* Sectors\t$(NEEDED_SECTOR_COUNT)"
	@echo "* Total size\t$(IMAGESIZE) Bytes"
	@dd if=/dev/zero bs=$(BLOCKSIZE) count=$(NEEDED_SECTOR_COUNT) status=none | pv --size $(IMAGESIZE) | dd of=$@ bs=$(BLOCKSIZE) count=$(NEEDED_SECTOR_COUNT) status=none

$(DEV_FLAT_FILE):
	LO_DEVICE=$(shell sudo losetup --partscan  --find --show $(IMAGE_FILENAME) > $(DEV_FLAT_FILE) )

get_lodevice:
	$(eval LO_DEVICE=$(shell sudo losetup --partscan --find --show $(IMAGE_FILENAME)))
	@echo "## Using loopback device: $(LO_DEVICE)"

partitions:
#Partitions
## as it is no blockdevice, we need to specify the blocksize
## Empty Partionts
## Then with first n -> 100MB dos partition
##           2nd   n -> fill the rest with another primary partition
	@echo "## Creating partitions..."
	cat fdisk_cmd.txt | sudo fdisk $(IMAGE_FILENAME) > /dev/null
	@sync

format: format_p1 format_p2

format_p1:
	@echo "## Formatting boot partition..."
	sudo  mkfs.vfat "$(LO_DEVICE)p1" > /dev/null

format_p2:
	@echo "## Formatting root partition..."
	sudo  mkfs.ext4 "$(LO_DEVICE)p2" > /dev/null

free_lo:
ifneq ("$(wildcard $(LO_DEVICE))", "")
	sudo losetup -d $(LO_DEVICE)
	sudo rm -f $(DEV_FLAT_FILE)
endif

$(ARCH_FILE):
	wget -c -O $(ARCH_FILE) $(ARCH_URL)

get_staging:
	@echo "## Obtaining staging packages..."
	wget --no-verbose -c -P $(SRC_STAGING_FOLDER) $(SERVICE_PIRATEBOX_URL)
	wget --no-verbose -c -P $(SRC_STAGING_FOLDER) $(SERVICE_TIMESAVE_URL)
	wget --no-verbose -c -P $(SRC_STAGING_FOLDER) $(MOTD_URL)

mount: mount_boot mount_root

mount_boot: $(BOOT_FOLDER) get_lodevice
	sudo mount "$(LO_DEVICE)p1"  $(BOOT_FOLDER)

mount_root: $(ROOT_FOLDER) get_lodevice
	sudo mount "$(LO_DEVICE)p2" $(ROOT_FOLDER)

umount: umount_boot umount_root

umount_boot:
	- sudo umount $(BOOT_FOLDER)

umount_root:
	- sudo umount $(ROOT_FOLDER)

prepare_environment: $(ARCH_FILE) get_staging mount_boot mount_root

install_files:
	@echo "## Moving files to their place..."
	sudo mkdir -p $(TGT_PACKAGE_FOLDER) $(TGT_STAGING_FOLDER) > /dev/null
	sudo tar -xf $(ARCH_FILE) -C $(ROOT_FOLDER) --warning=none
	sudo cp -rv $(SRC_PACKAGE_FOLDER)/$(ARCH)/* $(TGT_PACKAGE_FOLDER) > /dev/null
	- sudo cp -rv $(SRC_STAGING_FOLDER)/* $(TGT_STAGING_FOLDER) > /dev/null
	sudo cp $(IMAGE_PREPARE) $(TGT_STAGING_FOLDER) > /dev/null
	sudo cp $(IMAGE_FINALIZE) $(TGT_STAGING_FOLDER) > /dev/null
	sudo mv $(ROOT_FOLDER)/boot/* $(BOOT_FOLDER) > /dev/null
	sudo cp /usr/bin/qemu-arm-static $(ROOT_FOLDER)/usr/bin > /dev/null
	sudo sh -c 'echo "" > $(ROOT_FOLDER)/etc/fstab'
	@sync

chroot: chroot_prepare
	@echo "## Installing packages..."
	sudo chroot $(ROOT_FOLDER) sh -c "/prebuild/staging/install_packages.sh > /dev/null"
	@echo "## Installing PirateBox..."
	sudo chroot $(ROOT_FOLDER) sh -c "/prebuild/staging/piratebox_install.sh > /dev/null"
	sudo chroot $(ROOT_FOLDER) sh -c "sudo adduser alarm sudo"

chroot_prepare:
	@echo "## Preparing chroot environment..."
	- sudo mv $(ROOT_FOLDER)/etc/resolv.conf $(ROOT_FOLDER)/etc/resolv.conf.bak > /dev/null
	sudo cp /etc/resolv.conf $(ROOT_FOLDER)/etc/resolv.conf > /dev/null
	sudo mount -t proc proc $(ROOT_FOLDER)/proc/ > /dev/null

chroot_cleanup:
	- sudo mv $(ROOT_FOLDER)/etc/resolv.conf.bak $(ROOT_FOLDER)/etc/resolv.conf
	- sudo umount $(ROOT_FOLDER)/proc/ > /dev/null

clean: chroot_cleanup umount free_lo
	rm -f $(IMAGE_FILENAME) > /dev/null
	sudo rm -rf $(MOUNT_FOLDER) > /dev/null

cleanall: clean
	rm -f $(ARCH_FILE)
	rm -f $(SRC_STAGING_FOLDER)/*

format_only: get_lodevice format free_lo

create_arch_image: $(IMAGE_FILENAME) partitions get_lodevice format prepare_environment install_files umount free_lo
