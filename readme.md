Description
===========

Build iso images, create live usb drives, install on usb drives.
 
Archuseriso is based on Archiso the Arch Linux tool for building the official iso image.

Archuseriso provides new profiles and additional tools for building iso images and creating usb drives featuring persistent storage and encryption.


Highlights
----------

* easy build
* fast live images
* pacman updates support
* rEFInd boot manager
* LUKS encryption
* ZFS support
* language support
* user packages support
* Nvidia graphics support
* Optimus hardware support
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

Create iso image
----------------

Command synopsis:

    aui-mkiso [options] <path to profile>

Xfce profile with default options:

    sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Kde Plasma profile, German language plus options for Optimus hardware and additional packages:

    sudo aui-mkiso --language=de --optimus --add-pkg=byobu,base-devel /usr/share/archuseriso/profiles/kde/

Gnome profile, additional packages, user packages:

    sudo aui-mkiso --add-pkg=ntop,vlc --pkg-dir=~/mypackages /usr/share/archuseriso/profiles/gnome/

When done remove the `work` directory. The ISO image is located in the `out` directory.

Create live usb
---------------
The live usb is created with persistence enabled.

Command synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Live usb partitions:

    GPT layout
    Partition   Type      Usage         Size
    #1          Ext4      Squashfs      Image size 
    #2          EFI FAT   Boot          512 MiB
    #3          Ext4      Persistence   Free disk space 

#### ZFS support

Needs option '--zfs'.
The build script proceeds in two stages, first stage builds the zfs packages, second stage builds the iso image.
Archuseriso also provides a utility `aui-build_zfs_packages` for only building the ZFS packages.

Installation on a usb drive
---------------------------
Hard disk like installation except systemd journal configured in volatile mode.

Command synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

usb drive partitions:

    GPT layout
    Partition   Type      Usage    Size
    #1          EFI FAT   Boot     512 MiB
    #2          Ext4      System   Free disk space 
