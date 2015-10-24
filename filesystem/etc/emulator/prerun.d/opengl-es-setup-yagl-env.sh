 #!/bin/sh
if [ ! -z $1 ]; then
        NEW_ROOT=$1
else
        NEW_ROOT=
fi

USR_LIB=$NEW_ROOT/usr/lib
YAGL_PATH=/usr/lib/yagl
DUMMY_PATH=/usr/lib/dummy-gl

echo -e "[${_G} Opengl-es acceleration module setting. ${C_}]"
if [ -e /dev/yagl ] ; then
    echo -e "[${_G} Emulator support gles hw acceleration. ${C_}]"
    echo -e "[${_G} Apply to use hw gles library. ${C_}]"
    ln -s -f $YAGL_PATH/libEGL.so.1.0 $USR_LIB/libEGL.so
    ln -s -f $YAGL_PATH/libEGL.so.1.0 $USR_LIB/libEGL.so.1
    ln -s -f $YAGL_PATH/libGLESv1_CM.so.1.0 $USR_LIB/libGLESv1_CM.so
    ln -s -f $YAGL_PATH/libGLESv1_CM.so.1.0 $USR_LIB/libGLESv1_CM.so.1
    ln -s -f $YAGL_PATH/libGLESv2.so.1.0 $USR_LIB/libGLESv2.so
    ln -s -f $YAGL_PATH/libGLESv2.so.1.0 $USR_LIB/libGLESv2.so.1
else
    echo -e "[${_G} Emulator does *not* support gles hw acceleration. ${C_}]"
    echo -e "[${_G} Apply to use gles stub library. ${C_}]"
    ln -s -f $DUMMY_PATH/libEGL_dummy.so $USR_LIB/libEGL.so
    ln -s -f $DUMMY_PATH/libEGL_dummy.so $USR_LIB/libEGL.so.1
    ln -s -f $DUMMY_PATH/libGLESv1_dummy.so $USR_LIB/libGLESv1_CM.so
    ln -s -f $DUMMY_PATH/libGLESv1_dummy.so $USR_LIB/libGLESv1_CM.so.1
    ln -s -f $DUMMY_PATH/libGLESv2_dummy.so $USR_LIB/libGLESv2.so
    ln -s -f $DUMMY_PATH/libGLESv2_dummy.so $USR_LIB/libGLESv2.so.1
fi
