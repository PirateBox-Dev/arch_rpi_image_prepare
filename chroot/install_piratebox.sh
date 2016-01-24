#!/bin/sh
CONF_PATH=/opt/piratebox/conf/piratebox.conf
BIN_PATH=/opt/piratebox/bin

systemctl enable sshd
ln /usr/bin/python2 /usr/bin/python
groupadd nogroup && usermod -a -G nogroup nobody

cd /root
wget -q --show-progress http://downloads.piratebox.de/piratebox-ws_current.tar.gz
tar xzf piratebox-ws_current.tar.gz
mv piratebox/piratebox /opt
rm -r ./piratebox-ws_current.tar.gz

$($BIN_PATH/install_piratebox.sh "${CONF_PATH}"  part2 > /dev/null)
$($BIN_PATH/install_piratebox.sh "${CONF_PATH}" imageboard > /dev/null)

sed -i 's:TIMESAVE_FORMAT="":TIMESAVE_FORMAT="+%C%g%m%d":' $CONF_PATH
