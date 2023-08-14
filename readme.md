Description
===========

Archuseriso is a set of script programs for building iso images and bootable disk images of Arch Linux, and for installing Arch Linux on an external USB disk or thumb drive.

Archuseriso is based on Archiso, the program used by the Arch Linux developers to build the monthly iso image.

Archuseriso integrates most of the developments of Archiso and adds additional features. A list of new build profiles is offered, they make it easy to build a bootable iso image or a bootable disk image with a desktop environment. Archuseriso allows creating a live usb drive with persistence and allows installing Arch Linux on a removable USB disk using the iso image or disk image created.

System and data can be encrypted on the removable medium. Several types of file systems are offered, ext4 the default, Btrfs and F2FS. Archuseriso also provides tools for adding native ZFS support to the iso image and the disk image, including installing onto a ZFS filesystem.

Archuseriso images with a desktop environment can beneficially be used as an alternative to the Archiso image for installing on disk and for maintenance purposes.

* AUR repository https://aur.archlinux.org/packages/archuseriso
* ISO image download for DVDs and USB disks http://dl.gnutux.fr/archuseriso/iso
* GPT disk image download for USB disks only http://dl.gnutux.fr/archuseriso/img
* ZFS packages download http://dl.gnutux.fr/archuseriso/zfsonlinux

Highlights
----------

* preconfigured build profiles
* language choice
* zstandard compression algorithm
* persistence
* normal install on usb disk
* Ext4 / Btrfs / F2FS / ZFS file systems
* LUKS encryption
* syslinux bios bootloader
* systemd-boot, Grub or rEFInd bootloader for UEFI hardware
* Build ZFS packages
* Installation on ZFS root filesystem
* add AUR packages
* inclusion of personal data to image
* Nvidia graphics driver option
* Samba public folder sharing
* Docker image for running Archuseriso in a container

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

The recommended installation method is using the AUR repository [archuseriso](https://aur.archlinux.org/packages/archuseriso/)

Alternative method using the git repository:

      sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs erofs-utils grub libarchive libisoburn make mtools parted squashfs-tools syslinux
      git clone https://github.com/laurent85v/archuseriso.git
      sudo make -C archuseriso install

The online built images on the http://dl.gnutux.fr/archuseriso download page include archuseriso. This allows building your disk image from the Live system without having to install archuseriso on your own computer.

Note that archuseriso was designed for Arch Linux and has not been tested on Arch Linux derivatives.

Building an image
-----------------

Synopsis:

      aui-mkiso [options] <profile path>

Build Xfce iso image with the default options, directory profiles `/usr/share/archuseriso/profiles` is assumed when profile path is not provided, following commands are equivalent:

      sudo aui-mkiso xfce
      sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Using Kde Plasma profile, German language

      sudo aui-mkiso --language=de kde

Using the Gnome profile, additional packages are added, user packages located in directory `mypackages` are also added (pre-built AUR packages): 

      sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop --pkg-dir=~/mypackages gnome

Using Xfce profile, building a gpt disk image

      sudo aui-mkiso -m 'img' xfce

Once finished it is necessary to delete the `work` directory before building a new image. The generated disk image can be found in the `out` directory.

Help [Writing Disc Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities) and [Burning DVD](https://wiki.archlinux.org/title/Optical_disc_drive#Burning)


GPT disk image
--------------
The GPT disk image is a bootable disk image for USB flash drives and USB disks with persistence enabled. Write image directly to the usb drive. Free space on device can be used for creating new partitions for data storage or other usages.

Copy the gpt disk image to the usb device, e.g. as root with a usb device on /dev/sdc:

    # pv aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc

Since the disk image and the usb disk capacity are not the same size it is necessary to fix the gpt table size on the usb disk. You can use the following command, knowing that fdisk or gparted can also fix it.

Note the 3 dashes of the undocumented parted command option `---pretend-input-tty`:

    echo Fix | sudo parted /dev/sdc ---pretend-input-tty print

The partition size for persistence is only 128 MiB. You need to resize the partition for persistence to the desired size. Gparted allows you to do this easily.

Help [Writing Disk Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities)

USB drive with persistence
--------------------------
Using an archuseriso iso image for creating a bootable USB drive. The boot menu on startup offers to boot in Live mode or with persistence enabled.

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

To add ZFS support to the iso image two methods are available: either the `--zfs-support` option which will build the zfs packages before installing them, or the `--pkg-dir <path>` which indicates the path of a directory containing additional packages to install (including those of ZFS).

For the second method the `aui-buildzfs` script can build the zfs packages for you.

Example:

    sudo aui-mkiso --zfs-support xfce

#### ZFS packages

To build `zfs-utils`, `zfs-linux` and `zfs-linux-headers` for the current Arch Linux kernel, use the `aui-buildzfs` script:

      sudo aui-buildzfs

The script uses the zfs PKGBUILDs from archuseriso to build the zfs packages, they are compatible on any Arch Linux system.

Normal installation on usb device
----------------------------------
A normal installation can be carried out, this mode is the equivalent of an installation on an internal hard disk. Parameters specific to the live system are reset to Arch Linux default values with the exception of systemd journal which remains configured in volatile mode to limit disk I/O (especially for thumb drives)

Synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc


The disk partitioning is as follow:

    GPT layout
    Partition   FS Type           Type
    #1          EFI FAT           Boot
    #2          Ext4|Brtfs|F2FS   System


Installation on a ZFS Root File System
--------------------------------------
Requires an iso image with zfs support included. The script performs a normal installation with zfs as the root filesystem. A usb ssd drive is highly recommended:

      sudo aui-mkinstall --rootfs=zfs --username=foobar ./out/aui-xfce-linux_6_0_9-1123-x64.iso /dev/sdc

Test
----
You can use `aui-run` to test an iso image or a usb disk in a qemu virtual machine.

Examples:

test an iso image in bios mode

      aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

test an iso image in uefi mode

      aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

test of thumb drive /dev/sdc in bios mode

      sudo aui-run -d /dev/sdc

test of thumb drive /dev/sdc in uefi mode

      sudo aui-run -u -d /dev/sdc


Docker image
------------
Using a Docker image for running archuseriso.

Download the `Dockerfile` file from the archuseriso sources. Then from the directory containing the Dockerfile run the docker build command for building the archuseriso image.

    sudo docker build -t archuseriso .

The archuseriso docker image is now created and can be used for running archuseriso in a docker container. Example:

    sudo docker run --privileged --rm -it archuseriso
    [root@4dd3aab1018b /]# pacman -Q archuseriso

Note that Docker is out of the scope of this documentation. You are supposed to know how to run and handle docker containers.

Limitations

Building zfs packages from the docker container currently doesn't work. 

Archuseriso Program List
------------------------

* `aui-mkiso`: Build a bootable system image using a build profile
* `aui-mkusb`: create a bootable system on a USB drive with persistence
* `aui-mkinstall`: create a bootable system on a USB drive, corresponds to a normal hard disk installation
* `aui-mkhybrid`: create a bootable system on USB drive, combines live mode and normal installation on the same usb device
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
