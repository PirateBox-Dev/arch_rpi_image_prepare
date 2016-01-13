## Run a QEMU PI with a custom image.
##    The needed file is called "install_qemu_image
##    The generated imagefile from the Makefile is mounted as hdb

qemu-system-arm -kernel kernel-qemu-rpi -cpu arm1176 -m 256 \
        -M versatilepb -net nic -net user \
	-no-reboot -serial stdio \
	-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
	-hda  install_qemu_image \
	-hdb  ../raw_arch_image_file

