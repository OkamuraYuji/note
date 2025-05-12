#!/bin/bash

PROOT_PATH="$(pwd)/usr/local/bin/proot"
ROOTFS_PATH="$(pwd)"

$PROOT_PATH \
  --rootfs="$ROOTFS_PATH" \
  -0 -w "/root" \
  -b /dev -b /sys -b /proc -b /etc/resolv.conf \
  --kill-on-exit \
  env HOME=/root /bin/bash -c "sshx" > sshx_output.txt

LINK=$(cat sshx_output.txt | sed 's/\x1b\[[0-9;]*m//g' | grep -o 'https://sshx.io/s/[^ ]*')

echo "$LINK" > sshx_link.txt
