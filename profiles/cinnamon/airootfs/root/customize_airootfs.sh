#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# nsswitch.conf settings
# * Avahi : add 'mdns_minimal'
# * Winbind : add 'wins'
sed -i '/^hosts:/ {
        s/\(resolve\)/mdns_minimal \[NOTFOUND=return\] \1/
        s/\(dns\)$/\1 wins/ }' /etc/nsswitch.conf

# Optimus setup
if grep -q 'optimus' /version; then
    sed -i 's|^#\(display-setup-script=\)$|\1/etc/lightdm/display_setup.sh|' /etc/lightdm/lightdm.conf
fi

# Lightdm display-manager
# * live user autologin
# * Adwaita theme
# * background color
sed -i 's/^#\(autologin-user=\)$/\1live/
        s/^#\(autologin-session=\)$/\1cinnamon/' /etc/lightdm/lightdm.conf
sed -i 's/^#\(background=\)$/\1#232627/
        s/^#\(theme-name=\)$/\1Adapta/
        s/^#\(icon-theme-name=\)$/\1Adapta/' /etc/lightdm/lightdm-gtk-greeter.conf

# missing link pointing to default vncviewer
ln -s /usr/bin/gvncviewer /usr/local/bin/vncviewer

# Enable service when available
{ [[ -e /usr/lib/systemd/system/avahi-dnsconfd.service       ]] && systemctl enable avahi-dnsconfd.service;
  [[ -e /usr/lib/systemd/system/bluetooth.service            ]] && systemctl enable bluetooth.service;
  [[ -e /usr/lib/systemd/system/NetworkManager.service       ]] && systemctl enable NetworkManager.service;
  [[ -e /usr/lib/systemd/system/nmb.service                  ]] && systemctl enable nmb.service;
  [[ -e /usr/lib/systemd/system/cups.service                 ]] && systemctl enable cups.service;
  [[ -e /usr/lib/systemd/system/smb.service                  ]] && systemctl enable smb.service;
  [[ -e /usr/lib/systemd/system/winbind.service              ]] && systemctl enable winbind.service;
} > /dev/null 2>&1

# Set lightdm display-manager
ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G 'wheel' -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers

# Create autologin group
# add live to autologin group
groupadd -r autologin
gpasswd -a live autologin

# disable systemd-networkd.service
# we have NetworkManager for managing network interfaces
[[ -e /etc/systemd/system/multi-user.target.wants/systemd-networkd.service ]] && rm /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
[[ -e /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service ]] && rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
[[ -e /etc/systemd/system/sockets.target.wants/systemd-networkd.socket ]] && rm /etc/systemd/system/sockets.target.wants/systemd-networkd.socket
