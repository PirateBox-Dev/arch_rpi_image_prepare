#!/bin/sh
# Configure sudo and add the alarm user (just in case)
echo '%sudo ALL=(ALL) ALL' >> /etc/sudoers
usermod -a -G sudo alarm
