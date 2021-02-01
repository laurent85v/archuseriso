#
# SPDX-License-Identifier: GPL-3.0-or-later

all:

install: 
	install -d $(DESTDIR)/usr/bin/ $(DESTDIR)/usr/share/archuseriso/
	install -m 0644 AUTHORS.rst $(DESTDIR)/usr/share/archuseriso/
	install -m 0644 LICENSE $(DESTDIR)/usr/share/archuseriso/
	install -m 0644 readme.md $(DESTDIR)/usr/share/archuseriso/
	cp -aT --no-preserve=ownership archuseriso/ $(DESTDIR)/usr/bin/
	cp -aT --no-preserve=ownership profiles/ $(DESTDIR)/usr/share/archuseriso/profiles/

.PHONY: install
