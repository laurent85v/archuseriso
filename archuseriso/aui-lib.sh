#
# Copyright (C) 2026 Laurent Jourden <laurent85@enarel.fr>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Shared library for aui-mkusb, aui-mkhybrid, aui-mkinstall.
# Source this file; do not execute it directly.

# Guard against double-sourcing
[[ -v _AUI_LIB_LOADED ]] && return 0
_AUI_LIB_LOADED=1

# Current supported medium version
AUI_VALID_MEDIUM_VERSION="v14"

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

_msg_info() {
    local _msg="${1}"
    printf '[%s] INFO: %s\n' "${appname}" "${_msg}"
}

# ---------------------------------------------------------------------------
# Filesystem formatting (parameterized)
# ---------------------------------------------------------------------------

# Usage: _format_btrfs <label> <device> <partnum>
_format_btrfs() {
    local _label="${1}" _device="${2}" _partnum="${3}"
    _msg_info "partition #${_partnum}: type Btrfs, label ${_label}"
    if ! udevadm lock --device="${_device}" -- \
            mkfs.btrfs -L "${_label}" -- "${_device}" > /dev/null; then
        echo 'Formating partition failed!'
        exit 1
    fi
}

# Usage: _format_f2fs <label> <device> <partnum>
_format_f2fs() {
    local _label="${1}" _device="${2}" _partnum="${3}"
    _msg_info "partition #${_partnum}: type F2FS, label ${_label}"
    if ! udevadm lock --device="${_device}" -- \
            mkfs.f2fs -l "${_label}" -O encrypt,extra_attr,compression -- "${_device}" > /dev/null; then
        echo 'Formating partition failed!'
        exit 1
    fi
}

# ---------------------------------------------------------------------------
# GRUB EFI binary builder
# ---------------------------------------------------------------------------

# Make GRUB standalone EFI binary
# Usage: _make_grub_efi_binary <grub-efi-arch> <output-filename>
# Requires WD and workdir to be set in the calling script.
_make_grub_efi_binary() {
    local _grub_efi_arch="${1}"
    local _grub_efi_name="${2}"
    local _grubmodules=()

    IFS='' read -r -d '' grubembedcfg <<'EOF' || true
regexp --set=1:archiso_bootdevice '^\(([^)]+)\)\/?[Ee][Ff][Ii]\/?' "$cmdpath"
if ! [ -d "$cmdpath" ]; then
     # On some firmware, GRUB has a wrong cmdpath when booted from an optical disc.
     # https://gitlab.archlinux.org/archlinux/archiso/-/issues/183
     if regexp '^\(([^)]+)\)\/?[Ee][Ff][Ii]\/[Bb][Oo][Oo][Tt]\/?$' "$cmdpath"; then
         cmdpath="${archiso_bootdevice}/EFI/BOOT"
     fi
     if regexp '^\(([^)]+)\)\/?[Ee][Ff][Ii]\/[Gg][Rr][Uu][Bb]\/?$' "$cmdpath"; then
         cmdpath="${archiso_bootdevice}/EFI/grub"
     fi
fi
configfile "(${archiso_bootdevice})/grub/grub.cfg"
EOF

    printf '%s\n' "$grubembedcfg" > "${WD}/${workdir}/grub-embed.cfg"

    # Create EFI binary
    # Module list from https://bugs.archlinux.org/task/71382#comment202911
    _grubmodules=(all_video at_keyboard boot btrfs cat chain configfile echo efifwsetup efinet ext2 f2fs fat font  \
                  gfxmenu gfxterm gzio halt hfsplus iso9660 jpeg keylayouts linux loadenv loopback lsefi lsefimmap \
                  minicmd normal part_apple part_gpt part_msdos png read reboot regexp search search_fs_file       \
                  search_fs_uuid search_label serial sleep tpm usb usbserial_common usbserial_ftdi                 \
                  usbserial_pl2303 usbserial_usbdebug video xfs zstd)
    grub-mkstandalone -O "${_grub_efi_arch}"                                  \
                      --modules="${_grubmodules[*]}"                          \
                      --locales="en@quot"                                     \
                      --themes=""                                             \
                      --sbat=/usr/share/grub/sbat.csv                         \
                      --disable-shim-lock                                     \
                      -o "${WD}/${workdir}/usbesp/EFI/grub/${_grub_efi_name}" \
                      "boot/grub/grub.cfg=${WD}/${workdir}/grub-embed.cfg"
}
