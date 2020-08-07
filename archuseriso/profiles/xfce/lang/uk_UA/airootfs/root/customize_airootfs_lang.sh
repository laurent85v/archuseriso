#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# uk_UA.UTF-8 locales
sed -i 's/#\(uk_UA\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Ukraine, Kiev timezone
ln -sf /usr/share/zoneinfo/Europe/Kiev /etc/localtime
