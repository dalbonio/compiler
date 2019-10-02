%{
#include "lib/function.h"

int yylex(void);
%}

%token TK_ID
%token TK_NUM TK_REAL TK_BOOL TK_STR
%token TK_INPUT TK_PRINT

%token TK_NOT
%token TK_OP_ARIT TK_OP_REL TK_OP_LOG TK_DECR TK_INCR TK_CONT

%token TK_FOR TK_WHILE TK_IF TK_END TK_DO TK_LOOP TK_ELSE

%token TK_CASTING
%token TK_FIM TK_ERROR
%token TK_FIM_LINHA

%start S

%left '='
%left TK_OP_LOG
%left TK_OP_REL
%left TK_NOT
%left '+'
%left '-'
%left '*' '/'
%left '(' ')'

%%

S 			: BP //bloco principal
			{
				cout << "\n/*Compilador FOCA*/\n";
				cout << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n";
				cout <<	"\nint main(void)\n{\n";
				cout << "\tchar buffer[700];\n";
				cout << declare_variables();
				cout << $1.traducao << "\n\treturn 0;\n}" << endl;
			}
			;

BP			: COMANDOS
			{
				$$.traducao = $1.traducao;
			}
			;

BLOCO		: TK_DO TK_FIM_LINHA COMANDOS TK_END
			{
				$$.traducao = $3.traducao;
			}
			;

COMANDOS	: COMANDO TK_FIM_LINHA COMANDOS
			{
				$$.label = "";
				$$.traducao = $1.traducao + $3.traducao;
				//replace_all($2.traducao, "\n", "A");
				//cout << $2.traducao;
			}
			| TK_FIM_LINHA COMANDOS
			{
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
			| TK_PRINT '(' E ')'
			{
				if( $3.tipo == BOOLEAN )
				{
					$$.traducao = $3.traducao + "\t" + string("if(") + $3.label + ")" + " cout << \"true\"; else cout << \"false\";\n";
				}
				else
				{
					$$.traducao =  $3.traducao + "\t" + string("cout >> ") + $$.label + ";\n";
				}
			}
			| TK_LOOP '(' E ')'	BLOCO//while
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("condition errada");
				}

				string new_label = label_generator();
				string loop_label[2] = {loop_label_generator(), loop_label_end_generator()};
				umap_label_add(new_label, BOOLEAN);

				$$.traducao = $3.traducao;
				$$.traducao += "\n\t" + loop_label[0] + ":\n";
				$$.traducao += "\t" + new_label + " = !(" + $3.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + loop_label[1] + ";\n";
				$$.traducao += $4.traducao;
				$$.traducao += "\tgoto " + loop_label[0] + ";\n";
				$$.traducao += "\t" + loop_label[1] + ":\n\n";
			}
			| BLOCO TK_LOOP '(' E ')'//do while
			{
				if($4.tipo != BOOLEAN)
				{
					yyerror("condition errada");
				}

				string new_label = $4.label;
				string loop_label[2] = {loop_label_generator(), loop_label_end_generator()};
				cout << $4.label;

				$$.traducao = $4.traducao;
				$$.traducao += "\n\t" + loop_label[0] + ":\n";
				$$.traducao += $1.traducao;
				//$$.traducao += "\t" + new_label + " = !(" + $6.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + loop_label[0] + ";\n";
				//$$.traducao += "\tgoto " + loop_label[0] + ";\n";
				$$.traducao += "\t" + loop_label[1] + ":\n\n";
			}
			| TK_LOOP '(' ATR ';' COND ';' CONT ')' BLOCO //for
			{
				string new_label;
				string loop_label[2] = {loop_label_generator(), loop_label_end_generator()};

				umap_label_add(new_label, BOOLEAN);

				$$.traducao = $3.traducao;
				$$.traducao += "\n\t" + loop_label[0] + ":\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\t" + new_label + " = !(" + $5.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + loop_label[1] + ";\n";
				$$.traducao += $9.traducao;
				$$.traducao += $7.traducao;
				$$.traducao += "\tgoto " + loop_label[0] + ";\n";
				$$.traducao += "\t" + loop_label[1] + ":\n\n";
			}
			| TK_ID ',' REC_ATR ',' E
			{
				string newlabel;
				string local_traducao;
				pair<string, int> pair_exp;

				umap_label_add(newlabel, $5.tipo);

				local_traducao = "\t" + newlabel + " = " + $5.label + ";\n";
				pair_exp.first = newlabel;
				pair_exp.second = $5.tipo;

				multiple_atr_queue.push($1.label);
				multiple_atr_stack.push(pair_exp);


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

E 			: '(' E ')'
			{

				$$.tipo = $2.tipo;

				$$.label = label_generator(); //$$.label = $2.label
				variavel v; //useless
				v.tipo = $$.tipo; //useless
				temp_umap[$$.label] = v; //useless

				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + ";\n";
				//$$.resultado = $2.resultado;

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
			| TK_INPUT '(' TK_CASTING ')'
			{
				if($3.label == "boolean")
				{
					yyerror("nao tem como fazer input em boolean");
				}

				if($3.label == "string")
				{
					$$.tipo = STRING;
					string label_tamanho;

					umap_label_add($$.label, STRING);
					umap_label_add(label_tamanho, INT);

					$$.traducao = "\t" + string("cin >> buffer;\n");
					$$.traducao += "\t" + label_tamanho + " = strlen(buffer);\n";
					$$.traducao += "\t" + $$.label + " = malloc("+ label_tamanho +");\n";
					$$.traducao += "\tstrcpy(" + $$.label + ", buffer);\n";
				}
				else
				{
					$$.tipo = tipo_umap_str[$3.label];
					umap_label_add($$.label, $$.tipo);
					$$.traducao = "\t" + string("cin >> ") + $$.label + ";\n";
				}
			}
			| TK_INPUT '(' ')'
			{
				$$.tipo = STRING;
				$$.label = label_generator();
				string label_tamanho = label_generator();

				umap_label_add($$.label, STRING);
				umap_label_add(label_tamanho, INT);

				$$.traducao = "\t" + string("cin >> buffer;\n");
				$$.traducao += "\t" + label_tamanho + " = strlen(buffer);\n";
				$$.traducao += "\t" + $$.label + " = malloc("+ label_tamanho +");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", buffer);\n";
			}
			| TK_OP_ARIT E
			{
				if($1.traducao != "-")
				{
					yyerror("operation before expression");
				}

				if($2.tipo != INT && $2.tipo != DOUBLE)
				{
					yyerror("this operation is not allowed for this primitive");
				}

				$$.tipo = $2.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + $2.label + " * -1;\n";
				//$$.resultado = $2.resultado * -1;
			}
			| E TK_OP_ARIT E
			{
				variavel new_var;

				$$.label = label_generator();
				$$.traducao = $1.traducao + $3.traducao;
				
				$$.traducao += implicit_conversion_op($$, $1, $2, $3, 0);
				
				new_var.tipo = $$.tipo;
				temp_umap[$$.label] = new_var;
				//$$.resultado = $1.resultado + $3.resultado;
			}
			| COND
			{
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| CONT
			{
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| ATR
			{
				$$.traducao = $1.traducao;
			}
			| TK_NUM
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				//$$.resultado = stoi($1.traducao);
			}
			| TK_REAL
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
				//$$.resultado = stoi($1.traducao);
			}
			| TK_BOOL
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + ($1.traducao == "true"? "1" : "0") + ";\n";
				//$$.resultado = 0;
			}
			| TK_STR
			{
				$$.tipo = $1.tipo;
				string str = $1.traducao;
				str = str.substr(1, str.length() - 2); //remove quotes from lex rule

				replace_all(str, "\\n", ""); //feature para permitir string de varias linhas

				string label_tamanho = label_generator();
				umap_label_add($$.label, $$.tipo);
				umap_label_add(label_tamanho, INT);

				$$.traducao = "\t" + label_tamanho + " = " + to_string(str.length() + 1) + ";\n";
				$$.traducao += "\t" + $$.label + " = malloc("+ label_tamanho +");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", \"" + str + "\");\n";
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
				//$$.resultado = 0;
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

ATR 		: TK_ID '=' E
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

				$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n";
				//$$.resultado = $1.resultado;
			};

COND 		: E TK_OP_REL E
			{

				$$.tipo = BOOLEAN;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += implicit_conversion_op($$, $1, $2, $3, BOOLEAN);
				//$$.resultado = 0;

			}
			| E TK_OP_LOG E
			{
				$$.tipo = BOOLEAN;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += implicit_conversion_op($$, $1, $2, $3, BOOLEAN);
				//$$.resultado = 0;
			}
			| TK_NOT E
			{
				if($1.tipo != BOOLEAN)
				{
					yyerror("\nO operador \"not\" não pode ser utilizado com variável do tipo " + tipo_umap[$2.tipo]);
				}

				$$.tipo = $2.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + "!" + "(" + $2.label + ");\n";
			}
			;

CONT		: TK_ID TK_CONT E
			{
				if(temp_umap[$1.label].tipo == 0 || temp_umap[$1.label].tipo >= BOOLEAN)
				{
					yyerror("NO!!!");
				}

				$$.traducao = $3.traducao;

				if($1.tipo != $3.tipo)
				{
					string new_label;
					umap_label_add(new_label, $1.tipo);

					$$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[$1.tipo] + ") " + $3.label + ";\n";
					$$.traducao += "\t" + $1.label + " = " + $1.label + " " + $2.traducao[0] + " " + new_label + ";\n";
				}
				else
				{
					$$.traducao += "\t" + $1.label + " = " + $1.label + " " + $2.traducao[0] + " " + $3.label + ";\n";
				}
			}
			| TK_ID TK_INCR
			{
				string new_label;
				string value;

				switch(temp_umap[var_umap[$1.traducao]].tipo)
				{
					case INT:
					{
						value = "1";
					}
					break;

					case DOUBLE:
					{
						value = "1.0";
					}
					break;
				}

				umap_label_add(new_label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				//$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label;
				$$.traducao = "\t" + new_label + " = " + value + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " + " + new_label + ";\n";
			}
			| TK_ID TK_DECR
			{
				string new_label;
				string value;

				switch(temp_umap[var_umap[$1.traducao]].tipo)
				{
					case INT:
					{
						value = "1";
					}
					break;

					case DOUBLE:
					{
						value = "1.0";
					}
					break;
				}

				umap_label_add(new_label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				//$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label;
				$$.traducao = "\t" + new_label + " = " + value + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " - " + new_label + ";\n";
			}
			;

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yy_flex_debug = 1;
	yydebug = 1;
	initialize_tipo_umap();
	initialize_matrix();
	initialize_op_umap();
	yyparse();

	return 0;
}
