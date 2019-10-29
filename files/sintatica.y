%{
#include "lib/function.h"

int yylex(void);
%}

%token TK_ID
%token TK_NUM TK_REAL TK_BOOL TK_STR
%token TK_INPUT TK_PRINT

%token TK_NOT
%token TK_OP_ARIT TK_OP_REL TK_OP_LOG TK_DECR TK_INCR TK_CONT

%token TK_FOR TK_WHILE TK_IF TK_END TK_DO TK_LOOP TK_ELSEIF TK_ELSE

%token TK_CASTING
%token TK_FIM TK_ERROR
%token TK_FIM_LINHA
%token TK_SWITCH TK_CASE TK_DEFAULT

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


BLOCO		: TK_DO TK_FIM_LINHA COMANDOS BL_END
			{
				$$.traducao = $3.traducao;
			}
			;


BL_IF		: TK_DO COMANDOS BL_ELSE
			{
				$$.traducao =  $2.traducao;
				$$.traducao += $3.traducao;
			};


BL_ELSE		: TK_ELSEIF '(' E ')' BL_IF
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("condition errada");
				}

				$$.traducao = "\t}\n";
				$$.traducao += "\telse\n\t{\n" + $3.traducao;
				$$.traducao += "\n\tif(";
				$$.traducao += $3.label;
				$$.traducao += ")\n\t{\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\n\t}\n";
			}
			| TK_ELSE TK_DO COMANDOS BL_END
			{
				$$.traducao =  "\t\telse\n";
				$$.traducao += "\t{\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t}\n";
			}
			| BL_END
			{
				$$.traducao = "\t}\n";
			};


REC_NUM:	TK_NUM ',' REC_NUM
			{
				caseSwitchCounter++;
				cout << "case: " << caseSwitchCounter << endl;

				/*string cmd_label = cmd_label_generator();
				$$.traducao += "\tif(" + $$.label + ")\n";
				$$.traducao += "\tgoto " + cmd_label + ";\n";*/
				string new_label;
				umap_label_add($1.label, $1.tipo);
				umap_label_add(new_label, BOOLEAN);
				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + new_label + " = " + "VAR_LABEL == " + $1.label + ";\n/**/\n";
				$$.traducao += $3.traducao;
				//$$.label += new_label + $3.label;
				//cout << $$.label << endl;
				//$$.traducao += $$.label + " ";
			}
			| TK_NUM ':'
			{
				//string cmd_label = cmd_label_generator();
				//cmdLabelContador++;
				//caseSwitchCounter++;
				//string cmd_label = cmd_label_generator();
				//cmdLabelContador--;
				//cout << $$.label + "AQUI" << endl;
				string new_label;
				umap_label_add($1.label, $1.tipo);
				umap_label_add(new_label, BOOLEAN);
				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + new_label + " = " + "VAR_LABEL == " + $1.label + ";\n";
				$$.traducao += "\tif(" + new_label + ")\n\t{\n";
				//$$.traducao += "\tgoto " + cmd_label + ";\n/**/\n";
			};


BL_CASE:    TK_CASE REC_NUM COMANDOS BL_CASE
			{
				//caseSwitchCounter--;
				//cmdLabelContador -= caseSwitchCounter;
				//string cmd_label[2] = {cmd_label_generator(), cmd_label_end_generator()};

				$$.traducao = $2.traducao;
				//$$.traducao += "\t" + cmd_label[0] + ":\n";
				$$.traducao += $3.traducao + "\t}\n/**/\n";
				//$$.traducao += "\t" + cmd_label[1] + ":\n/**/\n";
				$$.traducao += $4.traducao;
			}
			| BL_DEFAULT
			{
				//caseSwitchCounter = 0;
				$$.traducao = $1.traducao;
			};


BL_DEFAULT: TK_DEFAULT ':' COMANDOS BL_END
			{
				$$.traducao =  "\telse\n";
				$$.traducao += "\t{\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t}\n/**/\n";
			};


BL_SWITCH:	TK_DO TK_FIM_LINHA BL_CASE
			{
				$$.traducao = $3.traducao;
			};


COMANDOS	: COMANDO TK_FIM_LINHA COMANDOS
			{
				//$$.label = "";
				$$.traducao = $1.traducao + $3.traducao;
				// cout << $2.traducao << endl;
				// replace_all($2.traducao, "\n", "A");
				// cout << $2.traducao + " 1st rule" << endl;
			}
			| TK_FIM_LINHA COMANDOS
			{
				$$.traducao = $2.traducao;
				// replace_all($1.traducao, "\n", "A");
				// cout << $1.traducao + " 2nd rule" << endl;
			}
			| //REGRA VAZIA
			{
				//$$.label = "";
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
					$$.traducao =  $3.traducao + "\t" + string("cout >> ") + $3.label + ";\n";
				}
			}

			| TK_SWITCH '(' TK_ID ')' BL_SWITCH
			{
				if( $3.tipo != INT )//POR ENQUANTO
				{
					yyerror(string("Tipo ") + " invalido para comando SWITCH.");
				}

				string label = search_variable($3.traducao);

				if(label == "0")
				{
					yyerror("Variável não declarada anteriormente");
				}

				replace_all($5.traducao, "VAR_LABEL", label);

				$$.traducao = "\n" + $5.traducao;
			}

			| TK_LOOP '(' E ')'	BLOCO//while
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("condition errada");
				}

				string new_label = label_generator();
				string cmd_label[2] = {cmd_label_generator(), cmd_label_end_generator()};
				cmdLabelContador++;
				umap_label_add(new_label, BOOLEAN);

				$$.traducao = "\n\t" + cmd_label[0] + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t" + new_label + " = !(" + $3.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + cmd_label[1] + ";\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\tgoto " + cmd_label[0] + ";\n";
				$$.traducao += "\t" + cmd_label[1] + ":\n\n";
			}
			| BLOCO TK_LOOP '(' E ')'//do while
			{
				if($4.tipo != BOOLEAN)
				{
					yyerror("condition errada");
				}

				string new_label = $4.label;
				string cmd_label[2] = {cmd_label_generator(), cmd_label_end_generator()};
				cmdLabelContador++;
				//cout << $4.label;

				$$.traducao = "\n\t" + cmd_label[0] + ":\n";
				$$.traducao += $1.traducao;
				//$$.traducao += "\t" + new_label + " = !(" + $6.label + ");\n";
				$$.traducao += $4.traducao;
				$$.traducao += "\tif(" + new_label + ") " + "goto " + cmd_label[0] + ";\n";
				//$$.traducao += "\tgoto " + cmd_label[0] + ";\n";
				$$.traducao += "\t" + cmd_label[1] + ":\n\n";
			}
			| TK_LOOP '(' ATR ';' E ';' CONT ')' BLOCO //for
			{
				if($2.tipo != BOOLEAN)
				{
					yyerror("This condition is not a boolean.\n");
				}

				string new_label;
				string cmd_label[2] = {cmd_label_generator(), cmd_label_end_generator()};
				cmdLabelContador++;

				umap_label_add(new_label, BOOLEAN);

				$$.traducao = $3.traducao;
				$$.traducao += "\n\t" + cmd_label[0] + ":\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\t" + new_label + " = !(" + $5.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + cmd_label[1] + ";\n";
				$$.traducao += $9.traducao;
				$$.traducao += $7.traducao;
				$$.traducao += "\tgoto " + cmd_label[0] + ";\n";
				$$.traducao += "\t" + cmd_label[1] + ":\n\n";
			}
			| TK_IF '(' E ')' BL_IF
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("Erro\n");
				}

				$$.traducao = $3.traducao;
				$$.traducao += "\tif(" + $3.label + ")\n";
				$$.traducao += "\t{\n";
				$$.traducao += $5.traducao;
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
					string var = multiple_atr_queue.back();
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
				/*if( $2.label != "int" && $2.label != "double")
				{
					yyerror("erro na conversao");
				}*/
				$$.tipo = tipo_umap_str[$2.label];
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $4.traducao;

				if($$.tipo == BOOLEAN)
				{
					yyerror("Não existe conversão para boolean");
				}

				if($$.tipo == $4.tipo)
				{
					yyerror(string("Não pode converter a variável para o tipo \"") + $2.label + string("\", pois ela já é desse tipo"));
				}

				if($4.tipo == STRING)
				{
					if($$.tipo == DOUBLE)
					{
						$$.traducao += string_to_double($4.label, $$.label);
					}
					else if($$.tipo == INT)
					{
						$$.traducao += string_to_int($4.label, $$.label);
					}
				}
				else
				{
					$$.traducao += "\t" + $$.label + " = " + "(" + $2.label + ") " + $4.label + ";\n";
				}
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

					umap_label_add($$.label, STRING, true);
					string label_tamanho = temp_umap[$$.label].size_label;

					$$.traducao = string("\t") + string("cin >> buffer;\n");
					$$.traducao += countStringProc();
					$$.traducao += "\t" + label_tamanho + " = countTempLabel;\n";
					$$.traducao += "\t" + $$.label + " = (char*) malloc("+ label_tamanho +");\n";
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

				umap_label_add($$.label, STRING, true);
				string label_tamanho = temp_umap[$$.label].size_label;

				$$.traducao = "\t" + string("cin >> buffer;\n");
				$$.traducao += countStringProc();
				$$.traducao += "\t" + label_tamanho + " = countTempLabel;\n";
				//falta adicionar casting para o malloc
				$$.traducao += "\t" + $$.label + " = (char*) malloc("+ label_tamanho +");\n";
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
				//cout << $$.label;
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

				umap_label_add($$.label, $$.tipo, true);
				//cout << "label: " << $$.label << endl;
				string label_tamanho = temp_umap[$$.label].size_label;
				$$.traducao = "\t" + label_tamanho + " = " + to_string(str.length() + 1) + ";\n";
				$$.traducao += "\t" + $$.label + " = (char*) malloc("+ label_tamanho +");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", \"" + str + "\");\n";
			}
			| TK_ID
			{
				$$.label = get_id_label($1.traducao);
				//cout << $$.label << endl;
				$$.tipo = temp_umap[$$.label].tipo;

				if ($$.tipo == 0)
				{
					yyerror("variable " + $1.traducao + " not declared");
				}

				$$.traducao = "";
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

				$1.label = get_id_label($1.traducao);
				multiple_atr_queue.push($1.label);
				multiple_atr_stack.push(pair_exp);
			}
			;


ATR 		: TK_ID '=' E
			{
				//no caso da variavel ja ter um tipo setado no codigo
				$1.label = get_current_context_id_label($1.traducao);
				//cout << $1.label;

				bool hasTamanho = false;

				if($3.tipo == STRING) //add new types with size in if clause, as vectors, matrices
				{
					hasTamanho = true;
					temp_umap[$1.label].size_label = temp_umap[$3.label].size_label;
				}

				if( temp_umap[$1.label].tipo != 0 && temp_umap[$1.label].tipo != $3.tipo )
				{
					$$.tipo = $3.tipo;
					//criar uma temporaria nova pra guardar o antigo valor
					$$.label = add_variable_in_current_context($1.traducao, $$.tipo, hasTamanho);
				}
				else
				{
					$$.tipo = $3.tipo;
					auto& cur_umap = context_stack.back();
					temp_umap[cur_umap[$1.traducao]].tipo = $3.tipo;
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
				if($2.tipo != BOOLEAN)
				{
					yyerror("O operador \"not\" não pode ser utilizado com variável do tipo " + tipo_umap[$2.tipo]);
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
			};


BL_END		: TK_END
			{
				endContext();
				$$.traducao = "";
			};

%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{
	yy_flex_debug = 1;
	yydebug = 1;
	context_stack.push_back(unordered_map<string, string>());
	initialize_tipo_umap();
	initialize_proc_temp_umap();
	initialize_matrix();
	initialize_op_umap();
	yyparse();

	return 0;
}
