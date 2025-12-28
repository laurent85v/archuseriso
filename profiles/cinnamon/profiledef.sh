#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="aui-cinnamon"
iso_label="AUICI"
iso_publisher=""
desktop="Cinnamon"
iso_application="Archuseriso ${desktop} Live/Rescue medium"
iso_version=""
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub'
           'uefi.refind'
           'uefi.systemd-boot'
           )
uefi_default_bootloader="uefi.systemd-boot"
arch="x86_64"
pacman_conf="pacman.conf"
pacman_testing_conf="pacman-testing.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:750"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
)
