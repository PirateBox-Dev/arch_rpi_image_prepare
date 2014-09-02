#Needs BC package
#extra/bc 1.06.95-1
#     An arbitrary precision calculator language 


##based up http://archlinuxarm.org/platforms/armv6/raspberry-pi
ARCH_URL=http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
IMAGE_FILENAME=./image_file1



# in Byte ; 2GiB * 1024 MiB    1024 KiB    1024 Byte
#IMAGESIZE=$(shell echo $( 2   \*  1024     \*  1024  \*   1024 ))
IMAGESIZE:=$(shell echo  2*1024*1024*1024 | bc  )
#Sector size like my Raspbian image 
#  in Byte
SECTORSIZE=512
BLOCKSIZE=512
NEEDED_SECTOR_COUNT=$(shell echo ${IMAGESIZE} / ${SECTORSIZE} | bc ) 

DEV_FLAT_FILE=./dev_node_name
LO_DEVICE=$(shell cat ${DEV_FLAT_FILE})

$(IMAGE_FILENAME): 
	echo "Creating image file size: " ${IMAGESIZE}
	echo " .. Filename " $(IMAGE_FILENAME)
	echo "    Blocksize " $(BLOCKSIZE)
	echo "    Needed Sectors " $(NEEDED_SECTOR_COUNT)
	echo "    Results in "$(IMAGESIZE)" B "
	dd if=/dev/zero of=$@  bs=$(BLOCKSIZE)  count=$(NEEDED_SECTOR_COUNT)

$(DEV_FLAT_FILE):
	$(shell sudo losetup --find --show $(IMAGE_FILENAME) > $(DEV_FLAT_FILE) )

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

do_format_only: get_lodevice format_p1 format_p2 free_lo 


