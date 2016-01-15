#!/bin/sh
# Install dependencies in a chrooted environment
# - Working internet connection required for downloading the dependencies

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

## Read some build info, like architecture CARCH
. /etc/makepkg.conf

pacman --needed --noconfirm -Sy base-devel

#### Create Package-PreBuild for start-stop-daemon
build_aur start-stop-daemon "https://aur.archlinux.org/cgit/aur.git/snapshot/start-stop-daemon.tar.gz"
build_aur proftpd "https://aur.archlinux.org/cgit/aur.git/snapshot/proftpd.tar.gz"

##--- additional wifi stuff
## verify ... $SUDO pacman --noconfirm -r /mnt/image -S dkms-8188eu dkms-8192cu

#-- aquire (pre) built package
pacman --needed --noconfirm -U /prebuild/*pkg.tar.xz

## Basic dependencies
pacman --needed --noconfirm -S python2 lighttpd bash iw hostapd dnsmasq \
  bridge-utils avahi wget wireless_tools netctl perl iptables zip unzip cronie \
  net-tools community/perl-cgi minidlna

## PHP related dependencies
pacman --needed --noconfirm -S radvd php php-cgi php-sqlite lftp imagemagick \
  php-gd

## cleanup Image
pacman --noconfirm -Scc
