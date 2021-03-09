#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# cs_CZ.UTF-8 locales
sed -i 's/#\(cs_CZ\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Czechia, Prague timezone
ln -sf /usr/share/zoneinfo/Europe/Prague /etc/localtime
