#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="aui-lxqt"
iso_label="AUILX"
iso_publisher=""
desktop="LXQt"
iso_application="Archuseriso ${desktop} Live/Rescue medium"
iso_version=""
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr'
           'bios.syslinux.eltorito'
           'uefi-ia32.grub.eltorito'
           'uefi-ia32.grub.esp'
           'uefi-x64.grub.eltorito'
           'uefi-x64.grub.esp'
           'uefi-x64.refind.eltorito'
           'uefi-x64.refind.esp'
           'uefi-ia32.systemd-boot.eltorito'
           'uefi-ia32.systemd-boot.esp'
           'uefi-x64.systemd-boot.esp'
           'uefi-x64.systemd-boot.eltorito'
           )
ia32_uefi_default_bootloader="uefi-ia32.systemd-boot.esp"
x64_uefi_default_bootloader="uefi-x64.systemd-boot.esp"
arch="x86_64"
pacman_conf="pacman.conf"
pacman_testing_conf="pacman-testing.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:750"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
)
