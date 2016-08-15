#!/system/bin/sh
#
# Copyright (c) 2013-2015, Motorola LLC  All rights reserved.
#

SCRIPT=${0#/system/bin/}

MID=`cat /sys/block/mmcblk0/device/manfid`
if [ "$MID" != "0x000090" ] ; then
  echo "Result: FAILED"
  echo "$SCRIPT: manufacturer not supported" > /dev/kmsg
  exit
fi
echo "Manufacturer: Hynix"

PNM=`cat /sys/block/mmcblk0/device/name`
PNM=${PNM:0:5}  # Hynix puts an unprintable character at the end of PNM >:(
echo "Device Name: $PNM"

if [ "$PNM" == "H8G1e" -o "$PNM" == "HAG2e" -o "$PNM" == "HAG4a" ] ; then
  # Firmware update for Hynix eMCPs
  CID=`cat /sys/block/mmcblk0/device/cid`
  PRV=${CID:18:2}
  echo "Product Revision: $PRV"

  if [ "$PRV" \> "a4" ] ; then
    echo "Result: PASS"
    echo "$SCRIPT: Curent version higher than A4, no action required" > /dev/kmsg
    exit
  fi

  # Flash the firmware
  echo "Starting upgrade..."
  sync
  /system/bin/emmc_ffu -yR
  STATUS=$?
  
  if [ "$STATUS" != "0" ] ; then
    echo "Result: FAIL"
    echo "$SCRIPT: firmware update failed ($STATUS)" > /dev/kmsg
    exit
  fi
  
  sleep 1
  CID=`cat /sys/block/mmcblk0/device/cid`
  PRV=${CID:18:2}
  echo "New Product Revision: $PRV"

  echo "Result: PASS"
  echo "$SCRIPT: firmware updated successfully" > /dev/kmsg
fi
