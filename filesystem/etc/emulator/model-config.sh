#!/bin/sh

CMDLINE=/proc/cmdline
XML=/etc/config/model-config.xml


echo -e "[${_G} model config setting ${C_}]"

# display resolution
if grep --silent "video=" $CMDLINE ; then
        echo -e "[${_G} modify the resolution value of platform features: ${C_}]"

        VIDEO=`sed s/.*video=// $CMDLINE | cut -d ' ' -f1`
        FORMAT=`echo $VIDEO | cut -d ':' -f2 | cut -d ',' -f2`
        RESOLUTION=`echo $FORMAT | cut -d '-' -f1`
        WIDTH=`echo $RESOLUTION | cut -d 'x' -f1`
        HEIGHT=`echo $RESOLUTION | cut -d 'x' -f2`

        TR_NUM=`echo $WIDTH$HEIGHT | tr -d '[0-9]'`
        if [ "$TR_NUM" != "" ] ; then
            echo "non-integer argument"
        else
            WIDTH_KEY="tizen.org\/feature\/screen.width\" type=\"int\""
            sed -i s/"$WIDTH_KEY".*\</"$WIDTH_KEY"\>"$WIDTH"\</ $XML
            HEIGHT_KEY="tizen.org\/feature\/screen.height\" type=\"int\""
            sed -i s/"$HEIGHT_KEY".*\</"$HEIGHT_KEY"\>"$HEIGHT"\</ $XML
            echo -e "[${_G} width=$WIDTH, height=$HEIGHT ${C_}]"

            # screen size
            SCREENSIZE_KEY="tizen.org\/feature\/screen.size.normal."
            SCREENSIZE_KEY_WQVGA=""$SCREENSIZE_KEY"240.400\" type=\"bool\""
            SCREENSIZE_KEY_HVGA=""$SCREENSIZE_KEY"320.480\" type=\"bool\""
            SCREENSIZE_KEY_WVGA=""$SCREENSIZE_KEY"480.800\" type=\"bool\""
            SCREENSIZE_KEY_WSVGA=""$SCREENSIZE_KEY"600.1024\" type=\"bool\""
            SCREENSIZE_KEY_HD=""$SCREENSIZE_KEY"720.1280\" type=\"bool\""
            SCREENSIZE_KEY_FHD=""$SCREENSIZE_KEY"1080.1920\" type=\"bool\""

            if [ $WIDTH -eq 480 ] && [ $HEIGHT -eq 800 ] ; then
                # WVGA
                sed -i s/"$SCREENSIZE_KEY_WVGA".*\</"$SCREENSIZE_KEY_WVGA"\>true\</ $XML
                sed -i s/"$SCREENSIZE_KEY_HD".*\</"$SCREENSIZE_KEY_HD"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_FHD".*\</"$SCREENSIZE_KEY_FHD"\>false\</ $XML
            elif [ $WIDTH -eq 720 ] && [ $HEIGHT -eq 1280 ] ; then
                # HD
                sed -i s/"$SCREENSIZE_KEY_WVGA".*\</"$SCREENSIZE_KEY_WVGA"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_HD".*\</"$SCREENSIZE_KEY_HD"\>true\</ $XML
                sed -i s/"$SCREENSIZE_KEY_FHD".*\</"$SCREENSIZE_KEY_FHD"\>false\</ $XML
            elif [ $WIDTH -eq 1080 ] && [ $HEIGHT -eq 1920 ] ; then
                # FHD
                sed -i s/"$SCREENSIZE_KEY_WVGA".*\</"$SCREENSIZE_KEY_WVGA"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_HD".*\</"$SCREENSIZE_KEY_HD"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_FHD".*\</"$SCREENSIZE_KEY_FHD"\>true\</ $XML
            else
                # etc
                sed -i s/"$SCREENSIZE_KEY_WVGA".*\</"$SCREENSIZE_KEY_WVGA"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_HD".*\</"$SCREENSIZE_KEY_HD"\>false\</ $XML
                sed -i s/"$SCREENSIZE_KEY_FHD".*\</"$SCREENSIZE_KEY_FHD"\>false\</ $XML
            fi
        fi
fi

# dot per inch
if grep --silent "dpi=" $CMDLINE ; then
        echo -e "[${_G} modify the dpi value of platform features: ${C_}]"

        DPI=`sed s/.*dpi=// $CMDLINE | cut -d ' ' -f1`

        TR_NUM=`echo $DPI | tr -d '[0-9]'`
        if [ "$TR_NUM" != "" ] ; then
            echo "non-integer argument"
        else
            SCREEN_DPI=`expr "$DPI" "/" 10`

            DPI_KEY="tizen.org\/feature\/screen.dpi\" type=\"int\""
            sed -i s/"$DPI_KEY".*\</"$DPI_KEY"\>"$SCREEN_DPI"\</ $XML
            echo -e "[${_G} dpi=$SCREEN_DPI ${C_}]"
        fi
fi

