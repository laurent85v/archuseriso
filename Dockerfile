FROM archlinux
RUN sh -c "pacman-key --init && \
           pacman --noconfirm -Suvy && \
           pacman --noconfirm -S wget && \
           curl -OJ http://dl.gnutux.fr/archuseriso/packages/archuseriso-0.8-1-any.pkg.tar.zst && \
           pacman --noconfirm -U archuseriso-0.8-1-any.pkg.tar.zst"
