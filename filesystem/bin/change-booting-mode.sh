#!/bin/sh
#
# Copyright 2010
# Read the file COPYING
#
# Authors: Yeongil Jang
#
# Copyright Samsung Electronics
#
FOTA_CONFIG_FILE="/sys/devices/platform/s3c_samsung_fota/samsung_fota_config"
FUS_CONFIG_FILE="/sys/devices/platform/s3c_samsung_fota/samsung_fus_config"
UPDATE_CONFIG_FILE="/sys/devices/platform/s3c_samsung_fota/samsung_update_config"
RTL_CONFIG_FILE="/sys/devices/platform/s3c_samsung_fota/samsung_rtl_config"

# print help message
do_help()
{
    cat >&2 <<EOF
change-booting-mode: usage:
    -?/--help        this message
    --fota           reboot for fota update
    --fus            reboot for fus update
    --fus_binary     reboot for fus binary update
    --update         reboot for developer update
    --rtl            reboot for rtl mode
    --fota_disable   remove fota update flag
    --fus_disable    remove fus update flag
    --fus_binary_disable    remove fus binary update flag
    --update_disable remove for developer update flag
    --rtl_disable    remove rtl test flag
EOF
}

# get and check specified options
do_options()
{
	# note: default settings have already been loaded

	while [ "$#" -ne 0 ]
	do
		arg=`printf %s $1 | awk -F= '{print $1}'`
		val=`printf %s $1 | awk -F= '{print $2}'`
		shift
		if test -z "$val"; then
			local possibleval=$1
			printf %s $1 "$possibleval" | grep ^- >/dev/null 2>&1
			if test "$?" != "0"; then
				val=$possibleval
				if [ "$#" -ge 1 ]; then
					shift
				fi
			fi
		fi

		case "$arg" in

			--fota)
				echo "Setting fota update mode" >&2
				echo fota_enable > $FOTA_CONFIG_FILE 
				/bin/fw_setenv SLP_FLAG_FOTA 1
				/bin/fw_setenv SLP_FOTA_PATH $val
				;;
			--fus)
				echo "Setting fus update mode" >&2
				echo fus_enable > $FUS_CONFIG_FILE
				/bin/fw_setenv SLP_FLAG_FUS 1
				echo "kill mtp-ui, data-router" >> /opt/var/log/fus_update.log 2>&1
				killall mtp-ui >> /opt/var/log/fus_update.log 2>&1
				killall data-router >> /opt/var/log/fus_update.log 2>&1
				umount /dev/gadget >> /opt/var/log/fus_update.log 2>&1
				lsmod >> /opt/var/log/fus_update.log 2>&1
				rmmod g_samsung >> /opt/var/log/fus_update.log 2>&1
				;;
			--fus_binary)
				echo "Setting fus binary update mode" >&2
				echo fus_enable > $FUS_CONFIG_FILE
				/bin/fw_setenv SLP_FLAG_FUS 2
				/bin/fw_setenv SLP_FUS_PATH $val
#				echo "kill mtp-ui, data-router" >> /opt/var/log/fus_update.log 2>&1
#				killall mtp-ui >> /opt/var/log/fus_update.log 2>&1
#				killall data-router >> /opt/var/log/fus_update.log 2>&1
#				umount /dev/gadget >> /opt/var/log/fus_update.log 2>&1
#				lsmod >> /opt/var/log/fus_update.log 2>&1
#				rmmod g_samsung >> /opt/var/log/fus_update.log 2>&1
				;;
			--update)
				echo "Setting update mode for engineers" >&2
				echo 0 > /sys/power/always_resume
#				touch /opt/etc/.hib_capturing # make fastboot image again on next booting
				mount -o remount,rw /
				exit
				;;
			--rtl)
				echo "Setting rtl mode" >&2
				echo rtl_enable > $RTL_CONFIG_FILE
				/bin/fw_setenv SLP_FLAG_RTL 1
				;;
			--fota_disable)
				echo "Clear fota update flag" >&2
				/bin/fw_setenv SLP_FLAG_FOTA 0
				;;
			--fus_disable)
				echo "Clear fus update flag" >&2
				/bin/fw_setenv SLP_FLAG_FUS 0
				;;
			--fus_binary_disable)
				echo "Clear fus binary update flag" >&2
				/bin/fw_setenv SLP_FLAG_FUS 0
				;;
			--update_disable)
				echo "Clear engineer update flag" >&2
				/bin/fw_setenv SLP_FLAG_UPDATE 0
				;;
			--rtl_disable)
				echo "Clear rtl test flag" >&2
				/bin/fw_setenv SLP_FLAG_RTL 0
				;;

			-?|--help)
				do_help
				exit 0
				;;
			*)
				echo "Unknown option \"$arg\". See --help" >&2
				do_help
				exit 0
				;;
		esac
	done
}

## main

if test -z "$1"; then
	do_help
	exit 0
fi

do_options $@
reboot
