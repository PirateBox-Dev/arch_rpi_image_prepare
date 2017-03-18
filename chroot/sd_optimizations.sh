#!/bin/sh

echo  "tmpfs   /var/log    tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0" >> /etc/fstab
echo  "tmpfs   /tmp    tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0" >> /etc/fstab
echo  "tmpfs   /var/tmp tmpfs   nodev,nosuid 0 0" >> /etc/fstab
echo  "tmpfs   /run tmpfs nodev,nosuid 0 0" >> /etc/fstab

# only use available swap if it is REALLY needed"
echo "vm.swappiness = 1" >> /etc/sysctl.d/50-sdcard.conf 

# More like experimental delays for writing
#  Start writing at 50% usage, use up to 80% ram for dirtied pages
#  And if we do not reach the limit, 
echo "
vm.dirty_background_ratio = 50
vm.dirty_ratio = 80
# default 3000 => 30s , we use 5 minutes = 30000
vm.dirty_expire_centisecs = 30000 
" >> /etc/sysctl.d/50-sdcard.conf

