#!/bin/sh
PIRATEBOX_PATH=/opt/piratebox
CONF_PATH=$PIRATEBOX_PATH/conf/piratebox.conf
BIN_PATH=$PIRATEBOX_PATH/bin

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

sed -i 's:TIMESAVE_FORMAT="":TIMESAVE_FORMAT="+%C%g%m%d %H%M":' $CONF_PATH

chmod 777 $PIRATEBOX_PATH/tmp
