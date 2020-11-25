#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# sr_RS locales
sed -i 's/#\(sr_RS UTF-8\)/\1/' /etc/locale.gen
sed -i 's/#\(sr_RS@latin UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Serbia, Belgrade timezone
ln -sf /usr/share/zoneinfo/Europe/Belgrade /etc/localtime
