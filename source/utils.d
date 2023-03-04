/**
 * Authors: Data gogiberidze <datawater1@gmail.com>
 */

module utils;

import core.stdc.stdlib, core.stdc.string;

void  exit(int c) {core.stdc.stdlib.exit(c);}
char* memset(char *b, char c, size_t len) {for (int i = 0; i < len; i++) b[i] = c; return b;}