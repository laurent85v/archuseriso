#
# SPDX-License-Identifier: GPL-3.0-or-later

V=

all:

install: 
	install -D archuseriso/aui-mkiso $(DESTDIR)/usr/bin/aui-mkiso
	install archuseriso/aui-mkusb $(DESTDIR)/usr/bin/aui-mkusb
	install archuseriso/aui-mkinstall $(DESTDIR)/usr/bin/aui-mkinstall
	install archuseriso/aui-build_zfs_packages $(DESTDIR)/usr/bin/aui-build_zfs_packages
	install -d $(DESTDIR)/usr/share/archuseriso/
	install LICENSE $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership airootfs $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership aui $(DESTDIR)/usr/share/archuseriso/
	install build.sh $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership efiboot $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership isolinux $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership lang $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership profiles $(DESTDIR)/usr/share/archuseriso/
	install readme.md $(DESTDIR)/usr/share/archuseriso/
	cp -a --no-preserve=ownership syslinux $(DESTDIR)/usr/share/archuseriso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install install-profiles dist
