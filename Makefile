#
# SPDX-License-Identifier: GPL-3.0-or-later

PREFIX ?= /usr/local
BIN_DIR=$(DESTDIR)$(PREFIX)/bin
DOC_DIR=$(DESTDIR)$(PREFIX)/share/doc/archuseriso
PROFILE_DIR=$(DESTDIR)$(PREFIX)/share/archuseriso

DOC_FILES=AUTHORS.rst LICENSE readme.md

all:

install: install-scripts install-pkgbuild install-profiles install-doc

install-scripts:
	install -vD -m 755 archuseriso/aui-mkiso              -t $(BIN_DIR)/
	install -vD -m 755 archuseriso/aui-mkusb              -t $(BIN_DIR)/
	install -vD -m 755 archuseriso/aui-mkhybrid           -t $(BIN_DIR)/
	install -vD -m 755 archuseriso/aui-mkinstall          -t $(BIN_DIR)/
	install -vD -m 755 archuseriso/aui-run                -t $(BIN_DIR)/
	install -vD -m 755 archuseriso/aui-buildzfs           -t $(BIN_DIR)/

install-pkgbuild:
	install -d -m 755 $(PROFILE_DIR)
	cp -a --no-preserve=ownership pkgbuild $(PROFILE_DIR)/

install-profiles:
	install -d -m 755 $(PROFILE_DIR)
	cp -a --no-preserve=ownership profiles $(PROFILE_DIR)/

install-doc:
	install -vD -m 644 $(DOC_FILES) -t $(DOC_DIR)/

.PHONY: install install-scripts install-profiles install-doc
