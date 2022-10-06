#!/bin/sh

set -e

show_help() {
  message="$1"
  echo "${message}"
  echo
  echo "Usage: ./$(basename "$0") <disk_name>"
  echo
  echo "Please enter a valid <disk_name> from command:"
  echo
  echo "lsblk --output KNAME,TYPE | grep disk | cut --delimiter=' ' --fields=1"
  echo
  echo "ˇˇˇ"
  lsblk --output KNAME,TYPE | grep disk | cut --delimiter=' ' --fields=1
  echo "^^^"
  echo
  echo "or from a command with more verbose output for a more detailed overview:"
  echo
  echo "lsblk --output KNAME,PATH,TYPE,TRAN,FSTYPE,FSVER,SIZE,FSUSED,FSAVAIL,MOUNTPOINT,MODEL,STATE"
  echo
  echo          "ˇˇˇˇˇ ˇˇˇˇ ˇˇˇˇˇˇˇˇˇˇ ˇˇˇˇˇˇˇˇˇˇ ˇˇˇˇˇˇˇˇˇˇ ˇˇˇˇˇˇˇˇˇˇ ˇˇˇˇˇˇˇˇˇˇ"
  lsblk --output KNAME,PATH,TYPE,TRAN,FSTYPE,FSVER,SIZE,FSUSED,FSAVAIL,MOUNTPOINT,MODEL,STATE
  echo          "^^^^^ ^^^^ ^^^^^^^^^^ ^^^^^^^^^^ ^^^^^^^^^^ ^^^^^^^^^^ ^^^^^^^^^^"
  echo
  echo "Usage example:"
  echo
  echo "./$(basename "$0") sdb"
  echo
}

# Is device name provided?
if [ $# -ne 1 ]
then
  show_help "Disk name missing."
  exit 1
fi

DISK_NAME="$1"

# Is the device is present in the list of devices?
set +e

device_name_present="$(lsblk --output KNAME | grep "${DISK_NAME}")"

set -e

if [ -z "${device_name_present}" ]
then
  show_help "Disk name '$1' is missing from the list of disks."
	exit 2
fi

SCRIPT_DIR="$(dirname "$(readlink --canonicalize "$0")")"

"${SCRIPT_DIR}/utils/prepare_usb_for_uefi_booting.sh" "${DISK_NAME}"
"${SCRIPT_DIR}/utils/install_shredos_to_prepared_usb.sh" "${DISK_NAME}" 
"${SCRIPT_DIR}/utils/make_usb_bootable.sh" "${DISK_NAME}"

script_name="$(basename "$0")"
ln -sf "${SCRIPT_DIR}/$script_name" "$HOME/$script_name"

echo "______________________________________"
echo
echo "Links to the complete ShredOS install script"
echo "had been made in your home directory for more convenient launching at"
echo
echo "${HOME}/${script_name}"
echo

