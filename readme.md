Description
===========

Profiles for building Arch Linux Live ISO images. Bootable USB drives creation tools featuring persistent storage and encryption.

Archuseriso is based on Archiso the tool for building the official Arch Linux ISO image.

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

Profiles available
------------------

* Console
* Cinnamon
* Deepin
* Gnome
* i3
* Kde
* LXQt
* Mate
* Xfce

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

Create ISO image
----------------

Command synopsis:

    aui-mkiso [options] <path to profile>

Xfce profile with default options:

    sudo aui-mkiso /usr/share/archuseriso/xfce/

Kde Plasma profile, German language plus options for Optimus hardware and additional packages:

    sudo aui-mkiso --language de --optimus --add-pkg byobu,base-devel /usr/share/archuseriso/kde/

Gnome profile, additional packages, user packages:

    sudo aui-mkiso --add-pkg ntop,vlc --pkg-dir ~/mypackages /usr/share/archuseriso/gnome/

LXQt profile, adding i3wm to X sessions available from the display manager:

    sudo aui-mkiso --add-i3-wm /usr/share/archuseriso/lxqt

When done remove the `work` directory. The ISO image is located in the `out` directory.

Create Live USB
---------------
The live usb is created with persistent storage support by default.

Command synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Live USB partition layout created by `aui-mkusb`:

    GPT layout
    Partition  Type  Usage        Size
    #1         Ext4  Squashfs     Image size 
    #2         FAT   Boot         Default 512 MiB
    #3         Ext4  Persistence  Default free disk space 

#### ISO image with ZFS support

`aui-mkiso` has a command option '--zfs' for building an iso image with ZFS support. The build script
proceeds in two stages, first stage builds the necessary zfs packages against current Arch Linux kernel,
second stage builds the iso image.

Archuseriso also provides a command line utility `aui-build_zfs_packages` for building the ZFS packages. The
packages can be installed on any Arch Linux system for adding ZFS support.

Hard disk like installation on a USB drive
------------------------------------------
No live image installed, no compression, hard disk like installation except systemd logs configured in volatile mode for limiting writes to usb drive. See the command line help for available options.

Command synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc
