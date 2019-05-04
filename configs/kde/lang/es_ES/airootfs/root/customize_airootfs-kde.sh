
#!/bin/bash

set -e -u

# Run releng's defaults
/root/customize_airootfs.sh

# es_ES.UTF8 locales
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
    echo 'xrandr --setprovideroutputsource modesetting NVIDIA-0' >> /usr/share/sddm/scripts/Xsetup
    echo 'xrandr --auto' >> /usr/share/sddm/scripts/Xsetup
fi

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

# Set sddm display-manager
# Using sddm-plymouth when available
if [[ -e /usr/lib/systemd/system/sddm-plymouth.service ]]; then
    ln -s /usr/lib/systemd/system/sddm-plymouth.service /etc/systemd/system/display-manager.service
else
    ln -s /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service
fi

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,sys,video,wheel" -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers
