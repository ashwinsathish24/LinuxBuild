#!/bin/sh
for f in $(find /sys/devices -name device_mode 2>/dev/null | grep 1532); do
    printf '\x03\x00' > "$f"
done
