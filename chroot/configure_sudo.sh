#!/bin/sh
# Configure sudo and add the alarm user
groupadd sudo
echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers
usermod -a -G sudo alarm
