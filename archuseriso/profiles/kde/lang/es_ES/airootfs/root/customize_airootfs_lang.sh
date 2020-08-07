#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

# es_ES.UTF-8 locales
sed -i 's/#\(es_ES\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Spain, Madrid timezone
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
