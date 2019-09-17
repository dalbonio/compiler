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

#define ERROR_VALUE -1
#define QTD_OPERATORS 12
#define QTD_TYPES 4

#define INT 1
#define DOUBLE 2
#define BOOLEAN 3
#define STRING 4

#define SUM 1
#define DIFF 2
#define MULT 3
#define DIV 4

#define EQ 5
#define NEQ 6
#define GEQ 7
#define LEQ 8
#define LESS 9
#define MORE 10

#define AND 11
#define OR 12

using namespace std;

struct variavel
{
	string user_label;
	int tipo;
};

struct atributos
{
	string label;
	string traducao;
	int resultado;
	int tipo;
};

unordered_map<string, string> var_umap;
unordered_map<string, variavel> temp_umap;
unordered_map<int, string> tipo_umap;

queue <string> multiple_atr_queue;
stack <pair<string, int>> multiple_atr_stack;

int matrix[QTD_OPERATORS + 1][QTD_TYPES + 1][QTD_TYPES + 1];

int tokenContador = 0;

string label_generator();
int yylex(void);
void yyerror(string);
string get_id_label(string user_label);
string declare_variables();
void initialize_tipo_umap();
void initialize_matrix();

%}

%token TK_NUM TK_REAL TK_BOOL

%token TK_MAIN TK_END
%token TK_ID TK_TIPO_INT TK_TIPO_STRING TK_TIPO_DOUBLE TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_AND TK_OR TK_NOT TK_EQ TK_NEQ
%token TK_FOR TK_WHILE TK_IF TK_GEQ TK_LEQ

%token TK_FIM TK_ERROR
%token TK_FIM_LINHA


%start S

%left '='
%left '>' '<' TK_EQ TK_NEQ TK_LEQ TK_GEQ
%left '+' '-'
%left '*' '/'

%%

S 			: BLOCO
			{
				cout << "\n/*Compilador FOCA*/\n";
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
			| TK_FIM_LINHA COMANDOS	//poder pular linha qt quiser no codigo
			{
				$$.label = "";
				$$.traducao = $2.traducao;
			}
			| //REGRA VAZIA
			{
				$$.label = "";
				$$.traducao = "";
			}
			;
/*
a = 1\n\n
TK_ID = TK_NUM\n\n
E\n\n
COMANDO\n\n

*/

COMANDO 	: E
			{
				$$.traducao = $1.traducao;
			}
			/*
			| E TK_FIM_LINHA
			{
				$$.traducao = $1.traducao;
			}
			*/
			| TK_ID ',' REC_ATR ',' E TK_FIM_LINHA
			{
				string newlabel = label_generator();
				variavel v;
				v.tipo = $5.tipo;
				temp_umap[newlabel] = v;

				pair<string, int> pair_exp;
				pair_exp.first = newlabel;
				pair_exp.second = $5.tipo;

				multiple_atr_queue.push($1.label);
				multiple_atr_stack.push(pair_exp);

				string local_traducao = "\t" + newlabel + " = " + $5.label + ";\n";

				while(!multiple_atr_queue.empty() || !multiple_atr_stack.empty() )
				{
					string var = multiple_atr_queue.front();
					pair<string, int> exp = multiple_atr_stack.top();

					temp_umap[var].tipo = exp.second;

					local_traducao += "\t" + var + " = " + exp.first + ";\n";

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
			| E '>' E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[MORE][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " > " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " > " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " > " + $3.label + ";\n";
				}
			}
			| E '<' E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[LESS][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " < " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " < " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " < " + $3.label + ";\n";
				}
			}
			| E TK_GEQ E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[GEQ][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " >= " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " >= " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " >= " + $3.label + ";\n";
				}
			}
			| E TK_LEQ E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[MORE][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " <= " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " <= " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " <= " + $3.label + ";\n";
				}
			}
			| E TK_EQ E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[EQ][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " == " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " == " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " == " + $3.label + ";\n";
				}
			}
			| E TK_NEQ E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.traducao = $1.traducao + $3.traducao;

				string new_label;
				int op_type = matrix[NEQ][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				if($1.tipo != op_type || $3.tipo != op_type)
				{
					new_label = label_generator();
					variavel vv;
					vv.tipo = op_type;
					temp_umap[new_label] = vv;

					if($1.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + new_label + " != " + $3.label + ";\n";
					}
					else if($3.tipo != op_type)
					{
						$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + " != " + new_label + ";\n";
					}
					
					/*
						a = 2.0 > 1
						temp1 = 2.0
						temp2 = 1
						temp4 = (float) temp2
						temp3 = temp1 > temp4
						temp0 = temp3
					*/
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
				}
			}
			| E TK_AND E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;

				int op_type = matrix[AND][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " && " + $3.label + ";\n";
			}
			| E TK_OR E
			{
				$$.label = label_generator();
				$$.resultado = 0;
				$$.tipo = BOOLEAN;
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;

				int op_type = matrix[OR][$1.tipo][$3.tipo];

				if(op_type == -1)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}
				
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " || " + $3.label + ";\n";
			}
			| TK_NOT E
			{
				/*if($1.tipo != BOOLEAN)
				{
					erro
				}*/
				$$.tipo = $2.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				cout << !(1) << !(0);
				$$.resultado = 0;
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + "!" + " " + $2.label + ";\n";
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
			| TK_BOOL
			{
				$$.tipo = $1.tipo;
				$$.label = label_generator();
				variavel v;
				v.tipo = $$.tipo;
				temp_umap[$$.label] = v;
				$$.resultado = 0;

				$$.traducao = "\t" + $$.label + " = " + ($1.traducao == "true"? "1" : "0") + ";\n";
				/*if ($1.traducao == "true")
				{
					$$.traducao = "\t" + $$.label + " = " + "1" + ";\n";
				}
				else
				{
					$$.traducao = "\t" + $$.label + " = " + "0" + ";\n";
				}*/
			}
			;

REC_ATR		: TK_ID ',' REC_ATR ',' E
			{
				//create $5 copy to multiple assignment
				string newlabel = label_generator();
				variavel v;
				v.tipo = $5.tipo;
				temp_umap[newlabel] = v;

				pair<string, int> pair_exp;
				pair_exp.first = newlabel;
				pair_exp.second = $5.tipo;

				multiple_atr_queue.push($1.label);
				multiple_atr_stack.push(pair_exp);

				//$$.label = label_generator();
				$$.traducao = $3.traducao + $5.traducao + "\t" + newlabel + " = " + $5.label + ";\n";
			}
			| TK_ID '=' E
			{
				//make copy of $3
				string newlabel = label_generator();
				variavel v;
				v.tipo = $3.tipo;
				temp_umap[newlabel] = v;

				pair<string, int> pair_exp;
				pair_exp.first = newlabel;
				pair_exp.second = $3.tipo;

				$$.label = "";
				$$.traducao = $3.traducao + "\t" + newlabel + " = " + $3.label + ";\n";

				multiple_atr_queue.push($1.label);
				multiple_atr_stack.push(pair_exp);
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	initialize_tipo_umap();
	initialize_matrix();
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
		total += "\t" + tipo_umap[it->second.tipo] + " " + it->first + ";\n";
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
		new_var.user_label = user_label;

		var_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}

	return var_umap[user_label];
}

void initialize_tipo_umap()
{
	tipo_umap[INT] = "int";
	//tipo_umap[STRING] = "string"
	tipo_umap[BOOLEAN] = "int";
	tipo_umap[DOUBLE] = "double";
}

void initialize_matrix()
{
	/*
		operadores aritmeticos
		string, string = string (+)
		string, float = string (+)
		string, int = string (+)

		double, double = double
		double, int = double
		int, int = int
		
		---
		operadores relacionais
		string, string = boolean (==, !=, >, <)

		double, double = boolean
		double, int = boolean
		int, int = boolean

		---
		operadores logicos
		boolean, boolean = boolean
	*/
	
	for(int i = 0; i < QTD_OPERATORS + 1; i++)
	{
		for(int j = 0; j < QTD_TYPES + 1; j++)
		{
			for(int k = 0; k < QTD_TYPES + 1; k++)
			{
				matrix[i][j][k] = ERROR_VALUE;
			}
		}
	}

	for(int i = 0; i < QTD_OPERATORS + 1; i++)
	{
		for(int j = INT; j <= DOUBLE; j++)
		{
			for(int k = INT; k <= DOUBLE; k++)
			{
				if(j == DOUBLE || k == DOUBLE)
				{
					matrix[i][j][k] = DOUBLE;
				}
				else
				{
					matrix[i][j][k] = INT;
				}
			}
		}
	}

	for(int i = AND; i <= OR ; i++)
	{
		matrix[i][BOOLEAN][BOOLEAN] = BOOLEAN;
	}

	/*matrix[SUM][DOUBLE][DOUBLE] = DOUBLE;
	matrix[SUM][DOUBLE][INT] = DOUBLE;
	matrix[SUM][INT][INT] = INT;

	matrix[DIFF][DOUBLE][DOUBLE] = DOUBLE;
	matrix[DIFF][DOUBLE][INT] = DOUBLE;
	matrix[DIFF][INT][INT] = INT;

	matrix[MULT][DOUBLE][DOUBLE] = DOUBLE;
	matrix[MULT][DOUBLE][INT] = DOUBLE;
	matrix[MULT][INT][INT] = INT;

	matrix[DIV][DOUBLE][DOUBLE] = DOUBLE;
	matrix[DIV][DOUBLE][INT] = DOUBLE;
	matrix[DIV][INT][INT] = INT;

	matrix[EQ][DOUBLE][DOUBLE] = DOUBLE;
	matrix[EQ][DOUBLE][INT] = DOUBLE;
	matrix[EQ][INT][INT] = INT;

	matrix[NEQ][DOUBLE][DOUBLE] = DOUBLE;
	matrix[NEQ][DOUBLE][INT] = DOUBLE;
	matrix[NEQ][INT][INT] = INT;

	matrix[GEQ][DOUBLE][DOUBLE] = DOUBLE;
	matrix[GEQ][DOUBLE][INT] = DOUBLE;
	matrix[GEQ][INT][INT] = INT;

	matrix[LEQ][DOUBLE][DOUBLE] = DOUBLE;
	matrix[LEQ][DOUBLE][INT] = DOUBLE;
	matrix[LEQ][INT][INT] = INT;

	matrix[MORE][DOUBLE][DOUBLE] = DOUBLE;
	matrix[MORE][DOUBLE][INT] = DOUBLE;
	matrix[MORE][INT][INT] = INT;

	matrix[LESS][DOUBLE][DOUBLE] = DOUBLE;
	matrix[LESS][DOUBLE][INT] = DOUBLE;
	matrix[LESS][INT][INT] = INT;*/
}