Description
===========

Build iso images, create live usb drives, install on usb drives.
 
Archuseriso is based on Archiso, the Arch Linux tool for building the official iso image.

Archuseriso provides profiles and additional tools for building iso images and creating bootable usb drives. Features persistence, usb drive installation and encryption.

AUR https://aur.archlinux.org/packages/archuseriso

ISO download http://dl.gnutux.fr/archuseriso

Features
--------

* desktop profiles
* easy build
* alternate language at build time
* zstandard fast compressor
* live usb drive with persistence
* pacman updates support
* installation on usb drive
* Btrfs/F2FS file system option
* LUKS encryption
* EFI rEFInd boot manager
* user packages additions to live image
* samba public folder sharing
* Nvidia graphics option
* Optimus hardware option
* ZFS support option
* testing package option
* user data addition to live image

Profiles
--------

* Console
* Cinnamon
* Deepin
* Gnome
* i3
* Kde
* LXQt
* Mate
* Sway
* Xfce

Hint for gr, rs, ru and ua with two keyboard layouts: press both `Shift keys` together for switching the keyboard layout. 

Installation
------------

Install [archuseriso](https://aur.archlinux.org/packages/archuseriso/) available on the AUR 

Alternate installation method from git repository:

    sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs libisoburn make mtools squashfs-tools syslinux
    git clone https://github.com/laurent85v/archuseriso.git
    sudo make -C archuseriso install

Create iso image
----------------

Synopsis:

    aui-mkiso [options] <path to profile>

Xfce profile with default options:

    sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Default directory `/usr/share/archuseriso/profiles` is assumed when using profile name only:

    sudo aui-mkiso xfce

Other examples:

Kde Plasma profile, German language, Optimus hardware (PRIME render offload setup) and additional packages

    sudo aui-mkiso --language=de --optimus --add-pkg=byobu,base-devel /usr/share/archuseriso/profiles/kde/

Gnome profile, additional packages, user packages addition (directory containing user pkg.tar.zst packages)

    sudo aui-mkiso --add-pkg=ntop,vlc --pkg-dir=~/mypackages /usr/share/archuseriso/profiles/gnome/

When done remove the `work` directory. The iso image is located in the `out` directory.

Live usb
--------
The live usb is created with persistence, the boot menu offers live booting and persistence booting.

Synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Drive partitioning, Ext4 default for persistence

    GPT layout
    Partition   Type              Usage
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Btrfs|F2FS   Persistence

#### Btrfs file system
Two subvolumes a created: `rootfs` and `home`. The `rootfs` subvolume is mounted as the persistent root file system. The `home` subvolmue is mounted as a separate volume for the home tree. This feature also facilitates the usage of `systemd-homed` for creating an additional user account with the `--storage=subvolume` option.  

#### ZFS

The buid option '--zfs' for adding zfs support proceeds in two stages. First stage builds the zfs packages, second stage builds the iso image. Archuseriso also provides a program `aui-build_zfs_packages` for building ZFS packages against current Linux kernel.

Installation on usb drive
-------------------------
Standard installation except systemd journal configured in volatile mode.

Synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

Drive partitioning, Ext4 default file system:

    GPT layout
    Partition   Type              Usage
    #1          EFI FAT           Boot
    #2          Ext4|Btrfs|F2FS   System

Hybrid usb drive
---------------
Both live and standard installation. Boot menu offers standard booting and live booting.

Synopsis:

    aui-mkhybrid [options] <iso image> <usb device>

Example:

    sudo aui-mkhybrid aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc

Drive partitioning, Ext4 default file system:

    GPT layout
    Partition   Type              Usage
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Brtfs|F2FS   System

Testing
-------
Running the iso image in a qemu virtual machine:

Bios mode

    aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

uefi mode

    aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

Testing the usb drive /dev/sdc:

Bios mode

    sudo aui-run -d /dev/sdc

uefi mode

    sudo aui-run -u -d /dev/sdc
