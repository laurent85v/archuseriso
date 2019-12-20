Description
===========

Build your own Arch Linux Live iso image. Features Persistent Storage, Encryption.

Highlights
----------

* easy build
* very fast images (zstd compression)
* live USB with persistent storage, supports full updates
* LUKS encryption option for persistent partition
* rEFInd boot manager
* language build option (de, es, fr, it, pt, ru, tr)
* user customization
* supports installation of AUR packages (user own binary packages)
* supports Nvidia driver (disabled by default)

Desktop environments
--------------------

* Console
* Cinnamon
* Deepin
* Gnome
* Kde
* Mate
* Xfce

`console` config english only, no persistence.

ISO image build
---------------

Install dependencies

    sudo pacman --needed -S archiso git

Clone master repository

    git clone https://github.com/laurent85v/archuseriso.git

Install

    sudo make -C archuseriso install

Command synopsis

    aui-mkiso <desktop environment> [options]

### Kde desktop iso example (Plasma)

    sudo aui-mkiso kde

Build with default language set to German

    sudo aui-mkiso kde -l de

When done remove the `work` directory. The generated image is located in the `out` directory.

Live USB creation
-----------------
Command synopsis

    aui-mkusb <usb device> <iso image> [options]

Example

    sudo aui-mkusb /dev/sdc archuseriso-xfce-1130-x64.iso

Live USB with persistent storage support
----------------------------------------
Adds a persistence entry to the boot menu options.
Command synopsis:

    aui-mkpersistent <usb device> <iso image> [options]

Example Live USB with persistent partition encrypted

    sudo aui-mkpersistent /dev/sdc archuseriso-xfce-1210-x64.iso --encrypt

Persistence supports full updates `pacman -Syu` including kernel updates!
All your settings and files are saved to the persistent partition. Enjoy ;)

User Customization
-------------------
Copy a config to your own working directory:

    cp -LrT /usr/share/archiso/configs/<iso config> [path/]<config> 2> /dev/null
    cp -rT /usr/share/archiso/aui [path/]<config>/aui

Example:

    cp -LrT /usr/share/archiso/configs/xfce ~/sources/xfce 2> /dev/null
    cp -rT /usr/share/archiso/aui ~/sources/xfce/aui

Customize packages\*.x86_64 files. To build the iso image run:

    sudo aui-mkiso xfce --configs-path ~/sources

Hard disk installation
----------------------
Hard disk installation is not supported however the file `install_alternative.txt` in the live's `/root` directory describes in a few steps how to migrate the live filesystem to a hard disk and how to easily remove the live settings.
