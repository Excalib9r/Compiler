#!/bin/bash

yacc -d -Wcounterexamples -Wother -Wconflicts-sr parser.y
flex scanner.l
g++ -w -g lex.yy.c y.tab.c -o out
./out test.c
rm lex.yy.c y.tab.c y.tab.h out