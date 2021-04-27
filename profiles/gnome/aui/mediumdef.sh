#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

aui_suffix="$(mktemp -u _XXX)"
cow_label="COW${aui_suffix:-}"
crypt_label="LUKS${aui_suffix:-}"
crypt_mapper="LUKS${aui_suffix:-}"
esp_label="ESP${aui_suffix:-}"
desktop="%DESKTOP%"
img_label="%ARCHISO_LABEL%${aui_suffix:-}"
install_dir="%INSTALL_DIR%"
iso_label="%ARCHISO_LABEL%"
iso_name="%ISO_NAME%"
iso_version="%ISO_VERSION%"
lang="%LANG%"
medium_version='v5'
root_label=ROOT${aui_suffix:-}
cow_files_settings=(
        "persistent_${img_label}/x86_64/upperdir/etc/fstab")
esp_files_settings=(
        'EFI/BOOT/refind.conf'
        'loader/entries/archiso-aui-0-x86_64-linux.conf'
        'loader/entries/archiso-aui-1-x86_64-linux.conf'
        'loader/entries/archiso-x86_64-linux.conf'
        'loader/entries/archiso_2_console-x86_64-linux.conf'
        'loader/entries/archiso_3_ram-x86_64-linux.conf'
        'syslinux/archiso_pxe-linux.cfg'
        'syslinux/archiso_sys-linux.cfg')
root_files_settings=(
        'etc/fstab'
)
