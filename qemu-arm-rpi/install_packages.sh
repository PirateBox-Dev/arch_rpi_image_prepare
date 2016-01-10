#!/bin/sh

## This script is for running on a PI 
##    - Tested in a QEMU environment.
##    - Mounted the "to-prepare" image at sdb via CLI (see other script)
##    - It requires a working internet connection for downloading the dependencies
##

BRAND=piratebox

### Template for building different arch packages
build_aur(){
  local package=$1
  local url=$2

  if ls /prebuild | grep "$package" | grep -q "$CARCH" ; then
	echo "Package $package skipped, because it is in /prebuild"
  else
	cd /tmp
	wget "$url"
	tar xzf "${package}.tar.gz"
	cd ${package}
	# Add arch if missing
	if ! grep -q $CARCH PKGBUILD ; then 
	  sed -i "s|'i686'|'i686' '$CARCH'|g" PKGBUILD
	fi
	chown nobody:nobody ./ -R
	sudo -u nobody makepkg
	cp $package.*-${CARCH}.pkg.* /prebuild 
        cd -
  fi
}

DEV_NODE=/dev/sdb2
SUDO=""

## Read some build info, like architecture CARCH
. /etc/makepkg.conf

pacman --noconfirm  -Sy wget sudo base-devel

#### Create Package-PreBuild for start-stop-daemon
build_aur start-stop-daemon "https://aur.archlinux.org/cgit/aur.git/snapshot/start-stop-daemon.tar.gz"

build_aur proftpd "https://aur.archlinux.org/cgit/aur.git/snapshot/proftpd.tar.gz"


$SUDO mkdir -p /mnt/image
$SUDO mount $DEV_NODE /mnt/image
$SUDO mount -o bind /proc /mnt/image/proc
$SUDO mount -o bind /dev  /mnt/image/dev

$SUDO pacman --noconfirm -r /mnt/image -Sy
$SUDO pacman --noconfirm -r /mnt/image -U /prebuild/*pkg.tar.xz 


##--- additional wifi stuff
## verify ... $SUDO pacman --noconfirm -r /mnt/image -S dkms-8188eu dkms-8192cu


#-- aquire (pre) built package
$SUDO pacman --noconfirm -r /mnt/image -U /prebuild/staging/*pkg.tar.xz 

## Basic dependencies
$SUDO pacman --noconfirm -r /mnt/image -S python2 lighttpd bash iw hostapd dnsmasq bridge-utils avahi wget wireless_tools netctl perl iptables zip unzip cronie net-tools community/perl-cgi minidlna

$SUDO pacman --noconfirm -r /mnt/image -S radvd proftpd php php-cgi php-sqlite lftp imagemagick php-gd 

## cleanup Image
$SUDO pacman --noconfirm -r /mnt/image -Scc

### Prepare chroot environment
mount -o bind /run /mnt/image/run
mount -o bind /dev /mnt/image/dev
mount -o bind /proc /mnt/image/proc
cp /etc/resolv.conf /mnt/image/etc

### Copy over working script
cp /prebuild/staging/${BRAND}_install.sh /mnt/image
chmod u+x /mnt/image/${BRAND}_install.sh

## Enter chroot and execute install-steps
chroot /mnt/image "/${BRAND}_install.sh"

#echo "if you are done run:"
#echo "umount -R /mnt/image"

umount -R /mnt/image


