Name: system-plugin-emulator
Version: 0.0.2
Release: 1

%define systemd_dir     /usr/lib/systemd

Summary: System plugin for emulator
License: Apache-2.0
Group: System/Base
Requires: udev
Requires: util-linux
Requires: sysvinit
Requires(post): setup
Requires(post): coreutils
Source0: %{name}-%{version}.tar.gz
Source1001: packaging/%{name}.manifest

%description
System plugin files for emulator

%prep

%setup -q

%build

%install
find . -name .gitignore -exec rm -f {} \;
cp -arf filesystem/* %{buildroot}

# for legacy init
ln -s /etc/init.d/ssh %{buildroot}/etc/rc.d/rc3.d/S50ssh

# for systemd
# for emulator_preinit.target
mkdir -p %{buildroot}/%{systemd_dir}/system/basic.target.wants
ln -s %{systemd_dir}/system/emulator_preinit.target %{buildroot}/%{systemd_dir}/system/basic.target.wants/emulator_preinit.target
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants
ln -s %{systemd_dir}/system/emul-opengl-mode.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/emul-opengl-mode.service
ln -s %{systemd_dir}/system/emul-opengl-yagl.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/emul-opengl-yagl.service
ln -s %{systemd_dir}/system/emul-alsa.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/emul-alsa.service
ln -s %{systemd_dir}/system/emul-legacy-start.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/emul-legacy-start.service
# for emulator.target
mkdir -p %{buildroot}/%{systemd_dir}/system/multi-user.target.wants
ln -s %{systemd_dir}/system/emulator.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/emulator.target
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator.target.wants
ln -s %{systemd_dir}/system/sdbd.service %{buildroot}/%{systemd_dir}/system/emulator.target.wants/sdbd.service
ln -s %{systemd_dir}/system/sshd.service %{buildroot}/%{systemd_dir}/system/emulator.target.wants/sshd.service

%post
mkdir -p /opt/usr
if [ -d /opt/media ]; then
        cp -aprf /opt/media/* /opt/usr/media/.
	rm -rf /opt/media
else
        mkdir -p /opt/usr/media
fi
if [ -d /opt/apps ]; then
        cp -aprf /opt/apps/* /opt/usr/apps/.
	rm -rf /opt/apps
else
        mkdir -p /opt/usr/apps
fi
if [ -d /opt/live ]; then
        cp -aprf /opt/live/* /opt/usr/live/.
	rm -rf /opt/live
else
        mkdir -p /opt/usr/live
fi
if [ -d /opt/ug ]; then
        cp -aprf /opt/ug/* /opt/usr/ug/.
	rm -rf /opt/ug
else
        mkdir -p /opt/usr/ug
fi
mkdir -p /opt/osp
mkdir -p /opt/usr/dbspace
ln -sf /opt/usr/apps /opt/apps
ln -sf /opt/usr/media /opt/media
ln -sf /opt/usr/live    /opt/live
ln -sf /opt/usr/osp/share       /opt/osp/share
ln -sf /opt/usr/ug      /opt/ug

#make fstab
if [ -e /etc/fstab ]; then
	echo "/opt/var   /var      bind    bind             0 0" >> /etc/fstab
	echo "/tmpfs     /tmp      tmpfs   defaults         0 0" >> /etc/fstab
	echo "/dev/vdb   swap      swap    defaults         0 0" >> /etc/fstab
fi

#make rtc1 device for alarm service
touch /dev/rtc1

%files
/bin/change-booting-mode.sh
/bin/ifconfig
/bin/mdev
/bin/route
/bin/ubimnt.sh
/etc/emulator/.emptydir
/etc/init.d/csa-tools
/etc/inittab
/etc/mdev.conf
/etc/mtools.conf
/etc/preconf.d/sshd.sh
/etc/profile.d/launcher.sh
/etc/profile.d/proxy_setting.sh
/etc/profile.d/sensord_setting.sh
/etc/profile.d/simulator-env.sh
/etc/profile.d/simulator-opengl.sh
/etc/profile.d/system.sh
/etc/rc.d/init.d/simulator-alsa
/etc/rc.d/rc.emul
/etc/rc.d/rc.firstboot
/etc/rc.d/rc.shutdown
/etc/rc.d/rc.sysinit
/etc/rc.d/rc3.d/S01simulator-alsa
/etc/rc.d/rc3.d/S20vmodem
/etc/rc.d/rc3.d/S45vconf-menuscreen
/etc/rc.d/rc3.d/S50ssh
/etc/rc.d/rc3.d/S96set_valperiod
/etc/rc.d/rc5.d/S99zzzbackup_csa
/etc/sshd_config
/etc/virtgl.sh
/etc/yagl.sh
/lib/udev/rules.d/99-serial-console.rules
/opt/home/root/.launcher/launcher.exit
/opt/media/.emptydir
/usr/bin/mount_slp.sh
/usr/bin/save_blenv
/usr/bin/wlan.sh
/usr/lib/systemd/system/emulator_preinit.target
/usr/lib/systemd/system/emulator.target
/usr/lib/systemd/system/basic.target.wants/emulator_preinit.target
/usr/lib/systemd/system/multi-user.target.wants/emulator.target
/usr/lib/systemd/system/emul-alsa.service
/usr/lib/systemd/system/emul-legacy-start.service
/usr/lib/systemd/system/emul-opengl-mode.service
/usr/lib/systemd/system/emul-opengl-yagl.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-alsa.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-legacy-start.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-opengl-mode.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-opengl-yagl.service
/usr/lib/systemd/system/sdbd.service
/usr/lib/systemd/system/sshd.service
/usr/lib/systemd/system/emulator.target.wants/sdbd.service
/usr/lib/systemd/system/emulator.target.wants/sshd.service
/usr/lib/udev/rules.d/95-tizen-emulator.rules
