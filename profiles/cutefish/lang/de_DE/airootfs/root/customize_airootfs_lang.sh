#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# de_DE.UTF-8 locales
sed -i 's/#\(de_DE\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Germany, Berlin timezone
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
