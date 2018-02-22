# Default build variables, they may be passed via command line
ARCH?=rpi
BUILD?=$(shell date +%d-%m-%Y)
VERSION?="1.1.4"
SOURCE?="piratebox"
BRANCH?="master"

ifeq ($(ARCH),rpi)
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
ARCH_FILE:=ArchLinuxARM-rpi-latest.tar.gz
endif

ifeq ($(ARCH),rpi2)
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
ARCH_FILE:=ArchLinuxARM-rpi-2-latest.tar.gz
endif

.PHONY: all package dist clean cleanall

PIRATEBOX_WS_GIT:=https://github.com/PirateBox-Dev/PirateBoxScripts_Webserver.git

PIRATEBOX_PACKAGE_FOLDER=piratebox-ws

# Name of the generated image file
IMAGE_FILENAME=./$(SOURCE)_$(ARCH)_$(VERSION)-$(BUILD).img
ZIPPED_FILENAME=$(IMAGE_FILENAME).zip

# Mount points
MOUNT_FOLDER:=./mount
BOOT_FOLDER:=$(MOUNT_FOLDER)/boot
ROOT_FOLDER:=$(MOUNT_FOLDER)/root

#Package cache
CACHE_FOLDER:=./pkg_cache/$(ARCH)/
CHROOT_CACHE:=$(ROOT_FOLDER)/var/cache/pacman/pkg

SRC_PACKAGE_FOLDER:="./packages"
TGT_PACKAGE_FOLDER:=$(ROOT_FOLDER)/prebuild

SRC_CHROOT_FOLDER:=./chroot
TGT_CHROOT_FOLDER:=$(ROOT_FOLDER)/root/chroot

# Imagesize should be 2GB
IMAGESIZE:=$(shell echo "2 * 1024 * 1024 * 1024" | bc)
BLOCKSIZE=512
NEEDED_SECTOR_COUNT=$(shell echo ${IMAGESIZE} / ${BLOCKSIZE} | bc )

LO_DEVICE=

all: $(ARCH_FILE) $(IMAGE_FILENAME) partition format mount_image  \
	install_files mount_cache chroot_install umount_cache \
	chroot_cleanup umount free_lo

dist: all package

$(MOUNT_FOLDER) $(BOOT_FOLDER) $(ROOT_FOLDER) $(CACHE_FOLDER):
	@mkdir -p $@

$(IMAGE_FILENAME):
	@echo "## Creating $(ARCH) image file"
	@echo "* Filename\t$(IMAGE_FILENAME)"
	@echo "* Blocksize\t$(BLOCKSIZE)"
	@echo "* Sectors\t$(NEEDED_SECTOR_COUNT)"
	@echo "* Total size\t$(IMAGESIZE) Bytes (2GB)"
	@dd if=/dev/zero bs=$(BLOCKSIZE) count=$(NEEDED_SECTOR_COUNT) status=none | pv --size $(IMAGESIZE) | dd of=$@ bs=$(BLOCKSIZE) count=$(NEEDED_SECTOR_COUNT) status=none
	@echo ""

get_lodevice:
	$(eval LO_DEVICE=$(shell sudo losetup --partscan --find --show $(IMAGE_FILENAME)))

## Partitions
# as it is no blockdevice, we need to specify the blocksize
# Empty Partionts
# Then with first n -> 100MB dos partition
# 2nd n -> fill the rest with another primary partition
partition:
	@echo "## Creating partitions..."
	cat ./config/fdisk_cmd.txt | sudo fdisk $(IMAGE_FILENAME) > /dev/null
	@sync
	@echo ""

format: get_lodevice
	@echo "## Formatting partitions..."
	sudo  mkfs.vfat "$(LO_DEVICE)p1" > /dev/null
	sudo  mkfs.ext4 "$(LO_DEVICE)p2" > /dev/null
	@echo ""

free_lo:
	@echo  "losetup detach  $(LO_DEVICE)"
	- test ! -z "$(LO_DEVICE)" && sudo losetup -d $(LO_DEVICE)

$(ARCH_FILE):
	@echo "## Obtaining root filesystem..."
	@wget -q --show-progress -c $(ARCH_URL)
	@echo ""

$(PIRATEBOX_PACKAGE_FOLDER):
	@echo "## Obtaining piratebox scripts..."
	git clone $(PIRATEBOX_WS_GIT) $(PIRATEBOX_PACKAGE_FOLDER) > /dev/null
## Hotfix for Development folder breaking checkout
	- test -e $(PIRATEBOX_PACKAGE_FOLDER)/$(BRANCH) && \
	   	cd $(PIRATEBOX_PACKAGE_FOLDER) && git checkout origin/$(BRANCH)
	cd $(PIRATEBOX_PACKAGE_FOLDER) && git checkout $(BRANCH) > /dev/null
	@echo ""

build_piratebox: $(PIRATEBOX_PACKAGE_FOLDER)
	@echo "# Building piratebox package..."
	cd $(PIRATEBOX_PACKAGE_FOLDER) && make
	@echo ""

mount_image: $(BOOT_FOLDER) $(ROOT_FOLDER) $(CACHE_FOLDER) get_lodevice
	@echo "## Mounting image..."
	sudo mount "$(LO_DEVICE)p1" $(BOOT_FOLDER)
	sudo mount "$(LO_DEVICE)p2" $(ROOT_FOLDER)
	@echo ""

mount_cache:
	@echo "## Mounting package cache..."
	sudo mount -o bind  "$(CACHE_FOLDER)" "$(CHROOT_CACHE)"

umount_cache:
	@echo "## Unmounting package cache..."
	- sudo umount $(CHROOT_CACHE)
	@echo ""

umount:
	@echo "## Unmounting image..."
	- sudo umount $(BOOT_FOLDER)
	- sudo umount -R  $(ROOT_FOLDER)
	@echo ""

install_files: build_piratebox
	@echo "## Moving files to their place..."
	sudo mkdir -p $(TGT_PACKAGE_FOLDER) > /dev/null
	sudo mkdir -p $(TGT_CHROOT_FOLDER) > /dev/null
	sudo tar -xf $(ARCH_FILE) -C $(ROOT_FOLDER) --warning=none
	sudo cp -rv $(SRC_PACKAGE_FOLDER)/$(ARCH)/* $(TGT_PACKAGE_FOLDER) > /dev/null
	sudo cp $(PIRATEBOX_PACKAGE_FOLDER)/*.tar.gz "$(ROOT_FOLDER)/root"
	sudo cp -rv $(SRC_CHROOT_FOLDER)/* $(TGT_CHROOT_FOLDER) > /dev/null
	sudo mv $(ROOT_FOLDER)/boot/* $(BOOT_FOLDER) > /dev/null
	sudo cp chroot/wpa_supplicant.conf $(BOOT_FOLDER)/ > /dev/null
	sudo cp /usr/bin/qemu-arm-static $(ROOT_FOLDER)/usr/bin > /dev/null
	sudo sh -c 'echo "/dev/mmcblk0p1 /boot vfat defaults,nofail 0 0" > $(ROOT_FOLDER)/etc/fstab'
	@sync
	@echo ""

chroot_install:
	@echo "## chroot'ing to RPi environment..."
	- sudo mv -f $(ROOT_FOLDER)/etc/resolv.conf $(ROOT_FOLDER)/etc/resolv.conf.bak > /dev/null
	sudo cp /etc/resolv.conf $(ROOT_FOLDER)/etc/resolv.conf > /dev/null
	sudo mount -t proc proc $(ROOT_FOLDER)/proc/ > /dev/null
	sudo mount -o bind $(BOOT_FOLDER) $(ROOT_FOLDER)/boot/ > /dev/null
	sudo mount -o bind /dev $(ROOT_FOLDER)/dev/ > /dev/null
	@echo ""
	@echo "# Adjusting for SD card optmization..."
	sudo chroot $(ROOT_FOLDER) sh -c "/root/chroot/sd_optimizations.sh > /dev/null"
	@echo ""
	@echo "# Installing packages..."
	sudo chroot $(ROOT_FOLDER) sh -c "/root/chroot/install_packages.sh > /dev/null"
	@echo ""
	@echo "# Configuring sudo..."
	sudo chroot $(ROOT_FOLDER) sh -c "/root/chroot/configure_sudo.sh > /dev/null"
	@echo ""
	@echo "# Installing PirateBox..."
	sudo chroot $(ROOT_FOLDER) sh -c "/root/chroot/install_piratebox.sh "$(BUILD)"  "$(VERSION)" > /dev/null"
	@echo ""

chroot_cleanup:
	@echo "## Cleaning up chroot..."
	@echo "Cleaning up image..."
	- sudo chroot $(ROOT_FOLDER) sh -c "pacman --noconfirm -Scc"
	# - sudo mv $(ROOT_FOLDER)/etc/resolv.conf.bak $(ROOT_FOLDER)/etc/resolv.conf
	@echo ""

clean: chroot_cleanup umount free_lo
	@echo "## Cleaning up..."
	rm -f $(IMAGE_FILENAME) > /dev/null
	rm -f $(ZIPPED_FILENAME) > /dev/null
	sudo rm -rf $(MOUNT_FOLDER) > /dev/null
	@echo ""

cleanall: clean
	rm -rf $(PIRATEBOX_PACKAGE_FOLDER) > /dev/null
	rm -f $(ARCH_FILE) > /dev/null
	rm -rf $(CACHE_FOLDER) > /dev/null

package:
	@echo "## Packaging image for distribution..."
	zip $(ZIPPED_FILENAME) $(IMAGE_FILENAME)
	@echo ""
