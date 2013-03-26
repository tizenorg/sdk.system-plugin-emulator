#!/bin/sh
# Mount host directory on /mnt/host via virtio-9p

if grep "virtio-9p" /proc/cmdline ; then
    if mount -t 9p -o trans=virtio fileshare /mnt/host -oversion=9p2000.L -o msize=65536; then
        echo -e "[${_Y}Mount.9pfs succeed${C_}]"
    else
        echo -e "[${_R}Mount.9pfs fail!!!!${C_}]"
    fi
fi

