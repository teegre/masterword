PROGNAME  ?= masterword
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
LIBDIR    ?= $(PREFIX)/lib
SHAREDIR  ?= $(PREFIX)/share
CONFIGDIR ?= /etc/$(PROGNAME)

.PHONY: install
install: src/mw
	install -d  $(BINDIR)
	install -m755  src/mw.sh $(BINDIR)/mw
	install -Dm644 src/lib/*.* -t $(LIBDIR)/$(PROGNAME)
	install -Dm644 data/fr_fr_wordlist -t $(CONFIGDIR)
	install -Dm644 LICENSE -t $(SHAREDIR)/licenses/$(PROGNAME)
	rm src/mw

.PHONY: uninstall
uninstall:
	rm $(BINDIR)/mw
	rm -rf $(LIBDIR)/$(PROGNAME)
	rm -rf $(CONFIGDIR)
	rm -rf $(SHAREDIR)/licenses/$(PROGNAME)
