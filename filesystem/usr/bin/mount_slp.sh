#!/bin/sh
# mount_slp.sh : mount variable partitions and the partition described on fstab for slp
#
#

_device=
_mnt_point=
_fs_type=
_var_part=
_ignore_part="/mnt/csc"
_force=

mount_fail() {
	for part in $_ignore_part
	do
		if [ "$part" == "$_mnt_point" ]; then
			return
		fi
	done
        echo -e "\n\nFATAL !!! ${_device} is not mounted on ${_mnt_point} as $_fs_type."
	echo -e "  Please contact wonil22.choi@samsung.com or anyone in kernel part.\n\n"
# Wait until user's input
	echo -e "\nPress 'y' key and press enter"
	read _answer < /dev/console; _answer=$(echo ${_answer} | tr a-z A-Z)
	while [ "${_answer}" != "Y" ]; do
		echo -e "\nPress 'y' key and press enter"
		read _answer < /dev/console; _answer=$(echo ${_answer} | tr a-z A-Z)
	done
}

# $1 - device
# $2 - mount point
# $3 - fs type
# if mounted properly, return 1 or return 0
chk_mnt() {
	if [ -z $_device ]; then
		return 0
	fi
	_tmp_mp=`grep $_mnt_point /etc/mtab | awk '{print $2}' | grep $_mnt_point`
	_tmp_ft=`grep $_mnt_point /etc/mtab | awk '{print $3}'| grep $_fs_type`
	if [[ -z "$_tmp_mp" || -z "$_tmp_ft" ]]; then
		return 0
	fi
	return 1
}

chk_mnt_fstab() {
	while read line
	do
		if [[ "z" != "z$line" && "#" != "${line:0:1}" ]]; then
			_device=`echo $line | awk '{print $1}'`
			_mnt_point=`echo $line | awk '{print $2}'`
			_fs_type=`echo $line | awk '{print $3}'`
			chk_mnt
			if [ $? -eq 0 ]; then
				mount_fail
			fi
		fi
	done < /etc/fstab
}

# If we have each fstab file for each specific target,
# following scripts are not required.
# But we don't have that now, so we get the variable partitions from the
# bootloader environment variable, that is SLP_VAR_PART.
# SLP_VAR_PART has "<partition name> <device> <mount point> <fs type>"

get_fw_env() {
	_tmp_vp=`/bin/fw_printenv | grep SLP_VAR_PART`
	if [ "z$_tmp_vp" == "z" ]; then
		echo "There is no SLP_VAR_PART variable from bootloader"
		return
	fi
	_var_part="${_tmp_vp#SLP_VAR_PART=}"
}

mount_one_part() {

	chk_mnt
	if [ $? -eq 1 ]; then
		echo "$_device is already mounted on $_mnt_point"
		return
	fi

	_tmp_ft=`/sbin/fs-type-checker $_device`
	if [[ "$_tmp_ft" == "Unknown fs-type" && "$_fs_type" == "ext4" ]]; then
		echo -e "  Initilize ${_device} forcibly despite of not in manufacturing process, you may loose your data."
		echo -e "\nErase anyway?  [y/N] "
		if [ -z "$_force" ]; then
			read _answer < /dev/console; _answer=$(echo ${_answer} | tr a-z A-Z)
		else
			_answer=Y
		fi

		if [ "${_answer}" == "Y" ];then
			/sbin/mkfs.ext4 $_device -F
			if [ $? -ne 0 ]; then
				echo "mkfs.ext4 error"
				exit 1
			fi
		fi
	fi

	if [ $_fs_type == "ubifs" ]; then
		if [ -z "$_force" ]; then
			/bin/ubimnt.sh $_name $_mnt_point -F
		else
			/bin/ubimnt.sh $_name $_mnt_point -F << EOF
y
EOF
		fi
	else
		mount -t $_fs_type $_device $_mnt_point
	fi
	if [ $? -ne 0 ]; then
		mount_fail
		exit 1
	fi
}

# get one partition info from SLP_VAR_PART and mount it
mount_var() {
	get_fw_env
	i=0
	for word in $_var_part; do
		case `expr $i % 4` in
			0)
				_name=$word
				;;
			1)
				_device=$word
				;;
			2)
				_mnt_point=$word
				;;
			3)
				_fs_type=${word%;}
				mount_one_part
				;;
		esac
		let i+=1
	done
}

_arg=
parse_arg() {
	get_fw_env
	i=0
	_match=
	for word in $_var_part; do
		if [ "$_arg" == "$word" ]; then
			_match=1
		fi
		case `expr $i % 4` in
			0)
				_name=$word
				;;
			1)
				_device=$word
				;;
			2)
				_mnt_point=$word
				;;
			3)
				_fs_type=${word%;}
				if [ "z$_match" == "z1" ]; then
					mount_one_part
					return
				fi
				;;
		esac
		let i+=1
	done
# It is not a variable partition. mount with fstab.
	echo "mount with fstab"
	mount $_arg

	if [ $? -eq 255 ]; then
		_mnt_chk=`grep $_arg /etc/mtab`
		if [ "z$_mnt_chk" == "z" ]; then
			exit 1
		fi
		echo "WARNING !!! $_arg seems to be mounted already."
	elif [ $? -ne 0 ]; then
		exit 1
	fi
}

# print help
do_help() {
	echo
	echo "Usage: $0 -a/PART_NAME/DEVICE/MOUNT_POINT"
	echo
	echo " Mount partition(s) for SLP."
	echo " PART_NAME is only availalbe with SLP_VAR_PART variable of the bootloader"
	echo
	echo -e "       ex) $0 csa           \t For specified partition on SLP_VAR_PART"
	echo -e "           $0 -a            \t For mount all partitions"
	echo -e "           $0 /dev/mmcblk0p3\t For mount /dev/mmcblk0p3"
	echo
	get_fw_env
	if [ "z" != "z$_var_part" ]; then
		echo -e "There is one or more variable partition(s)..\n\t $_var_part\n"
	fi
}



# mount all for SLP partitions
mount_all() {
	mount_var
	mount -a
	if [ $? -ne 0 ]; then
		chk_mnt_fstab
		exit 1
	fi
}

case "$1" in
	-a)
		mount_all
		;;
	-f)
		if [ $# != 2 ]; then
			do_help
		else
			_force=$1
			_arg=$2
			parse_arg
		fi
		;;
	*)
		if [ $# != 1 ]; then
			do_help
		else
			_arg=$1
			parse_arg
		fi
		;;
esac

date > /opt/etc/mnt.log
cat /opt/etc/info.ini >> /opt/etc/mnt.log
mount >> /opt/etc/mnt.log
exit 0

