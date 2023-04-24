Description
===========

Archuseriso is a set of scripts for creating bootable disk images of Arch Linux and installing an Arch Linux system to an external USB disk or thumb drive.

The build of disk images is based on the Archiso program used by Arch Linux developers to build the monthly iso images.

Archuseriso integrates most of the developments of Archiso and adds additional features. A list of new build profiles is available, they make it easy to build bootable disk images with a desktop environment. Archuseriso also allows installing an Arch Linux system on a removable USB disk from the iso image created.

System and data can be encrypted to protect the data on the removable medium. Several types of file systems are available for persistence and installation, including ZFS for installation.

* AUR repository https://aur.archlinux.org/packages/archuseriso
* ISO image download for DVDs and USB disks http://dl.gnutux.fr/archuseriso/iso
* GPT disk image download for USB disks only http://dl.gnutux.fr/archuseriso/img
* ZFS packages download http://dl.gnutux.fr/archuseriso/zfsonlinux

Highlights
----------

* preconfigured build profiles
* many languages
* zstandard compression algorithm
* live usb with persistence
* normal install on usb disk
* Ext4 / Btrfs / F2FS / ZFS file systems
* LUKS encryption
* syslinux bios bootloader
* systemd-boot, Grub or rEFInd bootloader for UEFI hardware
* building ZFS packages
* Installation on ZFS root filesystem
* add package from test repository
* add user's own packages
* inclusion of personal data in the disk image
* Nvidia graphics driver option
* Samba public folder sharing

Pre-configured build profiles
-----------------------------

* Console
* Cinnamon
* Cutefish
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

The recommended installation method using the AUR repository [archuseriso](https://aur.archlinux.org/packages/archuseriso/)

Or from the git repository:

      sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs erofs-utils grub libarchive libisoburn make mtools parted squashfs-tools syslinux
      git clone https://github.com/laurent85v/archuseriso.git
      sudo make -C archuseriso install

The images on the http://dl.gnutux.fr/archuseriso download page include Archuseriso. This allows you to make your disk image from the Live system without having to install Archuseriso on your own computer.

Note that Archuseriso was designed for Arch Linux and has not been tested on Arch Linux derivatives.

Build an image
-----------

Synopsis:

      aui-mkiso [options] <profile path>

Build an Xfce iso image with the default options:

      sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Default build directory `/usr/share/archuseriso/profiles` assumed when profile path is not provided:

      sudo aui-mkiso xfce

Examples:

Using Kde Plasma profile, German language

      sudo aui-mkiso --language=from kde

Using the Gnome profile, additional packages from the Arch Linux repositories are added, user packages located in directory `mypackages` are also added.

      sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop,vlc --pkg-dir=~/mypackages gnome

Using Xfce profile, building a gpt disk image

      sudo aui-mkiso -m 'img' xfce

Once finished it is necessary to delete the `work` directory before building a new image. The generated disk image can be found in the `out` directory.

Help [Writing Disc Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities) and [Burning DVD](https://wiki.archlinux.org/title/Optical_disc_drive#Burning)


GPT disk image
--------------
Bootable disk image for USB flash drives and USB disks with support for persistence. Image to write directly to usb drive. New partitions can be created on the free space for data storage.

Copy the gpt disk image to the usb device, e.g. as root with a usb device on /dev/sdc:

    # pv aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc

The disk image and the usb disk capacity are not the same size. To fix the gpt table size on the usb disk you can use the following command, fdisk or gparted can also do that. Note the 3 dashes of the undocumented `---pretend-input-tty` option of the `parted` command:

    echo Fix | sudo parted /dev/sdc ---pretend-input-tty print

The partition for persistence is only 128 MiB. After writing the disk image and correcting the size of the gpt table, it is necessary to resize the partition for persistence to the desired size. Gparted allows you to do this easily.

Help [Writing Disk Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities)

USB drive with persistence
--------------------------
The disk image installed on the usb drive supports persistence by default. The start menu offers to start in Live mode or with data persistence.

Synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

The disk partitioning is as follow:

    GPT layout
    Partition   FS type           Type
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Btrfs|F2FS   Persistence

#### Btrfs filesystem

For the Btrfs filesystem, two separate subvolumes are created for persistence: `rootfs` and `home`.

#### ZFS support

To add ZFS support to the image there are two methods: either the `--zfs-support` option which will build the zfs packages before installing them, or the `--pkg-dir <path>` which indicates the path of a directory containing additional packages to install (including those of ZFS).

For the second method there is the `aui-buildzfs` script which allows you to build the zfs packages.

Example:

    sudo aui-mkiso --zfs-support xfce

#### ZFS packages

To build `zfs-utils`, `zfs-linux` and `zfs-linux-headers` for the current Arch Linux kernel, use the `aui-buildzfs` script:

      sudo aui-buildzfs

The script uses the zfs PKGBUILDs from Archuseriso to build the zfs packages, they are compatible on any Arch Linux system.

Normal installation on usb device
----------------------------------
A normal installation can be carried out, this mode is the equivalent of an installation on internal hard disk. Parameters specific to the live system are reset to Arch Linux default values with the exception of the systemd journal which remains configured in volatile mode to limit disk I/O (especially for thumb drives)

Synopsis:

    aui-mkhybrid [options] <iso image> <usb device>

Example:

    sudo aui-mkhybrid aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc


The disk partitioning is as follow:

    GPT layout
    Partition   FS Type           Type
    #1          Ext4              Squashfs image
    #2          EFI FAT           Boot
    #3          Ext4|Brtfs|F2FS   System


Installation on a ZFS Root File System
-------------------------------------
Requires an iso image with zfs support. Perform a normal install with zfs as the root filesystem. For zfs an ssd disk is highly recommended:

      sudo aui-mkinstall --rootfs=zfs --username=foobar ./out/aui-xfce-linux_6_0_9-1123-x64.iso /dev/sdc

Test
----
You can use `aui-run` to test the iso image or a usb disk in a qemu virtual machine.

Examples:

test an iso image in bios mode

      aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

test an iso image in uefi mode

      aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

test of thumb drive /dev/sdc in bios mode

      sudo aui-run -d /dev/sdc

test of thumb drive /dev/sdc in uefi mode

      sudo aui-run -u -d /dev/sdc

Archuseriso Program List
------------------------

* `aui-mkiso`: Build a bootable system image using a build profile
* `aui-mkusb`: create a bootable system on a USB drive with persistence
* `aui-mkinstall`: create a bootable system on a USB drive, corresponds to a normal hard disk installation
* `aui-mkhybrid`: create a bootable system on USB drive, combines live mode and normal installation on on the same usb device
* `aui-buildzfs`: build ZFS packages
* `aui-run`: test an image or a bootable system installed on a usb drive

Documentation
--------------
Currently Archuseriso has no specific documentation. You can refer to Archiso's documentation.

Files of interest:

* profiles/&lt;profile name&gt;/packages.x86_64: list of packages to install
* profiles/&lt;profile name&gt;/profiledef.sh: profile settings

Known issues
------------
rEFInd Boot Manager may fail on some firmware.
