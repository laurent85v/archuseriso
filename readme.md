Description
===========

Archiso configurations for building alternate Arch Linux live and install iso images.
Live iso images support persistent storage.

Archuseriso Configurations Highlights
-------------------------------------

* Arch Linux repositories only
* iso image build fast and easy
* live images are fast (zstd compressor)
* supports persistent storage
* alternate image for installing Arch Linux
* upstream desktop setup mainly
* build option for default language (de, es, fr, it, pt, ru, tr)
* user may edit package list for installation
* supports installation of pre-built binary packages from the AUR
* supports Nvidia proprietary driver by configuring a
  basic setup (driver not installed by default)
* rEFInd as the default EFI boot manager
* alternate method for installing to disk
  (see install_alternative.txt in /root directory)

Archuseriso Configurations
--------------------------

* Console, english only
* Cinnamon desktop
* Deepin desktop
* Gnome desktop
* Kde desktop
* Mate desktop
* Xfce desktop

Run the config's script `build.sh -h` for available options.

Building an Archuseriso Image
-----------------------------

### Kde Desktop Example

* Install needed packages

        % sudo pacman --needed -S archiso git

* Clone Archuseriso master repository

        % git clone https://github.com/laurent85v/archuseriso.git`

* Install

        % sudo make -C archuseriso install

* Optionally put additional binary packages built from the AUR into the `configs/kde/pkglocal` directory. Here adding some extra tools and ZFS support not available in official Arch repositories.

        % cp byobu-5.127-2-any.pkg.tar.xz inxi-3.0.33-1-any.pkg.tar.xz zfs-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz zfs-utils-0.7.13-1-x86_64.pkg.tar.xz archuseriso/configs/kde/pkglocal

* Launch the build script

        % sudo archuseriso/configs/kde/build.sh

* Building with default language set to German:

        % sudo archuseriso/configs/kde/build.sh -l de

* Using archuseriso wrapper, building the Gnome iso, Spanish language :

        % sudo archuseriso gnome -l es

When done you can remove the `work` directory that was used for building the iso image. The iso image is generated in the `out` directory.

Adding Persistence
------------------
`mkauipers` creates a usb boot device allowing persistent storage. Command synopsys:

        % mkauipers <usb device> <archuseriso image>

Example:

        % sudo mkauipers /dev/sdc archuseriso-xfce-1030-x64.iso

From the Arch boot menu select the line `With Persistent Storage`, all your settings and files are saved to the persistent partition. Enjoy ;)
