%{
#define YYDEBUG 1
#define YYERROR_VERBOSE 1

#include <stdlib.h>
#include <stdio.h>
#include "json.h"

%}

%union {
	int a;
	char b;
}

%pure-parser
%parse-param {parser_state *p}
%lex-param {p}

%{
int yylex(YYSTYPE *lval, parser_state *p);
static void yyerror(parser_state *p, const char *s);
%}

%token NUMBER STRING
%token LEX_ERROR

%%

Json: Object |
	  Array
	  ;

Object: '{' Pairs '}' |
	    '{' '}'
	  ;

Array: '[' Values ']' |
	   '[' ']'
		;

Values: Values ',' Value |
        Value
	  ;

Value: Object |
	   Array  |
	   String |
	   Number
	 ;

Pairs: Pairs ',' Pair |
	   Pair
	 ;

Pair: String ':' Value
	;

Number:	NUMBER
	  ;

String: STRING
	  ;

%%

#include "lex.yy.c"

static void yyerror(parser_state *p, const char *s)
{
#ifdef DEBUG_VERBOSE
	fprintf(stderr, "error: %s at line %d.\n", s, yylineno);
#endif
}
