V=0.3.1

all:

install: install-program install-examples

install-program:
	install -D -m 755 archuseriso $(DESTDIR)/usr/bin/archuseriso
	install -D -m 755 mkauipers $(DESTDIR)/usr/bin/mkauipers

install-examples:
	install -d -m 755 $(DESTDIR)/usr/share/archiso/
	cp -a --no-preserve=ownership configs $(DESTDIR)/usr/share/archiso/

dist:
	git archive --format=tar --prefix=archuseriso-$(V)/ v$(V) | gzip -9 > archuseriso-$(V).tar.gz
	gpg --detach-sign --use-agent archuseriso-$(V).tar.gz

.PHONY: install install-program dist
