%{
#include "lib/function.h"

int yylex(void);
%}

%token TK_ID
%token TK_NUM TK_REAL TK_BOOL
%token TK_INPUT TK_PRINT

%token TK_NOT
%token TK_OP_ARIT TK_OP_REL TK_OP_LOG

%token TK_FOR TK_WHILE TK_IF TK_END TK_DO TK_LOOP

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

S 			: BLOCO
			{
				cout << "\n/*Compilador FOCA*/\n";
				cout << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n";
				cout <<	"\nint main(void)\n{\n";
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
			| TK_LOOP '(' E ')'	TK_DO TK_FIM_LINHA COMANDOS TK_FIM_LINHA TK_END//while
			{
				//
			}
			| TK_DO TK_FIM_LINHA COMANDOS TK_FIM_LINHA TK_LOOP '(' ')' TK_END//do while
			{

			}
			| TK_LOOP '(' ATR ';' COND ';' E ')' TK_DO TK_FIM_LINHA COMANDOS TK_FIM_LINHA TK_END//while
			/*| E TK_FIM_LINHA
			{
				$$.traducao = $1.traducao;
			}*/
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

E 			: | '(' E ')'
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

				$$.tipo = tipo_umap_str[$3.label];
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + string("cin >> ") + $$.label + ";\n";
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
				//$$.label = $1.label;
			}
			/*| E TK_OP_REL E
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
			}*/
			| ATR
			{
				$$.traducao = $1.traducao;
				//$$.label = $1.label;

				/*//no caso da variavel ja ter um tipo setado no codigo
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

				$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n";*/
				//$$.resultado = $1.resultado;
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
