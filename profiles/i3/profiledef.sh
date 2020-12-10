#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="aui-i3"
iso_label="AUI3"
iso_publisher=""
desktop="i3"
iso_application="Archuseriso ${desktop} Live/Rescue medium"
iso_version=""
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
pacman_testing_conf="pacman-testing.conf"
airootfs_image_tool_options=('-comp' 'zstd')
