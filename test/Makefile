YACC = bison -d
LEX = flex

TARGET = bin/calc
CFLAGS = -g -Wall

all: $(TARGET)

.PHONY: all

calc.tab.c: calc.y
	$(YACC) -o calc.tab.c calc.y

calc.yy.c: calc.l 
	$(LEX) -o calc.yy.c calc.l


$(TARGET): calc.tab.c calc.yy.c
	mkdir -p "$$(dirname $(TARGET))"
	$(CC) $(CFLAGS) calc.yy.c calc.tab.c -o $(TARGET)
