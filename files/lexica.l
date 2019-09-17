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

START "/*"
END "*/"
SIMPLE [^*]
SPACE [ \t\n]
COMPLEX "*"[^/]
%s newstate

%%
"//"(.*[ \t]*.*)*[\n]+    {}
{START}                    {yymore();BEGIN newstate;}
 <newstate>{SIMPLE}        {yymore();BEGIN newstate;}
 <newstate>{COMPLEX}      {yymore();BEGIN newstate;}
 <newstate>{SPACE}        {yymore();BEGIN newstate;}
 <newstate>{END}  {}

"\\\n"		{}
"\n"		{return TK_FIM_LINHA;}
">="		{return TK_GEQ;}
"<="		{return TK_LEQ;}

{DELIM} 	{}
"eq"		{return TK_EQ;}
"neq"		{return TK_NEQ;}
"and"		{return TK_AND;}
"or"		{return TK_OR;}
"not"		{return TK_NOT;}
"if"		{return TK_IF;}
"for"       {return TK_FOR;}
"while"     {return TK_WHILE;}
"end"		{return TK_END;}


"int"		{return TK_TIPO_INT;}
"float"		{return TK_TIPO_FLOAT;}
"double"    {return TK_TIPO_DOUBLE;}
"char"		{return TK_TIPO_CHAR;}
"string"    {return TK_TIPO_STRING;}
"bool"		{return TK_TIPO_BOOL;}

[(){}[\];,]	{ return *yytext; }

[+\-*/=]		{ return *yytext; }

{BOOL}      { yylval.tipo = BOOLEAN; yylval.traducao = yytext; return TK_BOOL; }
{STR}       {}
{NUM}		{ yylval.tipo = INT; yylval.traducao = yytext; return TK_NUM; }
{REAL}      { yylval.tipo = DOUBLE; yylval.traducao = yytext; return TK_REAL; }

{ID}		{ yylval.traducao = yytext; yylval.label = get_id_label(yytext); return TK_ID; }


.			{ *yytext; }

%%
