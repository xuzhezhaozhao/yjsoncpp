#ifndef _JSON_H_
#define _JSON_H_

#include <stdio.h>
#include <stdlib.h>

struct parser_state {
	int nerr = 0;
};

int parse_input(parser_state *p, FILE *f);
int parse_file(parser_state *p, const char *s);
int parse_string(parser_state *p, const char *prog);


#endif
