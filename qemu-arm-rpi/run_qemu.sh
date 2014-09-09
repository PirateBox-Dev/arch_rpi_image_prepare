QEMU_KEYMAP=de
qemu-system-arm -k $QEMU_KEYMAP -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -net nic -net user \
	-no-reboot -serial stdio \
	-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda image_file1  
