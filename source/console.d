/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

module console;

enum int RESET     = -1;
enum int CLEAR     = 31;
enum int FBLACK    = 0;
enum int FGRAY     = 8;
enum int FGREY     = 8;
enum int FRED      = 1;
enum int FLRED     = 9;
enum int FGREEN    = 2;
enum int FLGREEN   = 10;
enum int FYELLOW   = 3;
enum int FLYELLOW  = 11;
enum int FBLUE     = 4;
enum int FLBLUE    = 12;
enum int FMAGENTA  = 5;
enum int FPINK     = 5;
enum int FLMAGENTA = 13;
enum int FLPINK    = 13;
enum int FCYAN     = 6;
enum int FLCYAN    = 14;
enum int FWHITE    = 7;
enum int FLWHITE   = 15;
enum int BBLACK    = 1+15;
enum int BGRAY     = 9+15;
enum int BRED      = 2+15;
enum int BLRED     = 10+15;
enum int BGREEN    = 3+15;
enum int BLGREEN   = 11+15;
enum int BYELLOW   = 4+15;
enum int BLYELLOW  = 12+15;
enum int BBLUE     = 5+15;
enum int BLBLUE    = 13+15;
enum int BMAGENTA  = 6+15;
enum int BPINK     = 7+15;
enum int BLMAGENTA = 14+15;
enum int BLPINK    = 14+15;
enum int BCYAN     = 7+15;
enum int BLCYAN    = 15+15;
enum int BWHITE    = 8+15;
enum int BLWHITE   = 16+15;
enum int BOLD      = 32;
enum int ITALIC    = 33;
enum int UNDERLINE = 34;
enum int STRIKE    = 35;


extern (C) {
void init();
void color (int color);
int  printc(int color, const char* format, ...);
void error (const char* format, ...);
void warn  (const char* format, ...);
void info  (const char* format, ...);
}