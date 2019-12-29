#!/bin/bash

set -e -u

# Run releng's defaults
/root/customize_airootfs.sh

# es_ES.UTF-8 locales
sed -i 's/#\(es_ES\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Spain, Madrid timezone
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# nsswitch.conf settings
# * Avahi : add 'mdns_minimal'
# * Winbind : add 'wins'
sed -i '/^hosts:/ {
        s/\(resolve\)/mdns_minimal \[NOTFOUND=return\] \1/
        s/\(dns\)$/\1 wins/ }' /etc/nsswitch.conf

# Test nvidia package installed
# Nvidia GPU proprietary driver setup
if $(pacman -Qsq '^nvidia$' > /dev/null 2>&1); then
    sed -i 's|^#\(display-setup-script=\)$|\1/etc/lightdm/display_setup.sh|' /etc/lightdm/lightdm.conf
fi

# Lightdm display-manager
# * live user autologin
# * Deepin theme
# * background color
sed -i 's/^#\(autologin-user=\)$/\1live/
        s/^#\(autologin-session=\)$/\1deepin/' /etc/lightdm/lightdm.conf
sed -i 's/^#\(background=\)$/\1#204a87/
        s/^#\(theme-name=\)$/\1Deepin/
        s/^#\(icon-theme-name=\)$/\1Deepin/' /etc/lightdm/lightdm-gtk-greeter.conf

# Enable service when available
{ [[ -e /usr/lib/systemd/system/acpid.service                ]] && systemctl enable acpid.service;
  [[ -e /usr/lib/systemd/system/avahi-dnsconfd.service       ]] && systemctl enable avahi-dnsconfd.service;
  [[ -e /usr/lib/systemd/system/bluetooth.service            ]] && systemctl enable bluetooth.service;
  [[ -e /usr/lib/systemd/system/NetworkManager.service       ]] && systemctl enable NetworkManager.service;
  [[ -e /usr/lib/systemd/system/nmb.service                  ]] && systemctl enable nmb.service;
  [[ -e /usr/lib/systemd/system/org.cups.cupsd.service       ]] && systemctl enable org.cups.cupsd.service;
  [[ -e /usr/lib/systemd/system/smb.service                  ]] && systemctl enable smb.service;
  [[ -e /usr/lib/systemd/system/systemd-timesyncd.service    ]] && systemctl enable systemd-timesyncd.service;
  [[ -e /usr/lib/systemd/system/winbind.service              ]] && systemctl enable winbind.service;
} > /dev/null 2>&1

# Set lightdm display-manager
ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,sys,video,wheel" -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers

# Create autologin group
# add live to autologin group
groupadd -r autologin
gpasswd -a live autologin

# Deepin lightdm greeter broken
# Commenting out configuration file
if [[ -e /usr/share/lightdm/lightdm.conf.d/60-deepin.conf ]]; then
    sed -i 's/^/#/' /usr/share/lightdm/lightdm.conf.d/60-deepin.conf
fi

# Deepin disable dde-dock plugin overlay warning
if [[ -e /usr/lib/dde-dock/plugins/liboverlay-warning.so ]]; then
    mv /usr/lib/dde-dock/plugins/liboverlay-warning.so{,-disabled_by_archuseriso}
fi

# Update schemas
glib-compile-schemas /usr/share/glib-2.0/schemas/
