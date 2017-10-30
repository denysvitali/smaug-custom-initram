#!/sbin/busybox sh

set +x
_PATH="$PATH"
export PATH=/sbin

# Mount the /proc and /sys filesystems
busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t tmpfs none /dev
busybox mount -t devpts none /dev/pts

# Populate /dev
busybox mdev -s


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


#busybox sleep 2

# Dragon partitions: https://docs.google.com/spreadsheets/d/1uxdTSz23kFRDXrezeAclMY9yy8ih9cbi6UFVOFrVXJ8/edit?usp=sharing

# Mount the root filesystem, second partition on micro SDcard
# Boot from /data:
# busybox mount -t ext4 -o noatime,nodiratime,errors=panic /dev/mmcblk0p7 /mnt

# Boot from /system :
busybox mount -t ext4 -o noatime,nodiratime,errors=panic,rw /dev/mmcblk0p4 /mnt

# Mount /vendor as Read Only
busybox mount -t ext4 -o noatime,nodiratime,errors=panic,ro /dev/mmcblk0p5 /vendor

busybox mkdir /rootfs

#busybox mount /mnt/Arch /rootfs
busybox mount /mnt/ /rootfs
busybox mount /vendor /rootfs/vendor

# 1/4 System Mounted
echo "0 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox dmesg >> /rootfs/dmesg-1.txt

busybox sync



#umount /dev/sda1
# Clean up
umount /proc
umount /sys
umount /dev

# 2/4 Busybox Sync + Dmesg saved
echo "1 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

# Transfer root to SDcard
exec /sbin/busybox switch_root /rootfs /sbin/init

# Init ended 3/4
echo "2 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox dmesg > /rootfs/dmesg-2.txt
busybox sync

# Before reboot 4/4
echo "3 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
