#!/sbin/busybox sh
set +x
_PATH="$PATH"
export PATH=/sbin

external_drive=false

# Mount the /proc and /sys filesystems
busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t tmpfs none /dev
busybox mount -t devpts none /dev/pts

# Populate /dev
busybox mdev -s


cd /dev && busybox mknod console c 5 1


# initramfs pre-boot init script

echo "STOP" > /sys/class/chromeos/cros_ec/lightbar/sequence;
echo "0 255 255 255 1 255 255 255 2 255 255 255 3 255 255 255" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

#watchdogd 10 20

/sbin/adbd &

# Debug, turn on light bar if successful!

# Set Bar to RED
echo "0 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "1 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "2 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "3 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox sleep 2

# Dragon partitions: https://docs.google.com/spreadsheets/d/1uxdTSz23kFRDXrezeAclMY9yy8ih9cbi6UFVOFrVXJ8/edit?usp=sharing

# Mount the root filesystem, second partition on micro SDcard
# Boot from /data:
# busybox mount -t ext4 -o noatime,nodiratime,errors=panic /dev/mmcblk0p7 /mnt

## DEBUG
busybox mkdir /cache
busybox mount -t ext4 -o noatime,nodiratime,errors=panic,rw /dev/mmcblk0p6 /cache
busybox ls -la /dev > /cache/ls-la.txt
busybox dmesg > /cache/dmesg.txt

if [ "$external_drive" == true ]
then
    # Mount /dev/sda1 to /mnt
    echo "Loading rootfs from external drive..." >> /cache/log.txt
    i=0
    while [ ! -b "/dev/sda1" ]
    do
        # Show a warning pattern on the lightbar
        echo "0 233 255 0 1 255 93 0 2 233 255 0 3 255 93 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
        busybox sleep 0.2
        echo "0 255 93 0 1 233 255 0 2 255 93 0 3 233 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
        busybox sleep 1 # Wait for USB
        echo "$i Waiting for USB..." >> /cache/log.txt
        busybox ls -la /dev/ > "/cache/ls-$i.txt"
        busybox dmesg > "/cache/dmesg-$i.txt"
        busybox mdev -s
        i=$(($i+1))
    done 
    echo "USB found!" >> /cache/log.txt
    busybox mount -t ext4 -o noatime,nodiratime,errors=panic,rw /dev/sda1 /mnt
    echo "SDA1 mounted!" >> /cache/log.txt
else
    # Rootfs on "APP", mmcblk0p4, 3.8G (Android's /system partition) :
    echo "Loading rootfs from /system partition" >> /cache/log.txt
    busybox mount -t ext4 -o noatime,nodiratime,errors=panic,rw /dev/mmcblk0p4 /mnt
    echo "System mounted!" >> /cache/log.txt
fi

# Mount /vendor as Read Only
busybox mount -t ext4 -o noatime,nodiratime,errors=panic,ro /dev/mmcblk0p5 /vendor
echo "Vendor mounted!" >> /cache/log.txt

busybox mkdir /rootfs

#busybox mount /mnt/Arch /rootfs
busybox mount /mnt/ /rootfs
busybox mount /vendor /rootfs/vendor

echo "Mounted vendor and mnt to /rootfs/{,vendor}" >> /cache/log.txt

# 1/4 System Mounted [*   ]
echo "0 0 255 0 1 0 0 0 2 0 0 0 3 0 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

echo "Writing dmesg..." >> /cache/log.txt
date=$(busybox date +%s)
busybox dmesg >> /rootfs/dmesg-$date.txt
echo "Dmesg written to /rootfs/dmesg-$date.txt" >> /cache/log.txt
busybox sync
echo "Busybox sync successful" >> /cache/log.txt


# 2/4 Busybox Sync + Dmesg saved [**  ]
echo "0 0 255 0 1 0 255 0 2 0 0 0 3 0 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

# Transfer root to SDcard
echo "Chrooting..." >> /cache/log.txt
busybox sync
exec /sbin/busybox switch_root /rootfs /sbin/init

### Everything after this line will be executed on shutdown
echo "Init ended, shutting down..." >> /cache/log.txt
# Clean up
umount /proc
umount /sys
umount /dev
umount /cache

# Cleanup done 3/4 [*** ]
echo "0 0 255 0 1 0 255 0 2 0 255 0 3 0 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox echo "-------$(date +%s)--------" >> /rootfs/dmesg-2.txt
busybox dmesg >> /rootfs/dmesg-2.txt
busybox sync

umount /rootfs

# Before shutdown 4/4 [****]
echo "0 0 255 0 1 0 255 0 2 0 255 0 3 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
shutdown
