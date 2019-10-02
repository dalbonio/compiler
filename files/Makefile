all:
		clear
		lex -d lexica.l
		yacc -t -d sintatica.y --verbose
		g++ -o glf y.tab.c -ll -std=c++11
		./glf < exemplo.foca 2> y_debug.cpp
		@rm lex.yy.c
		@rm y.tab.c
		@rm y.tab.h
		@rm glf


#NORMAL COMPILING:
#yacc -t sintatica.y
#g++ -o glf y.tab.c -ll -std=c++11
#./glf < exemplo.foca

#DEBUG YACC AND LEX:
#put yy_flex_debug = 1; and
#put yydebug = 1; on the main() of .y file
#lex -d lexica.l
#yacc -t -d sintatica.y
#g++ -o glf y.tab.c -ll -std=c++11
#./glf < exemplo.foca

#SAVE DEBUG MESSAGE OR SAVE OUTPUT:
#to save the message of debug in a file use "2>" operator
#to save the output of the program in a file and show it on terminal use "| tee"
#this commands can be used together
#./glf < exemplo.foca 2> debug.file | tee output.file
