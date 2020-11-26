#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="aui-xfce"
iso_label="AUIX"
iso_publisher=""
desktop="Xfce"
iso_application="Archuseriso ${desktop} Live/Rescue medium"
iso_version=""
install_dir="arch"
profile="xfce"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
