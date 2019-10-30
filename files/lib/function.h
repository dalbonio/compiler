#ifndef FUNCTION_H
#define FUNCTION_H

#include "define.h"
#include "header.h"
#include "variable.h"

void yyerror(string);
string label_generator();
string declare_variables();
string get_id_label(string user_label);
void initialize_tipo_umap();
void set_error_matrix();
void initialize_matrix();
void replace_all(std::string& data, std::string toSearch, std::string replaceStr);
void umap_label_add(string& new_label, int new_tipo, bool hasTamanho = false);
void replace_op(string& op_type, string new_label, string first_label, string second_label, string main_label, string op);
void initialize_op_umap();
string implicit_conversion_op(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type);
string loop_label_generator();
string loop_label_end_generator();
int get_new_type(atributos atr_1, atributos atr_2, atributos atr_3);

void yyerror( string MSG )
{
	cout << "\n---\n" << "linha " << contadorLinha << ": " << MSG << "\n---\n";
	exit (0);
}

string label_generator()
{
	return string("temp") + to_string(tokenContador++);
}

string declare_variables()
{
	string total = string("");

	//comments to help in intermediate code read
	for(int i = context_stack.size() - 1; i >= 0 ; i--)
	{
		for(auto it = context_stack[i].begin(); it != context_stack[i].end(); it++)
		{
			total += "\t//" + it->first + " = " + it->second + "\n";
		}
	}

	total += "\n";

	for(auto it = proc_temp_umap.begin(); it != proc_temp_umap.end(); it++)
	{
		if(it->second == 0)
		{
			it->second = INT;
		}

		total += "\t" + tipo_umap[it->second] + " " + it->first + ";\n";
	}

	total += "\n";

	for(auto it = temp_umap.begin(); it != temp_umap.end(); it++)
	{
		if(it->second.tipo == 0)
		{
			it->second.tipo = INT;
		}

		total += "\t" + tipo_umap[it->second.tipo] + " " + it->first + ";\n";
	}

	total += "\n";

	return total;
}
void initialize_tipo_umap()
{
	tipo_umap[INT] = "int";
	tipo_umap[STRING] = "char*";
	tipo_umap[BOOLEAN] = "int";
	tipo_umap[DOUBLE] = "double";

	tipo_umap_str["int"] = INT;
	tipo_umap_str["string"] = STRING;
	tipo_umap_str["int"] = BOOLEAN;
	tipo_umap_str["double"] = DOUBLE;
}

void set_error_matrix()
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
}

void initialize_matrix()
{
	set_error_matrix();

	for(int i = ADD; i <= LESS; i++)
	{
		for(int j = INT; j <= DOUBLE; j++)
		{
			for(int k = INT; k <= DOUBLE; k++)
			{
				if(j < k)
				{
					matrix[i][j][k] = to_string(k) + "\tnew_label = ("+ tipo_umap[k] + ") first_label;\n\tmain_label = new_label operator second_label;\n";
				}
				else if(j > k)
				{
					matrix[i][j][k] = to_string(j) + "\tnew_label = ("+ tipo_umap[j] + ") second_label;\n\tmain_label = first_label operator new_label;\n";
				}
			}
		}

		for(int j = INT; j <= DOUBLE; j++)
		{
			matrix[i][j][j] = to_string(j) + "\tmain_label = first_label operator second_label;\n";
		}
	}

	for(int i = AND; i <= OR ; i++)
	{
		matrix[i][BOOLEAN][BOOLEAN] = to_string(BOOLEAN) + "\tmain_label = first_label operator second_label;\n";
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

void umap_label_add(string& new_label, int new_tipo, bool hasTamanho)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = new_tipo;
	if(hasTamanho)
	{
		string size_label = label_generator();
		variavel size_var;
		size_var.tipo = INT;
		temp_umap[size_label] = size_var;
		new_var.size_label = size_label;
	}

	temp_umap[new_label] = new_var;
}

string search_variable(string var_name)
{
	for(int i = context_stack.size() - 1; i >= 0 ; i--)
	{
		auto lbl_umap = context_stack[i];
		//caso não encontre a variavel no contexto mais proximo, tentar no proximo
		if(lbl_umap.find(var_name) != lbl_umap.end() )
			return lbl_umap[var_name];
	}
	return "0";
}

string get_current_context_id_label(string user_label)
{
	auto& lbl_umap = context_stack.back();
	if(lbl_umap.find(user_label) == lbl_umap.end() )
	{
		string new_label = label_generator();
		variavel new_var;
		new_var.user_label = user_label;
		new_var.tipo = 0;

		lbl_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}

	return lbl_umap[user_label];
}

string get_id_label(string user_label)
{
	auto& lbl_umap = context_stack.back();
	string label = search_variable(user_label);
	if(label == "0")
	{
		string new_label = label_generator();
		variavel new_var;
		new_var.user_label = user_label;
		new_var.tipo = 0;

		lbl_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}
	return label;
}


void replace_op(string& op_type, string new_label, string first_label, string second_label, string main_label, string op)
{
	replace_all(op_type, "new_label", new_label);
	replace_all(op_type, "first_label", first_label);
	replace_all(op_type, "second_label", second_label);
	replace_all(op_type, "main_label", main_label);
	replace_all(op_type, "operator", op);
}

string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho = false)
{
	auto cur_umap = context_stack.back();
	string new_label;
	umap_label_add(new_label, tipo, hasTamanho);
	cur_umap[var_name] = new_label;
}

void initialize_op_umap()
{
	op_umap[ADD] = "+";
	op_umap[SUB] = "-";
	op_umap[MULT] = "*";
	op_umap[DIV] = "/";

	op_umap[GEQ] = ">=";
	op_umap[LEQ] = "<=";
	op_umap[LESS] = "<";
	op_umap[GREATER] = ">";

	op_umap[EQ] = "==";
	op_umap[NEQ] = "!=";

	op_umap[AND] = "&&";
	op_umap[OR] = "||";

    op_umap_str["+"] = ADD;
	op_umap_str["-"] = SUB;
	op_umap_str["*"] = MULT;
	op_umap_str["/"] = DIV;

	op_umap_str[">="] = GEQ;
	op_umap_str["<="] = LEQ;
	op_umap_str["<"] = LESS;
	op_umap_str[">"] = GREATER;

	op_umap_str["eq"] = EQ;
	op_umap_str["neq"] = NEQ;

	op_umap_str["and"] = AND;
	op_umap_str["or"] = OR;
}

void initialize_proc_temp_umap()
{
	proc_temp_umap["countTempLabel"] = INT;

	has_length.insert(pair<int, bool>(STRING, true));
}

string implicit_conversion_op(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type)
{
	//final_type == 0 serve para o tipo de $$ ser igual ao tipo das conversões, em operações aritméticas
	int op;
	int new_type;
	string new_label;
	string op_translate;

	op = op_umap_str[atr_2.traducao];
	op_translate = matrix[op][atr_1.tipo][atr_3.tipo];
	new_type = op_translate[0] - '0';

	if(op_translate == ERROR_VALUE)
	{
		string tipo_1 = atr_1.tipo == BOOLEAN ? "boolean" : tipo_umap[atr_1.tipo];
		string tipo_2 = atr_3.tipo == BOOLEAN ? "boolean" : tipo_umap[atr_3.tipo];

		yyerror("Operação \"" + atr_2.traducao + "\" entre os tipos \"" + tipo_1 + "\" e \"" + tipo_2 + "\" não pode ser realizada.");
	}

	if(atr_1.tipo != atr_3.tipo)
	{
		umap_label_add(new_label, new_type);
	}

	if(final_type == 0) //para casos onde a expressao retorna um tipo diferente do tipo convertido
	{
		atr_main.tipo = new_type;
	}

	op_translate.replace(0, 1, "");
	//cout << op_translate << endl;
	replace_op(op_translate, new_label, atr_1.label, atr_3.label, atr_main.label, op_umap[op]);
	//cout << op_translate << endl;
	//cout << new_label << endl << atr_1.label << endl << atr_3.label << endl << atr_main.label << endl << op_umap[op] << endl;

	return op_translate;
}

string loop_label_generator()
{
	return string("LOOP_") + to_string(loopContador);
}

string loop_label_end_generator()
{
	return string("LOOP_END_") + to_string(loopContador++);
}

int get_new_type(atributos atr_1, atributos atr_2, atributos atr_3)
{
	int op;
	int new_type;
	string new_label;
	string op_translate;

	op = op_umap_str[atr_2.traducao];
	op_translate = matrix[op][atr_1.tipo][atr_3.tipo];
	new_type = op_translate[0] - '0';

	return new_type;
}

string genCountStrLabelStart()
{
	return string("CountStrLabelStart") + to_string(strLabelCounter) + ":\n";
}

string genCountStrLabelEnd()
{
	string str = string("CountStrLabelEnd") + to_string(strLabelCounter) + ":\n";
	return str;
}

void pushContext()
{
	context_stack.push_back(unordered_map<string, string>());
}

void endContext()
{
	context_stack.pop_back();
}

string countStringProc()
{
	string traducao = "\t//contandoStr\n";
	string labelStart = genCountStrLabelStart();
	string labelEnd = genCountStrLabelEnd();

	traducao += "\tcountTempLabel = 0\n";
	traducao += "\t" + labelStart;
	traducao += "\texpTempLabel = buffer[countTempLabel] == \'\\0\';\n";
	traducao += "\tif(expTempLabel) goto " + genCountStrLabelEnd() + "\n";
	traducao += "\tcountTempLabel = countTempLabel + 1\n";
	traducao += "\tgoto " + labelStart + "\n";
	traducao += "\t" + labelEnd + "\n";

	strLabelCounter += 1;
	return traducao;
}

#endif
