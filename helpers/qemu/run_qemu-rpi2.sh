## Run a QEMU PI with a custom image.
##    The needed file is called "install_qemu_image
##    The generated imagefile from the Makefile is mounted as hdb

qemu-system-arm -M vexpress-a9 -cpu cortex-a9 \
	-m 512 \
        -net nic -net user \
	-no-reboot -serial stdio \
	-drive file=install_qemu_image,index=0,if=sd,format=raw \
	-hdb  ../raw_arch_image_file \
	-append "root=/dev/mmcblk0p2 panic=1 rootfstype=ext4 rw" \
	-kernel kernel7.img

