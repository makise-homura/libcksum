UNITNAME    = cksum
MANSECT     = 3

PREFIX     ?= /usr/local
DESTDIR    ?=
LIBDIR      = $(DESTDIR)$(PREFIX)/lib
INCLUDEDIR  = $(DESTDIR)$(PREFIX)/include
MANDIR      = $(DESTDIR)$(PREFIX)/share/man/man$(MANSECT)

CFLAGS     ?= -g -O3 -Wall

LIBRARYNAME = lib$(UNITNAME)
MANFILE     = $(UNITNAME).$(MANSECT)
HEADERFILE  = $(UNITNAME).h
OBJFILE     = $(UNITNAME).o
STATICLIB   = $(LIBRARYNAME).a
SHAREDLIB   = $(LIBRARYNAME).so

TESTNAME    = test
SHAREDTEST  = $(TESTNAME)_shared
STATICTEST  = $(TESTNAME)_static

.PHONY: all shared static test clean install uninstall

V ?= 0
Q = $(if $(filter-out 0,$(V)),,@)
LOG = $(if $(filter-out 0,$(V)),true,echo -e)

all: static shared $(MANFILE) $(HEADERFILE)

static: $(STATICLIB)

shared: $(SHAREDLIB)

$(SHAREDTEST): $(SHAREDLIB) $(SHAREDTEST).o
	@$(LOG) \\tLD\\t$@
	$(Q)$(CC) -o $@ $^ -L. -l$(UNITNAME) -Wl,-rpath,.

$(STATICTEST): $(STATICLIB) $(STATICTEST).o
	@$(LOG) \\tLD\\t$@
	$(Q)$(CC) -static -o $@ $^ -L. -l$(UNITNAME)

test: $(SHAREDTEST) $(STATICTEST)
	@echo -e \\tTesting with shared library...
	$(Q)./$(SHAREDTEST)
	@echo -e \\tTesting with static library...
	$(Q)./$(STATICTEST)
	@echo -e \\tTests are successful.

$(STATICLIB): $(OBJFILE)
	@$(LOG) \\tAR\\t$@
	$(Q)$(AR) rcs $@ $^

$(SHAREDLIB): $(OBJFILE)
	@$(LOG) \\tLD\\t$@
	$(Q)$(CC) -shared -o $@ $^

$(OBJFILE): $(UNITNAME).c
$(STATICTEST).o: $(TESTNAME).c $(HEADERFILE)
$(SHAREDTEST).o: $(TESTNAME).c $(HEADERFILE)

%.o:
	@$(LOG) \\tCC\\t$@
	$(Q)$(CC) -o $@ -c -fPIC $(CFLAGS) $<

clean:
	rm -f *.o $(SHAREDLIB) $(STATICLIB) $(SHAREDTEST) $(STATICTEST)

install: all
	install -d $(LIBDIR)
	install -d $(INCLUDEDIR)
	install -d $(MANDIR)
	install -m 755 $(SHAREDLIB) $(LIBDIR)
	install -m 644 $(STATICLIB) $(LIBDIR)
	install -m 644 $(HEADERFILE) $(INCLUDEDIR)
	install -m 644 $(MANFILE) $(MANDIR)
	ldconfig

uninstall:
	rm -f $(LIBDIR)/$(SHAREDLIB)
	rm -f $(LIBDIR)/$(STATICLIB)
	rm -f $(INCLUDEDIR)/$(HEADERFILE)
	rm -f $(MANDIR)/$(MANFILE)
