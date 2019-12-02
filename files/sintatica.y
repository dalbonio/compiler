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
%token TK_BREAK TK_CONTINUE
%token TK_CASTING
%token TK_VAR TK_DEF
%token TK_FIM TK_ERROR TK_RETURN
%token TK_FIM_LINHA
%token TK_SWITCH TK_CASE TK_DEFAULT TK_GLOBAL TK_LOOPEACH TK_IN

%start S

%left TK_ID TK_NUM TK_REAL TK_STR TK_BOOL TK_INPUT '#'
%left '=' TK_CONT ':'
%left TK_OP_LOG
%left TK_OP_REL
%left TK_OP_ARIT
%left TK_NOT
%left '+' '-'
%left '*' '/'
%left '[' ']'
%left TK_INCR TK_DECR
%left TK_GLOBAL
%left '(' ')'

%%

S 			: FUNCTS BP //bloco principal
			{
				cout << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\n";
				cout << "using namespace std;\n\n";
				cout << $1.traducao;
				cout <<	"\nint main(void)\n{\n";
				cout << "\tchar* buffer;\n";
				cout << declare_variables();
				cout << "\tgoto Start;\n";
				cout << outOfBoundsError();
				cout << "\tStart: \n" << $2.traducao << "\n\tEnd_Of_Stream:\n\treturn 0;\n}" << endl;
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


FUNCTS		: FUN FUNCTS
			{
				//cout << $1.traducao;
				$$.traducao = $1.traducao + $2.traducao;
			}
			|//vazio
			{
				$$.traducao = "";
			};



FUN			: TK_DEF FUNCT
			{
				$$.traducao = $2.traducao;
			}


REC_PARAM	: TK_CASTING TK_ID ',' PARAM_FUNCT
			{
				int tipo = tipo_umap_str[$1.label];
				
				param_declr.push(tipo);
				int ptrs = 0;
				int pointsTo = 0;
				if(tipo == STRING)
				{
					ptrs = 1;
				}
				$2.label = get_current_context_id_label($2.traducao, 1, ptrs, pointsTo);
				temp_umap[$2.label].tipo = tipo;

				$$.traducao = get_tipo(tipo, ptrs) + " " + $2.label + ", " + $4.traducao;
			}
			| TK_CASTING TK_ID
			{
				int tipo = tipo_umap_str[$1.label];
				param_declr.push(tipo);

				int ptrs = 0;
				int pointsTo = 0;
				if(tipo == STRING)
				{
					ptrs = 1;
				}
				$2.label = get_current_context_id_label($2.traducao, 1, ptrs, pointsTo);
				temp_umap[$2.label].tipo = tipo;

				$$.traducao = get_tipo(tipo, ptrs) + " " + $2.label;
			};

PARAM_FUNCT	: REC_PARAM
			{
				$$.traducao = $1.traducao;
			}
			|
			{
				$$.traducao = "";
			};

FUNCT		: TK_CASTING TK_ID '(' PARAM_FUNCT ')' BL_FUNCT
			{
				int tipo = tipo_umap_str[$1.label];
				int ptrs = 0;
				//int pointsTo = 0;
				if(tipo == STRING)
				{
					ptrs = 1;
				}
				//cout << $1.label << endl << tipo << endl << $6.tipo << endl;
				if(tipo != $6.tipo)
				{
					yyerror("tipo de retorno inicial diferente do tipo de retorno da funcao");
				}

				if(funct_umap.find($2.traducao) != funct_umap.end())
				{
					yyerror("funcao de mesmo nome já declarada");
				}

				string funct_label = funct_label_generator();

				funct_umap[$2.traducao] = funct_label;
				param_funct_umap[funct_label] = param_declr;

				emptying_queue(param_declr);

				//print_queue(param_declr);
				$$.traducao = get_tipo(tipo, ptrs) + " " + funct_label + "(" + $4.traducao + ")" + $6.traducao;
			};


BL_FUNCT	: TK_DO TK_FIM_LINHA COMANDOS RTRN TK_FIM_LINHA BL_END
			{
				$$.tipo = $4.tipo; //tipo do retorno
				$$.traducao = "\n{\n" + $3.traducao + $4.traducao + ";\n}\n";
			};

RTRN		: TK_RETURN E
			{
				$$.tipo = $2.tipo;
				$$.traducao = $2.traducao + "\n\treturn " + $2.label;
			}

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


REC_NUM		:TK_NUM ',' REC_NUM
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

REC_STR		:TK_STR ',' REC_STR
			{
				string case_label;
				string new_label;

				umap_label_add($1.label, $1.tipo);
				umap_label_add(case_label, BOOLEAN);
				umap_label_add(new_label, BOOLEAN);

				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + case_label + " = " + "strcmp(VAR_LABEL, " + $1.label + ");\n";
				$$.traducao += "\t" + case_label + " = " + "0 == " + case_label + ";\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\t" + new_label + " = " + case_label + " || " + $3.label + ";\n";

				$$.label = new_label;
			}
			| TK_STR ':'
			{
				string case_label;

				umap_label_add($1.label, $1.tipo);
				umap_label_add(case_label, BOOLEAN);

				$$.traducao = "\t" + $1.label + " = " + $1.traducao + ";\n";
				$$.traducao += "\t" + case_label + " = " + "strcmp(VAR_LABEL, " + $1.label + ");\n";
				$$.traducao += "\t" + case_label + " = " + "0 == " + case_label + ";\n";

				$$.label = case_label;
			};


BL_CASE_INT	: TK_CASE REC_NUM COMANDOS BL_CASE_INT
			{
				//\n/**/\n
				$$.traducao = $2.traducao;
				$$.traducao += "\n/**/\n\tif(" + $2.label + ") goto " + cmd_label_generator("SWITCH") + ";\n";
				$$.traducao += "\tgoto " + cmd_label_end_generator("SWITCH") + ";\n";
				$$.traducao += "\n/**/\n\t" + cmd_label_generator("SWITCH") + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator() + ";\n";
				$$.traducao += "\t" + cmd_label_end_generator("SWITCH") + ":\n\n/**/\n";
				$$.traducao += $4.traducao;
				switchLabelContador++;
			}
			| BL_DEFAULT
			{
				$$.traducao = $1.traducao;
			};

BL_CASE_STR	: TK_CASE REC_STR COMANDOS BL_CASE_STR
			{
				//\n/**/\n
				$$.traducao = $2.traducao;
				//$$.traducao += "\t" + $2.label + " = !" + $2.label + ";\n";
				$$.traducao += "\n/**/\n\tif(" + $2.label + ") goto " + cmd_label_generator("SWITCH") + ";\n";
				$$.traducao += "\tgoto " + cmd_label_end_generator("SWITCH") + ";\n";
				$$.traducao += "\n/**/\n\t" + cmd_label_generator("SWITCH") + ":\n";
				$$.traducao += $3.traducao;
				$$.traducao += "\tgoto " + cmd_label_end_generator() + ";\n";
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


BL_SWITCH	: TK_DO TK_FIM_LINHA BL_CASE_INT
			{
				$$.traducao = $3.traducao;
			}
			| TK_DO TK_FIM_LINHA BL_CASE_STR
			{
				$$.traducao = $3.traducao;
			} ;


COMANDOS	: COMANDO TK_FIM_LINHA COMANDOS
			{
				//$$.label = "";
				$$.traducao = $1.traducao + $3.traducao;
				// cout << $2.traducao << endl;
				// replace_all($2.traducao, "\n", "A");
				// cout << $2.traducao + " 1st rule" << endl;
			}
			| COMANDO ';' COMANDOS
			{
				$$.traducao = $1.traducao + $3.traducao;
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
			| BLOCO
			{
				$$.traducao = $1.traducao;
			}
			| ATR
			{
				$$.traducao = $1.traducao;
			}
			| DCLR
			{

			}
			| TK_BREAK
			{
				if(context_stack.size() == 1)
					yyerror("there's no context to break");
				string goto_label = cmd_label_end_generator();
				$$.traducao = string("\tgoto ") + goto_label + ";\n";
			}
			| TK_CONTINUE
			{
				string goto_label = cmd_label_generator();
				$$.traducao = string("\tgoto ") + goto_label + ";\n";
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
				if( $3.tipo != INT && $3.tipo != STRING )
				{
					yyerror("COMANDO -> TK_SWITCH '(' TK_ID ')' BL_SWITCH\n" + string("Tipo ") + " invalido para comando SWITCH.");
				}

				string label = search_variable_cur_ctx($3.traducao);//talvez usar search variable

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
			| TK_FOR '(' ATR ';' E ';' ATR ')' BLOCO//for
			{
				if($5.tipo != BOOLEAN)
				{
					yyerror("COMANDO -> TK_LOOP '(' ATR ';' E ';' CONT ')' BLOCO//for\nThis condition is not a boolean.\n");
				}

				string new_label;
				string cmd_label[3] = {cmd_label_generator(), cmd_label_end_generator(), cmd_label_iter_generator()};
				cmdLabelContador++;

				umap_label_add(new_label, BOOLEAN);

				$$.traducao = $3.traducao;
				$$.traducao += "\n\t" + cmd_label[2] + ":\n";
				$$.traducao += $5.traducao;
				$$.traducao += "\t" + new_label + " = !(" + $5.label + ");\n";
				$$.traducao += "\tif(" + new_label + ") " + "goto " + cmd_label[1] + ";\n";
				$$.traducao += $9.traducao;
				$$.traducao += "\n\t" + cmd_label[0] + ":\n";
				$$.traducao += $7.traducao;
				$$.traducao += "\tgoto " + cmd_label[2] + ";\n";
				$$.traducao += "\t" + cmd_label[1] + ":\n\n";
			}
			| TK_LOOPEACH '(' TK_ID TK_IN E ')' BLOCO //fase de testes nao mudar nada
			{
				// if(has_length.find($5.tipo) == has_length.end())
				// {
				// 	yyerror("COMANDO -> TK_LOOPEACH (E) BLOCO//for\nelement doesnt have iterator implemented.\n");
				// }
				//
				// if(has_length.find($5.tipo) == has_length.end())
				// 	yyerror($5.label + "has not length attribute");
				//
				// int ptrs = temp_umap[$5.label].ptrs;
				// int pointsTo = temp_umap[$5.label].pointsTo;
				// //iterators dont need pointers
				// if($5 != ITERATOR)
				// {
				// 	ptrs -= 1;
				// 	pointsTo = INT
				// }
				//
				// $3.label = get_current_context_id_label($3.traducao, 1, ptrs, pointsTo);
				// $3.tipo = temp_umap[$3.label].tipo;
				//
				// int isMat = temp_umap[$3.label].isMat;
				// //if all good get id as starting position
				//
				// if($3.tipo == STRING || $3.tipo == ITERATOR || $3.tipo == ARRAY) //add new types with size in if clause, as vectors, matrices
				// {
				// 	hasTamanho = true;
				// 	umap_label_add_array
				// }
				//
				// if($1.tipo == ARRAY)
				// {
				// 	temp_umap[$1.label].row_size = temp_umap[$3.label].row_size;
				// 	temp_umap[$1.label].start_col = temp_umap[$3.label].start_col;
				// 	temp_umap[$1.label].step_col = temp_umap[$3.label].step_col;
				// 	temp_umap[$1.label].end_col = temp_umap[$3.label].end_col;
				// }
				//
				// $$.tipo = $1.tipo;
				// auto& cur_umap = context_stack.back();
				// temp_umap[cur_umap[$1.traducao]].tipo = $1.tipo;
				// $$.label = $1.label;
				//
				// $$.traducao = $3.traducao;
				//
				// string size_label = temp_umap[$3.label].size_label;
				// string start = temp_umap[$3.label].start_label;
				// string step = temp_umap[$3.label].step_label;
				// string end = temp_umap[$3.label].end_label;
				//
				// string new_label;
				// string cmd_label[3] = {cmd_label_generator(), cmd_label_end_generator(), cmd_label_iter_generator()};
				// cmdLabelContador++;
				//
				// $$.traducao = $3.traducao; //foreach started here
				// $$.traducao += "\n\t" + $3.label + " = " + start + " //ref index start foreach;\n";
				// $$.traducao += "\n\t" + $3.label + " = " + $6.label + "[" + ref_index + "]; //ref label start foreach\n";
				// $$.traducao += "\t" + cmd_label[0] + ":\n";
				// $$.traducao += "\ttmp = " + ref_index + " == " + end + ";\n";
				// $$.traducao += "\ttmp = !(tmp);\n";
				// $$.traducao += "\tif(tmp) goto " + cmd_label[1] + ";\n";
				// $$.traducao += $8.traducao;
				// $$.traducao += "\t" + cmd_label[2] + ":\n";
				// $$.traducao += "\t" + ref_index + " = " + ref_index + " + " + step + " //ref label iter foreach;\n";
				// $$.traducao += "\n\t" + $4.label + " = " + $6.label + "[" + ref_index + "]; //ref label iter foreach\n";
				// $$.traducao += "\tgoto " + cmd_label[0] + ";\n";
				// $$.traducao += "\t" + cmd_label[1] + ":\n\n";

				//cmdLabelContador++;
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

				if($2.label == "string")
				{
					umap_label_add($$.label, $$.tipo, true);
					temp_umap[$$.label].ptrs = 1;
					temp_umap[$$.label].pointsTo = STRING;
				}
				else
				{
					umap_label_add($$.label, $$.tipo);
				}

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
				else if($$.tipo == STRING)
				{
					if($4.tipo == DOUBLE)
					{
						$$.traducao += double_to_string($4.label, $$.label);
						$$.traducao += countStringProc();
						$$.traducao += "\t" + temp_umap[$$.label].size_label + " = countTempLabel;\n";
					}
					else if($4.tipo == INT)
					{
						$$.traducao += int_to_string($4.label, $$.label);
						$$.traducao += countStringProc();
						$$.traducao += "\t" + temp_umap[$$.label].size_label + " = countTempLabel;\n";
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
					//adicionar features de step, start e end
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
				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += types_operations($$, $1, $2, $3, 0);

				//cout << $$.label;
				//$$.resultado = $1.resultado + $3.resultado;
			}
			| '#' E
			{
				if(has_length.find($2.tipo) != has_length.end() )
				{
					umap_label_add($$.label, INT, 0);

					string start = temp_umap[$2.label].start_label;
					string step = temp_umap[$2.label].step_label;
					string size = temp_umap[$2.label].size_label;
					string end = temp_umap[$2.label].end_label;

					int isMat = temp_umap[$2.label].isMat;
					if(isMat == 0)
					{
						$$.traducao = $2.traducao;
						$$.traducao += "\ttmp = " + start + " - " + end + ";\n";
						$$.traducao += "\tif(tmp < 0) tmp = tmp * -1;\n";
						$$.traducao += "\ttmp = tmp / " + step + ";\n";
						$$.traducao += string("\t") + $$.label + " = tmp;\n";
					}
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

				int isMat = temp_umap[$1.label].isMat;

				if(has_length.find($1.tipo) != has_length.end() && isMat != 1)
				{
					string size_label = temp_umap[$1.label].size_label;
					string start = temp_umap[$1.label].start_label;
					string step = temp_umap[$1.label].step_label;
					string end = temp_umap[$1.label].end_label;
					if($3.tipo != ITERATOR)
					{
						string end_goto_lbl = genSliceLabelEnd();
						string create_goto_lbl = genSliceLabelCreate();
						string lower_lbl = genSliceLabelLower();
						string higher_lbl = genSliceLabelHigher();
						string after_lbl = genAfterSliceLabel();
						sliceLabelCounter += 1;
						$$.traducao = $1.traducao + $3.traducao;
						$$.traducao += "\tif(" + $3.label + " < 0 ) goto " + end_goto_lbl + ";\n";
						$$.traducao += "\ttempPos = " + $3.label + ";\n";
						$$.traducao += "\ttempPos = tempPos * " + step + ";\n";
						$$.traducao += "\ttempPos = tempPos + " + start + "; goto " + create_goto_lbl + ";\n";
						$$.traducao += "\t" + end_goto_lbl + ":\n";
						$$.traducao += "\ttempPos = " + $3.label + " + 1;\n";
						$$.traducao += "\ttempPos = " + step + " * tempPos;\n";
						$$.traducao += "\ttempPos = tempPos + " + end + ";\n";
						$$.traducao += "\t" + create_goto_lbl + ":\n";
						$$.traducao += "\tif(tempPos < 0 || tempPos >= " + size_label + ") goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + start + " < " + end +") goto " + lower_lbl + ";\n";
						$$.traducao += "\tif(tempPos >= " + start + " || tempPos < " + end + ") goto OutOfBoundsError;\n";
						$$.traducao += "\tgoto " + after_lbl + ";\n";
						$$.traducao += "\t" + lower_lbl + ":\n";
						$$.traducao += "\tif(tempPos < " + start + " || tempPos > " + end + ") goto OutOfBoundsError;\n";
						$$.traducao += "\t" + after_lbl + ":\n";
						//new $$ type is array $1 associated type.
						//Ex: if $1 is int array, $$ type is int
						// if($1.tipo == STRING)//substitute if by "$$.tipo = assoc_map[$1.tipo]"
						// {
						// 	$$.tipo = STRING;
						// 	umap_label_add($$.label, $$.tipo, true);
						// 	string label_tamanho = temp_umap[$$.label].size_label;
						//
						// 	$$.traducao += "\t" + label_tamanho + " = 1;\n";
						// 	$$.traducao += "\t" + step + " = 1; //step\n";
						// 	$$.traducao += "\t" + start + " = 0; //start\n";
						// 	$$.traducao += "\t" + end + " = 1; //end\n";
						// 	$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * 2);\n";
						// 	$$.traducao += "\t" + $$.label + "[0] = " + $1.label + "[tempPos];" + $$.label + "[1] = \'\\0\';\n";
						// }
						//else
						//{
							if(temp_umap[$1.label].ptrs > 1)
							{
								$$.tipo == ARRAY;
								int ptrs = temp_umap[$1.label].ptrs - 1;
								int pointsTo = temp_umap[$1.label].pointsTo;
								umap_label_add_array($$.label, pointsTo, ptrs);

								string tamanho_lbl = temp_umap[$$.label].size_label;
								string start_lbl = temp_umap[$$.label].start_label;
								string end_lbl = temp_umap[$$.label].end_label;
								string step_lbl = temp_umap[$$.label].step_label;

								$$.traducao += "\t" + tamanho_lbl + " = " + size_label +";\n";
								$$.traducao += "\t" + step_lbl + " = " + step + "; //step\n";
								$$.traducao += "\t" + start_lbl + " = " + start + "; //start\n";
								$$.traducao += "\t" + end_lbl + " = " + end + "; //end\n";
								$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n";
							}
							else if($1.tipo == STRING)//substitute if by "$$.tipo = assoc_map[$1.tipo]"
							{
								$$.tipo = STRING;
								umap_label_add($$.label, $$.tipo, true);
								string label_tamanho = temp_umap[$$.label].size_label;
								string start_lbl = temp_umap[$$.label].start_label;
								string end_lbl = temp_umap[$$.label].end_label;
								string step_lbl = temp_umap[$$.label].step_label;

								$$.traducao += "\t" + label_tamanho + " = 1;\n";
								$$.traducao += "\t" + step_lbl + " = 1; //step\n";
								$$.traducao += "\t" + start_lbl + " = 0; //start\n";
								$$.traducao += "\t" + end_lbl + " = 1; //end\n";
								$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * 2);\n";
								$$.traducao += "\t" + $$.label + "[0] = " + $1.label + "[tempPos];" + $$.label + "[1] = \'\\0\';\n";
							}
							else
							{
								int pointsTo = temp_umap[$1.label].pointsTo;
								umap_label_add($$.label, pointsTo, false);
								$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n";
							}
						//}
					}
					else
					{
						$$.tipo = $1.tipo;
						int pointsTo = temp_umap[$1.label].pointsTo;
						int ptrs = temp_umap[$1.label].ptrs;
						int isMat = temp_umap[$1.label].isMat;
						if($$.tipo == ARRAY)
						{
							if(isMat)
							{
								yyerror("simple indexing on matrix doesnt work");
							}
							else
							{
								umap_label_add_array($$.label, pointsTo, ptrs);
							}
						}
						else
						{
							if($$.tipo == STRING)
								yyerror("slicing is not allowed on strings");


							umap_label_add($$.label, $$.tipo, true);
						}

						string label_tamanho_arr = temp_umap[$1.label].size_label;

						string start_old = temp_umap[$3.label].start_label;
						string step_old = temp_umap[$3.label].step_label;
						string end_old = temp_umap[$3.label].end_label;

						string label_tamanho_new = temp_umap[$$.label].size_label;
						string start_new = temp_umap[$$.label].start_label;
						string step_new = temp_umap[$$.label].step_label;
						string end_new = temp_umap[$$.label].end_label;

						$$.traducao = $1.traducao + $3.traducao;
						$$.traducao += "\tif(" + start_old + " < 0) goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + start_old + " >= " + label_tamanho_arr + ") goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + end_old + " < 0) goto OutOfBoundsError;\n";
						$$.traducao += "\tif(" + end_old + " >= " + label_tamanho_arr + ") goto OutOfBoundsError;\n";
						$$.traducao += "\t" + step_new + " = " + step_old + "; //step\n";
						$$.traducao += "\t" + start_new + " = " + start_old + "; //start\n";
						$$.traducao += "\t" + end_new + " = " + end_old + "; //end \n ";
						$$.traducao += "\t" + label_tamanho_new + " = " + label_tamanho_arr + "; //tamanho\n";
						$$.traducao += "\t" + $$.label + " = " + $1.label + "; //referece\n\n";
					}
				}
				else
				{
					yyerror("E -> E '[' E ']'\nexpression is no array/string");
				}
			}
			| E '[' E ',' E ']'
			{
				if($3.tipo != INT && $3.tipo != ITERATOR)
				{
					yyerror(string("E -> E '[' E ']'\nexpression doesnt evaluate to") + tipo_umap[$3.tipo]);
				}

				if($5.tipo != INT && $5.tipo != ITERATOR)
				{
					yyerror(string("E -> E '[' E ']'\nexpression doesnt evaluate to") + tipo_umap[$3.tipo]);
				}

				int pointsTo = temp_umap[$1.label].pointsTo;
				int isMat = temp_umap[$1.label].isMat;

				if($1.tipo == ARRAY && isMat)
				{
					string size_label = temp_umap[$1.label].size_label;
					string start = temp_umap[$1.label].start_label;
					string step = temp_umap[$1.label].step_label;
					string end = temp_umap[$1.label].end_label;

					string row_size = temp_umap[$1.label].row_size;
					string start_col = temp_umap[$1.label].start_col;
					string step_col = temp_umap[$1.label].step_col;
					string end_col = temp_umap[$1.label].end_col;

					//in case there's no reference to be returned
					if($3.tipo != ITERATOR && $5.tipo != ITERATOR)
					{
						string end_goto_lbl = genSliceLabelEnd();
						string create_goto_lbl = genSliceLabelCreate();
						string lower_lbl = genSliceLabelLower();
						string higher_lbl = genSliceLabelHigher();
						string after_lbl = genAfterSliceLabel();
						sliceLabelCounter += 1;

						string end_goto_lbl_col = genSliceLabelEnd();
						string create_goto_lbl_col = genSliceLabelCreate();
						string lower_lbl_col = genSliceLabelLower();
						string higher_lbl_col = genSliceLabelHigher();
						string after_lbl_col = genAfterSliceLabel();

						sliceLabelCounter += 1;
						$$.traducao = $1.traducao + $3.traducao + $5.traducao;


						$$.traducao += "\tif(" + $3.label + " < 0 ) goto " + end_goto_lbl + ";\n";
						$$.traducao += "\ttempPosRow = " + $3.label + ";\n";
						$$.traducao += "\ttempPosRow = tempPosRow * " + step + ";\n";
						$$.traducao += "\ttempPosRow = tempPosRow + " + start + "; goto " + create_goto_lbl + ";\n";
						$$.traducao += "\t" + end_goto_lbl + ":\n";
						$$.traducao += "\ttempPosRow = " + $3.label + " + 1;\n";
						$$.traducao += "\ttempPosRow = " + step + " * tempPos;\n";
						$$.traducao += "\ttempPosRow = tempPosRow + " + end + ";\n";
						$$.traducao += "\t" + create_goto_lbl + ":\n";

						$$.traducao += "\tif(" + $5.label + " < 0 ) goto " + end_goto_lbl_col + ";\n";
						$$.traducao += "\ttempPosCol = " + $5.label + ";\n";
						$$.traducao += "\ttempPosCol = tempPosCol * " + step_col + ";\n";
						$$.traducao += "\ttempPosCol = tempPosCol + " + start_col + "; goto " + create_goto_lbl_col + ";\n";
						$$.traducao += "\t" + end_goto_lbl_col + ":\n";
						$$.traducao += "\ttempPosCol = " + $5.label + " + 1;\n";
						$$.traducao += "\ttempPosCol = " + step_col + " * tempPosCol;\n";
						$$.traducao += "\ttempPosCol = tempPosCol + " + end_col + ";\n";
						$$.traducao += "\t" + create_goto_lbl_col + ":\n";

						$$.traducao += "\ttempPos = tempPosRow * " + row_size + ";\n";
						$$.traducao += "\ttempPos = tempPos + tempPosCol;\n";


						$$.traducao += "\tif(tempPos < 0 || tempPos >= " + size_label + ") goto OutOfBoundsError;\n";
						//$$.traducao += "\tif(" + start + " < " + end +") goto " + lower_lbl + ";\n";
						//$$.traducao += "\tif(tempPos > " + start + " || tempPos < " + end + ") goto OutOfBoundsError;\n";
						//$$.traducao += "\tgoto " + after_lbl + ";\n";
						//$$.traducao += "\t" + lower_lbl + ":\n";
						//$$.traducao += "\tif(tempPos < " + start + " || tempPos > " + end + ") goto OutOfBoundsError;\n";
						//$$.traducao += "\t" + after_lbl + ":\n";
						//new $$ type is array $1 associated type.
						//Ex: if $1 is int array, $$ type is int
						// if(pointsTo == STRING)//substitute if by "$$.tipo = assoc_map[$1.tipo]"
						// {
						// 	$$.tipo = STRING;
						// 	umap_label_add($$.label, $$.tipo, true);
						// 	string label_tamanho = temp_umap[$$.label].size_label;
						//
						// 	$$.traducao += "\t" + label_tamanho + " = 2;\n";
						// 	$$.traducao += "\t" + step + " = 1; //step\n";
						// 	$$.traducao += "\t" + start + " = 0; //start\n";
						// 	$$.traducao += "\t" + end + " = 2; //end\n";
						// 	$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * 2);\n";
						// 	$$.traducao += "\t" + $$.label + "[0] = " + $1.label + "[tempPos];" + $1.label + "[1] = \'\\0\';\n";
						// }
						// else
						// {
							if(temp_umap[$1.label].ptrs > 1)
							{
								$$.tipo == ARRAY;
								int ptrs = temp_umap[$1.label].ptrs - 1;
								int isMat = temp_umap[$1.label].isMat;
								if(isMat)
								{
									umap_label_add_matrix($$.label, pointsTo, ptrs);

									string tamanho_lbl = temp_umap[$$.label].size_label;
									string start_lbl = temp_umap[$$.label].start_label;
									string end_lbl = temp_umap[$$.label].end_label;
									string step_lbl = temp_umap[$$.label].step_label;

									string size_row_new = temp_umap[$$.label].row_size;
									string start_col_new = temp_umap[$$.label].start_col;
									string end_col_new = temp_umap[$$.label].end_col;
									string step_col_new = temp_umap[$$.label].step_col;

									$$.traducao += "\t" + tamanho_lbl + " = " + size_label +";\n";
									$$.traducao += "\t" + step_lbl + " = " + step + "; //step\n";
									$$.traducao += "\t" + start_lbl + " = " + start + "; //start\n";
									$$.traducao += "\t" + end_lbl + " = " + end + "; //end\n";

									$$.traducao += "\t" + size_row_new + " = " + row_size +";\n";
									$$.traducao += "\t" + step_col_new + " = " + step_col + "; //step\n";
									$$.traducao += "\t" + start_col_new + " = " + start_col + "; //start\n";
									$$.traducao += "\t" + end_col_new + " = " + end_col + "; //end\n";

									$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n";
								}
								else
								{
									umap_label_add_array($$.label, pointsTo, ptrs);

									string tamanho_lbl = temp_umap[$$.label].size_label;
									string start_lbl = temp_umap[$$.label].start_label;
									string end_lbl = temp_umap[$$.label].end_label;
									string step_lbl = temp_umap[$$.label].step_label;

									$$.traducao += "\t" + tamanho_lbl + " = " + size_label +";\n";
									$$.traducao += "\t" + step_lbl + " = " + step + "; //step\n";
									$$.traducao += "\t" + start_lbl + " = " + start + "; //start\n";
									$$.traducao += "\t" + end_lbl + " = " + end + "; //end\n";
									$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n";
								}
							}
							else if(pointsTo == STRING)//substitute if by "$$.tipo = assoc_map[$1.tipo]"
							{
								$$.tipo = STRING;
								umap_label_add($$.label, $$.tipo, true);
								string label_tamanho = temp_umap[$$.label].size_label;

								$$.traducao += "\t" + label_tamanho + " = 2;\n";
								$$.traducao += "\t" + step + " = 1; //step\n";
								$$.traducao += "\t" + start + " = 0; //start\n";
								$$.traducao += "\t" + end + " = 2; //end\n";
								$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * 2);\n";
								$$.traducao += "\t" + $$.label + "[0] = " + $1.label + "[tempPos];" + $$.label + "[1] = \'\\0\';\n";
							}
							else
							{
								int pointsTo = temp_umap[$1.label].pointsTo;
								umap_label_add($$.label, pointsTo, false);
								$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n";
							}
						//}
					}
					else//in case $3 or $5 is a slice
					{
						$$.tipo == ARRAY;
						int ptrs = temp_umap[$1.label].ptrs - 1;
						int isMat = temp_umap[$1.label].isMat;

						umap_label_add_matrix($$.label, pointsTo, ptrs);

						string tamanho_lbl = temp_umap[$$.label].size_label;
						string start_lbl = temp_umap[$$.label].start_label;
						string end_lbl = temp_umap[$$.label].end_label;
						string step_lbl = temp_umap[$$.label].step_label;

						string size_row_new = temp_umap[$$.label].row_size;
						string start_col_new = temp_umap[$$.label].start_col;
						string end_col_new = temp_umap[$$.label].end_col;
						string step_col_new = temp_umap[$$.label].step_col;

						if($3.tipo != ITERATOR)
						{
							//end row = start row = $3.label
							//step row = 1
							$$.traducao += "\t" + tamanho_lbl + " = " + size_label +";\n";
							$$.traducao += "\t" + step_lbl + " = 1; //step\n";
							$$.traducao += "\t" + start_lbl + " = " + $3.label + "; //start\n";
							$$.traducao += "\t" + end_lbl + " = " + start_lbl + "; //end\n";

							$$.traducao += "\t" + size_row_new + " = " + row_size +";\n";
							$$.traducao += "\t" + step_col_new + " = " + step_col + "; //step\n";
							$$.traducao += "\t" + start_col_new + " = " + start_col + "; //start\n";
							$$.traducao += "\t" + end_col_new + " = " + end_col + "; //end\n";
						}
						if($5.tipo != ITERATOR)
						{
							//end col = start col = $3.label
							//step col = 1
							$$.traducao += "\t" + tamanho_lbl + " = " + size_label +";\n";
							$$.traducao += "\t" + step_lbl + " = " + step + "; //step\n";
							$$.traducao += "\t" + start_lbl + " = " + start + "; //start\n";
							$$.traducao += "\t" + end_lbl + " = " + end + "; //end\n";

							$$.traducao += "\t" + size_row_new + " = " + row_size +";\n";
							$$.traducao += "\t" + step_col_new + " = 1; //step\n";
							$$.traducao += "\t" + start_col_new + " = " + $5.label + "; //start\n";
							$$.traducao += "\t" + end_col_new + " = " + start_col_new + "; //end\n";
						}

						$$.traducao += "\t" + $$.label + " = " + $1.label + "[tempPos];\n\n";
					}
				}
				else
				{
					yyerror("E -> E '[' E ']'\nexpression is no matrix");
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
				$$.traducao += "\t" + cmd_label_end_generator("IF") + ":\n\n";
				ifLabelContador++;
			}
			| COND
			{
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			| TK_NUM
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			| TK_REAL
			{
				$$.tipo = $1.tipo;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
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
				temp_umap[$$.label].ptrs = 1;
				temp_umap[$$.label].pointsTo = STRING;
				string label_tamanho = temp_umap[$$.label].size_label;
				string start = temp_umap[$$.label].start_label;
				string end = temp_umap[$$.label].end_label;
				string step = temp_umap[$$.label].step_label;

				$$.traducao = "\t" + label_tamanho + " = " + to_string(str.length()) + "; //tamanho string\n";
				$$.traducao += "\t" + start + " = 0;  //start index string\n";
				$$.traducao += "\t" + end + " = " + label_tamanho + "; //final index string\n";
				$$.traducao += "\t" + step + " = 1; //step string\n";
				$$.traducao += "\t" + $$.label + " = (char*) malloc(sizeof(char) * (1 + "+ label_tamanho +"));\n";
				$$.traducao += "\tstrcpy(" + $$.label + ", \"" + str + "\");\n";
			}
			| TK_ID
			{
				$$.label = get_current_context_id_label($1.traducao);
				//cout << $$.label << "   " << $1.traducao << endl;
				//cout << $$.label << endl;
				$$.tipo = temp_umap[$$.label].tipo;
				//cout << $$.label << $$.tipo;
				if ($$.tipo == 0)
				{
					yyerror("E -> TK_ID\nvariable " + $1.traducao + " not declared");
				}

				$$.traducao = "";
			}
			| TK_GLOBAL TK_ID
			{
				$$.label = get_id_label($2.traducao);
				//cout << $$.label << endl;
				$$.tipo = temp_umap[$$.label].tipo;

				if ($$.tipo == 0)
				{
					yyerror("E -> TK_ID\nvariable " + $2.traducao + " not declared");
				}

				$$.traducao = "";
			}
			// | E PE2 PE2
			// {
			// 	cout << "complex" << $1.tipo << ", " << $2.tipo << ", " << $3.tipo << endl;
			// 	if( $1.tipo != INT || $2.tipo != INT || $3.tipo != INT)
			// 		yyerror("only int available to iterators");
			//
			// 	$$.tipo = ITERATOR;
			// 	umap_label_add_iterator($$.label);
			//
			// 	string label_start = temp_umap[$$.label].start_label;
			// 	string label_end = temp_umap[$$.label].end_label;
			// 	string label_step = temp_umap[$$.label].step_label;
			// 	string label_tamanho = temp_umap[$$.label].size_label;
			//
			// 	$$.traducao = $1.traducao + $2.traducao + $3.traducao;
			// 	$$.traducao += string("\t") + "pEndTemp1 = " + $2.label + " - " + $1.label + ";\n";
			// 	$$.traducao += "\tpEndTemp2 = pEndTemp1 / " + $3.label + ";\n";
			// 	$$.traducao += "\tpEndTemp3 = pEndTemp2 * " + $3.label + ";\n";
			// 	$$.traducao += "\tposTemp = " + $1.label + " - " + $2.label + ";\n";
			// 	$$.traducao += "\tif(posTemp < 0) posTemp = posTemp * -1;\n";
			// 	$$.traducao += "\tposTemp = posTemp / " + $3.label + ";\n";
			// 	$$.traducao += "\tif(posTemp < 0) posTemp = posTemp * -1;\n";
			// 	$$.traducao += "\t" + label_tamanho + " = posTemp; //tamanho\n";
			// 	$$.traducao += "\t" + label_end + " = pEndTemp3 + " + $1.label + ";\n";
			// 	//$$.traducao += "\t" + label_end + " = " + label_end + "; //end\n";
			// 	$$.traducao += "\t" + label_start + " = " + $1.label + "; //start\n";
			// 	$$.traducao += "\t" + label_step + " = " + $3.label + "; //step\n";
			// 	$$.traducao += "\t" + $$.label + " = -1; //mera formalidade\n\n";
			// }
			| '{' E ITR
			{
				if($2.tipo != INT)
					yyerror("only int available to iterators");

				$$.tipo = ITERATOR;
				umap_label_add_iterator($$.label);

				temp_umap[$$.label].end_label = $3.label;
				temp_umap[$$.label].step_label = $3.resultado;

				string label_start = temp_umap[$$.label].start_label;
				string label_end = temp_umap[$$.label].end_label;
				string label_step = temp_umap[$$.label].step_label;
				string label_tamanho = temp_umap[$$.label].size_label;

				$$.traducao = $2.traducao + $3.traducao;
				$$.traducao += string("\t") + "pEndTemp1 = " + label_end + " - " + $2.label + ";\n";
				$$.traducao += "\tpEndTemp2 = pEndTemp1 / " + label_step + ";\n";
				$$.traducao += "\tpEndTemp3 = pEndTemp2 * " + label_step + ";\n";
				$$.traducao += "\tposTemp = " + $2.label + " - " + label_end + ";\n";
				$$.traducao += "\tif(posTemp < 0) posTemp = posTemp * -1;\n";
				$$.traducao += "\tposTemp = posTemp / " + label_step + ";\n";
				$$.traducao += "\tif(posTemp < 0) posTemp = posTemp * -1;\n";
				$$.traducao += "\t" + label_tamanho + " = posTemp; //tamanho\n";
				$$.traducao += "\t" + label_end + " = pEndTemp3 + " + $2.label + ";\n";
				$$.traducao += "\t" + label_start + " = " + $2.label + "; //start\n";
				$$.traducao += "\t" + $$.label + " = -1; //mera formalidade\n\n";
			}
			| '[' {} ARR_REC
			{

			}
			| '{' TK_CASTING '}' '[' E ']'
			{
				if($5.tipo != INT)
					yyerror("only int available to array size");

				int arr_tipo = tipo_umap_str[$2.label];
				if(arr_tipo)
				$$.tipo = ARRAY;
				int pointers = 1;
				if(arr_tipo == STRING)
				{
					pointers = 2;
				}
				//change to temp_umap[$1.label].pointers + 1
				umap_label_add_array($$.label, arr_tipo, pointers);

				string label_start = temp_umap[$$.label].start_label;
				string label_end = temp_umap[$$.label].end_label;
				string label_step = temp_umap[$$.label].step_label;
				string label_tamanho = temp_umap[$$.label].size_label;

				$$.traducao = $5.traducao;
				$$.traducao += "\tif(" + $5.label + " <= 0) goto OutOfBoundsError;\n";
				$$.traducao += "\t" + label_tamanho + " = " + $5.label + "; //tamanho\n";
				$$.traducao += "\t" + label_end + " = " + $5.label + " - 1; //end\n";
				$$.traducao += "\t" + label_start + " = 0; //start\n";
				$$.traducao += "\t" + label_step + " = 1; //step\n";
				$$.traducao += "\t" + $$.label + " = (" + get_tipo(arr_tipo, pointers) +  ") malloc(sizeof(" + get_tipo(arr_tipo, pointers - 1) + ") * " + $5.label + "); //alocando memoria\n\n";
			}
			| '{' TK_CASTING '}' '[' E ',' E ']'
			{
				if($5.tipo != INT)
					yyerror("only int available to array size");

				if($7.tipo != INT)
						yyerror("only int available to array size");

				int arr_tipo = tipo_umap_str[$2.label];
				$$.tipo = ARRAY; //change to matrix
				int pointers = 1;
				if(arr_tipo == STRING)
				{
					pointers = 2;
				}
				//change to temp_umap[$1.label].pointers + 1
				umap_label_add_matrix($$.label, arr_tipo, pointers);

				string label_start = temp_umap[$$.label].start_label;
				string label_end = temp_umap[$$.label].end_label;
				string label_step = temp_umap[$$.label].step_label;
				string label_tamanho = temp_umap[$$.label].size_label;

				string start_col = temp_umap[$$.label].start_col;
				string end_col = temp_umap[$$.label].end_col;
				string step_col = temp_umap[$$.label].step_col;
				string row_size = temp_umap[$$.label].row_size;

				$$.traducao = $5.traducao;
				$$.traducao += $7.traducao;
				$$.traducao += "\tif(" + $5.label + " <= 0) goto OutOfBoundsError;\n";
				$$.traducao += "\t" + row_size + " = " + $5.label + "; //row size\n";
				$$.traducao += "\t" + label_end + " = " + $5.label + " - 1; //end\n";
				$$.traducao += "\t" + label_start + " = 0; //start\n";
				$$.traducao += "\t" + label_step + " = 1; //step\n";

				$$.traducao += "\tif(" + $7.label + " <= 0) goto OutOfBoundsError;\n";
				$$.traducao += "\ttempPos = " + row_size + " * " + $7.label + "; //getting correct full size\n";
				$$.traducao += "\t" + label_tamanho + " = tempPos; //tamanho\n";
				$$.traducao += "\t" + end_col + " = " + $7.label + " - 1; //end col\n";
				$$.traducao += "\t" + start_col + " = 0; //start col\n";
				$$.traducao += "\t" + step_col + " = 1; //step col\n";


				$$.traducao += "\t" + $$.label + " = (" + get_tipo(arr_tipo, pointers) +  ") malloc(sizeof(" + get_tipo(arr_tipo, pointers - 1) + ") * " + label_tamanho + "); //alocando memoria\n\n";
			}
			| TK_ID '(' ARG_FUNCT ')'//chamada de funcao
			{
				if(funct_umap.find($1.traducao) == funct_umap.end())
				{
					yyerror("funcao nao declarada");
				}

				string funct_label = funct_umap[$1.traducao];
				queue<int> funct_param = param_funct_umap[funct_label];

				if(funct_param.size() != param_use.size())
				{
					yyerror("quantidade de parametros nao coincide com o que a funcao precisa");
				}

				int param_pos = 1;

				for(int i = funct_param.size(); i >= 0; i--)
				{
					if(funct_param.front() != param_use.front())
					{
						yyerror("o tipo do parametro " + to_string(param_pos) + " nao coincide com o que foi declarado na funcao");
					}
					else
					{
						funct_param.pop();
						param_use.pop();
					}

					param_pos++;
				}

				//$$.label = funct_label;
				$$.traducao = $3.traducao + "\t" + funct_label + "(" + $3.label + ");\n";
			}
			;

ARG_FUNCT 	: REC_E
			{
				$$.label = $1.label;
				$$.traducao = $1.traducao;
			}
			|
			{
				$$.label = "";
				$$.traducao = "";
			}

REC_E		: E ',' REC_E
			{
				param_use.push($1.tipo);
				$$.traducao = $1.traducao + $3.traducao;
				$$.label = $1.label + "," + $3.label;
			}
			| E
			{
				param_use.push($1.tipo);
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			};

ATR 		: TK_ID '=' E
			{
				//no caso da variavel ja ter um tipo setado no codigo
				int ptrs = temp_umap[$3.label].ptrs;
				int pointsTo = temp_umap[$3.label].pointsTo;
				$1.label = get_current_context_id_label($1.traducao, 0, ptrs, pointsTo);
				bool hasTamanho = false;
				temp_umap[$1.label].isMat = temp_umap[$3.label].isMat;

				if($3.tipo == STRING || $3.tipo == ITERATOR || $3.tipo == ARRAY) //add new types with size in if clause, as vectors, matrices
				{
					hasTamanho = true;
					temp_umap[$1.label].size_label = temp_umap[$3.label].size_label;
					temp_umap[$1.label].start_label = temp_umap[$3.label].start_label;
					temp_umap[$1.label].step_label = temp_umap[$3.label].step_label;
					temp_umap[$1.label].end_label = temp_umap[$3.label].end_label;
				}

				if($3.tipo == ARRAY)
				{
					temp_umap[$1.label].row_size = temp_umap[$3.label].row_size;
					temp_umap[$1.label].start_col = temp_umap[$3.label].start_col;
					temp_umap[$1.label].step_col = temp_umap[$3.label].step_col;
					temp_umap[$1.label].end_col = temp_umap[$3.label].end_col;
				}

				if( temp_umap[$1.label].tipo != 0
					&& temp_umap[$1.label].tipo != $3.tipo
					&& temp_umap[$1.label].fixed == 0){

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
				else if(temp_umap[$1.label].fixed == 1)
				{
					//conversao implicita
				}
				else
				{
					$$.tipo = $3.tipo;
					auto& cur_umap = context_stack.back();
					temp_umap[cur_umap[$1.traducao]].tipo = $3.tipo;
					$$.label = $1.label;
				}

				$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n\n";
				//$$.resultado = $1.resultado;
			}
			| TK_GLOBAL TK_ID '=' E
			{
				//no caso da variavel ja ter um tipo setado no codigo
				string label = search_variable($2.traducao);
				if(label == "0")
					yyerror( $2.traducao + "variable not declared");

				int ptrs = temp_umap[$4.label].ptrs;
				int pointsTo = temp_umap[$4.label].pointsTo;
				$2.label = get_id_label($2.traducao, 0, 0, 0);

				bool hasTamanho = false;

				if($4.tipo == STRING || $4.tipo == ITERATOR || $4.tipo == ARRAY) //add new types with size in if clause, as vectors, matrices
				{
					hasTamanho = true;
					temp_umap[$2.label].size_label = temp_umap[$4.label].size_label;
					temp_umap[$2.label].start_label = temp_umap[$4.label].start_label;
					temp_umap[$2.label].step_label = temp_umap[$3.label].step_label;
					temp_umap[$2.label].end_label = temp_umap[$3.label].end_label;
				}

				if($4.tipo == ARRAY)
				{
					temp_umap[$2.label].row_size = temp_umap[$4.label].row_size;
					temp_umap[$2.label].start_col = temp_umap[$4.label].start_col;
					temp_umap[$2.label].step_col = temp_umap[$4.label].step_col;
					temp_umap[$2.label].end_col = temp_umap[$4.label].end_col;
				}

				if( temp_umap[$2.label].tipo != 0
					&& temp_umap[$2.label].tipo != $4.tipo
					&& temp_umap[$2.label].fixed == 0){

					$$.tipo = $4.tipo;
					temp_umap[$2.label].isMat = temp_umap[$4.label].isMat;
					//criar uma temporaria nova pra guardar o antigo valor
					if($$.tipo != ITERATOR)
					{
						$$.label = add_variable_in_current_context($2.traducao, $$.tipo, hasTamanho);
					}
					else
					{
						$$.label = add_iterator_in_current_context($2.traducao);
					}
				}
				else if(temp_umap[$2.label].fixed == 1)
				{
					//conversao implicita
				}
				else
				{
					$$.label = $2.label;
					$$.tipo = temp_umap[$$.label].tipo;
				}

				$$.traducao = $4.traducao + "\t" + $$.label + " = " + $4.label + ";\n\n";
				//$$.resultado = $1.resultado;
			}
			| E '[' E ']' '=' E
			{
				// string user_label = $1.traducao;
				// auto& lbl_umap = context_stack.back();
				// if(lbl_umap.find(user_label) == lbl_umap.end() )
				// 	yyerror($1.label + "not declared");
				$1.tipo = temp_umap[$1.label].tipo;
				int ptrs = temp_umap[$1.label].ptrs;
				int pointsTo = temp_umap[$1.label].pointsTo;

				if(has_length.find($1.tipo) == has_length.end())
					yyerror($1.label + "has not length attribute");

				if($3.tipo != INT)
					yyerror("integer expected in array set index operation");

				if(pointsTo != temp_umap[$6.label].tipo)
					yyerror("array and expression have different types");

				bool hasTamanho = false;

				//in case id has length and is declared, check if types are matching
				if(pointsTo == temp_umap[$6.label].tipo)
				{
					if(!(ptrs == temp_umap[$6.label].ptrs + 1))
						yyerror( tipo_umap[pointsTo] + "is expected");
				}

				//if all good, calculate position
				string size_label = temp_umap[$1.label].size_label;
				string start = temp_umap[$1.label].start_label;
				string step = temp_umap[$1.label].step_label;
				string end = temp_umap[$1.label].end_label;

				string end_goto_lbl = genSliceLabelEnd();
				string create_goto_lbl = genSliceLabelCreate();
				string lower_lbl = genSliceLabelLower();
				string higher_lbl = genSliceLabelHigher();
				string after_lbl = genAfterSliceLabel();
				sliceLabelCounter += 1;
				$$.traducao = $3.traducao + $6.traducao;
				$$.traducao += "\tif(" + $3.label + " < 0 ) goto " + end_goto_lbl + ";\n";
				$$.traducao += "\ttempPos = " + $3.label + ";\n";
				$$.traducao += "\ttempPos = tempPos * " + step + ";\n";
				$$.traducao += "\ttempPos = tempPos + " + start + "; goto " + create_goto_lbl + ";\n";
				$$.traducao += "\t" + end_goto_lbl + ":\n";
				$$.traducao += "\ttempPos = " + $3.label + " + 1;\n";
				$$.traducao += "\ttempPos = " + step + " * tempPos;\n";
				$$.traducao += "\ttempPos = tempPos + " + end + ";\n";
				$$.traducao += "\t" + create_goto_lbl + ":\n";
				$$.traducao += "\tif(tempPos < 0 || tempPos >= " + size_label + ") goto OutOfBoundsError;\n";
				$$.traducao += "\tif(" + start + " < " + end +") goto " + lower_lbl + ";\n";
				$$.traducao += "\tif(tempPos > " + start + " || tempPos < " + end + ") goto OutOfBoundsError;\n";
				$$.traducao += "\tgoto " + after_lbl + ";\n";
				$$.traducao += "\t" + lower_lbl + ":\n";
				$$.traducao += "\tif(tempPos < " + start + " || tempPos > " + size_label + ") goto OutOfBoundsError;\n";
				$$.traducao += "\t" + after_lbl + ":\n";
				//after calculating position in tempPos, attempt to insert new item in array
				$$.traducao += "\t" + $1.label + "[tempPos] = " + $6.label + "; //inserting in position\n\n";
			}
			| E '[' E ',' E ']' '=' E
			{
				// string user_label = $1.traducao;
				// auto& lbl_umap = context_stack.back();
				// if(lbl_umap.find(user_label) == lbl_umap.end() )
				// 	yyerror($1.label + "not declared");

				$1.tipo = temp_umap[$1.label].tipo;
				int ptrs = temp_umap[$1.label].ptrs;
				int pointsTo = temp_umap[$1.label].pointsTo;

				if($3.tipo != INT)
					yyerror("integer expected in array set index operation");
				if($5.tipo != INT)
					yyerror("integer expected in array set index operation");

				if(pointsTo != temp_umap[$8.label].tipo)
					yyerror("matrix and expression have different types");

				bool hasTamanho = false;

				if(has_length.find($1.tipo) == has_length.end())
					yyerror($1.label + "has not length attribute");

				//in case id has length and is declared, check if types are matching
				if(pointsTo == temp_umap[$8.label].tipo)
				{
					if(!(ptrs == temp_umap[$8.label].ptrs + 1))
						yyerror(tipo_umap[pointsTo] + "is expected");
				}

				//if all good, calculate position
				string size_label = temp_umap[$1.label].size_label;
				string start = temp_umap[$1.label].start_label;
				string step = temp_umap[$1.label].step_label;
				string end = temp_umap[$1.label].end_label;

				string row_size = temp_umap[$1.label].row_size;
				string start_col = temp_umap[$1.label].start_col;
				string step_col = temp_umap[$1.label].step_col;
				string end_col = temp_umap[$1.label].end_col;

				string end_goto_lbl = genSliceLabelEnd();
				string create_goto_lbl = genSliceLabelCreate();
				string lower_lbl = genSliceLabelLower();
				string higher_lbl = genSliceLabelHigher();
				string after_lbl = genAfterSliceLabel();
				sliceLabelCounter += 1;

				string end_goto_lbl_col = genSliceLabelEnd();
				string create_goto_lbl_col = genSliceLabelCreate();
				string lower_lbl_col = genSliceLabelLower();
				string higher_lbl_col = genSliceLabelHigher();
				string after_lbl_col = genAfterSliceLabel();

				sliceLabelCounter += 1;
				$$.traducao = $3.traducao + $5.traducao + $8.traducao;
				$$.traducao += "\tif(" + $3.label + " < 0 ) goto " + end_goto_lbl + ";\n";
				$$.traducao += "\ttempPosRow = " + $3.label + ";\n";
				$$.traducao += "\ttempPosRow = tempPosRow * " + step + ";\n";
				$$.traducao += "\ttempPosRow = tempPosRow + " + start + "; goto " + create_goto_lbl + ";\n";
				$$.traducao += "\t" + end_goto_lbl + ":\n";
				$$.traducao += "\ttempPosRow = " + $3.label + " + 1;\n";
				$$.traducao += "\ttempPosRow = " + step + " * tempPosRow;\n";
				$$.traducao += "\ttempPosRow = tempPosRow + " + end + ";\n";
				$$.traducao += "\t" + create_goto_lbl + ":\n";

				$$.traducao += "\tif(" + $5.label + " < 0 ) goto " + end_goto_lbl_col + ";\n";
				$$.traducao += "\ttempPosCol = " + $5.label + ";\n";
				$$.traducao += "\ttempPosCol = tempPosCol * " + step_col + ";\n";
				$$.traducao += "\ttempPosCol = tempPosCol + " + start_col + "; goto " + create_goto_lbl_col + ";\n";
				$$.traducao += "\t" + end_goto_lbl_col + ":\n";
				$$.traducao += "\ttempPosCol = " + $5.label + " + 1;\n";
				$$.traducao += "\ttempPosCol = " + step_col + " * tempPosCol;\n";
				$$.traducao += "\ttempPosCol = tempPosCol + " + end_col + ";\n";
				$$.traducao += "\t" + create_goto_lbl_col + ":\n";

				$$.traducao += "\ttempPos = tempPosRow * " + row_size + ";\n";
				$$.traducao += "\ttempPos = tempPos + tempPosCol;\n";


				$$.traducao += "\tif(tempPos < 0 || tempPos >= " + size_label + ") goto OutOfBoundsError;\n";

				//after calculating position in tempPos, attempt to insert new item in array
				$$.traducao += "\t" + $1.label + "[tempPos] = " + $8.label + "; //inserting in position\n\n";
			}
			| CONT
			{
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
				$$.label = $1.label;
			}
			;

DCLR		: TK_CASTING TK_ID
			{
				int tipo = tipo_umap_str[$1.label];
				int ptrs = 0;
				int pointsTo = 0;
				if(tipo == STRING)
				{
					ptrs = 1;
				}

				$2.label = get_current_context_id_label($2.traducao, 1, ptrs, pointsTo);

				if(temp_umap[$2.label].tipo != 0)
				{
					yyerror($2.traducao + "ja declarada");
				}

				temp_umap[$2.label].tipo = tipo;
				string default_value = default_value_map[tipo];

				$$.traducao = "";
			}
			| TK_CASTING TK_ID '=' E
			{
				int tipo = tipo_umap_str[$1.label];
				int ptrs = 0;
				int pointsTo = 0;

				if(tipo != $4.tipo)//por enquanto == forever
				{
					yyerror("DCLR -> TK_CASTING TK_ID '=' E\ncoercao nao permitida");
				}
				if(tipo == STRING)
				{
					ptrs = 1;
				}
				$2.label = get_current_context_id_label($2.traducao, 1, ptrs, pointsTo);

				if(temp_umap[$2.label].tipo != 0)
				{
					yyerror($2.traducao + "ja declarada");
				}
				temp_umap[$2.label].tipo = tipo;

				//caso a expressao seja de valor diferente da variavel, tentar conversao implicita
				if( temp_umap[$2.label].tipo != $4.tipo )
				{
					//check if conversion is possible

					//in case converion was success
				}

				bool hasTamanho = false;
				if(tipo == STRING || tipo == ITERATOR || tipo == ARRAY) //add new types with size in if clause, as vectors, matrices
				{
					hasTamanho = true;
					temp_umap[$2.label].size_label = temp_umap[$4.label].size_label;
					temp_umap[$2.label].start_label = temp_umap[$4.label].start_label;
					temp_umap[$2.label].step_label = temp_umap[$4.label].step_label;
					temp_umap[$2.label].end_label = temp_umap[$4.label].end_label;
				}
				add_variable_in_current_context($2.traducao, tipo, hasTamanho);

				//$$.traducao = conversao(antes da linha abaixo)
				$$.traducao = $4.traducao + "\t" + $2.label + " = " + $4.label + ";\n\n";
				//$$.resultado = $1.resultado;
			};


COND 		: E TK_OP_REL E
			{
				$$.tipo = BOOLEAN;
				umap_label_add($$.label, $$.tipo);
				$$.traducao = $1.traducao + $3.traducao;
				$$.traducao += types_operations($$, $1, $2, $3, BOOLEAN);
				//cout << $$.traducao;
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

ARR_REC		: E ','
			{

			}
			| E ']'
			{
				$$.label = $1.label;
				$$.tipo = $1.tipo;
				$$.traducao = $1.traducao;
			}


CONT		: TK_ID TK_CONT E
			{
				string user_label = $1.traducao;
				auto& lbl_umap = context_stack.back();
				if(lbl_umap.find(user_label) == lbl_umap.end() )
					yyerror($1.label + "not declared");

				$1.label = get_current_context_id_label($1.traducao, 0, 0, 0);
				if(temp_umap[$1.label].tipo == 0 || temp_umap[$1.label].tipo >= BOOLEAN)
				{
					yyerror("CONT -> TK_ID TK_CONT E\nOperacao Invalida!!!");
				}

				int ptrs = temp_umap[$1.label].ptrs;
				int pointsTo = temp_umap[$1.label].pointsTo;


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
			| E TK_INCR
			{
				string new_label;
				string value;

				if($1.tipo != INT)
				{
					yyerror("CONT -> E TK_INCR\n");
				}

				umap_label_add(new_label, INT);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				$$.traducao = $1.traducao;
				$$.traducao += "\t" + new_label + " = 1" + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " + " + new_label + ";\n";
			}
			| E TK_DECR
			{
				string new_label;
				string value;

				if($1.tipo != INT)
				{
					yyerror("CONT -> E TK_INCR\n");
				}

				umap_label_add(new_label, INT);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				$$.traducao = $1.traducao;
				$$.traducao += "\t" + new_label + " = 1" + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " - " + new_label + ";\n";
			}
			| TK_INCR E
			{
				string new_label;
				string value;

				if($2.tipo != INT)
				{
					yyerror("CONT -> E TK_INCR\n");
				}

				umap_label_add(new_label, INT);
				$$.tipo = $2.tipo;
				$$.label = $2.label;

				$$.traducao = "\t" + new_label + " = 1" + ";\n";
				$$.traducao += "\t" + $2.label + " = " + $2.label + " + " + new_label + ";\n";
				$$.traducao += $2.traducao;
			}
			| TK_DECR E
			{
				string new_label;
				string value;

				if($2.tipo != INT)
				{
					yyerror("CONT -> E TK_INCR\n");
				}

				umap_label_add(new_label, INT);
				$$.tipo = $2.tipo;
				$$.label = $2.label;

				$$.traducao = "\t" + new_label + " = 1" + ";\n";
				$$.traducao += "\t" + $2.label + " = " + $2.label + " - " + new_label + ";\n";
				$$.traducao += $2.traducao;
			};


BL_END		: TK_END
			{
				endContext();
				$$.traducao = "";
			};

ITR			: ':' E ITR_REST
			{
				if($2.tipo != INT)
					yyerror("only int available to iterators");

				string label_end;
				umap_label_add(label_end, INT);
				$$.resultado = $3.label;
				$$.label = label_end;

				$$.traducao = $3.traducao + $2.traducao;
				$$.traducao += "\t" + label_end + " = " + $2.label + "; //end\n";
			};

ITR_REST	: ':' E '}'
			{
				if($2.tipo != INT)
					yyerror("only int available to iterators");

				string label_step;
				umap_label_add(label_step, INT);
				$$.label = label_step;

				$$.traducao = $2.traducao;
				$$.traducao += "\t" + label_step + " = " + $2.label + "; //step\n";
			}
			| '}'
			{
				string label_step;
				umap_label_add(label_step, INT);
				$$.label = label_step;

				$$.traducao = "\t" + label_step + " = 1; //step\n";
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
