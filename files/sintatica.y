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
				cout << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n";
				cout << "using namespace std;";
				cout <<	"\nint main(void)\n{\n";
				cout << "\tchar* buffer;\n";
				cout << declare_variables();
				cout << "\tgoto Start;\n";
				cout << outOfBoundsError();
				cout << "\tStart: \n" << $1.traducao << "\n\tEnd_Of_Stream:\n\treturn 0;\n}" << endl;
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
				$$.traducao = "\n/**/\n\t" + cmd_label_generator("IF") + ":\n";
				$$.traducao += $2.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator() + ";\n";
				$$.traducao += "\t" + cmd_label_end_generator("IF") + ":\n";
				$$.traducao += "\n/**/\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\n/**/\n";
				//ifLabelContador++;
				//cmdLabelContador++;
			};


BL_ELSE		: TK_ELSEIF '(' E ')' BL_IF
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("BL_ELSE -> TK_ELSEIF '(' E ')' BL_IF\ncondition errada");
				}

				//$$.traducao = "\t}\n";
				//$$.traducao += "\telse\n\t{\n";
				$$.traducao = $3.traducao;
				$$.traducao += "\n/**/\n\tif(" + $3.label + ") " + "goto " + cmd_label_generator("IF") + ";\n";
				$$.traducao += "\tgoto " + cmd_label_end_generator("IF") + ";\n";
				//$$.traducao += "\n\tif(";
				//$$.traducao += $3.label;
				//$$.traducao += ")\n\t{\n";
				//$$.traducao += "\n/**/\n";
				$$.traducao += $5.traducao;
				ifLabelContador++;
				//$$.traducao += "\n\t}\n";
			}
			| TK_ELSE TK_DO COMANDOS BL_END
			{
				//$$.traducao += "\n/**/\n";
				//$$.traducao += "\tif(" + if_condition + ") goto " + cmd_label_end_generator();
				//$$.traducao = "\t\telse\n";
				//$$.traducao += "\t{\n";
				$$.traducao = "\t" + cmd_label_generator("IF") + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator() + ";\n";
				$$.traducao += "\t" + cmd_label_end_generator("IF") + ":\n";
				ifLabelContador++;
				//$$.traducao += "\t}\n";
			}
			| BL_END
			{
				$$.traducao = "\n";
			};

REC_NUM:	TK_NUM ',' REC_NUM
			{
				string case_label;
				string new_label;

				umap_label_add($1.label, $1.tipo);
				umap_label_add(case_label, BOOLEAN);
				umap_label_add(new_label, BOOLEAN);

				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + case_label + " = " + "VAR_LABEL == " + $1.label + ";\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t" + new_label + " = " + case_label + " || " + $3.label + ";\n";

				$$.label = new_label;
			}
			| TK_NUM ':'
			{
				string case_label;

				umap_label_add($1.label, $1.tipo);
				umap_label_add(case_label, BOOLEAN);

				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + case_label + " = " + "VAR_LABEL == " + $1.label + ";\n";

				$$.label = case_label;
			};


BL_CASE:    TK_CASE REC_NUM COMANDOS BL_CASE
			{
				//\n/**/\n
				$$.traducao = $2.traducao;
				$$.traducao += "\n/**/\n\tif(" + $2.label + ") goto " + cmd_label_generator("SWITCH") + ";\n";
				$$.traducao += "\tgoto " + cmd_label_end_generator("SWITCH") + ";\n";
				$$.traducao += "\n/**/\n\t" + cmd_label_generator("SWITCH") + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t" + cmd_label_end_generator("SWITCH") + ":\n\n/**/\n";
				$$.traducao += $4.traducao;
				switchLabelContador++;
			}
			| BL_DEFAULT
			{
				$$.traducao = $1.traducao;
			};


BL_DEFAULT: TK_DEFAULT ':' COMANDOS BL_END
			{
				$$.traducao = "\t" + cmd_label_generator("SWITCH") + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator() + ";\n";
				$$.traducao += "\t" + cmd_label_end_generator("SWITCH") + ":\n\n/**/\n";
				switchLabelContador++;
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
					$$.traducao =  $3.traducao + "\t" + string("cout << ") + $3.label + " << endl;\n";
				}
			}

			| TK_SWITCH '(' TK_ID ')' BL_SWITCH
			{
				if( $3.tipo != INT )//POR ENQUANTO
				{
					yyerror("COMANDO -> TK_SWITCH '(' TK_ID ')' BL_SWITCH\n" + string("Tipo ") + " invalido para comando SWITCH.");
				}

				string label = search_variable($3.traducao);

				if(label == "0")
				{
					yyerror("COMANDO -> TK_SWITCH '(' TK_ID ')' BL_SWITCH\nVariável não declarada anteriormente");
				}

				replace_all($5.traducao, "VAR_LABEL", label);

				$$.traducao = "\n/**/\n\t" + cmd_label_generator() + ":\n";
				$$.traducao += "\n" + $5.traducao;
				$$.traducao += "\t" + cmd_label_end_generator() + ":\n";
				cmdLabelContador++;
			}

			| TK_LOOP '(' E ')' BLOCO//while
			{
				if($3.tipo != BOOLEAN)
				{
					yyerror("COMANDO -> TK_LOOP '(' E ')' BLOCO//while\ncondition errada");
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
					yyerror("COMANDO -> BLOCO TK_LOOP '(' E ')'//do while\ncondition errada");
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
			| TK_LOOP '(' ATR ';' E ';' CONT ')' BLOCO//for
			{
				if($2.tipo != BOOLEAN)
				{
					yyerror("COMANDO -> TK_LOOP '(' ATR ';' E ';' CONT ')' BLOCO//for\nThis condition is not a boolean.\n");
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
					yyerror("COMANDO -> TK_IF '(' E ')' BL_IF\nErro\n");
				}

				//string new_label;
				//umap_label_add(new_label, STRING);

				//if_condition = $3.label;
				$$.traducao = "\n/**/\n\t" + cmd_label_generator() + ":\n";
				$$.traducao += $3.traducao;
				//$$.traducao += "\t" + new_label + " = !" + $3.label + ";\n";
				$$.traducao += "\n/**/\n\tif(" + $3.label + ") " + "goto " + cmd_label_generator("IF") + ";\n";
				$$.traducao += "\tgoto " + cmd_label_end_generator("IF") + ";\n";
				//$$.traducao += "\t{\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\t" + cmd_label_end_generator() + ":\n";
				cmdLabelContador++;
				ifLabelContador++;
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
					yyerror("E -> '(' TK_CASTING ')' E\nNão existe conversão para boolean");
				}

				if($$.tipo == $4.tipo)
				{
					yyerror("E -> '(' TK_CASTING ')' E\n" + string("Não pode converter a variável para o tipo \"") + $2.label + string("\", pois ela já é desse tipo"));
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
					yyerror("E -> TK_INPUT '(' TK_CASTING ')'\nnao tem como fazer input em boolean");
				}

				if($3.label == "string")
				{
					$$.tipo = STRING;

					umap_label_add($$.label, STRING, true);
					string label_tamanho = temp_umap[$$.label].size_label;

					$$.traducao = string("\t") + string("cin >> buffer;\n");
					$$.traducao += countStringProc();
					$$.traducao += "\t" + label_tamanho + " = countTempLabel;\n";
					$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * "+ label_tamanho +");\n";
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
				$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * "+ label_tamanho +");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", buffer);\n";
			}
			| TK_OP_ARIT E//unário
			{
				if($1.traducao != "-")
				{
					yyerror("E -> TK_OP_ARIT E//unário\noperation before expression");
				}

				if($2.tipo != INT && $2.tipo != DOUBLE)
				{
					yyerror("E -> TK_OP_ARIT E//unário\nthis operation is not allowed for this primitive");
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
				$$.traducao += types_operations($$, $1, $2, $3, 0);

				new_var.tipo = $$.tipo;
				temp_umap[$$.label] = new_var;
				//cout << $$.label;
				//$$.resultado = $1.resultado + $3.resultado;
			}
			| '#' E
			{
				if(has_length.find($2.tipo) != has_length.end() )
				{
					$$.label = label_generator();
					$$.tipo = INT;
					variavel new_var;
					new_var.tipo = $$.tipo;
					temp_umap[$$.label] = new_var;
					$$.traducao = $2.traducao;
					$$.traducao += string("\t") + $$.label + " = " + temp_umap[$2.label].size_label + ";\n";
				}
				else
				{
					yyerror("E -> '#' E\nexpression has no length attribute");
				}
			}
			| E '[' E ']'
			{
				if($3.tipo != INT && $3.tipo != ITERATOR)
				{
					yyerror(string("E -> E '[' E ']'\nexpression doesnt evaluate to") + tipo_umap[$3.tipo]);
				}

				if(has_length.find($1.tipo) != has_length.end())
				{
					string size_label = temp_umap[$1.label].size_label;
					string start = temp_umap[$1.label].start_label;
					string step = temp_umap[$1.label].step_label;
					string end = temp_umap[$1.label].end_label;
					if($3.tipo != ITERATOR)
					{

						$$.traducao = $1.traducao + $3.traducao;
						$$.traducao += "\ttempPos = " + step + " * " + $3.label + ";\n";
						$$.traducao += "\ttempPos = tempPos + " + start + ";\n";
						$$.traducao += "\tif(tempPos < 0 ) tempPos = " + size_label + " + " + $3.label + ";\n";
						$$.traducao += "\telse tempPos = tempPos - 1;\n";
						$$.traducao += "\tif(tempPos < 0 ) tempPos = " + size_label + " + tempPos;\n";
						$$.traducao += "\tif(tempPos < 0 || tempPos >= " + size_label + ") goto OutOfBoundsError;\n";
						//new $$ type is array $1 associated type.
						//Ex: if $1 is int array, $$ type is int
						if($1.tipo == STRING)//substitute if by "$$.tipo = assoc_map[$1.tipo]"
						{
							$$.tipo = STRING;
							umap_label_add($$.label, $$.tipo, true);
							string label_tamanho = temp_umap[$$.label].size_label;

							$$.traducao += "\t" + label_tamanho + " = 2;\n";
							$$.traducao += "\t" + step + " = 1; //step\n";
							$$.traducao += "\t" + start + " = 0; //start\n";
							$$.traducao += "\t" + end + " = 2; //end\n";
							$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * 2);\n";
							$$.traducao += "\t" + $$.label + "[0] = " + $1.label + "[tempPos];" + $1.label + "[1] = \'\\0\';\n";
						}
					}
					else
					{
						$$.tipo = STRING;
						umap_label_add($$.label, $$.tipo, true);

						string label_tamanho_iter = temp_umap[$3.label].size_label;
						string start_old = temp_umap[$3.label].start_label;
						string step_old = temp_umap[$3.label].step_label;
						string end_old = temp_umap[$3.label].end_label;

						string label_tamanho_arr = temp_umap[$1.label].size_label;

						string label_tamanho_new = temp_umap[$$.label].size_label;
						string start_new = temp_umap[$$.label].start_label;
						string step_new = temp_umap[$$.label].step_label;
						string end_new = temp_umap[$$.label].end_label;

						$$.traducao = $1.traducao + $3.traducao;
						$$.traducao += "\tif(" + start_old + " < 0) goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + start_old + " > " + label_tamanho_arr + ") goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + end_old + " < 0) goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + end_old + " > " + label_tamanho_arr + ") goto OutOfBoundsError;\n";
						$$.traducao += "\t" + step_new + " = " + step_old + "; //step\n";
						$$.traducao += "\t" + start_new + " = " + start_old + "; //start\n";
						$$.traducao += "\t" + end_new + " = " + end_old + "; //end \n ";
						$$.traducao += "\t" + label_tamanho_new + " = " + label_tamanho_iter + "; //tamanho\n";
						$$.traducao += "\t" + $$.label + " = &" + $1.label + "[" + start_new + "]; //referece\n";
					}
				}
				else
				{
					yyerror("E -> E '[' E ']'\nexpression has no length attribute");
				}
			}
			| '(' E ')' '?' E ':' E//ternário
			{
				if($2.tipo != BOOLEAN)
				{
					yyerror("E -> E '?' E ':' E//ternário\nfirst expression is not a boolean");
				}

				$$.traducao = $2.traducao;
				$$.traducao += "\n/**/\n\tif(" + $2.label + ") " + "goto " + cmd_label_generator("IF") + ";\n";
				$$.traducao += $7.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator("IF") + ";\n";
				$$.traducao += "\n/**/\n\t" + cmd_label_generator("IF") + ":\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\t" + cmd_label_end_generator("IF") + ":\n";
				ifLabelContador++;
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
				string start = temp_umap[$$.label].start_label;
				string end = temp_umap[$$.label].end_label;
				string step = temp_umap[$$.label].step_label;

				$$.traducao = "\t" + label_tamanho + " = " + to_string(str.length() + 1) + "; //tamanho string\n";
				$$.traducao += "\t" + start + " = 0;  //start index string\n";
				$$.traducao += "\t" + end + " = " + label_tamanho + " - 1; //final index string\n";
				$$.traducao += "\t" + step + " = 1; //step string\n";
				$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * "+ label_tamanho +");\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", \"" + str + "\");\n";
			}
			| TK_ID
			{
				$$.label = get_id_label($1.traducao);
				//cout << $$.label << endl;
				$$.tipo = temp_umap[$$.label].tipo;

				if ($$.tipo == 0)
				{
					yyerror("E -> TK_ID\nvariable " + $1.traducao + " not declared");
				}

				$$.traducao = "";
			}
			| E ':' E ':' E
			{
				if( $1.tipo != INT || $3.tipo != INT || $5.tipo != INT)
					yyerror("only int available to iterators");

				$$.tipo = ITERATOR;
				umap_label_add_iterator($$.label);

				string label_start = temp_umap[$$.label].start_label;
				string label_end = temp_umap[$$.label].end_label;
				string label_step = temp_umap[$$.label].step_label;
				string label_tamanho = temp_umap[$$.label].size_label;

				$$.traducao = $1.traducao + $3.traducao + $5.traducao;
				$$.traducao += string("\t") + "pEndTemp1 = " + $3.label + " - " + $1.label + ";\n";
				$$.traducao += "\tpEndTemp2 = pEndTemp1 / " + $5.label + ";\n";
				$$.traducao += "\tpEndTemp3 = pEndTemp2 * " + $5.label + ";\n";
				$$.traducao += "\tposTemp = " + $1.label + " - " + $3.label + ";\n";
				$$.traducao += "\tif(posTemp < 0) posTemp = posTemp * -1;\n";
				$$.traducao += "\t" + label_tamanho + " = posTemp / " + $5.label + ";\n";
				$$.traducao += "\t" + label_tamanho + " = " + label_tamanho + " + 1; //tamanho\n";
				$$.traducao += "\t" + label_end + " = pEndTemp3 + " + $1.label + ";\n";
				$$.traducao += "\t" + label_end + " = " + label_end + " - 1; //end\n";
				$$.traducao += "\t" + label_start + " = " + $1.label + " - 1; //start\n";
				$$.traducao += "\t" + label_step + " = " + $5.label + "; //step\n";
				$$.traducao += "\t" + $$.label + " = -1;\n";
			}
			| E ':' E
			{
				if($1.tipo != INT || $3.tipo != INT)
					yyerror("only int available to iterators");

				$$.tipo = ITERATOR;
				umap_label_add_iterator($$.label);

				string label_start = temp_umap[$$.label].start_label;
				string label_end = temp_umap[$$.label].end_label;
				string label_step = temp_umap[$$.label].step_label;
				string label_tamanho = temp_umap[$$.label].size_label;

				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += "\t" + label_end + " = " + $3.label + " - 1; //end\n";
				$$.traducao += "\t" + label_start + " = " + $1.label + " - 1; //start\n";
				$$.traducao += "\t" + label_step + " = 1; //step\n";
				$$.traducao += "\ttempPos = " + label_start + " - " + label_end + ";\n";
				$$.traducao += "\tif(tempPos < 0) tempPos = tempPos * -1;\n";
				$$.traducao += "\t" + label_tamanho + " = tempPos + 1; //tamanho\n";
				$$.traducao += "\t" + $$.label + " = -1; //mera formalidade\n";
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

				bool hasTamanho = false;

				if($3.tipo == STRING) //add new types with size in if clause, as vectors, matrices
				{
					hasTamanho = true;
					temp_umap[$1.label].size_label = temp_umap[$3.label].size_label;
					temp_umap[$1.label].start_label = temp_umap[$3.label].start_label;
					temp_umap[$1.label].step_label = temp_umap[$3.label].step_label;
					temp_umap[$1.label].end_label = temp_umap[$3.label].end_label;
				}
				if($3.tipo == ITERATOR) //add new types with size in if clause, as vectors, matrices
				{
					temp_umap[$1.label].start_label = temp_umap[$3.label].start_label;
					temp_umap[$1.label].step_label = temp_umap[$3.label].step_label;
					temp_umap[$1.label].end_label = temp_umap[$3.label].end_label;
				}

				if( temp_umap[$1.label].tipo != 0 && temp_umap[$1.label].tipo != $3.tipo )
				{
					$$.tipo = $3.tipo;
					//criar uma temporaria nova pra guardar o antigo valor
					if($$.tipo != ITERATOR)
					{
						$$.label = add_variable_in_current_context($1.traducao, $$.tipo, hasTamanho);
					}
					else
					{
						$$.label = add_iterator_in_current_context($1.traducao);
					}
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
				$$.traducao += types_operations($$, $1, $2, $3, BOOLEAN);
				cout << $$.traducao;
				//$$.resultado = 0;

			}
			| E TK_OP_LOG E
			{
				$$.tipo = BOOLEAN;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += types_operations($$, $1, $2, $3, BOOLEAN);
				//$$.resultado = 0;
			}
			| TK_NOT E
			{
				if($2.tipo != BOOLEAN)
				{
					yyerror("COND -> TK_NOT E\nO operador \"not\" não pode ser utilizado com variável do tipo " + tipo_umap[$2.tipo]);
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
					yyerror("CONT -> TK_ID TK_CONT E\nNO!!!");
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
	yydebug = atoi(argv[1]);
	context_stack.push_back(unordered_map<string, string>());
	initialize_tipo_umap();
	initialize_proc_temp_umap();
	initialize_matrix();
	initialize_op_umap();
	yyparse();

	return 0;
}
