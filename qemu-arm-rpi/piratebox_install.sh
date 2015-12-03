#!/bin/sh
  systemctl enable sshd
  ln /usr/bin/python2 /usr/bin/python
  cd root
  wget http://downloads.piratebox.de/piratebox-ws_current.tar.gz
  tar xzf piratebox-ws_current.tar.gz
  cp -rv piratebox/piratebox /opt
  groupadd nogroup && usermod -a -G nogroup nobody
  /opt/piratebox/bin/install_piratebox.sh  /opt/piratebox/conf/piratebox.conf  part2
  /opt/piratebox/bin/install_piratebox.sh  /opt/piratebox/conf/piratebox.conf imageboard
  cp /prebuild/staging/*.service  /etc/systemd/system 
  cp /prebuild/staging/RPi_motd.txt /etc/motd


