Description
===========

Archuseriso  
Archiso user configs for creating alternate Arch Linux live and install iso images.

Archuseriso configs highlights
------------------------------

* Arch Linux repositories only
* live system created with up-to-date packages,
  including latest kernel, drivers
* upstream desktop setup, limited customization
* build option for alternate language (de, es, fr, it, pt)
* user may edit package list, add/remove packages
* support installation of user custom packages
  (user own packages created from AUR)
* support Plymouth graphical boot splash screen
  (needs plymouth AUR package)
* support Nvidia proprietary driver by configuring a
  basic setup (driver not installed by default)
* rEFInd as the default EFI boot manager
* alternate installation image for installing Arch Linux
* alternate method available for installing
  (see install_alternative.txt in /root directory)

Archuseriso configs
-------------------

* configs/console  Console mode only, english only
* configs/gnome    Gnome desktop
* configs/kde      Kde desktop

Run config's script `build.sh -h` for available build script options.

Building an Archuseriso image
=============================

As an example building the Kde desktop
--------------------------------------

* Install Archuseriso needed packages

        % sudo pacman --needed -S archiso git

* Clone Archuseriso master repository

        % git clone https://github.com/laurent85v/archuseriso.git`

* Install

        % sudo make -C archuseriso install

* Optionally put your AUR .pkg.tar.xz package files into the `configs/kde/pkglocal` directory. Here adding some extra tools, plymouth splash screen and ZFS support not available in the official Arch repositories

        % cp byobu-5.127-2-any.pkg.tar.xz inxi-3.0.33-1-any.pkg.tar.xz plymouth-0.9.4-4-x86_64.pkg.tar.xz spl-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz timeshift-19.01-2-x86_64.pkg.tar.xz zfs-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz zfs-utils-0.7.13-1-x86_64.pkg.tar.xz archuseriso/configs/kde/pkglocal

* Launch the build script

        % sudo archuseriso/configs/kde/build.sh

* Building with default language set to either German, Spanish, French, Italian, Portuguese:

        % sudo archuseriso/configs/kde/build.sh -l de
        % sudo archuseriso/configs/kde/build.sh -l es
        % sudo archuseriso/configs/kde/build.sh -l fr
        % sudo archuseriso/configs/kde/build.sh -l it
        % sudo archuseriso/configs/kde/build.sh -l pt

* Using the archuseriso program interface, building the gnome iso, Italian language :

        % sudo archuseriso gnome -l it

When done you can remove the `work` directory that was used for building the iso image. The iso image is generated in the `out` directory.
