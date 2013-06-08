#!/bin/sh

echo -e "[${_G} model config setting ${C_}]"
if grep "platform_feature=3btn" /proc/cmdline ; then
        echo -e "[${_G} turn on input.keys feature ${C_}]"
        sed -i 's/name=\"tizen.org\/feature\/input.keys.menu\" type=\"bool\">false/name=\"tizen.org\/feature\/input.keys.menu\" type=\"bool\">true/g' /etc/config/model-config.xml
        sed -i 's/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">false/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">true/g' /etc/config/model-config.xml
else
        echo -e "[${_G} turn off input.keys feature ${C_}]"
        sed -i 's/name=\"tizen.org\/feature\/input.keys.menu\" type=\"bool\">true/name=\"tizen.org\/feature\/input.keys.menu\" type=\"bool\">false/g' /etc/config/model-config.xml
        sed -i 's/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">true/name=\"tizen.org\/feature\/input.keys.back\" type=\"bool\">false/g' /etc/config/model-config.xml
fi

