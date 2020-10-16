Description
===========

Profiles for building Arch Linux Live ISO images. Bootable USB drives creation tools featuring persistent storage and encryption.

Highlights
----------

* easy build
* very fast live images
* live usb drive creation tool
* persistence support
* pacman updates support
* rEFInd boot manager
* LUKS encryption option
* ZFS support option
* language option
* package list customization
* user packages support
* Nvidia graphics driver option
* Optimus hardware option
* samba public folder sharing

Desktop environments profiles
-----------------------------

* Console
* Cinnamon
* Deepin
* Gnome
* i3
* Kde
* LXQt
* Mate
* Xfce

'console profile': english only, no persistence, options related to Xorg ignored.

Hint for gr, rs, ru and ua with two keyboard layouts: press both `Shift keys` together for keyboard layout switch. 

Installation
------------

Install [archuseriso](https://aur.archlinux.org/packages/archuseriso/) available on the AUR 

Or manual install on Arch Linux:

    sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs libisoburn make mtools squashfs-tools syslinux

Clone master repository:

    git clone https://github.com/laurent85v/archuseriso.git

Install:

    sudo make -C archuseriso install

Building iso image
------------------

Command synopsis:

    aui-mkiso <profile> [options]

Xfce profile with default options:

    sudo aui-mkiso xfce

Kde Plasma profile, German language plus options for Optimus hardware and additional packages:

    sudo aui-mkiso kde --language de --optimus --addpkg byobu,base-devel

Gnome profile, additional packages, user packages:

    sudo aui-mkiso gnome --addpkg ntop,vlc --pkgdir ~/mypackages

LXQt profile, adding i3wm to X sessions available from the display manager:

    sudo aui-mkiso lxqt --addi3wm

When done remove the `work` directory. The ISO image is located in the `out` directory.

Live USB creation
-----------------
The live usb is created with persistent storage support by default.

Command synopsis:

    aui-mkusb <iso image> <usb device> [options]

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Persistence note: for a Live USB created with a different tool the missing persistence feature can be turned on from the live usb (restart needed). The following command executed within the live's desktop environment only supports a subset of the standard features. Prefer using `aui-mkusb` for creating the live usb to take advantage of full features.

    sudo aui-addpersistence

Live USB partition layout created by `aui-mkusb`:

    GPT layout
    Partition  Type  Usage        Size
    #1         Ext4  Squashfs     Image size 
    #2         FAT   Boot         Default 512 MiB
    #3         Ext4  Persistence  Default free disk space 

#### aui-mkiso command line help

    Archuseriso tool for building a custom Arch Linux Live ISO image.

    Command synopsis:
    aui-mkiso <profile> [options]

    Options:
    -h, --help                          Command line help
    --addi3wm                           Add i3wm packages: i3-gaps,feh,dmenu,i3status,wmctrl
    --addpkg <package1,package2,...>    Comma separated list of additional packages
    -C, --confdir <path>                Archuseriso directory path (default: /usr/share/archuseriso)
    --embeddir <directory path>         Embed directory in the iso image. Data will be available
                                        from the user's live session
    -l, --language <language>           Set default language:
                                        cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua
    --nvidia                            Add Nvidia graphics driver
    --optimus                           For Optimus hardware. Set Intel iGPU default, Nvidia dGPU
                                        configured for PRIME render offload (prime-run <application>)
    --pkgdir <path>                     User directory containing package files for installation
    --testing  <package1,package2,...>  Comma separated list of additional packages from testing
                                        and community-testing repositories
    -v, --verbose                       Verbose mode
    --zfs                               Add ZFS support. Dynamically builds the ZFS packages before
                                        building the iso image

#### ISO image with ZFS support

`aui-mkiso` has a command option '--zfs' for building an iso image with ZFS support. The build script
proceeds in two stages, first stage builds the necessary zfs packages against current Arch Linux kernel,
second stage builds the iso image.

Archuseriso also provides a command line utility `aui-build_zfs_packages` for building the ZFS packages. The
packages can be installed on any Arch Linux system for adding ZFS support.

#### aui-mkusb command line help

    Archuseriso tool for creating a Live USB with persistent storage

    Command synopsis:
    aui-mkusb <usb device> <iso image> [options]

    Options:
    -h, --help                Command line help
    --encrypt                 Encrypt persistent partition
    --ext4journal             Enable ext4 journal (disabled by default for minimizing drive writes)
    --f2fs                    Use the F2FS file system for the persistent partition (Default Ext4)
    --rawwrite                Raw ISO image write to USB drive (dd like mode)
    --sizepart2 integer[g|G]  2nd partition size in GiB (Boot partition, FAT)
    --sizepart3 integer[g|G]  3rd partition size in GiB (persistent partition, Ext4)

Normal installation on a USB drive
-------------------------------------
No live image installed, no compression, hard disk like installation except systemd logs configured in volatile mode for limiting writes to usb drive. See the command line help for available options.

Command synopsis:

    aui-mkinstall <iso image> <usb device> [options]

Example

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc
