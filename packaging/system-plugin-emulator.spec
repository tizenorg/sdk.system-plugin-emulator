Name: system-plugin-emulator
Version: 0.0.12
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
if [ ! -d %{buildroot}/etc/rc.d/rc3.d ]; then
    mkdir -p %{buildroot}/etc/rc.d/rc3.d
fi
ln -s /etc/init.d/setup-audio-volume %{buildroot}//etc/rc.d/rc3.d/S02setup-audio-volume
ln -s /etc/init.d/mount-hostdir %{buildroot}//etc/rc.d/rc3.d/S03mount-hostdir
ln -s /etc/init.d/ssh %{buildroot}/etc/rc.d/rc3.d/S50ssh

# for systemd
# for emulator_preinit.target
mkdir -p %{buildroot}/%{systemd_dir}/system/basic.target.wants
ln -s %{systemd_dir}/system/emulator_preinit.target %{buildroot}/%{systemd_dir}/system/basic.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants
ln -s %{systemd_dir}/system/emul-setup-audio-volume.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
ln -s %{systemd_dir}/system/emul-mount-hostdir.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
ln -s %{systemd_dir}/system/emul-common-preinit.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
# for emulator.target
mkdir -p %{buildroot}/%{systemd_dir}/system/multi-user.target.wants
ln -s %{systemd_dir}/system/emulator.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator.target.wants
ln -s %{systemd_dir}/system/sdbd.service %{buildroot}/%{systemd_dir}/system/emulator.target.wants/
ln -s %{systemd_dir}/system/sshd.service %{buildroot}/%{systemd_dir}/system/emulator.target.wants/

# for host file sharing
mkdir -p %{buildroot}/mnt/host

# include license
mkdir -p %{buildroot}/usr/share/license
cp LICENSE %{buildroot}/usr/share/license/%{name}

%post
#make fstab
if [ -e /etc/fstab ]; then
	echo "/opt/var   /var      bind    bind             0 0" >> /etc/fstab
	echo "/tmpfs     /tmp      tmpfs   defaults         0 0" >> /etc/fstab
	echo "/dev/vdb   swap      swap    defaults         0 0" >> /etc/fstab
fi

%files
/etc/emulator/setup-audio-volume.sh
/etc/emulator/mount-hostdir.sh
/etc/emulator/model-config.sh
/etc/init.d/setup-audio-volume
/etc/init.d/mount-hostdir
/etc/inittab
/etc/preconf.d/emulator_ns.preinit
/etc/preconf.d/systemd_conf.preinit
/etc/profile.d/proxy_setting.sh
/etc/rc.d/rc.emul
/etc/rc.d/rc.firstboot
/etc/rc.d/rc.shutdown
/etc/rc.d/rc.sysinit
/etc/rc.d/rc3.d/S02setup-audio-volume
/etc/rc.d/rc3.d/S03mount-hostdir
/etc/rc.d/rc3.d/S50ssh
/usr/lib/systemd/system/emulator_preinit.target
/usr/lib/systemd/system/emulator.target
/usr/lib/systemd/system/basic.target.wants/emulator_preinit.target
/usr/lib/systemd/system/multi-user.target.wants/emulator.target
/usr/lib/systemd/system/emul-setup-audio-volume.service
/usr/lib/systemd/system/emul-mount-hostdir.service
/usr/lib/systemd/system/emul-common-preinit.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-setup-audio-volume.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-mount-hostdir.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-common-preinit.service
/usr/lib/systemd/system/sdbd.service
/usr/lib/systemd/system/sshd.service
/usr/lib/systemd/system/emulator.target.wants/sdbd.service
/usr/lib/systemd/system/emulator.target.wants/sshd.service
/usr/lib/udev/rules.d/95-tizen-emulator.rules
%dir /mnt/host
/usr/share/license/%{name}
