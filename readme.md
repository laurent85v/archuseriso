Description
===========

Templates for building Arch Linux Live iso image. Live USB featuring Persistent Storage & Encryption.

Highlights
----------

* easy build
* very fast images (zstd compression)
* live USB creation tool, persistent storage support by default
* live USB full updates support
* rEFInd boot manager
* LUKS encryption option
* partition size option 
* installation tool to USB device
* language build option (cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua)
* packages customization
* user packages support
* supports Nvidia driver (default: disabled)

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

Kde Plasma desktop, German language plus options for Optimus hardware and some additional packages

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

Persistence note: for a Live USB created with a different tool, the missing persistence feature can be turned on from the live environment (Restart needed). Note this tool only supports a subset of the standard features. Use `aui-mkusb` for full features. 

    sudo aui-addpersistence

Live USB partition layout

    GPT
    Partition Type Usage       Size
    #1        Ext4 Squashfs    Image size 
    #2        FAT  Boot        Default 512 MiB
    #3        Ext4 Persistence Default free disk space 
    Free 

#### aui-mkiso command help

    Archuseriso tool for building a custom Arch Linux Live ISO image.

    Command synopsis:
    aui-mkiso <desktop environment> [options]

    Options:
    -h, --help                        Command help
    --addpkg <package1,package2,...>  Comma separated list of additional package names to incluse
    -C, --confdir <path>              Directory configs (default: /usr/share/archiso/configs)
        --configs-dir <path>
    -l, --language <language>         Default language
                                      cz, de, es, fr, gr, hu, it, nl, pl, pt, ro, rs, ru, tr, ua
    --nvidia                          Nvidia graphics driver
    --optimus                         Optimus hardware. Nvidia graphics driver and Xorg setup
                                      for PRIME render offload
    --pkgdir <path>                   User directory containing user package files to include
    -v, --verbose                     Verbose mode

    Desktop environments list:
    console, cinnamon, deepin, gnome, kde, mate, xfce

#### aui-mkusb command help

    Archuseriso tool for creating a Live USB with persistent storage

    Command synopsis:
    aui-mkusb <usb device> <iso image> [options]

    Options:
    -h, --help                Command help
    --encrypt                 Encrypt persistent partition
    --rawwrite                ISO image raw write to USB device (dd like mode)
    --sizepart2 integer[g|G]  FAT partition size in GiB (Boot partition)
    --sizepart3 integer[g|G]  Ext4 partition size in GiB (persistent partition)

    Example:
    aui-mkusb /dev/sdc archuseriso-xfce-0330-x64.iso

Standard installation on a USB flash drive
------------------------------------------
Installation on a USB flash drive. No live image installed, no compression, works like a standard
installation on a hard disk.

Command synopsis:

    aui-mkinstall <usb device> <iso image> [options]

Example

    sudo aui-mkinstall /dev/sdc archuseriso-xfce-0310-x64.iso

Hard disk installation
----------------------
Hard disk installation is not supported however the file `install_alternative.txt` in the live's `/root` directory describes in a few steps how to migrate the live filesystem to a hard disk and how to easily remove the live settings.
