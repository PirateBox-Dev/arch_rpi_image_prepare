#!/bin/sh
systemctl enable sshd
ln /usr/bin/python2 /usr/bin/python
groupadd nogroup && usermod -a -G nogroup nobody

cd root
wget -q --show-progress http://downloads.piratebox.de/piratebox-ws_current.tar.gz
tar xzf piratebox-ws_current.tar.gz
mv piratebox/piratebox /opt
rm -r ./piratebox-ws_current.tar.gz

/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf  part2 > /dev/null
/opt/piratebox/bin/install_piratebox.sh /opt/piratebox/conf/piratebox.conf imageboard > /dev/null
