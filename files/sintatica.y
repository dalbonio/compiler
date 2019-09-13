%{
#include <iostream>
#include <string>
#include <sstream>
#include <iterator>
#include <unordered_map>
#include <map>
#include <queue>
#include <stack>

#define YYSTYPE atributos

using namespace std;

struct variavel
{
	string tipo;
};

struct atributos
{
	string label;
	string traducao;
	int resultado;
	string tipo;
};

unordered_map<string, string> var_umap;
unordered_map<string, variavel> temp_umap;

queue <atributos> multiple_atr_queue;
stack <atributos> multiple_atr_stack;

int tokenContador = 0;

string label_generator();
int yylex(void);
void yyerror(string);
string get_id_label(string user_label);
string declare_variables();

%}

%token TK_NUM TK_REAL

%token TK_MAIN TK_END
%token TK_ID TK_TIPO_INT TK_TIPO_STRING TK_TIPO_DOUBLE TK_TIPO_FLOAT TK_TIPO_CHAR
%token TK_FOR TK_WHILE TK_IF

%token TK_FIM TK_ERROR
%token TK_FIM_LINHA


%start S

%left '+' '-'
%left '*' '/'

%%

S 			: BLOCO
			{
				cout << "/*Compilador FOCA*/\n";
				cout << "#include <iostream>\n";
				cout << "#include<string.h>\n#include<stdio.h>\n";
				cout <<	"int main(void)\n{\n";
				cout << declare_variables();
				cout << $1.traducao << "\n\treturn 0;\n}" << endl;
			}
			;

BLOCO		: COMANDOS
			{
				$$.traducao = $1.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.label = "";
				$$.traducao = $1.traducao + $2.traducao;
			}
			| //vazio
			{
				$$.label = "";
				$$.traducao = "";
			}
			;

COMANDO 	: E TK_FIM_LINHA
			{
				$$.traducao = $1.traducao;
			}
			| TK_ID ',' REC_ATR ',' E TK_FIM_LINHA
			{
				multiple_atr_queue.push($1);
				multiple_atr_stack.push($5);

				string local_traducao = "";
				while(!multiple_atr_queue.empty() || !multiple_atr_stack.empty() )
				{
					atributos var = multiple_atr_queue.front();
					atributos exp = multiple_atr_stack.top();

					temp_umap[var.label].tipo = exp.tipo;

					local_traducao += "\t" + var.label + " = " + exp.label + ";\n";

					multiple_atr_queue.pop();
					multiple_atr_stack.pop();
				}

				/*if( multiple_atr_queue.empty() && multiple_atr_stack.empty() )
				{
					while( !multiple_atr_queue.empty() )
					{
						multiple_atr_queue.pop()
					}

					while( !multiple_atr_stack.empty() )
					{
						multiple_atr_stack.pop()
					}

					cout << "erro atribuicao multipla";
					$$.traducao = $3.traducao + $5.traducao;
				}*/
				//else
				{
					$$.traducao = $3.traducao + $5.traducao + local_traducao;
				}
			}
			;

E 			: E '+' E
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = $1.resultado + $3.resultado;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";

			}
			| E '-' E
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = $1.resultado - $3.resultado;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";

			}
			| E '*' E
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = $1.resultado * $3.resultado;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";

			}
			| E '/' E
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = $1.resultado / $3.resultado;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";

			}
			| TK_ID '=' E
			{
				$$.tipo = $3.tipo;
				temp_umap[var_umap[$1.traducao]].tipo = $3.tipo;
				$$.label = $1.label;

				$$.resultado = $1.resultado;
				$$.traducao = $3.traducao + "\t" + $1.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = stoi($1.traducao);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_REAL
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = stoi($1.traducao);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_ID
			{
				$$.tipo = temp_umap[var_umap[$1.traducao]].tipo;
				$$.label = $1.label;
				$$.traducao = "";
				$$.resultado = 0;
			}
			;

REC_ATR		: TK_ID ',' REC_ATR ',' E
			{
				multiple_atr_queue.push($1);
				multiple_atr_stack.push($5);

				//$$.label = label_generator();
				$$.traducao = $3.traducao + $5.traducao;
			}
			| TK_ID '=' E
			{
				$$.label = "";
				$$.traducao = $3.traducao;

				multiple_atr_queue.push($1);
				multiple_atr_stack.push($3);
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}

string label_generator()
{
	return string("temp") + to_string(tokenContador++);
}

string declare_variables()
{
	string total = string("");

	for(auto it=var_umap.begin(); it!=var_umap.end(); it++)
	{
		total += "\t//" + it->first + "=" + it->second + "\n";
	}

	total += "\n";

	for(auto it=temp_umap.begin(); it!=temp_umap.end(); it++)
	{
		total += "\t" + it->second.tipo + " " + it->first + ";\n";
	}

	total += "\n";

	return total;
}

/*string check_not_declared(string var_label)
{
	if(var_umap.find(user_label) == var_umap.end())
	{
		string new_label = label_generator();
		//variavel new_var = new_label;
		var_umap[user_label] = new_label;
		return new_label;
	}
}*/

string get_id_label(string user_label)
{
	if(var_umap.find(user_label) == var_umap.end())
	{
		string new_label = label_generator();
		variavel new_var;

		var_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}

	return var_umap[user_label];
}
