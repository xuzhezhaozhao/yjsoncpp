%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
int yylex(void);
void yyerror(char *, ...);
%}

%token INTEGER
%token BLANK
%left '+' '-'
%left '*' '/'

%%

program:
	   program expr '\n' {printf("%d\n", $2);}
	   |
	   ;
expr:
	INTEGER {$$ = $1;}
	| expr '*' expr {$$ = $1 * $3;}
	| expr '/' expr {$$ = $1 / $3;}
	| expr '+' expr {$$ = $1 + $3;}
	| expr '-' expr {$$ = $1 - $3;}
	;

%%
void yyerror(char *fmt, ...)
{
	va_list vl;
	va_start(vl, fmt);
	vfprintf(stderr, fmt, vl);
	va_end(vl);
}

int main(void)
{
	yyparse();
	yylex_destroy();
	return 0;
}
