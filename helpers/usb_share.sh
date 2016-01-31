# Find a vfat partition and configure it as an external share
MOUNTPOINT="/mnt/usbshare"
FS="vfat"
UUIDS=$(blkid | grep "/dev/sd*.*TYPE=\"${FS}\"" | cut -f1 -d"T")

if [ $(echo "${UUIDS}" | wc -l) -gt 1 ]; then
  echo "You seem to have more than one valid ${FS} partition for a USB share:"
  echo "${UUIDS}\n"
  echo "Please make sure you have a USB thumb drive attached with a single ${FS} partition."
  exit 1
fi

if [ $(echo "${UUIDS}" | wc -l) -lt 1 ]; then
  echo "You seem to have no valid ${FS} partition for a USB share."
  echo "Please make sure you have a USB thumb drive attached with a single ${FS} partition."
  exit 1
fi

echo "## Adding USB share..."
UUID=$(echo "${UUIDS}" | cut -f2 -d" " | sed s/"\""/""/g)
mkdir -p "${MOUNTPOINT}" > /dev/null
echo "${UUID} ${MOUNTPOINT} vfat umask=0,noatime,rw,user 0 0" >> /etc/fstab
mount "${MOUNTPOINT}" > /dev/null

echo "## Moving files..."
sudo mv /opt/piratebox/share "${MOUNTPOINT}/share" 2>&1 /dev/null
sudo ln -s "${MOUNTPOINT}/share" /opt/piratebox/share > /dev/null

exit 0
