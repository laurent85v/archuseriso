#
# SPDX-License-Identifier: GPL-3.0-or-later

V=0.4.4.3

all:

install: install-program install-examples

install-program:
	install -D archuseriso/aui-mkiso $(DESTDIR)/usr/bin/aui-mkiso
	install archuseriso/aui-mkusb $(DESTDIR)/usr/bin/aui-mkusb
	install archuseriso/aui-mkinstall $(DESTDIR)/usr/bin/aui-mkinstall
	install archuseriso/aui-build_zfs_packages $(DESTDIR)/usr/bin/aui-build_zfs_packages

install-examples:
	install -d $(DESTDIR)/usr/share/archiso/
	cp -a --no-preserve=ownership configs $(DESTDIR)/usr/share/archiso/
	cp -a --no-preserve=ownership aui $(DESTDIR)/usr/share/archiso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install install-program dist
