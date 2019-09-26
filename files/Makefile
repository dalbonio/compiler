all:
		clear
		lex lexica.l
		yacc -t -d sintatica.y --debug --verbose
		g++ -o glf y.tab.c -ll -std=c++11 -DYYDEBUG
		./glf < exemplo.foca

d:
		clear
		lex lexica.l
		yacc -t -d sintatica.y --debug --verbose
		g++ -o glf y.tab.c -ll -std=c++11 -DYYDEBUG
		./glf < exemplo.foca 2> debug.cpp


#NORMAL COMPILING:
#yacc -d sintatica.y
#g++ -o glf y.tab.c -ll -std=c++11
#./glf < exemplo.foca

#DEBUG YACC:
#put yydebug = 1; on the main() of .y file
#yacc -t -d sintatica.y
#g++ -o glf y.tab.c -ll -std=c++11 -DYYDEBUG
#./glf < exemplo.foca

#SAVE DEBUG MESSAGE OR SAVE OUTPUT:
#to save the message of debug in a file use "2>" operator
#to save the output of the program in a file and show it on terminal use "| tee"
#this commands can be used together
#./glf < exemplo.foca 2> debug.file | tee output.file
