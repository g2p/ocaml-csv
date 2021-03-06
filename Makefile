PKGNAME	    = $(shell oasis query name)
PKGVERSION  = $(shell oasis query version)
PKG_TARBALL = $(PKGNAME)-$(PKGVERSION).tar.gz

DISTFILES   = LICENSE.txt INSTALL.txt README.md _oasis \
  _tags Makefile setup.ml csv.install pp.ml \
  $(filter-out %~, $(wildcard src/*) $(wildcard examples/*) $(wildcard tests/*))

WEB = san@math.umons.ac.be:~/public_html/software/csv/

.PHONY: all byte native configure doc test install uninstall reinstall \
  upload-doc

all byte native: configure opam
	ocaml setup.ml -build

configure: setup.ml
	ocaml $< -configure --enable-tests --enable-lwt

setup.ml: _oasis
	oasis setup -setup-update dynamic

test doc install uninstall reinstall: all
	ocaml setup.ml -$@

upload-doc: doc
	scp -C -p -r _build/API.docdir $(WEB)

csvtool: all
	./csvtool.native pastecol 1-3 2,1,2 \
	  tests/testcsv9.csv tests/testcsv9.csv

opam csv.install: _oasis
	oasis2opam --local -y

dist tar: setup.ml opam
	@ if [ -z "$(PKGNAME)" ]; then echo "PKGNAME not defined"; exit 1; fi
	@ if [ -z "$(PKGVERSION)" ]; then \
		echo "PKGVERSION not defined"; exit 1; fi
	mkdir $(PKGNAME)-$(PKGVERSION)
	cp -r --parents $(DISTFILES) $(PKGNAME)-$(PKGVERSION)/
#	Generate a setup.ml independent of oasis
	cd $(PKGNAME)-$(PKGVERSION) && oasis setup
	tar -zcvf $(PKG_TARBALL) $(PKGNAME)-$(PKGVERSION)
	$(RM) -rf $(PKGNAME)-$(PKGVERSION)

upload-tar: tar
	scp -C -p -r $(PKG_TARBALL) $(WEB)

web: doc
	$(MAKE) -C doc $@

.PHONY: clean distclean
clean::
	ocaml setup.ml -clean
	$(RM) $(PKG_TARBALL) setup.data

distclean:
	ocaml setup.ml -distclean
	$(RM) $(wildcard *.ba[0-9] *.bak *~ *.odocl)
