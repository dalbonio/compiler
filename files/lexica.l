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

%%

<<EOF>>		                { static int once = 0; return once++ ? 0: TK_FIM_LINHA; }

"//"(.*[ \t]*.*)*[\n]+      {}
"\\\n"		                {}
"\n"                        { yylval.traducao = yytext; contadorLinha++; return TK_FIM_LINHA; }

"input"                     { return TK_INPUT; }
"print"                     { return TK_PRINT; }
"loop"		                { cmdLabelContador++; return TK_LOOP; }
"for"		                { pushContext(); ctxPushReseter = 1; return TK_FOR; }
"loopeach"		            { pushContext(); ctxPushReseter = 1; return TK_LOOPEACH; }
"if"		                { return TK_IF; }
"else"                      { return TK_ELSE; }
"elif"						{ return TK_ELSEIF; }
"do"		                { pushContext(); return TK_DO; }
"end"		                { return TK_END; }
"not"		                { return TK_NOT; }
"switch"					{ return TK_SWITCH; }
"case"					    { return TK_CASE; }
"default"					{ return TK_DEFAULT; }
"in"					    { return TK_IN; }
"global"                    { return TK_GLOBAL; }
"var"                       { return TK_VAR; }
"break"                     { return TK_BREAK; }
"continue"                  { return TK_CONTINUE; }

"++"                        { return TK_INCR; }
"--"                        { return TK_DECR; }
"+="		                { yylval.traducao = yytext; return TK_CONT; }
"-="		                { yylval.traducao = yytext; return TK_CONT; }
"*="		                { yylval.traducao = yytext; return TK_CONT; }
"/="		                { yylval.traducao = yytext; return TK_CONT; }

[#(){}[\];,:?]	            { return *yytext; }
[=!]		                { return *yytext; }
[+\-*/]                     { yylval.traducao = yytext; return TK_OP_ARIT; }

{OP_REL}                    { yylval.traducao = yytext; return TK_OP_REL; }
{OP_LOG}                    { yylval.traducao = yytext; return TK_OP_LOG; }
{TIPO}                      { yylval.label = yytext; return TK_CASTING; }
{BOOL}                      { yylval.tipo = BOOLEAN; yylval.traducao = yytext; return TK_BOOL; }
{NUM}		                { yylval.tipo = INT; yylval.traducao = yytext; return TK_NUM; }
{REAL}                      { yylval.tipo = DOUBLE; yylval.traducao = yytext; return TK_REAL; }
{STR}                       { yylval.tipo = STRING; yylval.traducao = yytext; return TK_STR; }
{ID}		                { yylval.traducao = yytext; return TK_ID; }

.			                { *yytext; }

%%

/*
*/
