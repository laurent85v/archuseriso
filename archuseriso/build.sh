#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

iso_name=aui-xfce
iso_label=AUIX
iso_publisher=""
desktop=Xfce
iso_application="Archuseriso ${desktop} Live/Rescue medium"
iso_version=""
install_dir=arch
work_dir=work
out_dir=out
gpg_key=""
lang=""
comp_type=zstd
profile=xfce

verbose=""

umask 0022

_usage ()
{
    echo "usage ${0} [options]"
    echo
    echo " General options:"
    echo "    -A, --application <application>    Set an application name for the disk"
    echo "                                       Default: '${iso_application}'"
    echo "    -c, --comptype <comp_type>         Set SquashFS compression type (gzip, lzma, lzo, xz, zstd)"
    echo "                                       Default: ${comp_type}"
    echo "    -D, --installdir <install_dir>     Set an install_dir (directory inside iso)"
    echo "                                       Default: ${install_dir}"
    echo "    -h, --help                         This help message"
    echo "    -L, --label <iso_label>            Set an iso label (disk label)"
    echo "                                       Default: ${iso_label}"
    echo "    -l, --language <language>          Change the default language, select one from:"
    echo "                                       cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua"
    echo "    -N, --name <iso_name>              Set an iso filename (prefix)"
    echo "                                       Default: ${iso_name}"
    echo "    -o, --outdir <out_dir>             Set the output directory"
    echo "                                       Default: ${out_dir}"
    echo "    -P, --publisher <publisher>        Set a publisher for the disk"
    echo "                                       Default: '${iso_publisher}'"
    echo "    -p, --profile <profile>            Set profile for building iso"
    echo "                                       Default: ${profile}"
    echo "                                       available profiles: cinnamon,console,"
    echo "                                       deepin,gnome,i3,kde,lxqt,mate,xfce"
    echo "    --testing <package1,package2,...>  Comma separated list of additional packages from testing"
    echo "                                       and community-testing repositories" 
    echo "    -V, --version <iso_version>        Set an iso version (in filename)"
    echo "                                       Default: ${iso_version}"
    echo "    -v, --verbose                      Enable verbose output"
    echo "    -w, --workdir <work_dir>           Set the working directory"
    echo "                                       Default: ${work_dir}"
    exit "${1}"
}

# set profile variables
_profile () {
    case "${profile}" in
        'cinnamon')
            iso_name=aui-cinnamon
            iso_label=AUIC
            desktop=Cinnamon
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=cinnamon ;;
        'console')
            iso_name=aui-console
            iso_label=AUIO
            desktop=Console
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=console ;;
        'deepin')
            iso_name=aui-deepin
            iso_label=AUID
            desktop=Deepin
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=deepin ;;
        'gnome')
            iso_name=aui-gnome
            iso_label=AUIG
            desktop=Gnome
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=gnome;;
        'i3')
            iso_name=aui-i3
            iso_label=AUI3
            desktop=i3
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=i3 ;;
        'kde')
            iso_name=aui-kde
            iso_label=AUIK
            desktop=Kde
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=kde ;;
        'lxqt')
            iso_name=aui-lxqt
            iso_label=AUIL
            desktop=LXQt
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=lxqt ;;
        'mate')
            iso_name=aui-mate
            iso_label=AUIM
            desktop=Mate
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=mate ;;
        'xfce')
            iso_name=aui-xfce
            iso_label=AUIX
            desktop=Xfce
            iso_application="Archuseriso ${desktop} Live/Rescue medium"
            profile=xfce ;;
        *)
            echo "The profile ${profile} does not exist!"
            _usage 1 ;;
    esac
}

# airootfs extra cleanup
_cleanup_airootfs() {
    local _cleanlist=(  "${work_dir}/x86_64/airootfs/root/.cache/"
                        "${work_dir}/x86_64/airootfs/root/.gnupg/"
                        "${work_dir}/x86_64/airootfs/var/cache/fontconfig/"
                        "${work_dir}/x86_64/airootfs/root/customize_airootfs_lang.sh"
                        "${work_dir}/x86_64/airootfs/var/lib/systemd/catalog/database"
                        "${work_dir}/x86_64/airootfs/var/cache/ldconfig/aux-cache"
                     )

    [[ -e "${work_dir}/x86_64/airootfs/root/customize_airootfs.sh" ]] && _cleanlist+=("${work_dir}/x86_64/airootfs/root/customize_airootfs.sh")
    [[ -e "${work_dir}/x86_64/airootfs/root/customize_airootfs-${profile}.sh" ]] && _cleanlist+=("${work_dir}/x86_64/airootfs/root/customize_airootfs-${profile}.sh")

    for file_or_dir in "${_cleanlist[@]}"; do
      [[ -e "${file_or_dir}" ]] && rm -r "${file_or_dir}"
    done
}

# Helper function to run make_*() only one time per architecture.
run_once() {
    if [[ ! -e "${work_dir}/build.${1}" ]]; then
        "$1"
        touch "${work_dir}/build.${1}"
    fi
}

# Setup custom pacman.conf with current cache directories.
make_pacman_conf() {
    local _cache_dirs
    _cache_dirs=("$(pacman -v 2>&1 | grep '^Cache Dirs:' | sed 's/Cache Dirs:\s*//g')")
    sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n "${_cache_dirs[@]}")|g" \
        "${script_path}/pacman.conf" > "${work_dir}/pacman.conf"
    sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n "${_cache_dirs[@]}")|g" \
        "${script_path}/pacman-testing.conf" > "${work_dir}/pacman-testing.conf"
}

# Prepare working directory and copy custom airootfs files (airootfs)
make_custom_airootfs() {
    local _airootfs="${work_dir}/x86_64/airootfs"
    mkdir -p -- "${_airootfs}"

    if [[ -d "${script_path}/airootfs" ]]; then
        cp -afT --no-preserve=ownership -- "${script_path}/airootfs/." "${_airootfs}"
        if [[ -d "${profile_path}/airootfs" ]]; then
            cp -afT --no-preserve=ownership -- "${profile_path}/airootfs/." "${_airootfs}"
        fi
        # airootfs localization
        if [[ -n "${lang}" ]]; then
            cp -af --no-preserve=ownership -- "${script_path}/lang/${lang}/airootfs/." "${_airootfs}"
            if [[ -d "${profile_path}/lang/${lang}/airootfs" ]]; then
                cp -af --no-preserve=ownership -- "${profile_path}/lang/${lang}/airootfs/." "${_airootfs}"
            fi
        fi

        [[ -e "${_airootfs}/etc/shadow" ]] && chmod -f 0400 -- "${_airootfs}/etc/shadow"
        [[ -e "${_airootfs}/etc/gshadow" ]] && chmod -f 0400 -- "${_airootfs}/etc/gshadow"

    fi

    # Set archiso cow_spacesize to 50% ram size
    sed -i 's|\(cow_spacesize=\)"256M"|\1"$(( $(awk \x27/MemTotal:/ { print $2 }\x27 /proc/meminfo) / 2 / 1024 ))M"|' \
        "${work_dir}/x86_64/airootfs/etc/initcpio/hooks/archiso"
}

# Packages (airootfs)
make_packages() {
    local _lang=
    if [[ -n "${lang}" ]]; then
        _lang=$(grep -Ehv '^#|^$' "${profile_path}"/lang/"${lang}"/packages{-extra,-${profile}}.x86_64 | sed ':a;N;$!ba;s/\n/ /g')
    fi
    if [ -n "${verbose}" ]; then
        mkaui \
            -v -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" \
            -p "$(grep -Ehv '^#|^$' \
               "${script_path}"/packages.x86_64 \
               "${profile_path}"/packages-extra.x86_64 \
               "${profile_path}"/packages-${profile}.x86_64 | \
               sed ':a;N;$!ba;s/\n/ /g') \
               ${_lang} \
               ${AUI_ADDITIONALPKGS:-}" \
            install
    else
        mkaui \
            -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" \
            -p "$(grep -Ehv '^#|^$' \
               "${script_path}"/packages.x86_64 \
               "${profile_path}"/packages-extra.x86_64 \
               "${profile_path}"/packages-${profile}.x86_64 | \
               sed ':a;N;$!ba;s/\n/ /g') \
               ${_lang} \
               ${AUI_ADDITIONALPKGS:-}" \
            install
    fi
}

# Packages in testing (airootfs)
make_packages_testing () {
    local _testingpackages=""
    if [[ -n "${testingpackages:-}" ]]; then
        unshare --fork --pid pacman --config "${script_path}/pacman-testing.conf" --root "${work_dir}/x86_64/airootfs" -Sy > /dev/null 2>&1
        for _package in ${testingpackages}; do
            if [[ "${_package}" = 'linux' ]]; then
                if [[ "${AUI_ADDITIONALPKGS:-}" =~ 'nvidia' ]]; then
                    _testingpackages+="nvidia "
                    if [[ "${AUI_ADDITIONALPKGS:-}" =~ 'bbswitch' ]]; then
                        _testingpackages+="bbswitch"
                    fi
                fi
            break
            fi
        done
        if [ -n "${verbose}" ]; then
            mkaui -v -w "${work_dir}/x86_64" -C "${work_dir}/pacman-testing.conf" -D "${install_dir}" -p "${testingpackages} ${_testingpackages}" install
        else
            mkaui -w "${work_dir}/x86_64" -C "${work_dir}/pacman-testing.conf" -D "${install_dir}" -p "${testingpackages} ${_testingpackages}" install
        fi
    fi
}

# airootfs install user provided packages
make_packages_local() {
    local _pkglocal
    if [[ -n "${AUI_USERPKGDIR:-}" && -d "${AUI_USERPKGDIR:-}" ]]; then
        _pkglocal+=($(find "${AUI_USERPKGDIR}" -maxdepth 1 \( -name "*.pkg.tar.xz" -o -name "*.pkg.tar.zst" \) ))
    fi

    if [[ ${_pkglocal[@]} ]]; then
        if [ -n "${verbose}" ]; then
            mkaui -v -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -p "$(sed ':a;N;$!ba;s/\n/ /g' <<< "${_pkglocal[@]}")" upgrade
        else
            mkaui -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -p "$(sed ':a;N;$!ba;s/\n/ /g' <<< "${_pkglocal[@]}")" upgrade
        fi
    fi

    iso_version="$(pacman --sysroot "${work_dir}/x86_64/airootfs" -Q linux | cut -d' ' -f2 | sed s'/\./_/g; s/_arch.*//; s/^/linux_/')${AUI_ISONAMEOPTION:+-$AUI_ISONAMEOPTION}${lang:+-$lang}-$(date +%m%d)"
}

# Customize installation (airootfs)
make_customize_airootfs() {
    # Set up user home directories and permissions
    for _passwdfile in "${script_path}/airootfs/etc/passwd" "${profile_path}/airootfs/etc/passwd"; do
        if [[ -e "${_passwdfile}" ]]; then
            while IFS=':' read -a passwd -r; do
                [[ "${passwd[5]}" == '/' ]] && continue
                if [[ -d "${work_dir}/x86_64/airootfs${passwd[5]}" ]]; then
                    cp -RdT --preserve=mode,timestamps,links -- "${work_dir}/x86_64/airootfs/etc/skel" "${work_dir}/x86_64/airootfs${passwd[5]}"
                    chown -hR -- "${passwd[2]}:${passwd[3]}" "${work_dir}/x86_64/airootfs${passwd[5]}"
                    chmod -f 0750 -- "${work_dir}/x86_64/airootfs${passwd[5]}"
                else
                    install -d -m 0750 -o "${passwd[2]}" -g "${passwd[3]}" -- "${work_dir}/x86_64/airootfs${passwd[5]}"
                fi
            done < "${_passwdfile}"
        fi
    done

    if [[ -e "${work_dir}/x86_64/airootfs/root/customize_airootfs-${profile}.sh" ]]; then
        if [ -n "${verbose}" ]; then
            mkaui -v -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -r "/root/customize_airootfs-${profile}.sh" run
        else
            mkaui -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -r "/root/customize_airootfs-${profile}.sh" run
        fi
    fi

    # airootfs extra cleanup
    _cleanup_airootfs
}

# rebuild initramfs (airootfs)
make_setup_mkinitcpio() {
    if [[ "${gpg_key}" ]]; then
      gpg --export "${gpg_key}" > "${work_dir}/gpgkey"
      exec 17<>"${work_dir}/gpgkey"
    fi
    # ignore mkinitcpio return status error
    set +e
    if [ -n "${verbose}" ]; then
        ARCHISO_GNUPG_FD="${gpg_key:+17}" mkaui -v -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -r 'mkinitcpio -P' run
    else
        ARCHISO_GNUPG_FD="${gpg_key:+17}" mkaui -w "${work_dir}/x86_64" -C "${work_dir}/pacman.conf" -D "${install_dir}" -r 'mkinitcpio -P' run
    fi
    set -e
    if [[ "${gpg_key}" ]]; then
      exec 17<&-
    fi
}

# Prepare kernel/initramfs ${install_dir}/boot/
make_boot() {
    mkdir -p "${work_dir}/iso/${install_dir}/boot/x86_64"
    cp "${work_dir}/x86_64/airootfs/boot/initramfs-linux.img" "${work_dir}/iso/${install_dir}/boot/x86_64/"
    cp "${work_dir}/x86_64/airootfs/boot/vmlinuz-linux" "${work_dir}/iso/${install_dir}/boot/x86_64/"
}

# Add other aditional/extra files to ${install_dir}/boot/
make_boot_extra() {
    if [[ -e "${work_dir}/x86_64/airootfs/boot/memtest86+/memtest.bin" ]]; then
        # rename for PXE: https://wiki.archlinux.org/index.php/Syslinux#Using_memtest
        cp "${work_dir}/x86_64/airootfs/boot/memtest86+/memtest.bin" "${work_dir}/iso/${install_dir}/boot/memtest"
        mkdir -p "${work_dir}/iso/${install_dir}/boot/licenses/memtest86+/"
        cp "${work_dir}/x86_64/airootfs/usr/share/licenses/common/GPL2/license.txt" \
            "${work_dir}/iso/${install_dir}/boot/licenses/memtest86+/"
    fi
    if [[ -e "${work_dir}/x86_64/airootfs/boot/intel-ucode.img" ]]; then
        cp "${work_dir}/x86_64/airootfs/boot/intel-ucode.img" "${work_dir}/iso/${install_dir}/boot/"
        mkdir -p "${work_dir}/iso/${install_dir}/boot/licenses/intel-ucode/"
        cp "${work_dir}/x86_64/airootfs/usr/share/licenses/intel-ucode/"* \
            "${work_dir}/iso/${install_dir}/boot/licenses/intel-ucode/"
    fi
    if [[ -e "${work_dir}/x86_64/airootfs/boot/amd-ucode.img" ]]; then
        cp "${work_dir}/x86_64/airootfs/boot/amd-ucode.img" "${work_dir}/iso/${install_dir}/boot/"
        mkdir -p "${work_dir}/iso/${install_dir}/boot/licenses/amd-ucode/"
        cp "${work_dir}/x86_64/airootfs/usr/share/licenses/amd-ucode/"* \
            "${work_dir}/iso/${install_dir}/boot/licenses/amd-ucode/"
    fi
}

# Prepare /${install_dir}/boot/syslinux
make_syslinux() {
    _uname_r=$(file -b "${work_dir}/x86_64/airootfs/boot/vmlinuz-linux"| awk 'f{print;f=0} /version/{f=1}' RS=' ')
    mkdir -p "${work_dir}/iso/${install_dir}/boot/syslinux"
    for _cfg in "${script_path}/syslinux/"*.cfg; do
        sed "s|%DESKTOP%|${desktop}|g;
             s|%ARCHISO_LABEL%|${iso_label}|g;
             s|%INSTALL_DIR%|${install_dir}|g" "${_cfg}" > "${work_dir}/iso/${install_dir}/boot/syslinux/${_cfg##*/}"
    done
    cp "${script_path}/syslinux/splash.png" "${work_dir}/iso/${install_dir}/boot/syslinux/"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/"*.c32 "${work_dir}/iso/${install_dir}/boot/syslinux/"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/lpxelinux.0" "${work_dir}/iso/${install_dir}/boot/syslinux/"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/memdisk" "${work_dir}/iso/${install_dir}/boot/syslinux/"
    mkdir -p "${work_dir}/iso/${install_dir}/boot/syslinux/hdt"
    gzip -c -9 "${work_dir}/x86_64/airootfs/usr/share/hwdata/pci.ids" > \
        "${work_dir}/iso/${install_dir}/boot/syslinux/hdt/pciids.gz"
    gzip -c -9 "${work_dir}/x86_64/airootfs/usr/lib/modules/${_uname_r}/modules.alias" > \
        "${work_dir}/iso/${install_dir}/boot/syslinux/hdt/modalias.gz"
}

# Prepare /isolinux
make_isolinux() {
    mkdir -p "${work_dir}/iso/isolinux"
    sed "s|%INSTALL_DIR%|${install_dir}|g" "${script_path}/isolinux/isolinux.cfg" > "${work_dir}/iso/isolinux/isolinux.cfg"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/isolinux.bin" "${work_dir}/iso/isolinux/"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/isohdpfx.bin" "${work_dir}/iso/isolinux/"
    cp "${work_dir}/x86_64/airootfs/usr/lib/syslinux/bios/ldlinux.c32" "${work_dir}/iso/isolinux/"
}

# Prepare /EFI
make_efi() {
    mkdir -p "${work_dir}/iso/EFI/boot" "${work_dir}/iso/EFI/live"
    cp "${work_dir}/x86_64/airootfs/usr/share/refind/refind_x64.efi" "${work_dir}/iso/EFI/boot/bootx64.efi"
    cp -a "${work_dir}"/x86_64/airootfs/usr/share/refind/{drivers_x64,icons}/ "${work_dir}/iso/EFI/boot/"

    cp "${work_dir}/x86_64/airootfs/usr/lib/systemd/boot/efi/systemd-bootx64.efi" "${work_dir}/iso/EFI/live/livedisk.efi"
    cp "${work_dir}/x86_64/airootfs/usr/share/refind/icons/os_arch.png" "${work_dir}/iso/EFI/live/livedisk.png"

    cp "${script_path}/efiboot/boot/refind-usb.conf" "${work_dir}/iso/EFI/boot/refind.conf"

    mkdir -p "${work_dir}/iso/loader/entries"
    cp "${script_path}/efiboot/loader/loader.conf" "${work_dir}/iso/loader/"
    cp "${script_path}/efiboot/loader/entries/archiso-x86_64-linux.conf" "${work_dir}/iso/loader/entries/archiso-x86_64.conf"
    cp "${script_path}/efiboot/loader/entries/archiso_2_console-x86_64-linux.conf" "${work_dir}/iso/loader/entries/archiso_2_console-x86_64.conf"
    cp "${script_path}/efiboot/loader/entries/archiso_3_ram-x86_64-linux.conf" "${work_dir}/iso/loader/entries/archiso_3_ram-x86_64.conf"

    sed -i "s|%DESKTOP%|${desktop}|g;
            s|%ARCHISO_LABEL%|${iso_label}|g;
            s|%INSTALL_DIR%|${install_dir}|g" \
            "${work_dir}"/iso/loader/entries/archiso{,_2_console,_3_ram}-x86_64.conf

    # EFI Shell 2.0 for UEFI 2.3+
    # shellx64.efi is picked up automatically when on /
    cp "${work_dir}/x86_64/airootfs/usr/share/edk2-shell/x64/Shell_Full.efi" "${work_dir}/iso/shellx64.efi"
}

# Prepare efiboot.img::/EFI for "El Torito" EFI boot mode
make_efiboot() {
    mkdir -p "${work_dir}/iso/EFI/archiso"
    truncate -s 96M "${work_dir}/iso/EFI/archiso/efiboot.img"
    mkfs.fat -n LIVEMEDIUM "${work_dir}/iso/EFI/archiso/efiboot.img" > /dev/null

    mkdir -p "${work_dir}/efiboot"
    mount "${work_dir}/iso/EFI/archiso/efiboot.img" "${work_dir}/efiboot"

    mkdir -p "${work_dir}/efiboot/EFI/archiso"
    cp "${work_dir}/iso/${install_dir}/boot/x86_64/vmlinuz-linux" "${work_dir}/efiboot/EFI/archiso/"
    cp "${work_dir}/iso/${install_dir}/boot/x86_64/initramfs-linux.img" "${work_dir}/efiboot/EFI/archiso/"

    cp "${work_dir}/iso/${install_dir}/boot/intel-ucode.img" "${work_dir}/efiboot/EFI/archiso/"
    cp "${work_dir}/iso/${install_dir}/boot/amd-ucode.img" "${work_dir}/efiboot/EFI/archiso/"

    mkdir -p "${work_dir}/efiboot/EFI/boot" "${work_dir}/efiboot/EFI/live"
    cp "${work_dir}/x86_64/airootfs/usr/share/refind/refind_x64.efi" "${work_dir}/efiboot/EFI/boot/bootx64.efi"
    cp -a "${work_dir}"/x86_64/airootfs/usr/share/refind/{drivers_x64,icons}/ "${work_dir}/efiboot/EFI/boot/"

    cp "${work_dir}/x86_64/airootfs/usr/lib/systemd/boot/efi/systemd-bootx64.efi" "${work_dir}/efiboot/EFI/live/livedvd.efi"
    cp "${work_dir}/x86_64/airootfs/usr/share/refind/icons/os_arch.png" "${work_dir}/efiboot/EFI/live/livedvd.png"

    cp "${script_path}/efiboot/boot/refind-dvd.conf" "${work_dir}/efiboot/EFI/boot/refind.conf"

    mkdir -p "${work_dir}/efiboot/loader/entries"
    cp "${script_path}/efiboot/loader/loader.conf" "${work_dir}/efiboot/loader/"
    cp "${script_path}/efiboot/loader/entries/archiso-x86_64-linux.conf" "${work_dir}/efiboot/loader/entries/archiso-x86_64.conf"
    cp "${script_path}/efiboot/loader/entries/archiso_2_console-x86_64-linux.conf" "${work_dir}/efiboot/loader/entries/archiso_2_console-x86_64.conf"
    cp "${script_path}/efiboot/loader/entries/archiso_3_ram-x86_64-linux.conf" "${work_dir}/efiboot/loader/entries/archiso_3_ram-x86_64.conf"

    sed -i "s|%DESKTOP%|${desktop}|g;
            s|%ARCHISO_LABEL%|${iso_label}|g;
            s|%INSTALL_DIR%|${install_dir}|g" \
            "${work_dir}"/efiboot/loader/entries/archiso{,_2_console,_3_ram}-x86_64.conf

    # shellx64.efi is picked up automatically when on /
    cp "${work_dir}/iso/shellx64.efi" "${work_dir}/efiboot/"

    umount -d "${work_dir}/efiboot"
}

# Archuseriso data
make_aui() {
    cp -a --no-preserve=ownership "${profile_path}/aui/" "${work_dir}/iso"
    mv "${work_dir}"/iso/aui/persistent{,_"${iso_label}"}

    ### esp
    # syslinux
    mkdir -p "${work_dir}/iso/aui/esp/${install_dir}/boot/"
    ln -s "../../../../${install_dir}/boot/syslinux" "${work_dir}/iso/aui/esp/${install_dir}/boot/syslinux"
    mkdir -p "${work_dir}/iso/aui/esp/syslinux/"
    ln -s "../../../isolinux/isolinux.cfg" "${work_dir}/iso/aui/esp/syslinux/syslinux.cfg"

    # live kernel & initramfs
    mkdir -p "${work_dir}/iso/aui/esp/${install_dir}/boot/x86_64/"
    mkdir -p "${work_dir}/iso/aui/esp/${install_dir}/boot/licenses/"
    for _ucode_image in {intel-uc.img,intel-ucode.img,amd-uc.img,amd-ucode.img,early_ucode.cpio,microcode.cpio}; do
            if [[ -e "../../../../${install_dir}/boot/${_ucode_image}" ]]; then
                ln -s "../../../../${install_dir}/boot/${_ucode_image}" "${work_dir}/iso/aui/esp/"
            fi
    done
    for _license in "../../../../../${install_dir}/boot/licenses/"*; do
        ln -s "../../../../../${install_dir}/boot/licenses/${_license}/" \
              "${work_dir}/iso/aui/esp/${install_dir}/boot/licenses/${_license}"
    done
    ln -s "../../../../${install_dir}/boot/memtest" "${work_dir}/iso/aui/esp/${install_dir}/boot/"
    ln -s "../../../../../${install_dir}/boot/licenses/memtest86+/" \
          "${work_dir}/iso/aui/esp/${install_dir}/boot/licenses/memtest86+"
    for _kernel in "../../../../../${install_dir}/boot/x86_64/vmlinuz-"* \
                   "../../../../../${install_dir}/boot/x86_64/initramfs-"*".img"; do
            ln -s "../../../../../${install_dir}/boot/x86_64/${_kernel}" \
                  "${work_dir}/iso/aui/esp/${install_dir}/boot/x86_64/"
    done

    # persistent kernel & initramfs
    mkdir -p "${work_dir}/iso/aui/esp/EFI/"
    for _ucode_image in {intel-uc.img,intel-ucode.img,amd-uc.img,amd-ucode.img,early_ucode.cpio,microcode.cpio}; do
            if [[ -e "../../${install_dir}/boot/${_ucode_image}" ]]; then
                ln -s "../../${install_dir}/boot/${_ucode_image}" "${work_dir}/iso/aui/esp/"
            fi
    done
    for _kernel in "../../${install_dir}/boot/x86_64/vmlinuz-"* \
                   "../../${install_dir}/boot/x86_64/initramfs-"*".img"; do
        ln -s "../../${install_dir}/boot/x86_64/${_kernel}" "${work_dir}/iso/aui/esp/"
    done
    ln -s ../../loader "${work_dir}/iso/aui/esp/loader"
    ln -s ../../../EFI/boot "${work_dir}/iso/aui/esp/EFI/BOOT"
    ln -s ../../../EFI/live "${work_dir}/iso/aui/esp/EFI/live"
    ln -s ../../shellx64.efi "${work_dir}/iso/aui/esp/shellx64.efi"

    # duplicate /boot contents to persistent boot partition
    # mounting persistent boot partition would hide original /boot contents
    mkdir -p "${work_dir}/iso/aui/persistent_${iso_label}/x86_64/upperdir/boot/"
    cp -a "${work_dir}/x86_64/airootfs/boot/memtest86+/" \
          "${work_dir}/iso/aui/persistent_${iso_label}/x86_64/upperdir/boot/"
    cp -a "${work_dir}/x86_64/airootfs/boot/syslinux/" \
          "${work_dir}/iso/aui/persistent_${iso_label}/x86_64/upperdir/boot/"

    if [[ -f "${work_dir}/iso/aui/AUIDATA" ]]; then
        eval $(grep cow_label "${work_dir}/iso/aui/AUIDATA")
        sed -i "s|%COMP_TYPE%|${comp_type}|;
                s|%DESKTOP%|${desktop}|;
                s|%INSTALL_DIR%|${install_dir}|;
                s|%ARCHISO_LABEL%|${iso_label}|;
                s|%ISO_NAME%|${iso_name}|;
                s|%ISO_VERSION%|${iso_version}|;
                s|%LANG%|${lang}|" \
                "${work_dir}/iso/aui/AUIDATA"
    fi
    if [[ -f "${work_dir}/iso/aui/loader/entries/0aui_persistence-x86_64.conf" ]]; then
        sed -i "s|%ARCHISO_LABEL%|${iso_label}|;
                s|%INSTALL_DIR%|${install_dir}|;
                s|%COW_LABEL%|${cow_label}|;
                s|%DESKTOP%|${desktop}|" \
                "${work_dir}/iso/aui/loader/entries/0aui_persistence-x86_64.conf"
    fi
    if [[ -f "${work_dir}/iso/aui/archiso_sys-linux.cfg" ]]; then
        sed -i "s|%ARCHISO_LABEL%|${iso_label}|;
                s|%INSTALL_DIR%|${install_dir}|;
                s|%COW_LABEL%|${cow_label}|;
                s|%DESKTOP%|${desktop}|" \
                "${work_dir}/iso/aui/archiso_sys-linux.cfg"
    fi
    if [[ -n "${AUI_EMBEDDIR:-}" && -d "${AUI_EMBEDDIR:-}" ]]; then
        cp -aT --no-preserve=ownership "${AUI_EMBEDDIR}" "${work_dir}/iso/data"
    fi
}

# Build airootfs filesystem image
make_prepare() {
    cp -a -l -f "${work_dir}/x86_64/airootfs" "${work_dir}"
    if [ -n "${verbose}" ]; then
        mkaui -v -w "${work_dir}" -D "${install_dir}" pkglist
        mkaui -v -w "${work_dir}" -D "${install_dir}" -c "${comp_type}" ${gpg_key:+-g ${gpg_key}} prepare
    else
        mkaui -w "${work_dir}" -D "${install_dir}" pkglist
        mkaui -w "${work_dir}" -D "${install_dir}" -c "${comp_type}" ${gpg_key:+-g ${gpg_key}} prepare
    fi
    rm -rf "${work_dir}/airootfs"
    # rm -rf "${work_dir}/x86_64/airootfs" (if low space, this helps)
}

# Build ISO
make_iso() {
    if [ -n "${verbose}" ]; then
        mkaui -v -w "${work_dir}" -D "${install_dir}" -L "${iso_label}" -P "${iso_publisher}" -A "${iso_application}" -o "${out_dir}" iso "${iso_name}-${iso_version}-x64.iso"
    else
         mkaui -w "${work_dir}" -D "${install_dir}" -L "${iso_label}" -P "${iso_publisher}" -A "${iso_application}" -o "${out_dir}" iso "${iso_name}-${iso_version}-x64.iso"
    fi
    cd "${out_dir}"
    sha512sum -b "${iso_name}-${iso_version}-x64.iso" > "${iso_name}-${iso_version}-x64.iso.sha512"
    if [[ "${gpg_key}" ]]; then
        gpg --detach-sign --default-key "${gpg_key}" "${iso_name}-${iso_version}-x64.iso"
    fi
    cd ~-
}

OPTS=$(getopt -o 'A:c:D:g:hL:l:N:o:P:p:V:vw:' -l 'name,version:,label:,publisher:,application:' \
       -l 'installdir:,workdir:,outdir:,gpgkey:,verbose,language:,comptype:' \
       -l 'profile:,testing:,help' -n 'build.sh' -- "$@")
[[ $? -eq 0 ]] || _usage 1
eval set -- "${OPTS}"
unset OPTS
[[ $# -eq 0 ]] && _usage 0

while true; do
    case "${1}" in
        '-A'|'--application')
            iso_application="${2}"
            shift 2 ;;
        '-c'|'--comptype')
            comp_type="${2}"
            shift 2 ;;
        '-D'|'--installdir')
            install_dir="${2}"
            shift 2 ;;
        '-g'|'--gpgkey')
            gpg_key="{2}"
            shift 2 ;;
        '-h'|'--help')
            _usage 0 ;;
        '-L'|'--label')
            iso_label="${2}"
            shift 2 ;;
        '-l'|'--language')
            case "${2}" in
                'cz'|'cs_CZ') lang="cs_CZ";;
                'de'|'de_DE') lang="de_DE";;
                'es'|'es_ES') lang="es_ES";;
                'fr'|'fr_FR') lang="fr_FR";;
                'gr'|'el_GR') lang="el_GR";;
                'hu'|'hu_HU') lang="hu_HU";;
                'it'|'it_IT') lang="it_IT";;
                'nl'|'nl_NL') lang="nl_NL";;
                'pl'|'pl_PL') lang="pl_PL";;
                'pt'|'pt_PT') lang="pt_PT";;
                'ro'|'ro_RO') lang="ro_RO";;
                'rs'|'sr_RS@latin') lang="sr_RS@latin";;
                'ru'|'ru_RU') lang="ru_RU";;
                'tr'|'tr_TR') lang="tr_TR";;
                'ua'|'uk_UA') lang="uk_UA";;
                *) _usage 1;;
            esac
            shift 2 ;;
        '-N'|'--name')
            iso_name="${2}"
            shift 2 ;;
        '-o'|'--outdir')
            out_dir="${2}"
            shift 2 ;;
        '-P'|'--publisher')
            iso_publisher="${2}"
            shift 2 ;;
        '-p'|'--profile')
            profile="${2}"
            _profile
            shift 2 ;;
        '--testing')
            testingpackages="$(tr ',' ' ' <<< ${2})"
            shift 2 ;;
        '-V'|'--version')
            iso_version="${2}"
            shift 2 ;;
        '-v'|'--verbose')
            verbose="-v"
            shift ;;
        '-w'|'--workdir')
            work_dir="${2}"
            shift 2 ;;
        '--')
            shift
            break ;;
    esac
done

if [[ ${EUID} -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

script_path="$( cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )"
profile_path="$( cd -P "$( dirname "$(readlink -f "$0")" )" && pwd )/profiles/${profile}"

if [[ "${profile}" = 'console' ]]; then
    lang=""
fi

mkdir -p "${work_dir}"

run_once make_pacman_conf
run_once make_custom_airootfs
run_once make_packages
run_once make_packages_testing
run_once make_packages_local
run_once make_customize_airootfs
run_once make_setup_mkinitcpio
run_once make_boot
run_once make_boot_extra
run_once make_syslinux
run_once make_isolinux
run_once make_efi
run_once make_efiboot
if [[ ! "${profile}" = 'console' ]]; then
  run_once make_aui
fi
run_once make_prepare
run_once make_iso

# vim: set expandtab:
