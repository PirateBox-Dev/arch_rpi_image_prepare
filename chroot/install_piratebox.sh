#!/bin/sh
PIRATEBOX_PATH=/opt/piratebox
CONF_PATH=$PIRATEBOX_PATH/conf/piratebox.conf
BIN_PATH=$PIRATEBOX_PATH/bin

systemctl enable sshd
ln /usr/bin/python2 /usr/bin/python
groupadd nogroup && usermod -a -G nogroup nobody

cd /root
tar xzf *.tar.gz
mv piratebox/piratebox /opt
rm -r ./*.tar.gz

$($BIN_PATH/install_piratebox.sh "${CONF_PATH}" part2 > /dev/null)
$($BIN_PATH/install_piratebox.sh "${CONF_PATH}" imageboard > /dev/null)

sed -i 's:TIMESAVE_FORMAT="":TIMESAVE_FORMAT="+%C%g%m%d %H%M":' $CONF_PATH

# Add minidlna user to nogroup and allow the group to read and write files
usermod -a -G nogroup minidlna
chmod -R g+rw $PIRATEBOX_PATH/tmp
chmod -R g+rw $PIRATEBOX_PATH/share

# Touch the file where the time is saved to update it to the current time
touch /var/lib/systemd/clock

# Place MOTD
cp $PIRATEBOX_PATH/rpi/motd.txt /etc/motd

# Move udev rules to their place
cp $PIRATEBOX_PATH/rpi/udev/* /etc/udev/rules.d/

# Move the services to their place
cp $PIRATEBOX_PATH/rpi/services/* /etc/systemd/system/

# Enable I2C support
echo device_tree_param=i2c_arm=on >> /boot/config.txt
# Load modules for RealTimeClock support
echo snd-bcm2835 >> /etc/modules-load.d/raspberrypi.conf
echo i2c-bcm2835 >> /etc/modules-load.d/raspberrypi.conf
echo i2c-dev 	 >> /etc/modules-load.d/raspberrypi.conf
echo rtc-ds1307  >> /etc/modules-load.d/raspberrypi.conf
