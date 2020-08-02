#
# SPDX-License-Identifier: GPL-3.0-or-later

V=

all:

install: install-program install-profiles

install-program:
	install -D archuseriso/aui-mkiso $(DESTDIR)/usr/bin/aui-mkiso
	install archuseriso/aui-mkusb $(DESTDIR)/usr/bin/aui-mkusb
	install archuseriso/aui-mkinstall $(DESTDIR)/usr/bin/aui-mkinstall
	install archuseriso/aui-build_zfs_packages $(DESTDIR)/usr/bin/aui-build_zfs_packages

install-profiles:
	install -d $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership build.sh $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership profiles $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership aui $(DESTDIR)/usr/share/archuseriso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install install-profiles dist
