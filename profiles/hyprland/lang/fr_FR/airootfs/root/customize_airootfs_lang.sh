#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# fr_FR.UTF-8 locales
sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# France, Paris timezone
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
