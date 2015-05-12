V ?= @

YACC = bison -d
LEX = flex
CXX = g++-4.8
TARGET = bin/parser
CDEFS = -DDEBUG_VERBOSE
CXXFLAGS = -g -Wall $(CDEFS) -std=c++11 
LIBS =

TESTS=$(wildcard cases/*.json)

SRCS = $(filter-out src/yacc.c src/lex.c, $(wildcard src/*.cpp))
OBJS:=$(SRCS:src/%.cpp=obj/%.o) obj/parser.o
DEPS:=$(OBJS:obj/%.o=obj/%.d)

all : $(TARGET)

.PHONY : all

test : all
	$V$(TARGET) $(TESTS)

obj:
	$Vmkdir $@

obj/%.o: src/%.cpp | obj
	@echo compiling $(@F)
	$V$(CXX) $(CXXFLAGS) -MMD -MP -c -o $@ $<

src/yacc.c src/yacc.h : src/parser.y
	@echo generating $(@F)
	$V$(YACC) -o src/yacc.c src/parser.y

src/lex.c src/lex.h : src/lex.l
	@echo generating $(@F)
	$V$(LEX) --header-file=src/lex.h -o src/lex.c src/lex.l

obj/parser.o : src/yacc.c src/lex.c | obj
	@echo compiling $(@F)
	$V$(CXX) $(CXXFLAGS) -MMD -MP -c src/yacc.c -o obj/parser.o

obj/yjson.o : src/yacc.h src/lex.h

$(TARGET) : $(OBJS)
	@echo linking $(@F)
	$Vmkdir -p "$$(dirname $(TARGET))"
	$V$(CXX) $(CXXFLAGS) $(OBJS) -o $(TARGET) $(LIBS)

clean:
	$Vrm -rf $(OBJS) $(DEPS) $(TARGET)
	$Vrm -rf src/yacc.c src/yacc.h src/y.output
	$Vrm -rf src/lex.c src/lex.h

.PHONY : clean

-include $(DEPS)
