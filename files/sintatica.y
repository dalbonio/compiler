%{
#include "lib/function.h"

int yylex(void);
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
%left '+'
%left '-'
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
			| TK_OP_ARIT E
			{
				if($1.traducao != "-")
				{
					yyerror("operation before expression");
				}

				$$.tipo = $2.tipo;
				if($2.tipo != INT && $2.tipo != DOUBLE)
				{
					yyerror("this operation is not allowed for this primitive");
				}

				umap_label_add($$.label, $$.tipo);
				$$.resultado = $2.resultado * -1;
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + " * -1;\n";

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
				if ($$.tipo == 0)
				{
					yyerror("variable " + $1.traducao + " not declared");
				}
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
