#include <cstdio>
#include <iostream>

#include "yjson.h"

using namespace std;

#define CHECK(s, r, p)                                            \
	do {                                                   \
		if (!(r))                                      \
			fprintf(stdout, "%s: Syntax OK\n", s); \
		else {                                          \
			fprintf(stdout, "%s: Syntax NG\n", s); \
			fprintf(stdout, "%s\n", p.errmsg ? p.errmsg : "unknown error"); \
		} \
	} while (0)

int main(int argc, char *argv[]) {
	const char *prog = argv[0];
	const char *e_prog = NULL;

	parser_state p;

	while (argc > 1 && argv[1][0] == '-') {
		const char *s = argv[1] + 1;
		while (*s) {
			switch (*s) {
				case 'v':
					break;
				case 'c':
					break;
				case 'e':
					if (s[1] == '\0') {
						e_prog = argv[2];
						argc--;
						argv++;
					} else {
						e_prog = &s[1];
					}
					goto next_arg;
				default:
					fprintf(stderr,
						"%s: unknown option -%c\n",
						prog, *s);
			}
			s++;
		}
	next_arg:
		argc--;
		argv++;
	}

	
	TValue root;
	if (e_prog) {
		printf("%s\n", e_prog);
		CHECK("string: ", parse_string(&p, e_prog), p);
	} else if (argc == 1) {
		//CHECK("stdin: ", parse_input(&p, stdin), p);
		Reader reader;
		bool successful = reader.parse(stdin, root);
		if (successful) {
			Writer writer;
			std::cout << writer.formatWrite(root);
		}

	} else {
		for (int i = 1; i < argc; i++) {
			CHECK(argv[i], parse_file(&p, argv[i]), p);
		}
	}


	return 0;
}
