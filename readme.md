Description
===========

A set of bash script programs to create bootable Arch Linux images and to create bootable USB flash drives with a desktop environment.

Also includes a program to compress an Arch Linux system installed on a hard drive into a bootable disk image.

* AUR repository https://aur.archlinux.org/packages/archuseriso
* ISO images http://dl.gnutux.fr/archuseriso/iso
* IMG disk images for USB flash drives http://dl.gnutux.fr/archuseriso/img
* iPXE Network Bootloader images http://dl.gnutux.fr/archuseriso/ipxe
* ZFS packages http://dl.gnutux.fr/archuseriso/zfsonlinux

Archuseriso is based on Archiso https://wiki.archlinux.org/title/Archiso

Features
--------

* 10 profiles
* 16 languages
* data persistence
* choice of filesystem among Ext4 / Bcachefs / Btrfs / F2FS / ZFS
* data encryption
* ISO and IMG images
* ZFS support

Profiles
--------

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

Archuseriso is available on the AUR [archuseriso](https://aur.archlinux.org/packages/archuseriso/)

Online images at http://dl.gnutux.fr/archuseriso include archuseriso. 

Building iso image and disk image
---------------------------------

Synopsis:

      aui-mkiso [options] <profile path>

Xfce iso image with default options. Both command work:

      sudo aui-mkiso xfce
      sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Kde Plasma iso, german language:

      sudo aui-mkiso --language=de kde

Gnome iso, additional package names, add tar.zst package files contained in ~/mypackages directory: 

      sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop --pkg-dir=~/mypackages gnome

Xfce disk image:

      sudo aui-mkiso -m 'img' xfce

Help [Writing Disc Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities) and [Burning DVD](https://wiki.archlinux.org/title/Optical_disc_drive#Burning)



Creating a bootable USB flash drive with data persistence
---------------------------------------------------------

Synopsis:

    aui-mkusb [options] <archuseriso iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

Disk partitioning:

    GPT layout
    Partition   Filesystem                 Content
    #1          Ext4                       Squashfs image
    #2          EFI FAT                    Boot
    #3          Ext4|Bcachefs|Btrfs|F2FS   Persistence

#### Btrfs filesystem details

Two subvolumes are created for data persistence: `rootfs` and `home`.

Installing to a USB flash drive
-------------------------------

Synopsis:

    aui-mkinstall [options] <archuseriso iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc


Disk partitioning:

    GPT layout
    Partition   Filesystem type   Content
    #1          EFI FAT           Boot
    #2          Ext4|Brtfs|F2FS   System

The Systemd journal is configured in volatile mode to limit disk I/O.

Disk image
----------
Bootable disk image with data persistence.

Write disk image to usb device, e.g. with usb flash drive /dev/sdc:

    # cat aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc

Important notice: the disk image and the usb flash drive do not have the same size. It is necessary to correct the size of the gpt partition table on the usb flash drive. Use parted, fdisk or gparted for that.

Using parted, notice the 3 dashes prepending the command option `---pretend-input-tty`:

    echo Fix | sudo parted /dev/sdc ---pretend-input-tty print

The partition size for data persistence is only 128 MiB. Resize the persistent partition to your needs. gparted can do that easily.

Help [Writing Disk Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities)

iPXE Network Bootloader
-----------------------
Network boot the latest live Xfce desktop from the Archuseriso server.
 
Pick one of the iPXE image at http://dl.gnutux.fr/archuseriso/ipxe

* aui-ipxe.iso: cdrom image for legacy bios
* aui-ipxe.img: usb flash drive for legacy bios
* aui-ipxe-efi.iso: cdrom image for x64 uefi platform
* aui-ipxe-efi.img: usb flash drive for x64 uefi platform
* aui-ipxe.efi: x64 UEFI binary

Boot the media to load the iPXE boot menu and start the live Xfce desktop. 

For wireless network connectivity on a laptop, use a smartphone's USB tethering feature. The iPXE wifi support is not implemented.

Adding ZFS support
------------------
Two methods are available.

The `--zfs-support` command option: automatically builds and adds the zfs packages to the iso image.

The `--pkg-dir <path>` command option: the directory must contain the zfs packages to install.

Example with the first method:

    sudo aui-mkiso --zfs-support xfce

#### Building ZFS packages

To build the zfs packages `zfs-utils`, `zfs-linux` and `zfs-linux-headers` against the current linux kernel use the `aui-buildzfs` program.

      sudo aui-buildzfs

#### ZFS Root File System
Installing an archuseriso iso image to a ZFS root filesystem requires an iso image with zfs support:

      sudo aui-mkinstall --rootfs=zfs --username=foobar aui-xfce-linux_6_0_9-1123-x64.iso /dev/sdc

Using Docker for running archuseriso
------------------------------------
Download the `Dockerfile` file from the archuseriso sources. From a working directory containing the Dockerfile run the docker build command for building the archuseriso docker image.

    sudo docker build -t archuseriso .

The archuseriso docker image is now created. To run archuseriso in a docker container use:

    sudo docker run --privileged --rm -it archuseriso
    [root@4dd3aab1018b /]# pacman -Q archuseriso

Limitations: Building zfs packages from the docker container does not work. 

Compressing an Arch Linux system installed on a hard drive into a bootable disk image
-------------------------------------------------------------------------------------
Mount the root filesystem partition under a mount point of your choice. Do the same for home in case of a separate home partition.

Synopsis:

    aui-hd2aui [options] <path to root filesystem>

Example with `/dev/sdc2` the root partition and `/dev/sdc3` the home partition of an Arch Linux system installed on a hard drive or a usb flash drive:

    sudo mount /dev/sdc2 /mnt/rootfs
    sudo mount /dev/sdc3 /mnt/rootfs/home
    sudo aui-hd2aui /mnt/rootfs/


Disk partitioning:

    GPT layout
    Partition   Filesystem                 Content
    #1          -                          Stage 2 bootloader for Legacy Bios
    #2          EFI FAT                    Boot
    #3          Ext4                       Squashfs image
    #4          Ext4                       Persistence

Testing
-------
Use `aui-run` for testing a bootable iso image or a bootable usb flash drive in a qemu virtual machine.

Examples:

testing an iso image in bios legacy mode

      aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

testing an iso image in uefi mode

      aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

testing a thumb drive /dev/sdc in bios legacy mode

      sudo aui-run -d /dev/sdc

testing a thumb drive /dev/sdc in uefi mode

      sudo aui-run -u -d /dev/sdc


Archuseriso programs list
-------------------------

* `aui-hd2aui`: Compress an Arch Linux system to a bootable disk image.
* `aui-mkiso`: Build a bootable iso image or a bootable disk image.
* `aui-mkusb`: Create a bootable usb flash drive with data persistence using an archuseriso iso image file.
* `aui-mkinstall`: Install on an external usb flash drive using an archuseriso iso image file.
* `aui-mkhybrid`: Create a hybrid bootable usb flash drive. Combines `aui-mkusb` without persistence and `aui-mkinstall`.
* `aui-buildzfs`: Build ZFS packages using upsteam Openzfs sources.
* `aui-run`: Test iso image and usb flash drive in a qemu virtual machine.

Archuseriso documentation
-------------------------
The archuseriso documentation is limited to this readme. You can refer to the Archiso documentation.

Files of interest:

* profiles/&lt;profile name&gt;/packages.x86_64: list of packages to install
* profiles/&lt;profile name&gt;/profiledef.sh: profile configuration

Known issues
------------
rEFInd Boot Manager may fail on some firmware.
