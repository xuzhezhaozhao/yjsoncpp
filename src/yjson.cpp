#include <stdio.h>

#include "yjson.h"

#include "y.tab.h"
#include "lex.yy.h"

int yyparse (parser_state *p);

int parse_input (parser_state *p, FILE *f) {

	yylineno = 1;
	yyrestart(f);
	int n = yyparse(p);

	return 0 == n ? 0 : 1;
}

int parse_file (parser_state *p, const char *fname) {
	FILE *fp = fopen(fname, "rb");
	if (fp == NULL) {
		perror("fopen");
		return 1;
	}

	yylineno = 1;
	yyrestart(fp);
	int n = yyparse(p);
	fclose(fp);

	return 0 == n ? 0 : 1;
}

int parse_string (parser_state *p, const char *prog)
{
	yy_scan_string(prog);
	int n = yyparse(p);

	return 0 == n ? 0 : 1;
}

int parse_lstring(parser_state *p, const char *str, size_t len) {
	yy_scan_string(str);
	int n = yyparse(p);
	return 0 == n ? 0 : 1;
}
