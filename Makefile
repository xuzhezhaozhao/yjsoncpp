V ?= @

YACC = bison -d
LEX = flex
CXX = g++-4.8
TARGET = bin/parser
CDEFS = -DDEBUG_VERBOSE
CXXFLAGS = -g -Wall $(CDEFS) -std=c++11 
LIBS =

TESTS=$(wildcard cases/*.json)

SRCS = $(filter-out src/y.tab.c src/lex.yy.c, $(wildcard src/*.cpp))
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

src/y.tab.c src/y.tab.h : src/parser.y
	@echo generating $(@F)
	$V$(YACC) -o src/y.tab.c src/parser.y

src/lex.yy.c src/lex.yy.h : src/lex.l
	@echo generating $(@F)
	$V$(LEX) --header-file=src/lex.yy.h -o src/lex.yy.c src/lex.l

obj/parser.o : src/y.tab.c src/lex.yy.c | obj
	@echo compiling $(@F)
	$V$(CXX) $(CXXFLAGS) -MMD -MP -c src/y.tab.c -o obj/parser.o

obj/yjson.o : src/y.tab.h src/lex.yy.h

$(TARGET) : $(OBJS)
	@echo linking $(@F)
	$Vmkdir -p "$$(dirname $(TARGET))"
	$V$(CXX) $(CXXFLAGS) $(OBJS) -o $(TARGET) $(LIBS)

clean:
	$Vrm -rf $(OBJS) $(DEPS) $(TARGET)
	$Vrm -rf src/y.tab.c src/y.tab.h src/y.output
	$Vrm -rf src/lex.yy.c src/lex.yy.h

.PHONY : clean

-include $(DEPS)
