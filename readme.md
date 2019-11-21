Description
===========

Archiso configurations for building your own Arch Linux live iso
with persistent storage support.

Highlights
----------

* easy build
* very fast images (zstd compression)
* live usb supports persistent storage including `pacman -Syu`
* rEFInd boot manager
* alternate image for installing Arch Linux to disk
* language build option (de, es, fr, it, pt, ru, tr)
* package list customization
* supports installation of AUR packages (user own binary packages)
* supports Nvidia driver (disabled by default)

Desktop environments
--------------------

* Console, english only
* Cinnamon
* Deepin
* Gnome
* Kde
* Mate
* Xfce

Building an iso image
---------------------

* Install dependencies

        % sudo pacman --needed -S archiso git

* Clone master repository

        % git clone https://github.com/laurent85v/archuseriso.git`

* Install

        % sudo make -C archuseriso install

* Command synopsys

        % aui-mkiso <desktop environment> [options]

### Kde desktop iso example (Plasma)

        % sudo aui-mkiso kde

Build iso with default language set to German

        % sudo aui-mkiso kde -l de

When done remove the `work` directory. The generated image is located in the `out` directory.

Creating a Live USB
-------------------
Command synopsys

        % aui-mkusb <usb device> <iso image>

Example

        % sudo aui-mkusb /dev/sdc archuseriso-xfce-1130-x64.iso

Creating a Live USB with persistent storage support
---------------------------------------------------
Adds a persistence entry in the boot menu options.
Command synopsys:

        % aui-mkpersistent <usb device> <iso image>

Persistence supports `pacman -Syu` including kernel updates!
All your settings and files are saved to the persistent partition. Enjoy ;)

Installing to disk using copy
-----------------------------
See install_alternative.txt in the live's `/root` directory.
