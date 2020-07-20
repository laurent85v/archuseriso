Description
===========

Templates for building Arch Linux Live ISO images. Tools for creating bootable USB flash drives featuring persistent storage, encryption and regular installation on a usb drive.

Highlights
----------

* easy build
* very fast images (zstd compression)
* live USB creation tool featuring persistent storage
* live USB pacman updates support
* rEFInd boot manager
* LUKS encryption option
* ZFS support option
* language option (cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua)
* package list customization
* user packages support
* Nvidia driver support option
* Optimus hardware support option
* regular installation onto usb device
* samba public folder sharing

Desktop environments
--------------------

* Console
* Cinnamon
* Deepin
* Gnome
* i3
* Kde
* LXQt
* Mate
* Xfce

'console template': english only, no persistence, options related to Xorg ignored.

Hint for gr, rs, ru and ua with two keyboard layouts: press both `Shift keys` together for keyboard layout switch. 

Installation
------------

Install [archuseriso](https://aur.archlinux.org/packages/archuseriso/) available on the AUR 

Or manual install on Arch Linux:

    sudo pacman --needed -S archiso git make syslinux

Clone master repository:

    git clone https://github.com/laurent85v/archuseriso.git

Install:

    sudo make -C archuseriso install

ISO image build
---------------

Command synopsis:

    aui-mkiso <desktop environment> [options]

Xfce desktop with default options:

    sudo aui-mkiso xfce

Kde Plasma desktop, German language plus options for Optimus hardware and additional packages:

    sudo aui-mkiso kde --language de --optimus --addpkg byobu,base-devel

Gnome desktop, additional packages, user packages:

    sudo aui-mkiso gnome --addpkg ntop,vlc --pkgdir ~/mypackages

Two desktop environments, building LXQt ISO, adding i3wm to X sessions available from the display manager:

    sudo aui-mkiso lxqt --addi3wm

When done remove the `work` directory. The ISO image is located in the `out` directory.

Live USB creation
-----------------
The live usb is created with persistent storage support by default.

Command synopsis:

    aui-mkusb <iso image> <usb device> [options]

Example:

    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

Persistence note: for a Live USB created with a different tool the missing persistence feature can be turned on from the live usb (restart needed). The following command executed within the live desktop environment only supports a subset of the standard features, prefer using `aui-mkusb` for creating the live usb to take advantage of full features.

    sudo aui-addpersistence

Live USB partition layout created using `aui-mkusb`:

    GPT
    Partition Type Usage       Size
    #1        Ext4 Squashfs    Image size 
    #2        FAT  Boot        Default 512 MiB
    #3        Ext4 Persistence Default free disk space 


#### aui-mkiso command line help
    Archuseriso tool for building a custom Arch Linux Live ISO image.

    Command synopsis:
    aui-mkiso <desktop environment> [options]

    Options:
    -h, --help                        Command help
    --addi3wm                         Add i3wm to package installation list:
                                      option adding packages i3-gaps,feh,dmenu,i3status,wmctrl
    --addpkg <package1,package2,...>  Comma separated list of additional package names to install
    -C, --confdir <path>              Directory configs (default: /usr/share/archiso/configs)
        --configs-dir <path>
    --embeddir <directory path>       Embed directory contents in the iso image. Directory contents
                                      available from the user\s live session
    -l, --language <language>         Default language. Select one from:
                                      cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua
    --nvidia                          Installs Nvidia graphics driver
    --optimus                         Optimus hardware setup. Intel iGPU used by default,
                                      Nvidia dGPU configured for PRIME render offload
    --pkgdir <path>                   User directory containing package files to install
    -v, --verbose                     Verbose mode
    --zfssupport                      Build userspace utilities and kernel modules packages for the
                                      Zettabyte File System. Then build the iso image with zfs support.

    ISO template configs list:
    console, cinnamon, deepin, gnome, i3, kde, lxqt, mate, xfce

    Build Examples

    Xfce desktop environment with default options:
    sudo aui-mkiso xfce

    Xfce desktop environment, Spanish language, PRIME render offload setup for Optimus hardware:
    sudo aui-mkiso xfce --language es --optimus

    Xfce desktop environment, additional packages from official repositories, plus user packages
    located in directory ~/mypackages. Directory contains pkg.tar.xz or pkg.tar.zst package files:
    sudo aui-mkiso xfce --addpkg byobu,base-devel --pkgdir ~/mypackages

#### aui-mkusb command line help

    Archuseriso tool for creating a Live USB with persistent storage

    Command synopsis:
    aui-mkusb <iso image> <usb device> [options]

    Options:
    -h, --help                Command help
    --encrypt                 Encrypt persistent partition
    --ext4journal             Enable ext4 journal (disabled by default for minimizing disk writes)
    --rawwrite                Raw ISO image write to USB device (dd like mode)
    --sizepart2 integer[g|G]  2nd partition size in GiB (Boot partition, FAT)
    --sizepart3 integer[g|G]  3rd partition size in GiB (persistent partition, Ext4)

    Example using default options:
    sudo aui-mkusb aui-xfce-linux_5_7_10-optimus-0724-x64.iso /dev/sdc

    Example with custom partitioning, unallocated space left for other usages:
    sudo aui-mkusb aui-xfce-linux_5_7_10-i3-zfs-0724-x64.iso /dev/sdc --sizepart2 1G --sizepart3 10G

Regular installation onto a USB drive
-------------------------------------
Persistent installation identical to normal installation on a hard disk drive. No live image installed, no compression, hard disk like installation on a usb drive.

Command synopsis:

    aui-mkinstall <iso image> <usb device> [options]

Example

    sudo aui-mkinstall aui-xfce-linux_5_7_10-0724-x64.iso /dev/sdc
