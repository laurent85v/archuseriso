#!/bin/sh

# Default X wallpaper
~/.fehbg

# solft link to embeded data dir if any
if [ -d /run/archiso/bootmnt/data ] && [ -f ~/.firstboot ]; then
        ln -s /run/archiso/bootmnt/data "$(xdg-user-dir DESKTOP)"
        rm ~/.firstboot
fi

if [ -f ~/.firstboot ]; then
        rm ~/.firstboot
fi
