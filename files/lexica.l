%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]
STR \"([^\\\"]|\\.)*\"

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*

BOOL true|false
TIPO int|double|boolean|string
OP_REL >=|<=|<|>|eq|neq
OP_LOG and|or

J_LINE (\n)+

%%

{J_LINE}	                { contadorLinha += strlen(yytext); yylval.traducao = yytext; return TK_FIM_LINHA; }
<<EOF>>		                { strcat(yytext, "\n"); return 0; }

"//"(.*[ \t]*.*)*[\n]+      {}
"\\\n"		                {}
"input"                     { return TK_INPUT; }
"print"                     { return TK_PRINT; }
"loop"		                { return TK_LOOP; }
"if"		                { return TK_IF; }
"else"                      { return TK_ELSE; }
"do"		                { return TK_DO; }
"end"		                { return TK_END; }
"not"		                { return TK_NOT; }

"++"                        { return TK_INCR; }
"--"                        { return TK_DECR; }
"+="		                { yylval.traducao = yytext; return TK_CONT; }
"-="		                { yylval.traducao = yytext; return TK_CONT; }
"*="		                { yylval.traducao = yytext; return TK_CONT; }
"/="		                { yylval.traducao = yytext; return TK_CONT; }

[(){}[\];,]	                { return *yytext; }
[=!]		                { return *yytext; }
[+\-*/]                     { yylval.traducao = yytext; return TK_OP_ARIT; }

{OP_REL}                    { yylval.traducao = yytext; return TK_OP_REL; }
{OP_LOG}                    { yylval.traducao = yytext; return TK_OP_LOG; }
{TIPO}                      { yylval.label = yytext; return TK_CASTING; }
{BOOL}                      { yylval.tipo = BOOLEAN; yylval.traducao = yytext; return TK_BOOL; }
{NUM}		                { yylval.tipo = INT; yylval.traducao = yytext; return TK_NUM; }
{REAL}                      { yylval.tipo = DOUBLE; yylval.traducao = yytext; return TK_REAL; }
{STR}                       { yylval.tipo = STRING; yylval.traducao = yytext; return TK_STR; }
{ID}		                { yylval.traducao = yytext; yylval.label = get_id_label(yytext); return TK_ID; }

.			                { *yytext; }

%%

/*
%s newstate
START "/*"
END "*(/)"
SIMPLE [^*]
SPACE [ \t\n]
COMPLEX "*"[^/]
*/