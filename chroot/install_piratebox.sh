#!/bin/sh
PIRATEBOX_PATH=/opt/piratebox
CONF_PATH=$PIRATEBOX_PATH/conf/piratebox.conf
BIN_PATH=$PIRATEBOX_PATH/bin
BUILD="$1"
VERSION="$2"
NEW_HOSTNAME="piratebox"
PBX_USER="pbxuser"
PBX_GRP="pbxuser"
IS_NEXT="no"
NEXT="2."

if echo "${VERSION}" | grep -q "${NEXT}" ; then
    IS_NEXT="yes"
else
    echo "Running PirateBox configuration in 1.1.x mode"
fi

systemctl enable sshd

cd /root
tar xzf *.tar.gz
mv piratebox/piratebox /opt
rm -r ./*.tar.gz

# Adjust USER configuration in piratebox.conf
sed -e "s|LIGHTTPD_USER=nobody|LIGHTTPD_USER=${PBX_USER}|g" \
    -e "s|LIGHTTPD_GROUP=nogroup|LIGHTTPD_GROUP=${PBX_GRP}|g" \
    -i "${CONF_PATH}"
# Adjust user & group in lighttpd.conf
sed -e "s|nobody|${PBX_USER}|g" \
    -e "s|nogroup|${PBX_GRP}|g" \
    -i "${PIRATEBOX_PATH}/conf/lighttpd/lighttpd.conf"

if [ "$IS_NEXT" = "yes" ] ; then
    $($BIN_PATH/install_piratebox.sh part2 > /dev/null)
    $($BIN_PATH/install_piratebox.sh imageboard > /dev/null)
else
    $($BIN_PATH/install_piratebox.sh "${CONF_PATH}" part2 > /dev/null)
    $($BIN_PATH/install_piratebox.sh "${CONF_PATH}" imageboard > /dev/null)
fi

# Add minidlna user to nogroup and allow the group to read and write files
usermod -a -G ${PBX_GRP}  minidlna
chmod -R g+rw $PIRATEBOX_PATH/tmp
chmod -R g+rw $PIRATEBOX_PATH/share

# Touch the file where the time is saved to update it to the current time
systemctl enable cronie
sed -i -e 's|TIMESAVE="$PIRATEBOX_FOLDER/share/timesave_file"|TIMESAVE="/var/lib/systemd/clock"|' "$CONF_PATH"
touch /var/lib/systemd/clock

# Place MOTD
sed -i  -e "s|00-00-0000|${BUILD}|" "$PIRATEBOX_PATH/rpi/motd.txt"
cp $PIRATEBOX_PATH/rpi/motd.txt /etc/motd

# Create some default links to the PBXUSER home directory
ln -s "${PIRATEBOX_PATH}/share/Shared"  "/home/${PBX_USER}/PirateBox_Shared"
ln -s "${PIRATEBOX_PATH}/share/content" "/home/${PBX_USER}/PirateBox_www-content"
ln -s "${PIRATEBOX_PATH}/conf" "/home/${PBX_USER}/PirateBox_conf"

# Make sure config files are writeable to the current PBXUSER
chown -R "${PBX_USER}" /opt/piratebox/conf/*

# Add PirateBox' bin pathes to user bash lookup path
echo "export PATH=$PATH:${PIRATEBOX_PATH}/bin:${PIRATEBOX_PATH}/rpi/bin" >> /home/${PBX_USER}/.bashrc

# Set system's hostname to PirateBox
echo "${NEW_HOSTNAME}" > /etc/hostname

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

# Prepare minidlna configuration
cp /etc/minidlna.conf /etc/minidlna.conf.bkp
cp /opt/piratebox/src/linux.example.minidlna.conf /etc/minidlna.conf
