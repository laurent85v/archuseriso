Description
===========

Build iso images, create live usb drives, install on usb drives.
 
Archuseriso is based on Archiso, the Arch Linux tool for building the official iso image.

Archuseriso provides profiles and additional tools for building iso images and creating usb drives. Features persistence, installation and encryption.


Features
--------

* easy build
* persistence
* usb installation
* LUKS encryption
* fast live images
* pacman updates support
* rEFInd boot manager
* language support
* user packages support
* Nvidia graphics support
* Optimus hardware support
* samba public folder sharing
* ZFS support

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
* Xfce

Hint for gr, rs, ru and ua with two keyboard layouts: press both `Shift keys` together for switching the keyboard layout. 

Installation
------------

Install [archuseriso](https://aur.archlinux.org/packages/archuseriso/) available on the AUR 

Alternate installation method using the git repository:

    sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs libisoburn make mtools squashfs-tools syslinux
    git clone https://github.com/laurent85v/archuseriso.git
    sudo make -C archuseriso install

Create iso image
----------------

Synopsis:

    aui-mkiso [options] <path to profile>

Xfce profile with default options:

    sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Default directory `/usr/share/archuseriso/profiles` is assumed when only using profile name:

    sudo aui-mkiso xfce

Other examples:

Kde Plasma profile, German language plus options for Optimus hardware and additional packages

    sudo aui-mkiso --language=de --optimus --add-pkg=byobu,base-devel /usr/share/archuseriso/profiles/kde/

Gnome profile, additional packages, user packages

    sudo aui-mkiso --add-pkg=ntop,vlc --pkg-dir=~/mypackages /usr/share/archuseriso/profiles/gnome/

When done remove the `work` directory. The iso image is located in the `out` directory.

Live usb
--------
The live usb is created with persistence enabled.

Synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Drive partitioning:

    GPT layout
    Partition   Type      Usage         Size
    #1          Ext4      Squashfs      Image size 
    #2          EFI FAT   Boot          512 MiB
    #3          Ext4      Persistence   Free disk space 

#### ZFS support

Command option '--zfs'.
The build script proceeds in two stages, first stage builds the zfs packages, second stage builds the iso image.
Archuseriso also provides a utility `aui-build_zfs_packages` for building the ZFS packages alone.

Installation on usb drive
-------------------------
Permanent installation except systemd journal is configured in volatile mode.

Synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

Drive partitioning:

    GPT layout
    Partition   Type      Usage    Size
    #1          EFI FAT   Boot     512 MiB
    #2          Ext4      System   Free disk space 

Hybrid usb drive
---------------
Both live usb and permanent installation.

Synopsis:

    aui-mkhybrid [options] <iso image> <usb device>

Example:

    sudo aui-mkhybrid aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc

Drive partitioning:

    GPT layout
    Partition   Type      Usage         Size
    #1          Ext4      Squashfs      Image size
    #2          EFI FAT   Boot          512 MiB
    #3          Ext4      System        Free disk space

Testing
-------
Run the iso image in a qemu virtual machine:

Bios mode

    aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

uefi mode

    aui-run --uefi -i aui-xfce-linux_5_10_7-0116-x64.iso

Testing the usb drive /dev/sdc:

Bios mode

    sudo aui-run -d /dev/sdc

uefi mode

    sudo aui-run --uefi -d /dev/sdc
