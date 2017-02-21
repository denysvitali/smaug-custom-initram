#!/sbin/busybox sh
set +x 
_PATH="$PATH" 
export PATH=/sbin 

# Mount the /proc and /sys filesystems
busybox mount -t proc none /proc
busybox mount -t sysfs none /sys
busybox mount -t tmpfs none /dev

# Something (what?) needs a few cycles here
busybox sleep 1

# Populate /dev
busybox mdev -s


busybox sleep 1

# initramfs pre-boot init script
#watchdogd 10 20

busybox ifconfig lo up
/sbin/adbd &

busybox echo 0 > /sys/devices/virtual/android_usb/android0/enable
busybox echo 18d1 > /sys/class/android_usb/android0/idVendor
busybox echo 1 > /sys/class/android_usb/android0/idProduct
busybox echo "MyCompany" > /sys/class/android_usb/android0/iManufacturer
busybox echo "MyProduct" > /sys/class/android_usb/android0/iProduct
busybox echo "0123456789" > /sys/class/android_usb/android0/iSerial
busybox echo "adb" > /sys/class/android_usb/android0/functions
busybox echo 1 > /sys/devices/virtual/android_usb/android0/enable


busybox sleep 10

busybox mkdir /dev/usb-ffs 0770 shell shell
busybox mkdir /dev/usb-ffs/adb 0770 shell shell
busybox mount configfs none /config
busybox mkdir /config/usb_gadget/g1 0770 shell shell
busybox echo 0x18d1 > /config/usb_gadget/g1/idVendor
busybox echo 0xffff > /config/usb_gadget/g1/bcdDevice
busybox echo 0x0200 > /config/usb_gadget/g1/bcdUSB
busybox mkdir /config/usb_gadget/g1/strings/0x409 0770
busybox echo 0123459876 > /config/usb_gadget/g1/strings/0x409/serialnumber
busybox echo 0x18d1 > /config/usb_gadget/g1/strings/0x409/manufacturer
busybox echo 0x5203 > /config/usb_gadget/g1/strings/0x409/product
busybox mkdir /config/usb_gadget/g1/functions/accessory.gs3
busybox mkdir /config/usb_gadget/g1/functions/audio_source.gs2
busybox mkdir /config/usb_gadget/g1/functions/ffs.adb
busybox mkdir /config/usb_gadget/g1/functions/mtp.gs0
busybox mkdir /config/usb_gadget/g1/functions/ptp.gs1
busybox mkdir /config/usb_gadget/g1/functions/rndis.gs4
busybox echo 1 > /config/usb_gadget/g1/functions/rndis.gs4/wceis
busybox mount functionfs adb /dev/usb-ffs/adb uid=2000,gid=2000


/sbin/adbd

busybox sleep 200



















# Populate /dev
busybox mdev -s

# Mount the root filesystem, second partition on micro SDcard
busybox mount -t ext4 -o noatime,nodiratime,errors=panic /dev/sda1 /mnt

busybox echo "heheheh" > /mnt/testi
busybox sync


busybox umount /dev/sda1
# Clean up
#umount /proc
#umount /sys
#umount /dev

# Transfer root to SDcard
exec /sbin//busybox switch_root /mnt /sbin/init


