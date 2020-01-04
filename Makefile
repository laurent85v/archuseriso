V=0.3.6.1

all:

install: install-program install-examples

install-program:
	install -D aui-mkiso $(DESTDIR)/usr/bin/aui-mkiso
	install aui-mkusb $(DESTDIR)/usr/bin/aui-mkusb
	install aui-mkpersistent $(DESTDIR)/usr/bin/aui-mkpersistent

install-examples:
	install -d $(DESTDIR)/usr/share/archiso/
	cp -a --no-preserve=ownership configs $(DESTDIR)/usr/share/archiso/
	cp -a --no-preserve=ownership aui $(DESTDIR)/usr/share/archiso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install install-program dist
