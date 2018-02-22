#!/bin/sh

PBX_USER="pbxuser"
PBX_GRP="pbxuser"

# Configure our default system user & groups
useradd -m -U -c "PirateBox default user" "${PBX_USER}"

# Default password is pbxuser
echo "${PBX_USER}:${PBX_USER}" | chpasswd

# Expire Password to force user to reset it
passwd -e ${PBX_USER}

# Disable default user alarm with an empty password
passwd -d alarm

groupadd -r sudo
groupadd -r nogroup
usermod -a -G sudo,nogroup ${PBX_USER}
