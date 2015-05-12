%{
	#include <stdlib.h>
	#include "calc.tab.h"
	void yyerror(char *, ...);
%}

%%

[0-9]+		{yylval = atoi(yytext); return INTEGER;}
[-+*/\n]	{return *yytext;}
[ \t]+		;
.			yyerror("lex error: invalid char in line %d.", yylineno);

%%

int yywrap(void)
{
	return 1;
}
