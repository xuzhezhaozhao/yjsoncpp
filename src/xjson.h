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

struct parser_state {
	int nerr = 0;
	TValue root;
	char *errmsg = NULL;
};

class JsonObject {
public:
	std::map<Key*, TValue*> *mp;

public:
	JsonObject() : mp(NULL) {}

	~JsonObject() {
		if (mp) {
			for (auto &p : *mp) {
				delete p.first;
				delete p.second;
			}
			delete mp;
		}
	}

	void add(Key* k, TValue* v) {
		mp->insert( std::make_pair(k, v) );
	}
};


class ArrayObject {
public:
	std::vector<TValue*> *vec;

public:
	ArrayObject () : vec(NULL) {}

	~ArrayObject() {
		if (vec) {
			for (TValue* val : *vec) {
				delete val;
			}
			delete vec;
		}
	}

	void add(TValue* v) {
		vec->push_back(v);
	}
};


class Reader {
private:	

public:

	Reader () {}

	bool parse (
			const std::string &document, Value &root, 
			bool collectComments = true) {
		return true;
	}

	bool parse (const char *beginDoc, const char *endDoc, 
			Value &root, bool collectComments = true) {
		return true;
	}

	bool parse (std::istream &is, Value &root, 
			bool collectComments = true ) {
		return true;
	}

	std::string	getFormatedErrorMessages () const {
		return "";
	}

	std::string	getFormattedErrorMessages () const {
		return "";
	}

};


int parse_input (parser_state *p, FILE *f);
int parse_file (parser_state *p, const char *s);
int parse_string (parser_state *p, const char *prog);


#endif
