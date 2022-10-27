Description
===========

Archuseriso is a set of script programs written in Bash based on Archiso, the Arch Linux tool for building the official iso image released monthly.

Archuseriso aims at extending the base features of Archiso, providing pre-configured build profiles for building live iso images with desktop environment.

Archuseriso brings additional tools for making a bootable live usb drive with persistence, allowing to run Arch Linux on a removable medium for many kinds of use cases.

Alternatively a standard installation can be performed if persistence is not an option for your needs.

Another cool feature of Archuseriso is optional disk encryption.

AUR https://aur.archlinux.org/packages/archuseriso

ISO download http://dl.gnutux.fr/archuseriso

Highlights
----------

* pre-configured build profiles
* language choice
* zstandard fast compressor
* persistence, pacman updates compatible
* standard installation on usb drive
* Ext4 / Btrfs / F2FS file systems
* LUKS encryption
* systemd UEFI boot loader
* syslinux bios boot loader
* boot loaders alternatives (rEFInd, Grub)
* ZFS support option
* add user packages
* add testing package to iso image
* add any data to iso image
* Nvidia and Optimus hardware options
* samba public folder sharing

Pre-configured build profiles
-----------------------------

* Console
* Cinnamon
* Deepin
* Gnome
* i3
* Kde Plasma
* LXQt
* Mate
* Sway
* Xfce

Installation
------------

Installation from the AUR [archuseriso](https://aur.archlinux.org/packages/archuseriso/)

Installation from the git repository:

    sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs erofs-utils grub libarchive libisoburn make mtools squashfs-tools syslinux
    git clone https://github.com/laurent85v/archuseriso.git
    sudo make -C archuseriso install

Note that Archuseriso was designed for Arch Linux and was not tested on Arch Linux derivatives.

Build iso image
---------------

Synopsis:

    aui-mkiso [options] <path to profile>

Build Xfce iso image with default options:

    sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Default build directory `/usr/share/archuseriso/profiles` assumed when path to profile not provided:

    sudo aui-mkiso xfce

Examples:

Kde Plasma profile and German language

    sudo aui-mkiso --language=de kde

Gnome profile, add packages to profile, add user packages (directory containing pkg.tar.zst packages)

    sudo aui-mkiso --add-pkg=ntop,vlc --pkg-dir=~/mypackages gnome

When done remove the `work` directory. The iso image is located in the `out` directory.

Make live usb with persistence
------------------------------
The live usb supports persistence by default. The boot menu offers to boot with or without persistence.

Synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

The drive partitioning is as follow:

    GPT layout
    Partition   FS type           Type
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Btrfs|F2FS   Persistence

#### Btrfs file system

For the Btrfs file system two subvolumes are created: `rootfs` and `home`. The `rootfs` subvolume for root persistence and the `home` subvolume for home persistence.


#### ZFS support

Run `aui-build_zfs_packages` for building the ZFS package.

Standard installation on usb drive
----------------------------------
A standard installation on a usb drive can be performed. The live settings are removed except systemd journal that remains configured in volatile mode to limit disk I/O.

Synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

The drive partitioning is as follow:

    GPT layout
    Partition   FS Type           Type
    #1          EFI FAT           Boot
    #2          Ext4|Btrfs|F2FS   System

Make hybrid usb drive
---------------------
Combines both a live system and a standard installation. The boot menu offers to boot live or to boot the system installed on the usb drive.

Synopsis:

    aui-mkhybrid [options] <iso image> <usb device>

Example:

    sudo aui-mkhybrid aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc


The drive partitioning is as follow:

    GPT layout
    Partition   FS Type           Type
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Brtfs|F2FS   System

Test the iso image and the usb drive
------------------------------------
Run `aui-run` to test the iso image or the usb drive in a qemu virtual machine.

Examples:

iso image test in bios mode

    aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

iso image test in uefi mode

    aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

usb drive /dev/sdc test in bios mode

    sudo aui-run -d /dev/sdc

usb drive /dev/sdc test in uefi mode

    sudo aui-run -u -d /dev/sdc

Script programs
---------------

aui-mkiso : build live iso image

aui-mkusb : make live usb drive with persistence

aui-mkinstall : make standard installation on usb drive

aui-mkhybrid : make live usb drive and standard installation

aui-build_zfs_packages : build ZFS packages

Documentation
-------------
Currently Archuseriso has no specific documentation. You can refer to the Archiso documentation as most also applies to Archuseriso.

Files of interest:

profiles/&lt;profile name&gt;/packages.x86_64 : list of packages to install

profiles/&lt;profile name&gt;/profiledef.sh : iso profile settings

Known issues
------------
rEFInd boot manager may fail on some firmware.
