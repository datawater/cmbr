@echo off
rem Launch this in an msvc enabled console

set CFLAGS=/nologo /W4 /std:c11
set LIBSRC=src/console.c src/convert.c

@echo on
cl /c %CFLAGS% %LIBSSRC%
ren *.obj *.o