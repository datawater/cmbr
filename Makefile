BUILD_SRC = source/console.c source/convert.c

main: clean build-libs
	DFLAGS='-wi -w -lowmem' dub build -v

release: clean build-libs
	DFLAGS='-wi -w -O -boundscheck=off -release' dub build -v

build-libs:
	$(CC) -Wall -Wextra -Werror -std=c99 -O3 -fPIC -c $(BUILD_SRC)

clean:
	@-rm *.o
	@-rm cmbr

todo:
	@-grep -rnEi 'TODO(O*):' --color=auto --exclude="Makefile" .