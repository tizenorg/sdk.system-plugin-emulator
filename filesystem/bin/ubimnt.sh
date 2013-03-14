#!/bin/sh
#
# ubimnt.sh : mount ubifs volume on directory
#	ubifs [ubi_vol_name] [mnt pos] [force]
#		ubi_vol_name : volume name
#		mnt_pos : mount directory
#		force : if failed print error and stop
#
# ex) ./ubifs csa /csa -f
#
if [ $# -lt 2 ];then
	echo "$0 Error : no volume name or mount directory"
	echo "ex) $0 modem /modem"
	exit 1
fi

_volname=$1
_mntpos=$2
_force=$3

_kernelver=$(uname -r)
_modpath="/lib/modules/${_kernelver}"
_ubisysfs="/sys/class/ubi"
_winpower="/sys/devices/platform/s3cfb/win_power"
_vtcon="/sys/class/vtconsole/vtcon1"
_vt_insmod="font softcursor bitblit fbcon"
_vt_rmmod="fbcon bitblit softcursor font"
_fbcondev="/dev/tty1"
_stdcon="/dev/console"
_condev="${_stdcon}"

_mtdname=$(grep ${_volname} /proc/mtd | cut -d : -f 1)
_mtdnum=${_mtdname#mtd}

fbcon_open() {
	for i in `echo ${_vt_insmod}`
	do 
		if [ ! -f "${_modpath}/${i}.ko" ];then
			_condev=${_stdcon}
			return 1
		fi
		insmod ${_modpath}/${i}.ko >/dev/null 2>&1
	done
	echo 0 1 > ${_winpower}
	echo 3 0 > ${_winpower}

	_condev="${_fbcondev}"
}

fbcon_close() {
	if [ ! -f "${_vtcon}/bind" ];then
		echo "FB console is not opened"
		return 1
	fi

	echo 0 > ${_vtcon}/bind
	echo 3 1 > ${_winpower}
	echo 0 0 > ${_winpower}
	for i in `echo ${_vt_rmmod}`
	do 
		rmmod ${i} >/dev/null 2>&1
	done
	_condev=${_stdcon}
}

put_error1() {
        echo -e "\n\nFATAL !!! Can't mount ${_volname} partition." >${_condev}
	echo -e "  Please contact sh0130.kim(010-8820-2960) or anyone in kernel part.\n\n" >${_condev}
}

put_error2() {
	echo -e "\n\nFATAL !! Can't make ${_volname} volume in ${_ubidev}." >${_condev}
	echo -e "  Please contact sh0130.kim(010-8820-2960) or anyone in kernel part." >${_condev}
}

############################
# Main
############################

# Check volume exists.
_ubidev=$(grep ${_volname} $(find ${_ubisysfs} -name name)|cut -d "/" -f 5)

if [ -z "${_ubidev}" ];then

	if [ -z "${_force}" ]; then
		exit 0
	fi

	fbcon_open

	echo -e "\n\nWARNNING !!! ${_volname} partition is not exists." >${_condev}

	# Check if failed on csa. CSA may need to initialize.
	if [ "${_volname}" == "csa" ];then
		echo -e "  Initilize ${_volname} forcibly despite of not in manufacturing process, you may loose your data (eg, IMEI)." >${_condev}
		echo -e "\nErase anyway?  [y/N] "	>${_condev}
		read _answer; _answer=$(echo ${_answer} | tr a-z A-Z)
		
		if [ "${_answer}" == "Y" ];then

			/bin/ubidetach -p /dev/${_mtdname}
			
			/bin/ubiformat -y /dev/${_mtdname}
			if [ $? -ne 0 ]; then
				echo -e "\nubiformat error\n" >${_condev}
				put_error2
				exit 1
			fi

			/bin/ubiattach -p /dev/${_mtdname}
			if [ $? -ne 0 ]; then
				echo -e "\nubiattach error\n" >${_condev}
				put_error2
				exit 1
			fi

			_ubidev=$(grep "^${_mtdnum}$" $(find ${_ubisysfs} -name mtd_num)|cut -d / -f 5)
			_devmajor=$(cat ${_ubisysfs}/${_ubidev}/dev|cut -d : -f 1)

			echo -e "\t$ /bin/mknod /dev/${_ubidev} c ${_devmajor} 0"
			/bin/mknod /dev/${_ubidev} c ${_devmajor} 0

			echo -e "\t$ /bin/ubimkvol /dev/${_ubidev} -m -N ${_volname}"
			/bin/ubimkvol /dev/${_ubidev} -m -N ${_volname}

			if [ $? -ne 0 ]; then
				put_error2
				exit 1
			fi
		else
			put_error1
			exit 1
		fi
	else
		put_error1
		exit 1
	fi
	
	fbcon_close

	_ubidev=$(grep ${_volname} $(find ${_ubisysfs} -name name)|cut -d "/" -f 5)
fi

# Check if mounted already
_mounted_already=$(grep "${_ubidev}!${_volname} ${_mntpos}" /etc/mtab)
if [ -n "${_mounted_already}" ];then
	echo -e "\nWARNNING !!! ${_volname} partition seems to be mounted already.\n"
	exit 0
fi

# Mount it.
mount -t ubifs -o bulk_read,no_chk_data_crc ${_ubidev}!${_volname} ${_mntpos}
if [ $? -ne 0 ]; then
	fbcon_open
	put_error1
	exit 1
fi

exit 0
