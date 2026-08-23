# Archuseriso

Bash toolkit for building **Arch Linux live ISO/IMG** media and **USB** layouts from [archiso](https://wiki.archlinux.org/title/Archiso)-style profiles, plus utilities for persistence, full install-to-USB, hybrid media, and ZFS package builds.

| | |
|---|---|
| AUR | [archuseriso](https://aur.archlinux.org/packages/archuseriso) |
| ISO | <http://dl.gnutux.fr/archuseriso/iso> |
| IMG | <http://dl.gnutux.fr/archuseriso/img> |
| iPXE | <http://dl.gnutux.fr/archuseriso/ipxe> |
| ZFS pkgs | <http://dl.gnutux.fr/archuseriso/zfsonlinux> |
| License | GPL-3.0-or-later |

Requires root for image/USB operations. Targets **x86_64**. Host needs a working Arch (or archuseriso-in-container) toolset: `pacstrap`, `mksquashfs`/`mkfs.erofs`, `xorriso`, firmware packages as for archiso.

## Scope

- Multi-desktop **profiles** (package lists + `airootfs` overlays + bootloader fragments)
- Live **ISO** and sparse **IMG** (`aui-mkiso`)
- USB: **persistent live** (`aui-mkusb`), **install** (`aui-mkinstall`), **hybrid** (`aui-mkhybrid`)
- Optional **encryption**, **Ext4 / Btrfs / F2FS** (and ZFS where scripted)
- **ZFS** live support via in-tree package build (`aui-buildzfs` / `--zfs-support`)
- QEMU helper: `aui-run` (BIOS / UEFI)

Boot modes are profile-defined (`profiledef.sh` → `bootmodes`). Typical combo: **BIOS `syslinux`**, **UEFI `systemd-boot`** (default), optional `uefi.grub` / `uefi.refind` (rEFInd as chainload entry, not sole primary on all firmware).

## Profiles

| Profile | Session |
|---------|---------|
| `console` | Text-only rescue |
| `cinnamon` | Cinnamon |
| `gnome` | GNOME |
| `hyprland` | Hyprland (Wayland compositor) |
| `i3` | i3 (X11) |
| `kde` | KDE Plasma |
| `lxqt` | LXQt |
| `mate` | MATE |
| `sway` | Sway |
| `xfce` | Xfce |

Removed from the tree: **Cutefish**, **Deepin**.

Profiles live under `profiles/<name>/` (installed as `$PREFIX/share/archuseriso/profiles/`). Important files:

| Path | Role |
|------|------|
| `profiledef.sh` | ISO metadata, `bootmodes`, permissions |
| `packages.x86_64` | pacstrap set |
| `airootfs/` | Rootfs overlay |
| `lang/<locale>/` | Extra packages / locale bits |
| `syslinux/`, `efiboot/`, `drive/` | Bootloader + USB helper trees |

### Hyprland

Wayland tiling compositor, not a full DE. Config is **Lua** (`hyprland.lua`, Hyprland ≥ 0.55). Live session: autologin as `live` on tty1, desktop started with **`start-hyprland`** (console remains usable after exit). Stack includes kitty, waybar, fuzzel, mako, thunar, hyprpaper/hyprlock/hypridle/hyprpolkitagent, portals. Super+F1 → shortcut help (`aui-hypr-help`).

Sway follows a similar manual-session live pattern.

## Install

**AUR:** [archuseriso](https://aur.archlinux.org/packages/archuseriso)

**From git:**

```bash
sudo make install          # scripts + profiles + docs; PREFIX=/usr/local by default
sudo make install-scripts  # binaries only
```

Published ISOs at dl.gnutux.fr already ship the tools in the live environment.

## Tools

| Tool | Role |
|------|------|
| `aui-mkiso` | Build ISO / IMG / bootstrap from a profile |
| `aui-mkusb` | Partition USB: live RO + ESP + persistence |
| `aui-mkinstall` | Full system install onto USB from ISO |
| `aui-mkhybrid` | Hybrid layout (live + installed root) |
| `aui-buildzfs` | Build OpenZFS packages for the running kernel |
| `aui-run` | QEMU boot of ISO or block device |

Shared helpers: `aui-lib.sh`.

---

## aui-mkiso

```text
aui-mkiso [options] <profile_dir|profile_name>
```

Profile name resolves under the installed profiles path (e.g. `xfce` → `…/profiles/xfce`).

Notable options (non-exhaustive; see `aui-mkiso -h`):

| Option | Effect |
|--------|--------|
| `-m, --build-modes` | `iso` (default), `img`, `bootstrap` |
| `-l, --language` | `cz de es fr gr hu it nl pl pt ro rs ru tr ua` |
| `-p, --add-pkg` | Extra packages (comma-separated) |
| `--pkg-dir` | Local package directory |
| `--lts` | linux-lts (+ nvidia-open-lts when applicable) |
| `--graphics=` | `nvidia` / `optimus-nvidia` / `optimus-prime` |
| `--zfs-support` | Build/include ZFS packages |
| `--embed-dir` | Embed tree on the medium |
| `-o` | Output directory |

Examples:

```bash
sudo aui-mkiso xfce
sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

sudo aui-mkiso --language=de kde
sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop --pkg-dir=~/mypackages gnome
sudo aui-mkiso -m img xfce
sudo aui-mkiso hyprland
sudo aui-mkiso --zfs-support xfce
```

Write ISO/IMG with usual block device tools; see [USB installation medium](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities).

---

## aui-mkusb

Persistent live USB from an AUI ISO.

```text
aui-mkusb [options] <iso> <block-device>
```

```bash
sudo aui-mkusb aui-xfce-….iso /dev/sdc
```

Default GPT layout:

| # | FS | Role |
|---|-----|------|
| 1 | Ext4 | Squashfs / live payload |
| 2 | FAT | ESP + bootloaders |
| 3 | Ext4/Btrfs/F2FS | Persistence (optional LUKS) |

Btrfs persistence: subvolumes `rootfs` and `home`. Options cover ESP/COW size, rootfs type, encryption, MBR vs GPT (see `aui-mkusb -h`).

---

## aui-mkinstall

Install the live system onto USB (writable root).

```text
aui-mkinstall [options] <iso> <block-device>
```

```bash
sudo aui-mkinstall aui-xfce-….iso /dev/sdc
```

GPT layout:

| # | FS | Role |
|---|-----|------|
| 1 | FAT | ESP |
| 2 | Ext4/Btrfs/F2FS/ZFS | Root |

Journal is typically volatile to cut USB wear. ZFS root example:

```bash
sudo aui-mkinstall --rootfs=zfs --username=foobar aui-xfce-….iso /dev/sdc
```

(ISO must include ZFS packages.)

---

## aui-mkhybrid

Combines live payload + installed system on one USB (see tool help for layout and options).

---

## IMG images

`aui-mkiso -m img` produces a bootable disk image with a small default COW partition (~128 MiB). After writing to a stick, fix/resize GPT as needed:

```bash
cat aui-….img > /dev/sdc
echo Fix | sudo parted /dev/sdc ---pretend-input-tty print
```

---

## ZFS

```bash
sudo aui-buildzfs                    # zfs-utils + zfs-linux(+headers) for current kernel
sudo aui-mkiso --zfs-support xfce    # or --pkg-dir with prebuilt packages
```

---

## aui-run

QEMU smoke tests (BIOS SeaBIOS / UEFI OVMF). ISO is an AHCI CD with `bootindex=1`. USB sticks and IMG files should be attached as a **raw disk** (`--disk` / `-d`), not USB-host passthrough.

```bash
aui-run -b -i path/to.iso                 # BIOS
aui-run -u -i path/to.iso                 # UEFI (default)
aui-run -b --disk path/to.img
sudo aui-run -u --disk /dev/sdc           # USB as virtio-blk / AHCI
aui-run -n -b -i path/to.iso              # print qemu argv
aui-run -u -i path/to.iso -- -smp 8       # extra qemu-system-x86_64 args
```

`--usb-host /dev/sdc` passthrough remains available (root; SeaBIOS often cannot boot it).

---

## iPXE

Prebuilt loaders at <http://dl.gnutux.fr/archuseriso/ipxe> (`aui-ipxe*.iso|img|efi`) pull a live Xfce-class session from the project server. Wi-Fi under iPXE itself is not available; tether if required.

---

## Known issues

- **rEFInd** as primary can fail on some UEFI firmwares; prefer systemd-boot + rEFInd chainload when both are present.
- **Hyprland + Waybar** `hyprland/workspaces` click-to-switch can break with Hyprland ≥ 0.55 / protocol mismatch ([Waybar#5198](https://github.com/Alexays/Waybar/issues/5198)); keyboard workspace binds remain valid. Workaround: `ext/workspaces` + persistent workspace rules, or a fixed Waybar release when available.

---

## Documentation

This file is the main doc. Profile and archiso conventions apply. Archiso reference: [Arch Wiki — Archiso](https://wiki.archlinux.org/title/Archiso).
