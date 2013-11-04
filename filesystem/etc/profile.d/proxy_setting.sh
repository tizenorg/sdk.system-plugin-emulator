#!/bin/sh
if grep -q "http_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*http_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        export "http_proxy=http://${__proxy}/"
fi
if grep -q "https_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*https_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        export "https_proxy=https://${__proxy}/"
fi
if grep -q "ftp_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*ftp_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        export "ftp_proxy=ftp://${__proxy}/"
fi
if grep -q "socks_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*socks_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        export "socks_proxy=socks://${__proxy}/"
fi
