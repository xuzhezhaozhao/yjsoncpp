#ifndef _YJSON_H_
#define _YJSON_H_

#include <stdio.h>
#include <stdlib.h>

#include <string>
#include <map>
#include <vector>
#include <utility>
#include <assert.h>


#define YJSON_TOBJECT  0
#define YJSON_TARRAY   1
#define YJSON_TSTRING  2
#define YJSON_TINTEGER 3
#define YJSON_TNUMBER  4

#define YJSON_TNIL  5

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
	int tt = YJSON_TNIL;
} TValue;

struct parser_state {
	int nerr = 0;
	TValue root;
	char *errmsg = NULL;

	~parser_state () {
		if (errmsg) { delete errmsg; }
	}
};


int parse_input (parser_state *p, FILE *f);
int parse_file (parser_state *p, const char *fname);
int parse_string (parser_state *p, const char *str);
int parse_lstring(parser_state *p, const char *str, size_t len);

class JsonObject {
public:
	std::map<std::string*, TValue*> *mp;

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

	void add(std::string* k, TValue* v) {
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
	parser_state p;
public:

	Reader () {}

	bool parse (
			const std::string &document, Value &root, 
			bool collectComments = true) {
		init_parser_state();
		return true;
	}

	bool parse (const char *beginDoc, const char *endDoc, 
			Value &root, bool collectComments = true) {
		init_parser_state();
		return true;
	}

	bool parse (const char *beginDoc, 
			TValue &root, bool collectComments = true) {
		init_parser_state();

		parse_string(&p, beginDoc);

		root = p.root;

		return p.nerr == 0 ? true : false;
	}

	bool parse (FILE *f, TValue &root, bool collectComments = true) {
		init_parser_state();
		parse_input(&p, f);
		root = p.root;

		return p.nerr == 0 ? true : false;
	}

	bool parse (std::istream &is, Value &root, 
			bool collectComments = true ) {
		init_parser_state();
		return true;
	}


	std::string	getFormatedErrorMessages () const {
		return "";
	}

	std::string	getFormattedErrorMessages () const {
		return "";
	}

private:
	void init_parser_state () {
		p.nerr = 0;
	}

};

class Writer {
public:
	std::string formatWrite (const TValue & root) {
		return doWrite(NULL, &root, 0, true, true);
	}

	std::string write (const TValue & root) {
		return doWrite(NULL, &root, 0, true, false);
	}

private:
	std::string doWrite (const std::string *key, 
			const TValue *val, int indent, bool last, bool format) {
		std::string result = "";
		size_t sz = 0, cnt = 0;
		switch (val->tt) {
			case YJSON_TOBJECT:
				result += auxWrite(key, "{", indent, true, format);

				sz = val->value.obj->mp->size();
				cnt = 0;
				for (auto & p : *(val->value.obj->mp)) {
					++cnt;
					result += doWrite(p.first, p.second, indent + 1, 
							cnt == sz, format);
				}
				result += auxWrite(NULL, "}", indent, last, format);
				break;
			case YJSON_TARRAY:
				result += auxWrite(key, "[", indent, true, format);

				sz = val->value.arrobj->vec->size();
				cnt = 0;
				for (auto & p : *(val->value.arrobj->vec)) {
					++cnt;
					result += doWrite(NULL, p, indent + 1, cnt == sz, format);
				}

				result += auxWrite(NULL, "]", indent, last, format);
				break;
			case YJSON_TSTRING:
				result += auxWrite(key, std::string("\"") 
						+ val->value.s + "\"", indent, last, format);
				break;
			case YJSON_TNUMBER:
				char buf[255];
				sprintf(buf, "%f", val->value.n);
				result += auxWrite(key, std::string(buf), indent, last,
						format);
				break;
			case YJSON_TINTEGER:
				break;
			default:
				assert(0);
				break;
		}
		return result;
	}

	std::string auxWrite(const std::string *key, const std::string & end, 
			int indent, bool last, bool format) {
		std::string w = "";
		if (format) {
			while (indent--) { w += "   "; }
			if (key) { w += "\"" + *key + "\"" + " : "; }
			w += end;
			if (!last) w += ',';
			w += '\n';
		} else {
			if (key) { w += "\"" + *key + "\"" + ":"; }
			w += end;
			if (!last) w += ',';
		}

		return w;
	}
};


#endif
