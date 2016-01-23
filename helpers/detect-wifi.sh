#!/bin/sh
PACKAGE_PATH="/prebuild/hostapd"
CONFIG_PATH="${PACKAGE_PATH}/configs"
CONFIG_TARGET="/opt/piratebox/conf/hostapd.conf"

# Check if we have an nl80211 enabled device with AP mode, then we are done
if iw list | grep > /dev/null "* AP$"; then
  echo "Found nl80211 device capable of AP mode..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-2.2-2-armv6h.pkg.tar.xz" > /dev/null
  cp "${CONFIG_PATH}/nl80211.conf" "${CONFIG_TARGET}"
  exit 0
fi

# Check for r8188eu enabled device
if dmesg | grep > /dev/null "r8188eu:"; then
  echo "Found r8188eu enabled device..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-8188eu-0.8-1-armv6h.pkg.tar.xz" > /dev/null
  cp "${CONFIG_PATH}/r8188eu.conf" "${CONFIG_TARGET}"
  exit 0
fi

# Check for rtl8192cu enabled device
if dmesg | grep > /dev/null "rtl8192cu"; then
  echo "Found rtl8192cu enabled device..."
  yes | pacman -U --needed "${PACKAGE_PATH}/hostapd-8192cu-0.8_rtw_r7475.20130812_beta-3-armv6h.pkg.tar.xz" > /dev/null
  cp "${CONFIG_PATH}/rtl8192cu.conf" "${CONFIG_TARGET}"
  exit 0
fi

echo "Could not find an AP enabled WiFi card..."
exit 1
