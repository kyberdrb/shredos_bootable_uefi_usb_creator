# ShredOS UEFI-Bootable USB

## Usage

1. Prepare USB for UEFI booting. `sdb` is the device name of my USB stick. Your device name may vary, so make sure with `lsblk` before and after inserting the USB stick that the name of the device corresponds to the name you enter as an argument. **THIS IS A DESTRUCTIVE OPERATION! ALL DATA ON THE USB STICK WILL BE ERASED WITH THIS SCRIPT!**

        ./make_shredos_usb.sh <ENTER_USB_DEVICE_NAME>

    e. g.

        ./make_shredos_usb.sh sdb

    where `sdb` is the device name of the USB drive given by `lsblk` command.

1. List USB devices before and after inserting the USB stick to determine the device name. Then choose this device for the shredos installation.

    quick and sufficiently detailed listing

        $ lsblk -o NAME,FSTYPE,FSVER,UUID,MOUNTPOINT
        NAME   FSTYPE FSVER UUID                                 MOUNTPOINT
        sda                                                      
        ├─sda1 vfat   FAT32 220C-B8F7                            /boot
        └─sda2 ext4   1.0   cb217b7c-f7c0-4dae-b9a6-412e68b52408 /
        sdb                                                      
        └─sdb1 vfat   FAT32 B0F1-03FD                            


    or quick listing

        $ lsblk
        NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
        sda      8:0    0 238.5G  0 disk 
        ├─sda1   8:1    0   600M  0 part /boot
        └─sda2   8:2    0   220G  0 part /
        sdb      8:16   1   1.9G  0 disk 
        └─sdb1   8:17   1   1.9G  0 part

    or for another type of output

        $ lsblk --fs
        NAME   FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
        sda                                                                                
        ├─sda1 vfat   FAT32            220C-B8F7                             356.3M    41% /boot
        └─sda2 ext4   1.0              cb217b7c-f7c0-4dae-b9a6-412e68b52408    7.5G    91% /
        sdb                                                                                
        └─sdb1 vfat   FAT32 SHREDOS    B0F1-03FD

    In my case the USB stick I inserted has the name `sdb`

---

The order of the operations matters.

I made this guide for shredos, but this can apply for any other UEFI bootable USB drive creation:

1. partition usb drive as gpt with one fat32 partition
2. download latest shredos 
3. extract the archive onto the usb drive

## Sources

- https://github.com/PartialVolume/shredos.x86_64

