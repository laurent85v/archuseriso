Description
===========

Templates for building Arch Linux Live ISO images. Tools for creating bootable USB flash drives featuring persistent storage, encryption and regular installation.

Highlights
----------

* easy build
* very fast images (zstd compression)
* live USB creation tool featuring persistent storage
* live USB update support
* rEFInd boot manager
* LUKS encryption option
* partition size option
* language option (cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua)
* package list customization
* user packages support
* Nvidia driver support (default: disabled)
* Optimus hardware support (default: disabled)
* regular installation onto usb device

Desktop environments
--------------------

* Console
* Cinnamon
* Deepin
* Gnome
* Kde
* Mate
* Xfce

`console`: english only, no persistence.

Hint for gr, rs, ru and ua with two keyboard layouts: press both `Shift keys` together for keyboard layout switch. 

Installation
------------

Install [archuseriso](https://aur.archlinux.org/packages/archuseriso/) available on the AUR 

Or manual install on Arch Linux:

    sudo pacman --needed -S archiso git syslinux

Clone master repository

    git clone https://github.com/laurent85v/archuseriso.git

Install

    sudo make -C archuseriso install

ISO image build
---------------

Command synopsis

    aui-mkiso <desktop environment> [options]

Xfce desktop with default options

    sudo aui-mkiso xfce

Kde Plasma desktop, German language plus options for Optimus hardware and additional packages

    sudo aui-mkiso kde --language de --optimus --addpkg byobu,base-devel

Gnome desktop, additional packages, user packages

    sudo aui-mkiso gnome --addpkg ntop,vlc --pkgdir ~/mypackages

When done remove the `work` directory. ISO image is located in the `out` directory.

Live USB creation
-----------------
The live usb is created with persistent storage support by default.

Command synopsis

    aui-mkusb <usb device> <iso image> [options]

Example

    sudo aui-mkusb /dev/sdc archuseriso-xfce-0330-x64.iso

Persistence note: for a Live USB created with a different tool the missing persistence feature can be turned on from the live usb (restart needed). The following command executed within the live desktop environment only supports a subset of the standard features, prefer using `aui-mkusb` for creating the live usb to take advantage of full features.

    sudo aui-addpersistence

Live USB partition layout

    GPT
    Partition Type Usage       Size
    #1        Ext4 Squashfs    Image size 
    #2        FAT  Boot        Default 512 MiB
    #3        Ext4 Persistence Default free disk space 


#### aui-mkiso command help
    Archuseriso tool for building a custom Arch Linux Live ISO image.

    Command synopsis:
    aui-mkiso <desktop environment> [options]

    Options:
    -h, --help                        Command help
    --addpkg <package1,package2,...>  Comma separated list of additional package names to install
    -C, --confdir <path>              Directory configs (default: /usr/share/archiso/configs)
        --configs-dir <path>
    -l, --language <language>         Default language. Select one from:
                                      cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua
    --nvidia                          Installs Nvidia graphics driver
    --optimus                         Optimus hardware setup. Intel iGPU used by default,
                                      Nvidia dGPU configured for PRIME render offload
    --pkgdir <path>                   User directory containing package files to install
    -v, --verbose                     Verbose mode

    ISO config list:
    console, cinnamon, deepin, gnome, kde, mate, xfce

    Build Examples

    Xfce desktop environment with default options:
    sudo aui-mkiso xfce

    Xfce desktop environment, Spanish language, PRIME render offload setup for Optimus hardware:
    sudo aui-mkiso xfce --language es --optimus

    Xfce desktop environment, additional packages from official repositories, plus user packages
    located in directory ~/mypackages. Directory contains pkg.tar.xz or pkg.tar.zst package files:
    sudo aui-mkiso xfce --addpkg byobu,base-devel --pkgdir ~/mypackages

#### aui-mkusb command help

    Archuseriso tool for creating a Live USB with persistent storage

    Command synopsis:
    aui-mkusb <usb device> <iso image> [options]

    Options:
    -h, --help                Command help
    --encrypt                 Encrypt persistent partition
    --ext4journal             Enable ext4 journal (disabled by default for minimizing disk writes)
    --rawwrite                Raw ISO image write to USB device (dd like mode)
    --sizepart2 integer[g|G]  2nd partition size in GiB (Boot partition, FAT)
    --sizepart3 integer[g|G]  3rd partition size in GiB (persistent partition, Ext4)

    Example using default options:
    sudo aui-mkusb /dev/sdc archuseriso-xfce-0330-x64.iso

    Example with custom partitioning, unallocated space left for other usages:
    sudo aui-mkusb /dev/sdc archuseriso-xfce-0330-x64.iso --sizepart2 1G --sizepart3 10G

Regular installation onto a USB flash drive
-------------------------------------------
Persistent installation identical to normal installation to hard disk drive. No live image installed, no compression, works like a standard
installation on a hard disk.

Command synopsis:

    aui-mkinstall <usb device> <iso image> [options]

Example

    sudo aui-mkinstall /dev/sdc archuseriso-xfce-0310-x64.iso

Hard disk installation
----------------------
Hard disk installation is not supported however the file `install_alternative.txt` in the live's `/root` directory describes in a few steps how to migrate the live filesystem to a hard disk and how to easily remove the live settings.
