#
# SPDX-License-Identifier: GPL-3.0-or-later

V=0.5.4.1

all:

install: 
	install -d $(DESTDIR)/usr/bin/ $(DESTDIR)/usr/share/archuseriso/
	install -m 0644 LICENSE $(DESTDIR)/usr/share/archuseriso/
	install -m 0644 readme.md $(DESTDIR)/usr/share/archuseriso/
	cp -aT --no-preserve=ownership tools/ $(DESTDIR)/usr/bin/
	cp -aT --no-preserve=ownership archuseriso/ $(DESTDIR)/usr/share/archuseriso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install dist
