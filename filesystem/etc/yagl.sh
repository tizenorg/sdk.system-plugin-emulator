#!/bin/sh

if test -f '/usr/lib/yagl/libGLESv2.so' && grep -q 'yagl=1' /proc/cmdline; then
    export LD_LIBRARY_PATH="/usr/lib/yagl${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export ELM_ENGINE=gl
    export YAGL_DEBUG=4
#   export YAGL_DEBUG_FUNC_TRACE=1

    # XXX FIXME: This has to be dropped too
    ulimit -SHl unlimited
fi
