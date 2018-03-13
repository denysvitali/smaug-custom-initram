#!/bin/bash
FOLDER=/tmp/bcm-bt-firmware
BCM_FILE=BCM4354_003.001.012.0208.0000_UART_eLNA.hcd
BRANCH=firmware-smaug-7132.B

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
git clone -b $BRANCH https://chromium.googlesource.com/chromiumos/third_party/broadcom $FOLDER
cp $FOLDER/bluetooth/patchram/$BCM_FILE $DIR/../lib/firmware/brcm/
rm -rf $FOLDER