/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

#define RESET    -1
#define CLEAR    31

#define FBLACK    0
#define FGRAY     8
#define FGREY     8
#define FRED      1
#define FLRED     9
#define FGREEN    2
#define FLGREEN   10
#define FYELLOW   3
#define FLYELLOW  11
#define FBLUE     4
#define FLBLUE    12
#define FMAGENTA  5
#define FPINK     5
#define FLMAGENTA 13
#define FLPINK    13
#define FCYAN     6
#define FLCYAN    14
#define FWHITE    7
#define FLWHITE   15

#define BBLACK    1+15
#define BGRAY     9+15
#define BRED      2+15
#define BLRED     10+15
#define BGREEN    3+15
#define BLGREEN   11+15
#define BYELLOW   4+15
#define BLYELLOW  12+15
#define BBLUE     5+15
#define BLBLUE    13+15
#define BMAGENTA  6+15
#define BPINK     7+15
#define BLMAGENTA 14+15
#define BLPINK    14+15
#define BCYAN     7+15
#define BLCYAN    15+15
#define BWHITE    8+15
#define BLWHITe   16+15

#define BOLD      32
#define ITALIC    33
#define UNDERLINE 34
#define STRIKE    35

#include <stdio.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdlib.h>

#ifdef _WIN32
#include <io.h>
#include <windows.h>
#define isatty _isatty

void clear_win() {
    COORD topLeft  = { 0, 0 };
    HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
    SCREEN_BUFFER_INFO screen;
    DWORD written;

    GetConsoleScreenBufferInfo(console, &screen);
    FillConsoleOutputCharacterA(
        console, ' ', screen.dwSize.X * screen.dwSize.Y, topLeft, &written
    );
    FillConsoleOutputAttribute(
        console, FOREGROUND_GREEN | FOREGROUND_RED | FOREGROUND_BLUE,
        screen.dwSize.X * screen.dwSize.Y, topLeft, &written
    );
    SetConsoleCursorPosition(console, topLeft);
}

static WORD win_default_attributes(HANDLE hConsole) {
	static WORD defaultAttributes = 0;
	SCREEN_BUFFER_INFO info;

    if (!defaultAttributes && GetConsoleScreenBufferInfo(hConsole, &info)) {
		defaultAttributes = info.wAttributes;
	}

	return defaultAttributes;
}

static void win_set_attributes(int fg, int bg) {
    WORD defaultAttributes;
    SCREEN_BUFFER_INFO info;
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);

    defaultAttributes = win_default_attributes(hConsole);

    if (fg == -1 && bg == -1) {
        SetConsoleTextAttribute(hConsole, defaultAttributes);
        return;
    }

    if (!GetConsoleScreenBufferInfo(hConsole, &info)) {
        return;
    }

    if (fg != -1) {
        info.wAttributes &= ~(info.wAttributes & 0x0F);
        info.wAttributes |= (WORD)fg;
    }

    if (bg != -1) {
        info.wAttributes &= ~(info.wAttributes & 0xF0);
        info.wAttributes |= (WORD)bg;
    }

    SetConsoleTextAttribute(hConsole, info.wAttributes);
}

#else
#include <unistd.h>
#endif // WIN32 OR LINUX

int* __PIPEDORNOT__ = NULL;
int  __INITED_OR_NOT__ = 0;

void init() {
    __PIPEDORNOT__ = ((int*) malloc(sizeof(int)));
    *__PIPEDORNOT__ = (isatty(1));
    __INITED_OR_NOT__ = 1;
}

void color(int color) {
    switch (color) {
        case RESET:
            #ifdef _WIN32
            win_set_attributes(-1, -1);
            #else
            (void) printf("\033[0m");
            #endif
        break;
        case CLEAR:
            #ifdef _WIN32
            clear_win();
            #else
            (void) printf("\033[2J");
            #endif
        break;
        case FBLACK:
            #ifdef _WIN32
            win_set_attributes(0, -1);
            #else
            (void) printf("\033[30m");
            #endif
        break;
        case FRED:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED, -1);
            #else
            (void) printf("\033[31m");
            #endif
        break;
        case FGREEN:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_GREEN, -1);
            #else
            (void) printf("\033[32m");
            #endif
        break;
        case FYELLOW:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_GREEN, -1);
            #else
            (void) printf("\033[33m");
            #endif
        break;
        case FBLUE:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_BLUE, -1);
            #else
            (void) printf("\033[34m");
            #endif
        break;
        case FMAGENTA:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_BLUE, -1);
            #else
            (void) printf("\033[35m");
            #endif
        break;
        case FCYAN:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_GREEN | FOREGROUND_BLUE, -1);
            #else
            (void) printf("\033[36m");
            #endif
        break;
        case FWHITE:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_RED, -1);
            #else
            (void) printf("\033[37m");
            #endif
        break;
        case FGRAY:
            #ifdef _WIN32
            SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 8);
            #else
            (void) printf("\033[30m");
            #endif
        break;
        case FLRED:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[90m");
            #endif
        break;
        case FLGREEN:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_GREEN | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[91m");
            #endif
        break;
        case FLYELLOW:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[92m");
            #endif
        break;
        case FLBLUE:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_BLUE | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[93m");
            #endif
        break;
        case FLMAGENTA:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_BLUE | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[94m");
            #endif
        break;
        case FLCYAN:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_GREEN | FOREGROUND_BLUE | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[96m");
            #endif
        break;
        case FLWHITE:
            #ifdef _WIN32
            win_set_attributes(FOREGROUND_RED | FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_INTENSITY, -1);
            #else
            (void) printf("\033[97m");
            #endif
        break;
        case BBLACK:
            #ifdef _WIN32
            win_set_attributes(-1, 0);
            #else
            (void) printf("\033[40m");
            #endif
        break;
        case BRED:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED);
            #else
            (void) printf("\033[41m");
            #endif
        break;
        case BGREEN:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_GREEN);
            #else
            (void) printf("\033[42m");
            #endif
        break;
        case BYELLOW:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_GREEN);
            #else
            (void) printf("\033[43m");
            #endif
        break;
        case BBLUE:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_BLUE);
            #else
            (void) printf("\033[44m");
            #endif
        break;
        case BMAGENTA:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_BLUE);
            #else
            (void) printf("\033[45m");
            #endif
        break;
        case BCYAN:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED);
            #else
            (void) printf("\033[46m");
            #endif
        break;
        case BWHITE:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_BLUE | BACKGROUND_GREEN);
            #else
            (void) printf("\033[47m");
            #endif
        break;
        case BGRAY:
            #ifdef _WIN32
            win_set_attributes(-1, -1); // TODO: Implement bgrey for windows
            #else
            (void) printf("\033[100m");
            #endif
        break;
        case BLRED:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[101m");
            #endif
        break;
        case BLGREEN:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_GREEN | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[102m");
            #endif
        break;
        case BLYELLOW:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[103m");
            #endif
        break;
        case BLBLUE:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_BLUE | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[104m");
            #endif
        break;
        case BLMAGENTA:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_RED | BACKGROUND_BLUE | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[105m");
            #endif
        break;
        case BLCYAN:
            #ifdef _WIN32
            win_set_attributes(-1, BACKGROUND_BLUE | BACKGROUND_GREEN | BACKGROUND_INTENSITY);
            #else
            (void) printf("\033[106m");
            #endif
        break;
        case BOLD:
            // TODO: Implement bold in windows
            (void) printf("\033[1m");
        break;
        case ITALIC:
        // TODO: Implement italic in windows
            (void) printf("\033[3m");
        break;
        case UNDERLINE:
        // TODO: Implement underline in windows
            (void) printf("\033[4m");
        break;
        case STRIKE:
        // TODO: Implement strike in windows
            (void) printf("\033[9m");
        break;
    }
}

int printc(int col, const char* format, ...) {
    va_list args;
    va_start(args, format);

    int r;

    if (__INITED_OR_NOT__ == 1 && *__PIPEDORNOT__) {
        color(col);
        r = vprintf(format,args);
        color(RESET);
    } else {
        r = vprintf(format,args);
    }
    va_end(args);
    return r;
}

void error(const char* format, ...) {va_list args; va_start(args,format); printc(FLRED, "[ERROR] "); vprintf(format, args);}
void warn(const char* format, ...) {va_list args; va_start(args,format); printc(FYELLOW, "[WARN] "); vprintf(format, args);}
void info  (const char* format, ...) {va_list args; va_start(args,format); printc(FBLUE, "[INFO] "); vprintf(format, args);}

#ifndef SHELL_READLINE_LIMIT_PR
#define SHELL_READLINE_LIMIT_PR 512
#endif
char* readline() {
    int buffer_size = SHELL_READLINE_LIMIT_PR; int p = 0;
    char* buffer = malloc(sizeof(char) * buffer_size);
    if (buffer == NULL) {return 0;}
    int c;

    for (;;) {
        c = getchar();
        if (c == '\n'){buffer[p] = '\0'; break;} 
        buffer[p++] = c;

        if (p >= buffer_size) {
            buffer_size += 128;
            buffer = realloc(buffer, buffer_size);
            if (buffer == NULL) {return 0;}
        }
    }
    return buffer;
}
