#!/bin/sh
if grep -q "http_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*http_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        echo -e "[Export environment variable: http_proxy=${__proxy}]"
        export "http_proxy=${__proxy}"
fi
if grep -q "https_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*https_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        echo -e "[Export environment variable: https_proxy=${__proxy}]"
        export "https_proxy=${__proxy}"
fi
if grep -q "ftp_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*ftp_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        echo -e "[Export environment variable: ftp_proxy=${__proxy}]"
        export "ftp_proxy=${__proxy}"
fi
if grep -q "socks_proxy=" /proc/cmdline ; then
        __proxy=`sed 's/^.*socks_proxy=\([^, ]*\).*$/\1/g' /proc/cmdline`
        echo -e "[Export environment variable: socks_proxy=${__proxy}]"
        export "socks_proxy=${__proxy}"
fi
if grep -q "dns1=" /proc/cmdline ; then
        __dns1=`sed 's/^.*dns1=\([^, ]*\).*$/\1/g' /proc/cmdline`
	rm -rf /etc/resolv.conf
	echo "nameserver ${__dns1}" >> /etc/resolv.conf
fi
if grep -q "dns2=" /proc/cmdline ; then
        __dns2=`sed 's/^.*dns2=\([^, ]*\).*$/\1/g' /proc/cmdline` 
	echo "nameserver ${__dns2}" >> /etc/resolv.conf
fi
if grep -q "sdb_port=" /proc/cmdline ; then
        __sdb_port=`sed 's/^.*sdb_port=\([^, ]*\).*$/\1/g' /proc/cmdline` 
    	rm -rf /opt/home/sdb_port.txt
	echo "${__sdb_port}" >> /opt/home/sdb_port.txt
fi
