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

#define ERROR_VALUE "-1"
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
unordered_map<string, int> tipo_umap_str;
unordered_map<int, string> op_umap;
unordered_map<string, int> op_umap_str;

queue <string> multiple_atr_queue;
stack <pair<string, int>> multiple_atr_stack;

string matrix[QTD_OPERATORS + 1][QTD_TYPES + 1][QTD_TYPES + 1];

int tokenContador = 0;
int contadorLinha = 0;

string label_generator();
int yylex(void);
void yyerror(string);
string get_id_label(string user_label);
string declare_variables();
void initialize_tipo_umap();
void initialize_matrix();
void replace_all(std::string & data, std::string toSearch, std::string replaceStr);
void umap_label_add(string& new_label, int new_tipo);
void replace_op(string& op_type, string new_label, string first_label, string second_label, string final_label, string op);
void initialize_op_umap();

%}

%token TK_NUM TK_REAL TK_BOOL

%token TK_MAIN TK_END TK_OP_ARIT TK_OP_REL
%token TK_ID TK_TIPO_INT TK_TIPO_STRING TK_TIPO_DOUBLE TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL
%token TK_AND TK_OR TK_NOT TK_EQ TK_NEQ
%token TK_FOR TK_WHILE TK_IF TK_GEQ TK_LEQ

%token TK_CASTING
%token TK_FIM TK_ERROR
%token TK_FIM_LINHA


%start S

%left '='
%left '>' '<' TK_EQ TK_NEQ TK_LEQ TK_GEQ
%left '+' '-'
%left '*' '/'
%left '(' ')'

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

COMANDO 	: E
			{
				$$.traducao = $1.traducao;
			}
			| E TK_FIM_LINHA
			{
				$$.traducao = $1.traducao;
			}
			| TK_ID ',' REC_ATR ',' E TK_FIM_LINHA
			{
				string newlabel;
				umap_label_add(newlabel, $5.tipo);
				
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

E 			: | '(' E ')'
			{

				$$.tipo = $2.tipo;

				$$.label = label_generator(); //$$.label = $2.label
				variavel v; //useless
				v.tipo = $$.tipo; //useless
				temp_umap[$$.label] = v; //useless

				$$.resultado = $2.resultado;
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + ";\n";

			}
			| '(' TK_CASTING ')' E
			{
				if( $2.label != "int" && $2.label != "double")
				{
					yyerror("erro na conversao");
				}

				if( $2.label == "boolean" && $4.tipo != BOOLEAN )
				{
					yyerror("n tem como converter pra boolean");
				}
				
				$$.tipo = tipo_umap_str[$2.label];
				umap_label_add($$.label, $$.tipo);

				$$.traducao = $4.traducao + "\t" + $$.label + " = " + "(" + $2.label + ")" + $4.label + ";\n";
			}
			| E TK_OP_ARIT E
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.resultado = $1.resultado + $3.resultado;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " " + $2.traducao + " " + $3.label + ";\n";

			}
			| E TK_OP_REL E
			{
				
				int op = op_umap_str[$2.traducao];
				string op_type = matrix[op][$1.tipo][$3.tipo];
				string new_label;
				int new_type = op_type[0] - '0';

				cout << op << endl << $2.traducao << endl << op_umap[op] << endl;
				$$.resultado = 0;
				$$.tipo = BOOLEAN;

				umap_label_add($$.label, $$.tipo);
				umap_label_add(new_label, new_type);

				op_type.replace(0, 1, "");
				replace_op(op_type, new_label, $1.label, $3.label, $$.label, op_umap[op]);

				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += op_type;

				if(op_type == ERROR_VALUE)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
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

				string op_type = matrix[AND][$1.tipo][$3.tipo];

				if(op_type == ERROR_VALUE)
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

				string op_type = matrix[OR][$1.tipo][$3.tipo];

				if(op_type == ERROR_VALUE)
				{
					yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
				}

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " || " + $3.label + ";\n";
			}
			| TK_NOT E
			{
				if($1.tipo != BOOLEAN)
				{
					yyerror("\nO operador \"not\" não pode ser utilizado com variável do tipo " + tipo_umap[$2.tipo]);
				}

				$$.tipo = $2.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + "!" + " " + $2.label + ";\n";
			}
			| TK_ID '=' E
			{
				//no caso da variavel ja ter um tipo setado no codigo
				if( temp_umap[$1.label].tipo != 0 && temp_umap[$1.label].tipo != $3.tipo )
				{
					$$.tipo = $3.tipo;

					//criar uma temporaria nova pra guardar o antigo valor
					umap_label_add($$.label, $$.tipo);
					var_umap[$1.traducao] = $$.label;
				}
				else
				{
					$$.tipo = $3.tipo;
					temp_umap[var_umap[$1.traducao]].tipo = $3.tipo;
					$$.label = $1.label;
				}

				$$.resultado = $1.resultado;
				$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n";
			}
			| TK_NUM
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.resultado = stoi($1.traducao);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_REAL
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
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
				umap_label_add($$.label, $$.tipo);
				$$.resultado = 0;

				cout << $$.label << endl << $$.tipo << endl;

				$$.traducao = "\t" + $$.label + " = " + ($1.traducao == "true"? "1" : "0") + ";\n";
			}
			;

REC_ATR		: TK_ID ',' REC_ATR ',' E
			{
				//create $5 copy to multiple assignment
				string newlabel;
				umap_label_add(newlabel, $5.tipo);

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
				string newlabel;
				umap_label_add(newlabel, $3.tipo);

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
	initialize_op_umap();
	yyparse();

	return 0;
}

void yyerror( string MSG )
{
	cout << "linha " << contadorLinha << ": " <<  MSG << endl;
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

string get_id_label(string user_label)
{
	if(var_umap.find(user_label) == var_umap.end())
	{
		string new_label = label_generator();
		variavel new_var;
		new_var.user_label = user_label;
		new_var.tipo = 0;

		var_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}

	return var_umap[user_label];
}

void initialize_tipo_umap()
{
	tipo_umap[INT] = "int";
	tipo_umap[STRING] = "string";
	tipo_umap[BOOLEAN] = "int";
	tipo_umap[DOUBLE] = "double";

	tipo_umap_str["int"] = INT;
	tipo_umap_str["string"] = STRING;
	tipo_umap_str["int"] = BOOLEAN;
	tipo_umap_str["double"] = DOUBLE;
}

void initialize_matrix()
{
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

	for(int i = SUM; i <= MORE; i++)
	{
		for(int j = INT; j <= DOUBLE; j++)
		{
			for(int k = INT; k <= DOUBLE; k++)
			{
				if(j < k)
				{
					matrix[i][j][k] = to_string(k) + "\tnew_label = ("+ tipo_umap[k] + ") first_label;\n\tfinal_label = new_label operator second_label;\n";
				}
				else if(j > k)
				{
					matrix[i][j][k] = to_string(j) + "\tnew_label = ("+ tipo_umap[j] + ") second_label;\n\tfinal_label = first_label operator new_label;\n";
				}
				else if(j == k)
				{
					matrix[i][j][k] = to_string(j) + "\tfinal_label = first_label operator second_label;\n";
				}
			}
		}
	}

	for(int i = AND; i <= OR ; i++)
	{
		matrix[i][BOOLEAN][BOOLEAN] = to_string(BOOLEAN) + "final_label = first_label operator second_label;\n";
	}
}

void replace_all(std::string & data, std::string toSearch, std::string replaceStr)
{
	// Get the first occurrence
	size_t pos = data.find(toSearch);
 
	// Repeat till end is reached
	while( pos != std::string::npos)
	{
		// Replace this occurrence of Sub String
		data.replace(pos, toSearch.size(), replaceStr);
		// Get the next occurrence from the current position
		pos = data.find(toSearch, pos + replaceStr.size());
	}
}

void umap_label_add(string& new_label, int new_tipo)
{
	new_label = label_generator();
	
	variavel new_var;
	new_var.tipo = new_tipo;
	temp_umap[new_label] = new_var;
}

void replace_op(string& op_type, string new_label, string first_label, string second_label, string final_label, string op)
{
	replace_all(op_type, "new_label", new_label);
	replace_all(op_type, "first_label", first_label);
	replace_all(op_type, "second_label", second_label);
	replace_all(op_type, "final_label", final_label);
	replace_all(op_type, "operator", op);
}

void initialize_op_umap()
{
	op_umap[SUM] = "+";
	op_umap[DIFF] = "-";
	op_umap[MULT] = "*";
	op_umap[DIV] = "/";

	op_umap[GEQ] = ">=";
	op_umap[LEQ] = "<=";
	op_umap[LESS] = "<";
	op_umap[MORE] = ">";

	op_umap[EQ] = "==";
	op_umap[NEQ] = "!=";
	
	op_umap[AND] = "&&";
	op_umap[OR] = "||";

    op_umap_str["+"] = SUM;
	op_umap_str["-"] = DIFF;
	op_umap_str["*"] = MULT;
	op_umap_str["/"] = DIV;

	op_umap_str[">="] = GEQ;
	op_umap_str["<="] = LEQ;
	op_umap_str["<"] = LESS;
	op_umap_str[">"] = MORE;

	op_umap_str["eq"] = EQ;
	op_umap_str["neq"] = NEQ;

	op_umap_str["and"] = AND;
	op_umap_str["or"] = OR;
}

/*
a = 1\n\n
TK_ID = TK_NUM\n\n
E\n\n
COMANDO\n\n
*/

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

/*
			| E '+' E
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
			*/
			/*
				a = 2.0 > 1
				temp1 = 2.0
				temp2 = 1
				temp4 = (float) temp2
				temp3 = temp1 > temp4
				temp0 = temp3
			*/
			/*
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
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
				}
			}
			*/