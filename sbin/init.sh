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

#watchdogd 10 20

/sbin/adbd &

# Debug, turn on light bar if successful!

# Set Bar to RED
echo "0 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "1 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "2 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
echo "3 255 0 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;


busybox sleep 2

# Mount the root filesystem, second partition on micro SDcard
busybox mount -t ext4 -o noatime,nodiratime,errors=panic /dev/mmcblk0p4 /mnt

# 1/4 System Mounted
echo "0 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox dmesg >> /rootfs/dmesg-1.txt

busybox sync



#umount /dev/sda1
# Clean up
#umount /proc
#umount /sys
#umount /dev

# 2/4 Busybox Sync + Dmesg saved
echo "1 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

# Transfer root to SDcard
exec /sbin/busybox switch_root /mnt /sbin/init

# Init ended 3/4
echo "2 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;

busybox dmesg > /rootfs/dmesg-2.txt
busybox sync

# Before reboot 4/4
echo "3 0 255 0" > /sys/class/chromeos/cros_ec/lightbar/led_rgb;
