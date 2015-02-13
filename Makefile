#Needs BC package
#extra/bc 1.06.95-1
#     An arbitrary precision calculator language 


##based up http://archlinuxarm.org/platforms/armv6/raspberry-pi
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
ARCH_FILE:=ArchLinuxARM-rpi-latest.tar.gz
IMAGE_FILENAME=./raw_arch_image_file 

MOUNT_FOLDER:=./mount
BOOT_FOLDER:=$(MOUNT_FOLDER)/boot
ROOT_FOLDER:=$(MOUNT_FOLDER)/root

SRC_PACKAGE_FOLDER:="./pre_build_packages"
TGT_PACKAGE_FOLDER:=$(ROOT_FOLDER)/prebuild

## LibraryBox Specific pacakges
SRC_STAGING_FOLDER:="./staging_packages"
TGT_STAGING_FOLDER:=$(TGT_PACKAGE_FOLDER)/staging

##Image_Prepare-Script
IMAGE_PREPARE=./qemu-arm-rpi/install_packages.sh

# in Byte ; 2GiB * 1024 MiB    1024 KiB    1024 Byte
#IMAGESIZE=$(shell echo $( 2   \*  1024     \*  1024  \*   1024 ))
IMAGESIZE:=$(shell echo  2*1024*1024*1024 | bc  )#Sector size like my Raspbian image 
#  in Byte
SECTORSIZE=512
BLOCKSIZE=512
NEEDED_SECTOR_COUNT=$(shell echo ${IMAGESIZE} / ${SECTORSIZE} | bc ) 

DEV_FLAT_FILE=./dev_node_name
LO_DEVICE=$(shell cat ${DEV_FLAT_FILE})

$(MOUNT_FOLDER) $(BOOT_FOLDER) $(ROOT_FOLDER):
	mkdir -p  $@

$(IMAGE_FILENAME): 
	echo "Creating image file size: " ${IMAGESIZE}
	echo " .. Filename " $(IMAGE_FILENAME)
	echo "    Blocksize " $(BLOCKSIZE)
	echo "    Needed Sectors " $(NEEDED_SECTOR_COUNT)
	echo "    Results in "$(IMAGESIZE)" B "
	dd if=/dev/zero of=$@  bs=$(BLOCKSIZE)  count=$(NEEDED_SECTOR_COUNT)

$(DEV_FLAT_FILE): 
	$(shell sudo losetup --partscan  --find --show $(IMAGE_FILENAME) > $(DEV_FLAT_FILE) )

get_lodevice: $(DEV_FLAT_FILE)
	echo "got: " $(LO_DEVICE)

partitions:
#Partitions
## as it is no blockdevice, we need to specify the blocksize
## Empty Partionts
## Then with first n -> 100MB dos partition
##           2nd   n -> fill the rest with another primary partition
	echo "Creating partitions"
	cat fdisk_cmd.txt | sudo fdisk    $(IMAGE_FILENAME) 
	sync
	


format_p1:
	echo "Formatting discs"
	echo " ... Format  boot partition"
	sudo  mkfs.vfat $(LO_DEVICE)"p1"

format_p2:
	echo " ... Format  root partition"
	sudo  mkfs.ext4 $(LO_DEVICE)"p2"

free_lo:
	- sudo losetup -d $(LO_DEVICE)
	- sudo rm $(DEV_FLAT_FILE)


$(ARCH_FILE):
	wget -c -O $(ARCH_FILE) $(ARCH_URL) 


mount_boot: $(BOOT_FOLDER) get_lodevice
	sudo mount $(LO_DEVICE)"p1"  $(BOOT_FOLDER)

umount_boot: 
	- sudo umount $(BOOT_FOLDER)

mount_root: $(ROOT_FOLDER) get_lodevice
	sudo mount $(LO_DEVICE)"p2" $(ROOT_FOLDER)

umount_root:
	- sudo umount $(ROOT_FOLDER)

prepare_environment: $(ARCH_FILE) mount_boot mount_root
		
install_files:
	sudo tar -xf $(ARCH_FILE)  -C $(ROOT_FOLDER)
	sudo mkdir -p $(TGT_PACKAGE_FOLDER)
	sudo cp -rv $(SRC_PACKAGE_FOLDER)/* $(TGT_PACKAGE_FOLDER)
	sudo mkdir -p $(TGT_STAGING_FOLDER)
	- sudo cp -rv $(SRC_STAGING_FOLDER)/* $(TGT_STAGING_FOLDER)
	sudo cp $(IMAGE_PREPARE) $(TGT_STAGING_FOLDER)
	sync
	sudo mv $(ROOT_FOLDER)/boot/* $(BOOT_FOLDER)
	
cleanup_env: umount_boot umount_root 

clean: cleanup_env free_lo
	- rm $(IMAGE_FILENAME)
	- rm -r $(MOUNT_FOLDER) 
	
cleanall: clean 
	- rm $(ARCH_FILE)


do_format_only: get_lodevice format_p1 format_p2 free_lo 

create_arch_image: $(IMAGE_FILENAME) partitions get_lodevice format_p1 format_p2 prepare_environment install_files cleanup_env free_lo

  
	
