#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument supplied for name of Image (eg.am335x-custom.img).."
    exit 1;
fi

NAME=$1;

sudo dd if=/dev/zero of=/opt/$NAME bs=1024 count=1958600

sleep 1;
DRIVE="/opt/$NAME"

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

sleep 1;
sudo losetup loop1 $DRIVE

sudo losetup

NEWDRIVE="/dev/loop1"

sudo parted -s $NEWDRIVE mklabel msdos
sudo parted -s $NEWDRIVE unit cyl mkpart primary fat32 -- 0 9
sudo parted -s $NEWDRIVE set 1 boot on
sudo parted -s $NEWDRIVE unit cyl mkpart primary ext2 -- 9 -2

sleep 1;
sudo mkfs.vfat -F 32 -n "boot" /dev/loop1p1
sleep 1;
sudo mkfs.ext3 -L "rootfs" /dev/loop1p2

sudo mkdir /opt/boot1
sudo mount /dev/loop1p1 /opt/boot1
sleep 1;

sudo mkdir /opt/rootfs1
sudo mount /dev/loop1p2 /opt/rootfs1
sleep 1;

ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n '' | awk '{print $5}'`
if [ "$PARTITION_TEST" = "" ]; then
	echo -e "Please insert an SD card to continue\n"
        while [ "$PARTITION_TEST" = "" ]; do
		read -p "Type 'y' to re-detect the SD card or 'n' to exit the script: " REPLY
		if [ "$REPLY" = 'n' ]; then
		      exit 1
		fi
		ROOTDRIVE=`mount | grep 'on / ' | awk {'print $1'} |  cut -c6-8`
		PARTITION_TEST=`cat /proc/partitions | grep -v $ROOTDRIVE | grep '\<sd.\>\|\<mmcblk.\>' | grep -n '' | awk '{print $5}'`
	done
fi

echo -e "SD card is found in partition : $PARTITION_TEST"

SDDRIVE="/dev/$PARTITION_TEST";

sudo cp -rf /media/user/boot/* /opt/boot1/.
sleep 1;
sudo cp -rf /media/user/rootfs/* /opt/rootfs1/.
sleep 1;
sudo umount -f /dev/loop1p1
sudo umount -f /dev/loop1p2
sudo rm -rf /opt/rootfs1
sudo rm -rf /opt/boot1

sudo umount -f /media/user/boot
sudo umount -f /media/user/rootfs

sudo umount -f $SDDRIVE*;

sudo eject $SDDRIVE;
sudo losetup --detach $NEWDRIVE

#sudo umount -f /dev/loop1
#fdisk -l $DRIVE
sleep 1;
sync
sync
sync

if [ -f $DRIVE ]
then
	echo "Image File created successfully : $DRIVE "
else
	echo "Error in Creating image file : $DRIVE "
fi

#sudo mkisofs -o /home/user/rootfs.iso /media/user/rootfs
#sudo mkisofs -o /home/user/boot.iso /media/user/boot
