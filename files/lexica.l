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

%%

"\n"		{return TK_FIM_LINHA;}

{DELIM} 	{}


"if"		{return TK_IF;}
"for"       {return TK_FOR;}
"while"     {return TK_WHILE;}
"end"		{return TK_END;}

"int"		{return TK_TIPO_INT;}
"double"    {return TK_TIPO_DOUBLE;}
"string"    {return TK_TIPO_STRING;}

[(){}[\];,]	{ return *yytext; }

[+\-*/=]		{ return *yytext; }

{STR}       {}
{NUM}		{ yylval.traducao = yytext; return TK_NUM; }
{ID}		{ yylval.label = get_id_label(yytext); return TK_ID; }
{REAL}      {}

.			{ *yytext; }

%%
