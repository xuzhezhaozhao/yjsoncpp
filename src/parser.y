%{
#define YYDEBUG 0
#define YYERROR_VERBOSE 0

#include <stdlib.h>
#include <stdio.h>
#include "yjson.h"

%}

%union {
	TValue *tv;
	double n;
	char *s;

	std::pair<Key*, TValue*> *p;
	std::map<Key*, TValue*> *mp;
	std::vector<TValue*> *vec;

	ArrayObject *arrobj;
	JsonObject *jsonobj;
};

%type <s> String
%type <n> Number 
%type <p> Pair
%type <mp> Pairs
%type <tv> Value
%type <vec> Values
%type <arrobj> Array
%type <jsonobj> Object

%pure-parser
%parse-param {parser_state *p}
%lex-param {p}

%{
int yylex(YYSTYPE *lval, parser_state *p);
static void yyerror(parser_state *p, const char *s);
%}

%token NUMBER STRING

%%

Json: Object 
	{
		  /*printf("json object\n");*/
		p->root.value.obj = $1;
		p->root.tt = XJSON_TOBJECT;
	}
	| Array
	{
		  /*printf("json array\n");*/
		p->root.value.arrobj = $1;
		p->root.tt = XJSON_TARRAY;
	}
	;

Object: '{' Pairs '}' 
	  {
		  /*printf("object\n");*/
		$$ = new JsonObject();
	  	$$->mp = $2;
	  }
	  | '{' '}'
	  {
		  /*printf("empty object\n");*/
		$$ = new JsonObject();
	  }
	  ;

Array: '[' Values ']' 
	 {
		  /*printf("array\n");*/
		$$ = new ArrayObject();
	 	$$->vec = $2;
	 }
	 | '[' ']'
	 {
		  /*printf("empty array\n");*/
		$$ = new ArrayObject();
	 }
	 ;

Values: Values ',' Value
	  {
		  /*printf("values\n");*/
	  	$1->push_back($3);
		$$ = $1;
	  }
	  | Value
	  {
		  /*printf("value in values\n");*/
	  	$$ = new std::vector<TValue *>();
		$$->push_back($1);
	  }
	  ;

Value: Object 
	 {
		  /*printf("object in value\n");*/
		$$ = new TValue();
	 	$$->value.obj = $1;
		$$->tt = XJSON_TOBJECT;
	 }
	 | Array  
	 {
		  /*printf("array in value\n");*/
		$$ = new TValue();
	 	$$->value.arrobj = $1;
		$$->tt = XJSON_TARRAY;
	 }
	 | String 
	 {
		  /*printf("string in value\n");*/
		$$ = new TValue();
	 	$$->value.s = $1;
		$$->tt = XJSON_TSTRING;
	 }
	 | Number
	 {
		  /*printf("number in value\n");*/
		$$ = new TValue();
	 	$$->value.n = $1;
		$$->tt = XJSON_TNUMBER;
	 }
	 ;

Pairs: Pairs ',' Pair 
	 {
		  /*printf("pairs\n");*/
	 	$1->insert(*$3);
		delete $3;
		$$ = $1;
	 }
	 | Pair
	 {
		  /*printf("pair in paris\n");*/
	 	$$ = new std::map<Key*, TValue*>();
		$$->insert(*$1);
		delete $1;
	 }
	 ;

Pair: String ':' Value
	{
		  /*printf("pair\n");*/
		$$ = new std::pair<Key*, TValue*>(new std::string($1), $3);
		delete $1;
	}
	;

Number:	NUMBER
	  {
		  /*printf("number\n");*/
	  }
	  ;

String: STRING
	  {
		  /*printf("string\n");*/
	  }
	  ;

%%

#include "lex.yy.c"

static void yyerror(parser_state *p, const char *s)
{
	if (!p->errmsg) p->errmsg = new char[128];

	sprintf(p->errmsg, "error: %s at line %d.\n", s, yylineno);
	++p->nerr;
}
