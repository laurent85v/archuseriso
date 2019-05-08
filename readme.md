Description
===========

Archuseriso  
Archiso user configs for creating alternate Arch Linux live and install iso images.

Archuseriso configs highlights
------------------------------

* using Arch Linux repositories only
* live system created with up-to-date packages,
  including latest kernel, drivers
* no desktop customization, using upstream defaults
* build option for alternate language (de, es, fr, it, pt)
* user may edit package list, add/remove packages
* support installation of user custom packages
  (user own packages created from AUR)
* support Plymouth graphical boot splash screen
  (needs plymouth AUR package)
* support Nvidia proprietary driver by configuring a
  basic setup (driver not installed by default)
* use rEFInd as the default EFI boot manager
* alternate installation image for installing Arch Linux
* alternate method available for installating
  (see install_alternative.txt in /root directory)

Archuseriso configs
-------------------

* configs/console  Console spin
* configs/gnome    Gnome desktop spin
* configs/kde      Kde desktop spin

Run config's script `build.sh -h` for available build script options.

Building an Archuseriso image
=============================

As an example building the Kde desktop spin
-------------------------------------------

* Install Archuseriso needed packages

        % sudo pacman --needed -S archiso git

* Clone Archuseriso master repository

        % git clone https://github.com/laurent85v/archuseriso.git`

* Optionally put your AUR .pkg.tar.xz package files into the `configs/kde/pkglocal` directory. Here adding some extra tools, plymouth splash screen and ZFS support not available in the official Arch repositories

        % cp byobu-5.127-2-any.pkg.tar.xz inxi-3.0.33-1-any.pkg.tar.xz plymouth-0.9.4-4-x86_64.pkg.tar.xz spl-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz timeshift-19.01-2-x86_64.pkg.tar.xz zfs-linux-0.7.13_5.0.7.arch1.1-1-x86_64.pkg.tar.xz zfs-utils-0.7.13-1-x86_64.pkg.tar.xz archuseriso/configs/kde/pkglocal

* Launch the build script

        % sudo archuseriso/configs/kde/build.sh

When done you can remove the `work` directory that was used for building the iso image. The iso image is generated in the `out` directory.
