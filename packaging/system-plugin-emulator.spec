Name: system-plugin-emulator
Version: 0.1.11
Release: 1

%define systemd_dir     /usr/lib/systemd

Summary: System plugin for emulator
License: Apache-2.0
Group: System/Configuration
Requires: udev
Requires: util-linux
Requires(post): setup
Requires(post): coreutils
Source0: %{name}-%{version}.tar.gz
Source1001: packaging/%{name}.manifest
ExclusiveArch: %{ix86}

%description
System plugin files for emulator

%prep

%setup -q

%build

%install
find . -name .gitignore -exec rm -f {} \;
cp -arf filesystem/* %{buildroot}

# for systemd
# for emulator_preinit.target
mkdir -p %{buildroot}/%{systemd_dir}/system/basic.target.wants
ln -s %{systemd_dir}/system/emulator_preinit.target %{buildroot}/%{systemd_dir}/system/basic.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants
ln -s %{systemd_dir}/system/emul-setup-audio-volume.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
ln -s %{systemd_dir}/system/emul-common-preinit.service %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
ln -s %{systemd_dir}/system/dev-disk-by\\x2dlabel-emulator\\x2dswap.swap %{buildroot}/%{systemd_dir}/system/emulator_preinit.target.wants/
# for emulator.target
mkdir -p %{buildroot}/%{systemd_dir}/system/multi-user.target.wants
ln -s %{systemd_dir}/system/emulator.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/
ln -s %{systemd_dir}/system/tizen-boot.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/
ln -s %{systemd_dir}/system/tizen-system.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/
ln -s %{systemd_dir}/system/tizen-runtime.target %{buildroot}/%{systemd_dir}/system/multi-user.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/emulator.target.wants
# services from system-plugin-exynos
ln -s ../tizen-generate-env.service %{buildroot}/%{systemd_dir}/system/basic.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/default.target.wants
ln -s ../tizen-readahead-collect.service %{buildroot}/%{systemd_dir}/system/default.target.wants/
ln -s ../tizen-readahead-replay.service %{buildroot}/%{systemd_dir}/system/default.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/tizen-boot.target.wants
ln -s ../wm_ready.service %{buildroot}/%{systemd_dir}/system/tizen-boot.target.wants/
mkdir -p %{buildroot}/%{systemd_dir}/system/tizen-system.target.wants

# include license
mkdir -p %{buildroot}/usr/share/license
cp LICENSE %{buildroot}/usr/share/license/%{name}

%if "%{?tizen_profile_name}" == "mobile" || "%{?tizen_profile_name}" == "tv"
touch %{buildroot}/etc/machine-id
%else
rm %{buildroot}/etc/machine-id
%endif

%post
#make fstab
if [ -e /etc/fstab ]; then
	echo "tmpfs      /tmp      tmpfs   comment=havefs-smackfs-smackfsroot=* 0 0" >> /etc/fstab
fi

%posttrans
#run emulator_ns.preinit script after all packages have been installed.
/etc/preconf.d/emulator_ns.preinit

%files
/etc/emulator/prerun
/etc/emulator/prerun.d/set-model-config.sh
/etc/emulator/prerun.d/generate-emulator-env.sh
/etc/emulator/prerun.d/opengl-es-setup-yagl-env.sh
/etc/inittab
%if "%{?tizen_profile_name}" == "mobile" || "%{?tizen_profile_name}" == "tv"
/etc/machine-id
%endif
/etc/preconf.d/emulator_ns.preinit
/etc/preconf.d/systemd_conf.preinit
/etc/profile.d/emulator_ecore_workaround.sh
/etc/rc.d/rc.emul
/etc/rc.d/rc.firstboot
/etc/rc.d/rc.shutdown
/etc/rc.d/rc.sysinit
/etc/systemd/default-extra-dependencies/ignore-units
/usr/lib/systemd/system/emulator_preinit.target
/usr/lib/systemd/system/emulator.target
/usr/lib/systemd/system/basic.target.wants/emulator_preinit.target
/usr/lib/systemd/system/basic.target.wants/tizen-generate-env.service
/usr/lib/systemd/system/default.target.wants/tizen-readahead-collect.service
/usr/lib/systemd/system/default.target.wants/tizen-readahead-replay.service
/usr/lib/systemd/system/multi-user.target.wants/emulator.target
/usr/lib/systemd/system/multi-user.target.wants/tizen-boot.target
/usr/lib/systemd/system/multi-user.target.wants/tizen-system.target
/usr/lib/systemd/system/multi-user.target.wants/tizen-runtime.target
/usr/lib/systemd/system/emul-setup-audio-volume.service
/usr/lib/systemd/system/emul-common-preinit.service
/usr/lib/systemd/system/dev-disk-by\x2dlabel-emulator\x2dswap.swap
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-setup-audio-volume.service
/usr/lib/systemd/system/emulator_preinit.target.wants/emul-common-preinit.service
/usr/lib/systemd/system/emulator_preinit.target.wants/dev-disk-by\x2dlabel-emulator\x2dswap.swap
/usr/lib/systemd/system/tizen-boot.target
/usr/lib/systemd/system/tizen-system.target
/usr/lib/systemd/system/tizen-runtime.target
/usr/lib/systemd/system/tizen-boot.target.wants/wm_ready.service
/usr/lib/systemd/system/tizen-readahead-collect.service
/usr/lib/systemd/system/tizen-readahead-replay.service
/usr/lib/systemd/system/wm_ready.service
/usr/lib/systemd/system/tizen-generate-env.service
/usr/lib/udev/rules.d/51-tizen-udev-default.rules
/usr/lib/udev/rules.d/95-tizen-emulator.rules
/usr/share/license/%{name}
%manifest packaging/%{name}.manifest

