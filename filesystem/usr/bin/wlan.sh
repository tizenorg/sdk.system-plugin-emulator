#!/bin/sh  

#PWRND=/proc/btwlan/bcm4329
DRV_PATH=/lib/modules/2.6.32.9
FW_PATH=/lib/firmware

# Driver path
DRIVER=$DRV_PATH/dhd.ko
MFTDRV=$DRV_PATH/wlan_manufacture.ko

# Firmware path
FIRMWARE=$FW_PATH/sdio-g-cdc-full11n-reclaim-roml-wme-idsup-pktfilter.bin
SOFTAP_FIRMWARE=$FW_PATH/sdio-g-cdc-roml-reclaim-wme-apsta-idsup-idauth.bin
MFTFW=$FW_PATH/sdio-ag-cdc-11n-roml-mfgtest.bin

# NVRAM path
NVRAM_COB=$FW_PATH/nvram_bcm4329_26.txt 
NVRAM_MOD=$FW_PATH/nvram_bcm4329_38.txt
NVRAM=$NVRAM_COB
MFTNVRAM_COB=$FW_PATH/nvram_mfg_rev09.txt
MFTNVRAM_MOD=$FW_PATH/nvram_mfg_h2.txt
MFTNVRAM=$MFTNVRAM_COB


check_hw()
{
	REVISION_NUM=`grep Revision /proc/cpuinfo | awk "{print \\$3}"`
	echo $REVISION_NUM > /tmp/revision_tmp
	REVISION_LOW=`cut -c3- /tmp/revision_tmp`
	REVISION_HIGH=`cut -c1-2 /tmp/revision_tmp`

	#echo $REVISION_LOW
	echo "HW revision = $REVISION_NUM"
	rm /tmp/revision_tmp
#	hw rev
#	H2=200c	S1=100e	AQ03=0809 LM08=8002

	if [ "$REVISION_HIGH" == 20 ]||[ "$REVISION_NUM" == 200c ]|| 
	   [ "$REVISION_NUM" == 1008 ]||[ "$REVISION_NUM" == 100e ]||
	   [ "$REVISION_NUM" == 0809 ]
	then
		NVRAM=$NVRAM_MOD
		MFTNVRAM=$MFTNVRAM_MOD
		echo "This is for H2 S1"
	fi
}
start()
{
check_hw
	rfkill unblock wlan
	echo $FIRMWARE
    insmod $DRIVER firmware_path=$FIRMWARE nvram_path=$NVRAM

	sleep 1
	ifconfig eth0 up
#	exit 1
	
#	while true
#	do
#	  if ifconfig -a | grep eth0 > /dev/null
#	  then
#		ifconfig eth0 up
#		exit 1
#	  fi
#	done	
}
stop()
{
	killall udhcpd
   	ifconfig eth0 down
  	rmmod dhd
	rfkill block wlan
}

softap()
{
	if ifconfig -a | grep eth0 > /dev/null
	then
		stop
	fi
	FIRMWARE=$SOFTAP_FIRMWARE
	start
	create_softap
	ifconfig wl0.1 192.168.16.1 up
	udhcpd /etc/udhcpd_wl01.conf
}

mfton()
{
check_hw
	rfkill unblock wlan

  	lsmod | grep 'wlan_' > /dev/null
  	if [ $? -ne 0 ]; then
		echo manufacture mode is not on! proceed
  	else
	 	echo manufacture mode is already running! quit
		exit 1
  	fi

	insmod $DRIVER firmware_path=$MFTFW nvram_path=$MFTNVRAM
	sleep 1
	ifconfig eth0 up
	wl PM 0
	mknod /dev/wlanserial c 230 0
	echo 0 > /proc/sys/kernel/printk
	insmod $MFTDRV
	mft_wlan 

}
mftphone()
{
check_hw
	rfkill unblock wlan

  	lsmod | grep 'wlan_' > /dev/null
  	if [ $? -ne 0 ]; then
		echo manufacture mode is not on! proceed
  	else
	 	echo manufacture mode is already running! quit
		exit 1
  	fi

	insmod $DRIVER firmware_path=$MFTFW nvram_path=$MFTNVRAM
	sleep 1
	ifconfig eth0 up

	wl PM 0
#	getWifiMac
#	mknod /dev/wlanserial c 230 0
#	echo 0 > /proc/sys/kernel/printk
#	insmod /lib/modules/wlan_manufacture.ko
#	mft_wlan -m
}
mftoff()
{	
   	ifconfig eth0 down
   	killall mft_wlan
  	rmmod wlan_manufacture
	rmmod dhd
	rm /dev/wlanserial
	rfkill block wlan
}
rftest()
{
check_hw
	rfkill unblock wlan
	insmod $DRIVER firmware_path=$MFTFW nvram_path=$MFTNVRAM
	sleep 1  
	ifconfig eth0 up
	wl PM 0
}


case $1 in
"start")
start
;;
"stop")
stop
;;
"softap")
softap
;;
"mfton")
mfton
;;
"mftphone")
mftphone
;;
"mftoff")
mftoff
;;
"rftest")
rftest
;;
"test")
check_hw
;;
*)
echo wlan.sh [start] [stop] [softap] [mfton] [mftoff] [rftest]
exit 1
;;
esac
