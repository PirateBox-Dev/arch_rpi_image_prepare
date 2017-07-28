#!/bin/sh
PIRATEBOX_PATH=/opt/piratebox
CONF_PATH=$PIRATEBOX_PATH/conf/piratebox.conf
BIN_PATH=$PIRATEBOX_PATH/bin
BUILD="$1"

systemctl enable sshd
ln /usr/bin/python2 /usr/bin/python
groupadd nogroup && usermod -a -G nogroup nobody

cd /root
tar xzf *.tar.gz
mv piratebox/piratebox /opt
rm -r ./*.tar.gz

$($BIN_PATH/install_piratebox.sh part2 > /dev/null)
$($BIN_PATH/install_piratebox.sh imageboard > /dev/null)

# Add minidlna user to nogroup and allow the group to read and write files
usermod -a -G nogroup minidlna
chmod -R g+rw $PIRATEBOX_PATH/tmp
chmod -R g+rw $PIRATEBOX_PATH/share

# Touch the file where the time is saved to update it to the current time
sed -i -e 's|TIMESAVE="$PIRATEBOX_FOLDER/share/timesave_file"|TIMESAVE="/var/lib/systemd/clock"|' "$CONF_PATH"
touch /var/lib/systemd/clock

# Place MOTD
sed -i  -e "s|00-00-0000|${BUILD}|" "$PIRATEBOX_PATH/rpi/motd.txt"
cp $PIRATEBOX_PATH/rpi/motd.txt /etc/motd


# Move udev rules to their place
cp $PIRATEBOX_PATH/rpi/udev/* /etc/udev/rules.d/

# Move the services to their place
cp $PIRATEBOX_PATH/rpi/services/* /etc/systemd/system/

# Disable system-resolver (blocks dnsmasq)
systemctl disable systemd-resolved.service
rm /etc/resolv.conf
touch /etc/resolv.conf

# Disable possible default dnsmasq
systemctl disable dnsmasq

# Enable I2C support
echo device_tree_param=i2c_arm=on >> /boot/config.txt
# Load modules for RealTimeClock support
echo snd-bcm2835 >> /etc/modules-load.d/raspberrypi.conf
echo i2c-bcm2835 >> /etc/modules-load.d/raspberrypi.conf
echo i2c-dev 	 >> /etc/modules-load.d/raspberrypi.conf
echo rtc-ds1307  >> /etc/modules-load.d/raspberrypi.conf

# Setup default wifi config
echo "wlan0" >> "/boot/wifi_card.conf"
