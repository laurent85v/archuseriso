#!/usr/bin/env bash

set -e -u

# ru_RU.UTF-8 locales
sed -i 's/#\(ru_RU\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Russia, Moscow timezone
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
