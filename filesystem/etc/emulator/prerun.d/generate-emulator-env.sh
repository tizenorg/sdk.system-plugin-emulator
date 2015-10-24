if [ ! -z $1 ]; then
    NEW_ROOT=$1
else
    NEW_ROOT=
fi

CMDLINE=/proc/cmdline
EMULATOR_ENV=$NEW_ROOT/etc/profile.d/emulator_env.sh

##### network proxy environments
echo -e "*** Generating network proxy env"

if [ -f $EMULATOR_ENV ]; then
    rm -f $EMULATOR_ENV
fi

# for busybux ash
PROXIES0="http_proxy"
PROXIES1="https_proxy"
PROXIES2="ftp_proxy"
PROXIES3="socks_proxy"

URLS0="http"
URLS1="https"
URLS2="ftp"
URLS3="socks"

for index in 0 1 2 3
do
    eval PROXY="\$PROXIES$index"
    eval URL="\$URLS$index"
    if [ ! -z ${PROXY} ] ; then
        EXPORT_CONTENT="${PROXY}="
        if grep -q ${PROXY} $CMDLINE ; then
            __PROXY=`sed "s/^.*${PROXY}=\([^, ]*\).*$/\1/g" $CMDLINE`
            if [ "x${__PROXY}" != "x" ] ; then
                EXPORT_CONTENT="${EXPORT_CONTENT}${URL}://${__PROXY}/" >> $EMULATOR_ENV
            fi
        fi
        echo "export ${EXPORT_CONTENT}" >> $EMULATOR_ENV
        echo -e "- ${EXPORT_CONTENT}"
    fi
done
echo "export no_proxy=localhost,127.0.0.1/8,10.0.2.0/24" >> $EMULATOR_ENV
echo -e "- no_proxy=localhost,127.0.0.1/8,10.0.2.0/24"
