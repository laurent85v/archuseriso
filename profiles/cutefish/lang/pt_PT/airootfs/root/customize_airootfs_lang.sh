#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# pt_PT.UTF-8 locales
sed -i 's/#\(pt_PT\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Portugal, Lisbon timezone
ln -sf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime
