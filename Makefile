PREFIX ?= /usr
DESTDIR ?=
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

ZSHCOMP_PATH ?= $(DESTDIR)$(PREFIX)/share/zsh/site-functions

all:
	install -m 0644 -v man/eii.1 "$(DESTDIR)$(MANDIR)/man1/eii.1"
	install -m 0644 -v src/completion/eii.zsh-completion "$(ZSHCOMP_PATH)/_eii"
	install -m 0755 -v src/eii.sh "$(DESTDIR)$(BINDIR)/eii"
