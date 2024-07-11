Description
===========

Set of bash script programs for building bootable images of Arch Linux and for creating bootable USB disks or thumb drives of Arch Linux with a desktop environment.

A list of build profiles of the main desktop environments is provided.
 
* AUR repository https://aur.archlinux.org/packages/archuseriso
* ISO hybrid image for DVDs, USB disks and thumb drives http://dl.gnutux.fr/archuseriso/iso
* Disk image for USB disks and thumb drives http://dl.gnutux.fr/archuseriso/img
* iPXE Network Boot image http://dl.gnutux.fr/archuseriso/ipxe
* ZFS packages http://dl.gnutux.fr/archuseriso/zfsonlinux

Archuseriso is based on Archiso https://wiki.archlinux.org/title/Archiso

Features
--------

* 10 desktop environments build profiles
* 16 languages
* live usb with data persistence
* choice of filesystem among Ext4 / Bcachefs / Btrfs / F2FS / ZFS file
* data encryption
* bootloader among syslinux, systemd-boot, Grub and rEFInd
* ISO images and USB disk images
* ZFS support

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

The recommended installation method from the AUR repository [archuseriso](https://aur.archlinux.org/packages/archuseriso/)

Alternative method from the git repository:

      sudo pacman --needed -S git arch-install-scripts bash dosfstools e2fsprogs erofs-utils grub libarchive libisoburn make mtools parted squashfs-tools syslinux
      git clone https://github.com/laurent85v/archuseriso.git
      sudo make -C archuseriso install

Online images at http://dl.gnutux.fr/archuseriso include archuseriso. The live system can be used for building your disk image without having to install archuseriso on your computer.

Notice that archuseriso was designed for Arch Linux and has not been tested on Arch Linux derivatives.

Building iso image and disk image
---------------------------------

Synopsis:

      aui-mkiso [options] <profile path>

Build a Xfce iso image with default options. The following commands are equivalent:

      sudo aui-mkiso xfce
      sudo aui-mkiso /usr/share/archuseriso/profiles/xfce/

Using the Kde Plasma profile with the German language option

      sudo aui-mkiso --language=de kde

Using the Gnome profile with options for adding packages from the Arch Linux repositories and from a user directory containing built AUR packages: 

      sudo aui-mkiso --add-pkg=firefox-ublock-origin,ntop --pkg-dir=~/mypackages gnome

Using the Xfce profile for building a disk image:

      sudo aui-mkiso -m 'img' xfce

Help [Writing Disc Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities) and [Burning DVD](https://wiki.archlinux.org/title/Optical_disc_drive#Burning)



Creating a bootable USB disk or thumb drive with data persistence
-----------------------------------------------------------------
Writes an archuseriso iso image to a usb disk image or thumb drive and enables data persistence on the device.

Synopsis:

    aui-mkusb [options] <iso image> <usb device>

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc

Disk partitioning:

    GPT layout
    Partition   Filesystem                 Content
    #1          Ext4                       Squashfs image
    #2          EFI FAT                    Boot
    #3          Ext4|Bcachefs|Btrfs|F2FS   Persistence

#### Btrfs filesystem details

For the Btrfs filesystem two separate subvolumes are created for data persistence: `rootfs` and `home`.

Creating a bootable USB disk or thumb drive without live mode
-------------------------------------------------------------
Uncompresses an archuseriso iso image to a usb disk or thumb drive, the procedure acting as a standard installation on the device. The live system settings are reset to Arch Linux defaults, except for the journal which remains configured in volatile mode to limit disk I/O. The resulting system on the usb device makes no difference with an standard installation on an internal hard drive with the benefits of removability.

This mode is suitable for external ssd drives mainly. For a thumb drive prefer the live mode with data persistence described in the previous paragraph.

Synopsis:

    aui-mkinstall [options] <iso image> <usb device>

Example:

    sudo aui-mkinstall aui-xfce-linux_5_10_9-0121-x64.iso /dev/sdc


The disk partitioning:

    GPT layout
    Partition   Filesystem type   Content
    #1          EFI FAT           Boot
    #2          Ext4|Brtfs|F2FS   System


Disk image
----------
The GPT disk image format is a bootable USB disk image with data persistence builtin to write directly to a USB disk or thumb drive.

Write the disk image to the usb device, e.g. with a usb key /dev/sdc:

    # cat aui-xfce-linux_6_2_8-fr_FR-0327-x64.img > /dev/sdc

Important notice: as the disk image and the usb disk do not have the same size it is necessary to correct the size of the gpt partition table of the usb disk. parted, fdisk and gparted can do that.

Using parted, notice the 3 dashes of the command option `---pretend-input-tty`:

    echo Fix | sudo parted /dev/sdc ---pretend-input-tty print

The partition size for data persistence of the disk image was configured to only 128 MiB to reduce the size of the disk image created by the original build process. Resize the partition to the desired size for data persistence. gparted can do that easily.

Help [Writing Disk Image](https://wiki.archlinux.org/title/USB_flash_installation_medium#Using_basic_command_line_utilities)

iPXE Network Bootloader
-----------------------
Network boot the latest live Xfce desktop from the Archuseriso server.
 
Pick one of the iPXE image at http://dl.gnutux.fr/archuseriso/ipxe

* aui-ipxe.iso cdrom image for legacy bios
* aui-ipxe.img usb key image for legacy bios
* aui-ipxe-efi.iso cdrom image for x64 uefi platform
* aui-ipxe-efi.img usb key image for x64 uefi platform
* aui-ipxe.efi x64 UEFI binary

Write the relevant image onto the media. Boot the media to load the iPXE boot menu and start the live Xfce desktop. 

For a laptop and Wifi connectivity, use the USB tethering feature of a smartphone for internet connectivity. iPXE native Wifi support is not implemented. 

ZFS support
-----------
To add ZFS support to an iso image two methods are available. The `--zfs-support` command option which builds the zfs packages during the build process of the iso image. Or the `--pkg-dir <path>` command option that points to a directory containing the additional package files to install to the image in .pkg.tar.zst archive format.

Example for the first method:

    sudo aui-mkiso --zfs-support xfce

#### Building ZFS packages

To build the `zfs-utils`, `zfs-linux` and `zfs-linux-headers` packages against the current linux kernel use the `aui-buildzfs` bash script program.

      sudo aui-buildzfs

#### ZFS Root File System

Requires an iso image with zfs support. 

      sudo aui-mkinstall --rootfs=zfs --username=foobar aui-xfce-linux_6_0_9-1123-x64.iso /dev/sdc

Using Docker for running archuseriso
------------------------------------
Download the `Dockerfile` file from the archuseriso sources. From a working directory containing the Dockerfile run the docker build command for building the archuseriso docker image.

    sudo docker build -t archuseriso .

The archuseriso docker image is now created. To run archuseriso in a docker container use:

    sudo docker run --privileged --rm -it archuseriso
    [root@4dd3aab1018b /]# pacman -Q archuseriso

Limitations: Building zfs packages from the docker container does not work. 

Testing
-------
Use `aui-run` for testing a bootable iso image or a bootable usb key in a qemu virtual machine.

Examples:

testing an iso image in bios legacy mode

      aui-run -i aui-xfce-linux_5_10_7-0116-x64.iso

testing an iso image in uefi mode

      aui-run -u -i aui-xfce-linux_5_10_7-0116-x64.iso

testing a thumb drive /dev/sdc in bios legacy mode

      sudo aui-run -d /dev/sdc

testing a thumb drive /dev/sdc in uefi mode

      sudo aui-run -u -d /dev/sdc


Archuseriso bash script programs list
-------------------------------------

* `aui-mkiso` program for building a bootable iso image or a bootable disk image using a build profile.
* `aui-mkusb` program for creating a bootable USB disk or thumb drive with data persistence.
* `aui-mkinstall` program for creating a bootable USB disk or thumb drive acting as a standard installed Arch Linux system on a external hard drive.
* `aui-mkhybrid` program for creating a bootable USB drive or thumb drive combining the live feature and the installed system on the same media.
* `aui-buildzfs` program for building the ZFS packages from the upsteam Openzfs sources.
* `aui-run` program for testing an bootable iso image or a bootable usb disk in a qemu virtual machine.

Archuseriso documentation
-------------------------
The archuseriso documentation is limited to this readme. You can refer to the Archiso documentation which describes the details of the iso image architecture as most also applies to archuseriso which is a derivative.

Files of interest:

* profiles/&lt;profile name&gt;/packages.x86_64: list of packages to install
* profiles/&lt;profile name&gt;/profiledef.sh: profile configuration

Known issues
------------
rEFInd Boot Manager may fail on some firmware.
