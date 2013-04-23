#!/bin/sh

CHECK_SENSOR="/opt/sensor"
CHECK_ACCEL="/opt/sensor/accel"
CHECK_LIGHT="/opt/sensor/light"
CHECK_PROXI="/opt/sensor/proxi"
CHECK_GEO="/opt/sensor/geo"
CHECK_GYRO="/opt/sensor/gyro"
CHECK_NFC="/opt/nfc"
CHECK_NFC_FILE="/opt/nfc/sdkMsg"

if [ ! -d $CHECK_SENSOR ]; then
	mkdir /opt/sensor

	if [ ! -d $CHECK_ACCEL ]; then
		mkdir /opt/sensor/accel
	fi

	if [ ! -d $CHECK_LIGHT ]; then
		mkdir /opt/sensor/light
	fi

	if [ ! -d $CHECK_PROXI ]; then
		mkdir /opt/sensor/proxi
	fi

	if [ ! -d $CHECK_GEO ]; then
		mkdir /opt/sensor/geo
	fi

	if [ ! -d $CHECK_GYRO ]; then
		mkdir /opt/sensor/gyro
	fi

	chmod -R 777 /opt/seneor/

	touch /opt/sensor/accel/name
	echo "accel_sim" > /opt/sensor/accel/name
	touch /opt/sensor/accel/xyz
	echo "0, 980665, 0" > /opt/sensor/accel/xyz

	touch /opt/sensor/light/name
	echo "light_sim" > /opt/sensor/light/name
	touch /opt/sensor/light/adc
	echo "65535" > /opt/sensor/light/adc
	touch /opt/sensor/light/level
	echo "10" > /opt/sensor/light/level

	touch /opt/sensor/proxi/name
	echo "proxi_sim" > /opt/sensor/proxi/name
	touch /opt/sensor/proxi/enable
	echo "1" > /opt/sensor/proxi/enable
	touch /opt/sensor/proxi/vo
	echo "8" > /opt/sensor/proxi/vo

	touch /opt/sensor/gyro/name
	echo "gyro_sim" > /opt/sensor/gyro/name
	touch /opt/sensor/gyro/gyro_x_raw
	echo "0" > /opt/sensor/gyro/gyro_x_raw
	touch /opt/sensor/gyro/gyro_y_raw
	echo "0" > /opt/sensor/gyro/gyro_y_raw
	touch /opt/sensor/gyro/gyro_z_raw
	echo "0" > /opt/sensor/gyro/gyro_z_raw

	touch /opt/sensor/geo/name
	echo "geo_sim" > /opt/sensor/geo/name
	touch /opt/sensor/geo/raw
	echo "0 -90 0 3" > /opt/sensor/geo/raw
	touch /opt/sensor/geo/tesla
	echo "1 0 -10" > /opt/sensor/geo/tesla
else
	echo "0, 980665, 0" > /opt/sensor/accel/xyz
	echo "65535" > /opt/sensor/light/adc
	echo "10" > /opt/sensor/light/level
	echo "1" > /opt/sensor/proxi/enable
	echo "8" > /opt/sensor/proxi/vo
	echo "0" > /opt/sensor/gyro/gyro_x_raw
	echo "0" > /opt/sensor/gyro/gyro_y_raw
	echo "0" > /opt/sensor/gyro/gyro_z_raw
	echo "0 -90 0 3" > /opt/sensor/geo/raw
	echo "1 0 -10" > /opt/sensor/geo/tesla
fi


if [ ! -d $CHECK_NFC ]; then
	mkdir /opt/nfc
	touch /opt/nfc/sdkMsg
else
	if [ ! -f $CHECK_NFC_FILE ]; then
		touch /opt/nfc/sdkMsg
	fi
fi

