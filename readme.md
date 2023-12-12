Description
===========

Archuseriso is a toolkit for building iso images and bootable disk images of Arch Linux, and for installing Arch Linux on a USB disk or thumb drive.

Archuseriso is based on Archiso, the program used for building the Arch Linux monthly iso image.

Archuseriso integrates most Archiso developments and adds additional features. A list of new build profiles is offered, they make it easy to build a bootable iso image or a bootable disk image with a desktop environment. Archuseriso allows the creation of a live usb drive with persistence and allows the installation of Arch Linux on a removable USB disk.

Encryption is an option when ceating the removable medium. Several types of file systems are offered, ext4, Bcachefs, Btrfs and F2FS. Adding native ZFS support to the iso image and the disk image is an option, including installation onto a ZFS filesystem.

* AUR repository https://aur.archlinux.org/packages/archuseriso
* ISO image download for DVDs and USB disks http://dl.gnutux.fr/archuseriso/iso
* GPT disk image download for USB disks only http://dl.gnutux.fr/archuseriso/img
* ZFS packages download http://dl.gnutux.fr/archuseriso/zfsonlinux

Features
--------

* preconfigured build profiles
* language configuration
* zstandard compression algorithm
* persistence mode
* installation mode
* Ext4 / Bcachefs / Btrfs / F2FS / ZFS file systems
* LUKS encryption
* GPT partition table
* DOS MBR partition table
* syslinux bios bootloader
* systemd-boot, Grub or rEFInd bootloader for UEFI hardware
* tool for building ZFS packages
* Installation on ZFS root filesystem
* add user own packages
* add user data to image
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

The online built images on the download page http://dl.gnutux.fr/archuseriso include archuseriso. This allows building your disk image from the live medium without having to install archuseriso.

Note that archuseriso was designed for Arch Linux and has not been tested on Arch Linux derivatives.

Building an image
-----------------

Synopsis:

      aui-mkiso [options] <profile path>

Build Xfce iso image with default options, directory profiles `/usr/share/archuseriso/profiles` is assumed when not provided. The following commands are equivalent:

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
The GPT disk image is a bootable disk image with persistence builtin. Write image directly to the usb drive. Free space on the device can be used for creating additional partitions for other usages.

Copy the gpt disk image to the usb device, e.g. as root with a usb device on /dev/sdc:

    # pv aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc

Since the disk image and the usb disk capacity are not the same size it is necessary to fix the gpt table size on the usb disk. You can use the following command. fdisk or gparted can also fix it.

Note the 3 dashes of the undocumented parted command option `---pretend-input-tty`:

    echo Fix | sudo parted /dev/sdc ---pretend-input-tty print

The partition size configured for persistence is only 128 MiB. You need to resize the partition according to your needs. Gparted can do that easily.

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
    Partition   FS type                    Type
    #1          Ext4                       Squashfs image
    #2          EFI FAT                    Boot
    #3          Ext4|Bcachefs|Btrfs|F2FS   Persistence

#### Btrfs filesystem

For the Btrfs filesystem, two separate subvolumes are created for persistence: `rootfs` and `home`.

#### ZFS support

To add ZFS support to the iso image two methods are available: either the `--zfs-support` option which will build the zfs packages before installing them, or the `--pkg-dir <path>` which indicates the path of a directory containing additional packages to install (including those of ZFS).

For the second method the `aui-buildzfs` program can build the zfs packages from sources against the current linux kernel.

Example:

    sudo aui-mkiso --zfs-support xfce

#### ZFS packages

To build `zfs-utils`, `zfs-linux` and `zfs-linux-headers`, use the `aui-buildzfs` tool:

      sudo aui-buildzfs

Normal installation on usb device
----------------------------------
A normal installation can be carried out, this mode is the equivalent of an installation to an internal hard disk. Live system specific settings are reset to Arch Linux defaults, except for the system log which remains configured in volatile mode to limit disk I/O.

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

Note that Docker is out of the scope of this readme. You are supposed to know how to handle docker containers.

Limitations

Building zfs packages from the docker container currently doesn't work. 

Archuseriso Program List
------------------------

* `aui-mkiso`: Build a bootable image using a build profile
* `aui-mkusb`: create a bootable USB drive with persistence
* `aui-mkinstall`: create a bootable USB drive, corresponds to a normal hard disk installation
* `aui-mkhybrid`: create a bootable USB drive, combines live mode and normal installation on the same usb device
* `aui-buildzfs`: build ZFS packages
* `aui-run`: test an image or a bootable usb drive

Documentation
--------------
Currently Archuseriso has no specific documentation. You can refer to Archiso's documentation.

Files of interest:

* profiles/&lt;profile name&gt;/packages.x86_64: list of packages to install
* profiles/&lt;profile name&gt;/profiledef.sh: profile settings

Known issues
------------
rEFInd Boot Manager may fail on some firmware.
