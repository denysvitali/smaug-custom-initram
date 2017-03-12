#!/sbin/busybox sh
set +x 
_PATH="$PATH" 
export PATH=/sbin 

# Mount the /proc and /sys filesystems
busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t tmpfs none /dev

# Something (what?) needs a few cycles here
busybox sleep 10

# Populate /dev
busybox mdev -s


busybox sleep 1

# initramfs pre-boot init script
#watchdogd 10 20

#busybox sleep 10
# Mount the root filesystem, second partition on micro SDcard
busybox mount -t ext4 -o noatime,nodiratime,errors=panic /dev/sda1 /mnt

busybox echo "heheheh" > /mnt/testi
busybox dmesg > /mnt/logDmesg.txt

busybox sync


#umount /dev/sda1
# Clean up
#umount /proc
#umount /sys
#umount /dev

busybox dmesg > /mnt/logD
busybox sync


# Transfer root to SDcard
exec /sbin/busybox switch_root /mnt /sbin/init

busybox dmesg > /mnt/logDmes
busybox sync



