Description
===========

Archiso configurations for building Arch Linux live iso with
persistent storage support.

Highlights
----------

* iso build fast and easy
* live images are fast (zstd compression)
* live usb supports persistent storage
* alternate image for installing Arch Linux
* build option for default language (de, es, fr, it, pt, ru, tr)
* user may edit package list
* supports installation of pre-built binary packages from the AUR
* supports Nvidia proprietary driver (default: disabled)
* rEFInd boot manager

Configurations
--------------

* Console, english only
* Cinnamon desktop
* Deepin desktop
* Gnome desktop
* Kde desktop
* Mate desktop
* Xfce desktop

Run the config's script `build.sh -h` for help.

Building an iso image
---------------------

### Kde Desktop Example

* Install needed packages

        % sudo pacman --needed -S archiso git

* Clone Archuseriso master repository

        % git clone https://github.com/laurent85v/archuseriso.git`

* Install

        % sudo make -C archuseriso install

* Optionally put additional binary packages built from the AUR into the `configs/kde/pkglocal` directory.

        % cp zfs-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz zfs-utils-0.7.13-1-x86_64.pkg.tar.xz archuseriso/configs/kde/pkglocal

* Running the build script:

        % sudo archuseriso/configs/kde/build.sh

* Building with default language set to German:

        % sudo archuseriso/configs/kde/build.sh -l de

* Using the `archuseriso` wrapper, building Gnome iso, Spanish language :

        % sudo archuseriso gnome -l es

When done remove the `work` directory. The generated iso image is located the `out` directory.

Creating a Live USB with Persistent Storage
-------------------------------------------
Command synopsys:

        % mkauipers <usb device> <archuseriso image>

Example:

        % sudo mkauipers /dev/sdc archuseriso-xfce-1030-x64.iso

From the Arch boot menu select the line `With Persistent Storage`, all your settings and files are saved to the persistent partition. Enjoy ;)

Installing to disk using copy
-----------------------------
See install_alternative.txt in the live's `/root` directory.
