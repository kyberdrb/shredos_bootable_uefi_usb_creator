#!/bin/sh

set -x

DISK_NAME="$1"
DISK_DEVICE="/dev/${DISK_NAME}"

#latest_shredos_release_version=$(curl --silent https://shredos.org/download/ | grep "Current Release" | cut --delimiter=':' --fields=2 | cut --delimiter=' ' --fields=2 | cut --delimiter='<' --fields=1)

if [ ! -f "/tmp/shredos_latest.iso" ]
then
  latest_shredos_iso_stable_URL=$(curl --silent --location https://github.com/PartialVolume/shredos.x86_64/releases | grep "\.img" | grep href | head --lines=1 | sed 's/.*<a href="//g' | sed 's/">.*//g')

  axel --verbose --num-connections=10 \
      "${latest_shredos_iso_stable_URL}" --output="/tmp/shredos_latest.iso"
fi

curl --silent --location https://github.com/PartialVolume/shredos.x86_64/releases | grep --ignore-case sha1.*img | sed 's/sha1/\nsha1\n/g' | sed 's/^\s*'//g > "/tmp/shredos_latest-checksums.txt"
SHREDOS_ISO_SHA1SUM_LOCAL="$(sha1sum /tmp/shredos_latest.iso | tr --squeeze-repeats ' ' | cut --delimiter=' ' --fields=1)"
SHREDOS_ISO_SHA1SUM_REMOTE="$(grep --ignore-case "^$SHREDOS_ISO_SHA1SUM_LOCAL" /tmp/shredos_latest-checksums.txt)"

if [ -z "${SHREDOS_ISO_SHA1SUM_REMOTE}" ]
then
  echo "File integrity compromised. Local and remote checksums are different."
  echo "Try to download the archive from different source and make sure the verification file is belonging to the archive you downloaded"
  exit 1
fi

echo
echo "*********************************************************************"
echo
echo "File integrity check passed. Local and remote checksums are matching."
echo "Proceeding..."
echo
echo "*********************************************************************"
echo

echo "Unmount all partitions of the device '/dev/${DISK_NAME}'"
PARTITION_NAME=$(cat /proc/partitions | grep "${DISK_NAME}" | rev | cut -d' ' -f1 | rev | grep -v ""${DISK_NAME}"$")
PARTITION_DEVICE="/dev/${PARTITION_NAME}"

udisksctl unmount --block-device ${PARTITION_DEVICE}
udisksctl mount --block-device ${PARTITION_DEVICE}
USB_MOUNT_DIR="$(lsblk -oNAME,MOUNTPOINTS "${PARTITION_DEVICE}" | tail --lines=1 | cut --delimiter=' ' --fields=1 --complement)/"

sudo 7z x -y "/tmp/shredos_latest.iso" -o"${USB_MOUNT_DIR}"

sync
sudo sync

udisksctl unmount --block-device ${PARTITION_DEVICE}

