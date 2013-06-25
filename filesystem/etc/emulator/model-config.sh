#!/bin/sh

#if grep "platform_feature=3btn" /proc/cmdline ; then
#        echo -e "[${_G} turn on the input.keys feature ${C_}]"
#        sed -i 's/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">false/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">true/g' ./model-config.xml
#else
#        echo -e "[${_G} turn off the input.keys feature ${C_}]"
#        sed -i 's/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">true/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">false/g' ./model-config.xml
#fi

CMDLINE=/proc/cmdline
XML=/etc/config/model-config.xml


echo -e "[${_G} model config setting ${C_}]"

if grep --silent "video=" $CMDLINE ; then
        echo -e "[${_G} modify the resolution value of platform features: ${C_}]"

        VIDEO=`sed s/.*video=// $CMDLINE | cut -d' ' -f1`
        FORMAT=`echo $VIDEO | cut -d',' -f2`
        RESOLUTION=`echo $FORMAT | cut -d'-' -f1`
        WIDTH=`echo $RESOLUTION | cut -d'x' -f1`
        HEIGHT=`echo $RESOLUTION | cut -d'x' -f2`

        WIDTH_KEY="tizen.org\/feature\/screen.width\" type=\"int\""
        sed -i s/"$WIDTH_KEY".*\</"$WIDTH_KEY"\>"$WIDTH"\</ $XML
        HEIGHT_KEY="tizen.org\/feature\/screen.height\" type=\"int\""
        sed -i s/"$HEIGHT_KEY".*\</"$HEIGHT_KEY"\>"$HEIGHT"\</ $XML
        echo -e "[${_G} width=$WIDTH, height=$HEIGHT ${C_}]"
fi

if grep --silent "dpi=" $CMDLINE ; then
        echo -e "[${_G} modify the dpi value of platform features: ${C_}]"

        DPI=`sed s/.*dpi=// $CMDLINE | cut -d' ' -f1`
        SCREEN_DPI=`expr "$DPI" "/" 10`

        DPI_KEY="tizen.org\/feature\/screen.dpi\" type=\"int\""
        sed -i s/"$DPI_KEY".*\</"$DPI_KEY"\>"$SCREEN_DPI"\</ $XML
        echo -e "[${_G} dpi=$SCREEN_DPI ${C_}]"
fi

