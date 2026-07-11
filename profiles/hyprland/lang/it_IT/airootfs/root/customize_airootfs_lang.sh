#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# it_IT.UTF-8 locales
sed -i 's/#\(it_IT\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Italy, Rome timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
