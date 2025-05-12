#!/bin/bash

PROOT_PATH="$(pwd)/usr/local/bin/proot"
ROOTFS_PATH="$(pwd)"

$PROOT_PATH \
  --rootfs="$ROOTFS_PATH" \
  -0 -w "/root" \
  -b /dev -b /sys -b /proc -b /etc/resolv.conf \
  --kill-on-exit \
  env HOME=/root /bin/bash -c "sshx" > sshx_output.txt

LINK=$(grep -o 'https://sshx.io/s/[^ ]*' sshx_output.txt)

echo "$LINK" > sshx_link.txt

echo "Đã lưu link SSHX vào sshx_link.txt"
