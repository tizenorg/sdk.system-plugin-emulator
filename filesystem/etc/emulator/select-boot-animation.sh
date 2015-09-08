#/bin/sh -e

CMDLINE=/proc/cmdline
VIDEO=`sed s/.*video=// $CMDLINE | cut -d ' ' -f1`
FORMAT=`echo $VIDEO | cut -d ':' -f2 | cut -d ',' -f2`
RESOLUTION=`echo $FORMAT | cut -d '-' -f1`
W=`echo $RESOLUTION | awk -Fx '{print $1}'`
H=`echo $RESOLUTION | awk -Fx '{print $2}'`

if [ -d /usr/share/edje ] && [ -d /usr/share/edje/emul ] &&
   [ -f /usr/share/edje/emul/1X1_poweron.edj ] && [ -f /usr/share/edje/emul/1X1_poweroff.edj ] &&
   [ -f /usr/share/edje/emul/3X4_poweron.edj ] && [ -f /usr/share/edje/emul/3X4_poweroff.edj ]
then
    rm -f /usr/share/edje/poweron.edj
    rm -f /usr/share/edje/poweroff.edj
    if [ $W == $H ]
    then
	ln -s emul/1X1_poweron.edj /usr/share/edje/poweron.edj
	ln -s emul/1X1_poweroff.edj /usr/share/edje/poweroff.edj
    else
	ln -s emul/3X4_poweron.edj /usr/share/edje/poweron.edj
	ln -s emul/3X4_poweroff.edj /usr/share/edje/poweroff.edj
    fi
fi
