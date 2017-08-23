Protect your Raspberry Pi µSD card (use read-only filesystem)
=============================================================

**WARNING!! EXPERIMENTAL SETTINGS: create a backup copy of your µSD card before applying these settings!**

Make Filesystem Read-Only
-------------------------------
**remove unnecessary packages** 

```
apt-get update
apt-get remove --purge cron logrotate dphys-swapfile
apt-get autoremove --purge
```

**link files to temporary filesystem** 

```
rm -rf /var/lib/dhcp/ /var/spool /var/lock
ln -s /tmp /var/lib/dhcp
ln -s /tmp /var/spool
touch /tmp/dhcpcd.resolv.conf
ln -s /tmp/dhcpcd.resolv.conf /etc/resolv.conf
ln -s /tmp /var/lock
ln -s /tmp /var/run
rm -f /var/lib/systemd/random-seed
ln -s /tmp/random-seed /var/lib/systemd/random-seed
```

**edit /etc/fstab** 

   * add **ro** to entries "/boot" and "/" 
   * replace the last digit in line "/boot" and "/" with **0**
   * append **tmpfs** entries for "/var/log", "/var/tmp" and "/tmp"

```
proc            /proc           proc    defaults              0 0
/dev/mmcblk0p1  /boot           vfat    ro,defaults           0 0
/dev/mmcblk0p2  /               ext4    ro,defaults,noatime   0 0
tmpfs           /var/log        tmpfs   nodev,nosuid          0 0
tmpfs           /var/tmp        tmpfs   nodev,nosuid          0 0
tmpfs           /tmp            tmpfs   nodev,nosuid          0 0
```

**disable filesystem check** 

    tune2fs -c -0 -i 0 /dev/mmcblk0p2 

**edit /etc/systemd/system/dhcpcd5**

    change "/run/dhcpcd.pid" to "/var/run/dhcpcd.pid"

**append "fastboot noswap ro" to /boot/cmdline.txt**

    fastboot = no file system check on boot
    noswap = disable swap
```   
dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait sc16is7xx.RS485=2 bcm2709.disk_led_gpio=5 bcm2709.disk_led_active_low=0 fastboot noswap ro
```

Make Changes in Read-Only State
-------------------------------

    mount -o remount,rw /


User Data on USB-Stick
----------------------

**append to /etc/hdparm.conf**

``` 
write_cache = off
``` 

**TODO:**  use a filesystem better suited for unexpected power fail
- append to **/etc/fstab**

```
/dev/sda1       /mnt            vfat    rw,defaults,nofail      0 2
```

