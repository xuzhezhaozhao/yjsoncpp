#ifndef _XJSON_H_
#define _XJSON_H_

#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <map>
#include <vector>
#include <utility>

#define XJSON_TOBJECT  0
#define XJSON_TARRAY   1
#define XJSON_TSTRING  2
#define XJSON_TINTEGER 3
#define XJSON_TNUMBER  4

typedef std::string Key;

class JsonObject;
class ArrayObject;

typedef union Value {
	JsonObject *obj;	
	ArrayObject *arrobj;
	char *s;
	int i;
	double n;
} Value;

typedef struct TValue {
	Value value;
	int tt;
} TValue;

class JsonObject {
public:
	std::map<Key*, TValue*> *mp;

public:
	void add(Key* k, TValue* v) {
		mp->insert( std::make_pair(k, v) );
	}
};


class ArrayObject {
public:
	std::vector<TValue*> *vec;

public:
	void add(TValue* v) {
		vec->push_back(v);
	}
};


struct parser_state {
	int nerr = 0;
	TValue root;
};


int parse_input(parser_state *p, FILE *f);
int parse_file(parser_state *p, const char *s);
int parse_string(parser_state *p, const char *prog);
void *new_obj(int tag);


#endif
