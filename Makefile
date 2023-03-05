BUILD_SRC = source/console.c source/convert.c
ifeq ($(DC),ldc2)
	DFLAGS = '-wi -w -lowmem --cache=.build-cache/'
	DFLAGS_REL = '-wi -w -O -boundscheck=off -release --cache=.build-cache/ --disable-d-passes'
endif
ifeq ($(DC),dmd)
	DFLAGS = '-wi -w -lowmem'
	DFLAGS_REL = '-wi -w -O -boundscheck=off -release'
endif
ifeq ($(DC),gdc)
	DFLAGS = '-Wall'
	DFLAGS_REL = '-O2 -fboundscheck=off -frelease'
endif

main: clean build-libs
	DFLAGS=$(DFLAGS) dub build -v --force
	@-rm *.s

release: clean build-libs
	DFLAGS=$(DFLAGS_REL) dub build -v --force
	@-rm *.s

build-libs:
	$(CC) -Wall -Wextra -Werror -std=c99 -O3 -fPIC -c $(BUILD_SRC)

clean:
	@-rm *.o
	@-rm cmbr

todo:
	@-grep -rnEi 'TODO(O*):' --color=auto --exclude="Makefile" .
