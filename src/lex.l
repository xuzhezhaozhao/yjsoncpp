%{
#include <stdio.h>
#include "yjson.h"

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

{NUMBER}		{ 
					lval->n = atof(yytext);
					return NUMBER; 
				}
{STRING}		{ 
					/* 去掉引号 */
					int len = strlen(yytext) - 2;
					lval->s = strncpy(new char[len + 1], yytext + 1, len);
					lval->s[len] = '\0';
					return STRING; 
				}
{OPERATOR}		{ return yytext[0]; }
[ \t\n]			{  }
.				{  }



%%
