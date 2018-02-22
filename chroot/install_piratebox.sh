#!/bin/sh
PIRATEBOX_PATH=/opt/piratebox
CONF_PATH=$PIRATEBOX_PATH/conf/piratebox.conf
BIN_PATH=$PIRATEBOX_PATH/bin
BUILD="$1"
VERSION="$2"
IS_NEXT="no"
NEXT="2."

if echo "${VERSION}" | grep -q "${NEXT}" ; then
    IS_NEXT="yes"
else
    echo "Running PirateBox configuration in 1.1.x mode"
    # We need to link python2 to python
    ln /usr/bin/python2 /usr/bin/python
fi

systemctl enable sshd
groupadd nogroup && usermod -a -G nogroup nobody

# Some other system configuration to make the system working with UTF8
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
mv /etc/locale.conf /etc/locale.conf.old
echo 'LANG="en_US.UTF-8"' > /etc/locale.conf


cd /root
tar xzf *.tar.gz
mv piratebox/piratebox /opt
rm -r ./*.tar.gz

if [ "$IS_NEXT" = "yes" ] ; then
    $($BIN_PATH/install_piratebox.sh part2 > /dev/null)
    $($BIN_PATH/install_piratebox.sh imageboard > /dev/null)
else
    $($BIN_PATH/install_piratebox.sh "${CONF_PATH}" part2 > /dev/null)
    $($BIN_PATH/install_piratebox.sh "${CONF_PATH}" imageboard > /dev/null)
fi

# Add minidlna user to nogroup and allow the group to read and write files
usermod -a -G nogroup minidlna
chmod -R g+rw $PIRATEBOX_PATH/tmp
chmod -R g+rw $PIRATEBOX_PATH/share

# Touch the file where the time is saved to update it to the current time
systemctl enable cronie
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
echo "# DNS Server from https://blog.uncensoreddns.org " >> /etc/resolv.conf
echo "#nameserver 91.239.100.100 " >> /etc/resolv.conf

# Disable possible default dnsmasq
systemctl disable dnsmasq

# Enable I2C support
echo device_tree_param=i2c_arm=on >> /boot/config.txt
# Load modules for RealTimeClock support
echo "snd-bcm2835" >> /etc/modules-load.d/raspberrypi.conf
echo "i2c-bcm2835" >> /etc/modules-load.d/raspberrypi.conf
echo "i2c-dev" 	   >> /etc/modules-load.d/raspberrypi.conf
echo "rtc-ds1307"  >> /etc/modules-load.d/raspberrypi.conf

# Setup default wifi config
echo "wlan0" >> "/boot/wifi_card.conf"
