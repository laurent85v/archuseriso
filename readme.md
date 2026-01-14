# Archuseriso

A collection of Bash scripts for creating bootable Arch Linux images and USB drives with desktop environments. Also includes tools to compress an installed Arch Linux system into a bootable disk image.

- [AUR Repository](https://aur.archlinux.org/packages/archuseriso)
- [ISO Images](http://dl.gnutux.fr/archuseriso/iso)
- [IMG Disk Images](http://dl.gnutux.fr/archuseriso/img)
- [iPXE Network Bootloader Images](http://dl.gnutux.fr/archuseriso/ipxe)
- [ZFS Packages](http://dl.gnutux.fr/archuseriso/zfsonlinux)

Based on [Archiso](https://wiki.archlinux.org/title/Archiso).

## Features

- Desktop profiles
- Language configuration
- Data persistence
- Filesystem choices: Ext4, Btrfs, F2FS, ZFS
- Data encryption
- ISO and IMG images
- ZFS support

## Profiles

- Console
- Cinnamon
- Cutefish
- GNOME
- i3
- KDE Plasma
- LXQt
- MATE
- Sway
- Xfce

## Installation

Archuseriso is available on the AUR: [archuseriso](https://aur.archlinux.org/packages/archuseriso/).

Online images at [http://dl.gnutux.fr/archuseriso](http://dl.gnutux.fr/archuseriso) include archuseriso.

## Building ISO and Disk Images

### Synopsis

```
aui-mkiso [options] <profile path>
```

### Examples

Xfce ISO with default options (both commands work):

```
sudo aui-mkiso xfce
sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/
```

KDE Plasma ISO with German language:

```
sudo aui-mkiso --language=de kde
```

GNOME ISO with additional packages and custom package directory:

```
sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop --pkg-dir=~/mypackages gnome
```

Xfce disk image:

```
sudo aui-mkiso -m 'img' xfce
```

See [Writing Disc Images](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities) and [Burning DVDs](https://wiki.archlinux.org/title/Optical_disc_drive#Burning).

## Creating a Bootable USB Drive with Persistence

### Synopsis

```
aui-mkusb [options] <archuseriso iso image> <usb device>
```

### Example

```
sudo aui-mkusb aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc
```

### Disk Partitioning

GPT layout:

| Partition | Filesystem | Content          |
|-----------|------------|------------------|
| #1        | Ext4       | Squashfs image   |
| #2        | EFI FAT    | Boot             |
| #3        | Ext4/Btrfs/F2FS | Persistence |

#### Btrfs Details

Two subvolumes for persistence: `rootfs` and `home`.

## Installing to a USB Drive

### Synopsis

```
aui-mkinstall [options] <archuseriso iso image> <usb device>
```

### Example

```
sudo aui-mkinstall aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc
```

### Disk Partitioning

GPT layout:

| Partition | Filesystem | Content |
|-----------|------------|---------|
| #1        | EFI FAT    | Boot    |
| #2        | Ext4/Btrfs/F2FS | System |

The systemd journal is configured in volatile mode to reduce disk I/O.

## Disk Image

Bootable disk image with persistence.

Write to USB device (e.g., /dev/sdc):

```
cat aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc
```

**Important:** Resize the GPT partition table on the USB drive using `parted`, `fdisk`, or `gparted`.

Using `parted`:

```
echo Fix | sudo parted /dev/sdc ---pretend-input-tty print
```

The persistence partition is 128 MiB by default. Resize as needed.

See [Writing Disk Images](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities).

## iPXE Network Bootloader

Network boot the latest live Xfce desktop from the Archuseriso server.

Download an iPXE image from [http://dl.gnutux.fr/archuseriso/ipxe](http://dl.gnutux.fr/archuseriso/ipxe):

- `aui-ipxe.iso`: CD-ROM for legacy BIOS
- `aui-ipxe.img`: USB for legacy BIOS
- `aui-ipxe-efi.iso`: CD-ROM for x64 UEFI
- `aui-ipxe-efi.img`: USB for x64 UEFI
- `aui-ipxe.efi`: x64 UEFI binary

Boot the media to load the iPXE menu and start the live Xfce desktop.

For wireless on laptops, use USB tethering (iPXE Wi-Fi not supported).

## Adding ZFS Support

Two methods:

1. Use `--zfs-support` to auto-build and add ZFS packages.
2. Use `--pkg-dir <path>` with pre-built ZFS packages.

Example:

```
sudo aui-mkiso --zfs-support xfce
```

### Building ZFS Packages

Build `zfs-utils`, `zfs-linux`, and `zfs-linux-headers` against the current kernel:

```
sudo aui-buildzfs
```

### ZFS Root Filesystem

Install to ZFS root using an ISO with ZFS support:

```
sudo aui-mkinstall --rootfs=zfs --username=foobar aui-xfce-linux_6_0_9-1123-x64.iso /dev/sdc
```

## Using Docker

Download the `Dockerfile` from sources. Build the image:

```
sudo docker build -t archuseriso .
```

Run in container:

```
sudo docker run --privileged --rm -it archuseriso
[root@4dd3aab1018b /]# pacman -Q archuseriso
```

**Limitation:** Building ZFS packages in Docker does not work.

## Compressing an Installed Arch Linux System

Mount the root filesystem (and home if separate) under a mount point.

### Synopsis

```
aui-hd2aui [options] <path to root filesystem>
```

### Example

For system on /dev/sdc2 (root) and /dev/sdc3 (home):

```
sudo mount /dev/sdc2 /mnt/rootfs
sudo mount /dev/sdc3 /mnt/rootfs/home
sudo aui-hd2aui /mnt/rootfs/
```

### Disk Partitioning

GPT layout:

| Partition | Filesystem | Content                      |
|-----------|------------|------------------------------|
| #1        | -          | Stage 2 bootloader (Legacy)  |
| #2        | EFI FAT    | Boot                         |
| #3        | Ext4       | Squashfs image               |
| #4        | Ext4       | Persistence                  |

## Testing

Use `aui-run` to test ISOs or USB drives in QEMU.

### Examples

Test ISO in BIOS legacy mode:

```
aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso
```

Test ISO in UEFI mode:

```
aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso
```

Test USB /dev/sdc in BIOS legacy mode:

```
sudo aui-run -d /dev/sdc
```

Test USB /dev/sdc in UEFI mode:

```
sudo aui-run -u -d /dev/sdc
```

## Programs

- `aui-hd2aui`: Compress an Arch Linux system to a bootable disk image.
- `aui-mkiso`: Build bootable ISO or disk images.
- `aui-mkusb`: Create bootable USB with persistence from ISO.
- `aui-mkinstall`: Install to USB from ISO.
- `aui-mkhybrid`: Create hybrid bootable USB (combines `aui-mkusb` without persistence and `aui-mkinstall`).
- `aui-buildzfs`: Build ZFS packages from upstream OpenZFS sources.
- `aui-run`: Test ISOs and USB drives in QEMU.

## Documentation

Limited to this README. Refer to [Archiso documentation](https://wiki.archlinux.org/title/Archiso).

Key files:

- `profiles/<profile name>/packages.x86_64`: Package list
- `profiles/<profile name>/profiledef.sh`: Profile configuration

## Known Issues

rEFInd Boot Manager may fail on some firmware.
