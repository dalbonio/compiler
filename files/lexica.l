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

START "/*
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

"\n"		{return TK_FIM_LINHA;}

{DELIM} 	{}

"if"		{return TK_IF;}
"for"       {return TK_FOR;}
"while"     {return TK_WHILE;}
"end"		{return TK_END;}

"int"		{return TK_TIPO_INT;}
"float"		{return TK_TIPO_FLOAT;}
"double"    {return TK_TIPO_DOUBLE;}
"char"		{return TK_TIPO_CHAR;}
"string"    {return TK_TIPO_STRING;}

[(){}[\];,]	{ return *yytext; }

[+\-*/=]		{ return *yytext; }

{STR}       {}
{NUM}		{ yylval.tipo = "int"; yylval.traducao = yytext; return TK_NUM; }
{ID}		{ yylval.traducao = yytext; yylval.label = get_id_label(yytext); return TK_ID; }
{REAL}      { yylval.tipo = "double"; yylval.traducao = yytext; return TK_REAL; }

.			{ *yytext; }

%%
