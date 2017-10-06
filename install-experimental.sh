#!/bin/bash

if [ $EUID -ne 0 ]; then
    echo -e "ERROR: This script should be run as root" 1>&2
    exit 1
fi

KERNEL=$(uname -r)

VERSION=$(echo $KERNEL | cut -d. -f1)
PATCHLEVEL=$(echo $KERNEL | cut -d. -f2)
SUBLEVEL=$(echo $KERNEL | cut -d. -f3 | cut -d- -f1)

KERNELVER=$(($VERSION*100000+1000*$PATCHLEVEL+$SUBLEVEL));

if [ $KERNELVER -le 409040 ]; then 
 echo "WARNING: kernel version not supported. >4.9.40 required" 1>&2
 exit 0
fi


clear
WELCOME="This script activates read-only filesystem overlay\n
continue installation?"

if (whiptail --title "Read-only Filesystem Installation Script" --yesno "$WELCOME" 20 60) then
    echo ""
else
    exit 0
fi

sed -i '1 s/^/overlay=yes /' /boot/cmdline.txt 

wget -nv https://raw.githubusercontent.com/janztec/empc-arpi-linux-readonly/master/hooks_overlay -O /etc/initramfs-tools/hooks/overlay
wget -nv https://raw.githubusercontent.com/janztec/empc-arpi-linux-readonly/master/init-bottom_overlay -O /etc/initramfs-tools/scripts/init-bottom/overlay

chmod +x /etc/initramfs-tools/hooks/overlay
chmod +x /etc/initramfs-tools/scripts/init-bottom/overlay

mkinitramfs -o /boot/initramfs.gz
echo "initramfs initramfs.gz followkernel" >>/boot/config.txt

if (whiptail --title "Read-only Filesystem Installation Script" --yesno "Installation completed! reboot required\n\nreboot now?" 12 60) then
    reboot
fi
