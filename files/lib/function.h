#ifndef FUNCTION_H
#define FUNCTION_H

#include "define.h"
#include "header.h"
#include "variable.h"

void yyerror(string);
string label_generator();
string declare_variables();
void initialize_tipo_umap();
void initialize_op_umap();
void replace_all(std::string& data, std::string toSearch, std::string replaceStr);

void umap_label_add(string& new_label, int new_tipo, bool hasTamanho = false);
void umap_label_add_iterator(string& new_label);
string search_variable(string var_name);
string get_current_context_id_label(string user_label);
string get_id_label(string user_label);
string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho = false);
void initialize_proc_temp_umap();
int get_new_type(atributos atr_1, atributos atr_2, atributos atr_3);
string genCountStrLabelStart();
string genCountStrLabelEnd();
void pushContext();
void endContext();
string countStringProc();
string outOfBoundsError();
void set_error_matrix();
void set_int_double_matrix();
void initialize_matrix();
string string_to_double(string str_label, string double_label);
string string_to_int(string str_label, string int_label);

string cmd_label_generator(string cmd_name = "CMD");
string cmd_label_end_generator(string cmd_name = "CMD");
string types_operations(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type);

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
	tipo_umap[ITERATOR] = "int";

	tipo_umap_str["int"] = INT;
	tipo_umap_str["string"] = STRING;
	tipo_umap_str["boolean"] = BOOLEAN;
	tipo_umap_str["double"] = DOUBLE;
	tipo_umap_str["iterator"] = ITERATOR;
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
		string start_label = label_generator();
		string end_label = label_generator();
		string step_label = label_generator();
		//cout << "size: " << size_label << endl;
		variavel size_var;
		size_var.tipo = INT;
		temp_umap[size_label] = size_var;
		temp_umap[start_label] = size_var;
		temp_umap[end_label] = size_var;
		temp_umap[step_label] = size_var;

		new_var.size_label = size_label;
		new_var.start_label = start_label;
		new_var.end_label = end_label;
		new_var.step_label = step_label;
		//cout << "size_label: " << size_label << " " << new_var.size_label << endl;
	}

	temp_umap[new_label] = new_var;
	//cout << "label: " << new_label << " size_label: " << temp_umap[new_label].size_label << endl;
}

void umap_label_add_iterator(string& new_label)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = ITERATOR;

	string size_label = label_generator();
	string start_label = label_generator();
	string end_label = label_generator();
	string step_label = label_generator();

	variavel size_var;
	size_var.tipo = INT;

	temp_umap[size_label] = size_var;
	temp_umap[start_label] = size_var;
	temp_umap[end_label] = size_var;
	temp_umap[step_label] = size_var;

	new_var.size_label = size_label;
	new_var.start_label = start_label;
	new_var.end_label = end_label;
	new_var.step_label = step_label;

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

string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho)
{
	auto cur_umap = context_stack.back();
	string new_label;
	umap_label_add(new_label, tipo, hasTamanho);
	//cout << "con_label: " << new_label << " con_size_label: " << temp_umap[new_label].size_label << endl;
	cur_umap[var_name] = new_label;
}

string add_iterator_in_current_context(string var_name)
{
	auto cur_umap = context_stack.back();
	string new_label;
	umap_label_add_iterator(new_label);
	//cout << "con_label: " << new_label << " con_size_label: " << temp_umap[new_label].size_label << endl;
	cur_umap[var_name] = new_label;
}

void initialize_proc_temp_umap()
{
	proc_temp_umap["countTempLabel"] = INT;
	proc_temp_umap["boundaryCheckTemp"] = INT;
	proc_temp_umap["tempPos"] = INT;
	proc_temp_umap["posTemp"] = INT;
	proc_temp_umap["pEndTemp1"] = INT;
	proc_temp_umap["pEndTemp2"] = INT;
	proc_temp_umap["pEndTemp3"] = INT;


	has_length.insert(pair<int, bool>(STRING, true));
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
	return string("CountStrLabelStart") + to_string(strLabelCounter) + "\n";
}

string genCountStrLabelEnd()
{
	string str = string("CountStrLabelEnd") + to_string(strLabelCounter) + "\n";
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
	traducao += "\t" + labelStart + ":";
	traducao += "\texpTempLabel = buffer[countTempLabel] == \'\\0\';\n";
	traducao += "\tif(expTempLabel) goto " + genCountStrLabelEnd() + ";\n";
	traducao += "\tcountTempLabel = countTempLabel + 1\n";
	traducao += "\tgoto " + labelStart + ";\n";
	traducao += "\t" + labelEnd + ":\n";

	strLabelCounter += 1;
	return traducao;
}

string outOfBoundsError()
{
	string traducao = string("\tOutOfBoundsError:\n");
	traducao += "\tcout << \"Index out of bounds\";\n";
	traducao += "\tgoto End_Of_Stream;\n";
	return traducao;
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

void set_int_double_matrix()
{
	for(int i = ADD; i <= LESS; i++)
	{
		for(int j = INT; j <= DOUBLE; j++)
		{
			for(int k = INT; k <= DOUBLE; k++)
			{
				string command1;
				string command2;

				if(j < k)
				{
					command1 = "\tnew_label = ("+ tipo_umap[k] + ") first_label;\n";
					command2 = "\tmain_label = new_label operator second_label;\n";
					matrix[i][j][k] = to_string(k) + command1 + command2;
				}
				else if(j > k)
				{
					command1 = "\tnew_label = ("+ tipo_umap[j] + ") second_label;\n";
					command2 = "\tmain_label = first_label operator new_label;\n";
					matrix[i][j][k] = to_string(j) + command1 + command2;
				}
			}
		}

		for(int j = INT; j <= DOUBLE; j++)
		{
			matrix[i][j][j] = to_string(j) + "\tmain_label = first_label operator second_label;\n";
		}
	}
}

void set_boolean_matrix()
{
	for(int i = AND; i <= OR ; i++)
	{
		matrix[i][BOOLEAN][BOOLEAN] = to_string(BOOLEAN) + "\tmain_label = first_label operator second_label;\n";
	}
}

void set_string_matrix()
{
	string command1 = "\tsize_final_str = size_first_str + size_second_str;\n";
	string command2 = "\tsize_final_str = size_final_str - 1;\n";
	string command3 = "\tnew_label = (char*) malloc(size_final_str);\n";
	string command4 = "\tstrcpy(new_label, \"\");\n";
	string command5 = "\tstrcat(new_label, first_label);\n";
	string command6 = "\tstrcat(new_label, second_label);\n";
	string command7 = "\tmain_label = new_label;\n";
	matrix[ADD][STRING][STRING] = to_string(STRING) + command1 + command2 + command3 + command4 + command5 + command6 + command7;
}

void initialize_matrix()
{
	set_error_matrix();
	set_int_double_matrix();
	set_boolean_matrix();
	set_string_matrix();
}

string string_to_double(string str_label, string double_label)
{
	return string("\tsscanf(") + str_label + string(", \"%lf\", &") + double_label + string(");\n");
}

string string_to_int(string str_label, string int_label)
{
	return string("\tsscanf(") + str_label + string(", \"%d\", &") + int_label + string(");\n");
}

string cmd_label_generator(string cmd_name)
{
	string label_name = cmd_name + string("_");

	if(cmd_name == "IF")
	{
		label_name += to_string(ifLabelContador);
	}
	else if(cmd_name == "SWITCH")
	{
		label_name += to_string(switchLabelContador);
	}
	else
	{
		label_name += to_string(cmdLabelContador);
	}

	return label_name;
}

string cmd_label_end_generator(string cmd_name)
{
	string label_end_name = cmd_name + string("_END_");

	if(cmd_name == "IF")
	{
		label_end_name += to_string(ifLabelContador);
	}
	else if(cmd_name == "SWITCH")
	{
		label_end_name += to_string(switchLabelContador);
	}
	else
	{
		label_end_name += to_string(cmdLabelContador);
	}

	return label_end_name;
}

string types_operations(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type)
{
	//final_type == 0 serve para o tipo de $$ ser igual ao tipo das conversões, em operações aritméticas
	int op;
	int new_type;
	string new_label;
	string op_translate;
	bool hasTamanho = false;

	op = op_umap_str[atr_2.traducao];
	op_translate = matrix[op][atr_1.tipo][atr_3.tipo];
	new_type = op_translate[0] - '0';

	if(op_translate == ERROR_VALUE)
	{
		string tipo_1 = atr_1.tipo == BOOLEAN ? "boolean" : tipo_umap[atr_1.tipo];
		string tipo_2 = atr_3.tipo == BOOLEAN ? "boolean" : tipo_umap[atr_3.tipo];

		yyerror("types_operations()\nOperação \"" + atr_2.traducao + "\" entre os tipos \"" + tipo_1 + "\" e \"" + tipo_2 + "\" não pode ser realizada.");
	}

	if(atr_1.tipo == STRING || atr_3.tipo == STRING)
	{
		hasTamanho = true;
		umap_label_add(new_label, new_type, hasTamanho);
	}

	if((atr_1.tipo != atr_3.tipo) && hasTamanho == false)
	{
		umap_label_add(new_label, new_type, hasTamanho);
	}

	if(final_type == 0) //para casos onde a expressao retorna um tipo diferente do tipo convertido
	{
		atr_main.tipo = new_type;
	}

	op_translate.replace(0, 1, "");
	//cout << "\n--AA: " << temp_umap[new_label].tipo << endl;
	//cout << "\n--BB: " << temp_umap[atr_1.label].tipo << endl;
	//cout << "op_label: " << new_label << " op_size_label: " << temp_umap[new_label].size_label << endl;
	//cout << "op_label: " << atr_1.label << " op_size_label: " << temp_umap[atr_1.label].size_label << endl;
	//cout << "op_label: " << atr_3.label << " op_size_label: " << temp_umap[atr_3.label].size_label << endl;
	if(hasTamanho == true)
	{
		replace_all(op_translate, "size_final_str", temp_umap[new_label].size_label);
		replace_all(op_translate, "size_first_str", temp_umap[atr_1.label].size_label);
		replace_all(op_translate, "size_second_str", temp_umap[atr_3.label].size_label);
	}

	//cout << "main: " << atr_main.label << endl;

	replace_all(op_translate, "new_label", new_label);
	replace_all(op_translate, "first_label", atr_1.label);
	replace_all(op_translate, "second_label", atr_3.label);
	replace_all(op_translate, "main_label", atr_main.label);
	replace_all(op_translate, "operator", op_umap[op]);

	return op_translate;
}

#endif
