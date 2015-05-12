%{
#include <stdio.h>
#include "json.h"

#define YY_DECL    int yylex(YYSTYPE *lval, parser_state *p)

%}


%option noyywrap
%option yylineno
%option nounput

TRAIL 	([\t \n]*)

DIGIT 	[0-9]
DIGITS 	{DIGIT}+
HEX 	[0-9a-fA-F]
INT 	"-"?([0-9]|[1-9][0-9]*)
FRAC 	"."{DIGITS}
E 		[eE][-+]?
EXP 	{E}{DIGITS}
NUMBER 	{INT}({FRAC}|{EXP}|{FRAC}{EXP})?


ASC     [\x00-\x7f]
ASCN    [\x00-\t\v-\x7f]
U       [\x80-\xbf]
U2      [\xc2-\xdf]
U3      [\xe0-\xef]
U4      [\xf0-\xf4]

UANY    {ASC}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}
UANYN   {ASCN}|{U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U} 
UONLY   {U2}{U}|{U3}{U}{U}|{U4}{U}{U}{U}

CHAR	{UANY}
CHARS	{CHAR}+

STRING  \"(\\["\\\/bfnrt]|\\"u"{HEX}{4}|[^\\"\n])*\"

OPERATOR ("{"|"}"|"]"|"["|","|":")

%%

{NUMBER}		{ return NUMBER; }
{STRING}		{ return STRING; }
{OPERATOR}		{ return yytext[0]; }
[ \t\n]			{  }
.				{ 
#ifdef DEBUG_VERBOSE
	/*
	fprintf(stderr, "error: lexical error, unexpected char '%c' at line %d.\n",
	yytext[0], yylineno);
	*/
#endif
	return LEX_ERROR;
}



%%
