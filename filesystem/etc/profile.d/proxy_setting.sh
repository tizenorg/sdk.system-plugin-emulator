#!/bin/sh
if grep -q "http_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*http_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        if [ "x${__proxy}" = "x" ]; then
            export "http_proxy="
        else
            export "http_proxy=http://${__proxy}/"
        fi
fi
if grep -q "https_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*https_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        if [ "x${__proxy}" = "x" ]; then
            export "https_proxy="
        else
            export "https_proxy=https://${__proxy}/"
        fi
fi
if grep -q "ftp_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*ftp_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        if [ "x${__proxy}" = "x" ]; then
            export "ftp_proxy="
        else
            export "ftp_proxy=ftp://${__proxy}/"
        fi
fi
if grep -q "socks_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*socks_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        if [ "x${__proxy}" = "x" ]; then
            export "socks_proxy="
        else
            export "socks_proxy=socks://${__proxy}/"
        fi
fi
