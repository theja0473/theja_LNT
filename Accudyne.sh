#!/bin/bash

# find the avaible SD cards
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
else
	echo -e "SD card is found in partition  : $PARTITION_TEST"
fi

# sudo lsblk;
echo "\n\n"
echo -e "SD card is found in partition  : $PARTITION_TEST"
echo "\n"

read -p "Type 'y' to continue to make Partitions, or 'n' to exit the script: " REPLY
if [ "$REPLY" = 'n' ]; then
	exit 1;
fi

DRIVE="/dev/$PARTITION_TEST";

sudo umount -f $DRIVE*;
sudo mkdosfs -I -F32 $DRIVE;

read -p "Type 'absolute path' of .img Image to load in SD card: " REPLY

while [ ! -f $REPLY ]
do
	read -p "absolute path is not proper, kindly provide 'absolute path' to load Image: " REPLY
done

echo "Flashing Image..."
sudo dd if=$REPLY of=$DRIVE bs=4M;
sync
sync
sudo eject $DRIVE;	
echo "Your SD card is ready to use in MVP display board"








