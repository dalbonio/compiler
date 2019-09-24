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

START "/*"
END "*/"
SIMPLE [^*]
SPACE [ \t\n]
COMPLEX "*"[^/]
%s newstate

%%
"//"(.*[ \t]*.*)*[\n]+      {}
{START}                     {yymore();BEGIN newstate;}
 <newstate>{SIMPLE}         {yymore();BEGIN newstate;}
 <newstate>{COMPLEX}        {yymore();BEGIN newstate;}
 <newstate>{SPACE}          {yymore();BEGIN newstate;}
 <newstate>{END}            {}

"\\\n"		{}
"\n"		{contadorLinha += 1; return TK_FIM_LINHA;}

"input"     {return TK_INPUT;}
"loop"		{return TK_LOOP;}
"do"		{return TK_DO;}
{DELIM} 	{}
"not"		{return TK_NOT;}
"if"		{return TK_IF;}
"for"       {return TK_FOR;}
"while"     {return TK_WHILE;}
"end"		{return TK_END;}

[(){}[\];,]	{ return *yytext; }

[=!]		{ return *yytext; }

[+\-*/]     {yylval.traducao = yytext; return TK_OP_ARIT;}
{OP_REL}    {yylval.traducao = yytext; return TK_OP_REL;}
{OP_LOG}    {yylval.traducao = yytext; return TK_OP_LOG;}

{TIPO}      { yylval.label = yytext; return TK_CASTING;}
{BOOL}      { yylval.tipo = BOOLEAN; yylval.traducao = yytext; return TK_BOOL; }
{NUM}		{ yylval.tipo = INT; yylval.traducao = yytext; return TK_NUM; }
{REAL}      { yylval.tipo = DOUBLE; yylval.traducao = yytext; return TK_REAL; }
{STR}       {}

{ID}		{ yylval.traducao = yytext; yylval.label = get_id_label(yytext); return TK_ID; }

.			{ *yytext; }

%%
/*
">="		{return TK_GEQ;}
"<="		{return TK_LEQ;}
"eq"		{return TK_EQ;}
"neq"		{return TK_NEQ;}
"eq"		{yylval.traducao = yytext; return TK_OP_REL;}
"neq"		{yylval.traducao = yytext; return TK_OP_REL;}
"and"		{return TK_AND;}
"or"		{return TK_OR;}
*/
