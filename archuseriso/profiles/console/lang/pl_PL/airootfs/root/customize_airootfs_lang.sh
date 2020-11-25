#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# pl_PL.UTF-8 locales
sed -i 's/#\(pl_PL\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Poland, Warsaw timezone
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
