#ifndef FUNCTION_H
#define FUNCTION_H

#include "define.h"
#include "header.h"
#include "variable.h"

void yyerror(string MSG)
{
	cout << "\n---\n" << "linha " << contadorLinha << ": " << MSG << "\n---\n";
	exit (0);
}

string label_generator()
{
	return string("temp") + to_string(tokenContador++);
}

string get_tipo(int tipo, int qtd_ptr = 0)
{

	if(qtd_ptr > 0)
	{
		string ptrs = "";
		for(int i = 0; i < qtd_ptr; i++){
			ptrs += "*";
		}
		return tipo_umap[tipo] + ptrs;
	}

	return tipo_umap[tipo];
}

string declare_variables()
{
	string total = string("");

	//comments to help in intermediate code read
	//show the match between written variable and temp variable
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
		string tipo;
		if(it->second.tipo != ARRAY)
		{
			tipo = get_tipo(it->second.tipo, it->second.ptrs);
		}
		else
		{
			tipo = get_tipo(it->second.pointsTo, it->second.ptrs);
		}

		total += "\t" + tipo + " " + it->first + ";\n";
	}

	total += "\n";

	return total;
}

void initialize_tipo_umap()
{
	tipo_umap[INT] = "int";
	tipo_umap[STRING] = "char";
	tipo_umap[BOOLEAN] = "int";
	tipo_umap[DOUBLE] = "double";
	tipo_umap[ITERATOR] = "int";

	tipo_umap_str["int"] = INT;
	tipo_umap_str["string"] = STRING;
	tipo_umap_str["boolean"] = BOOLEAN;
	tipo_umap_str["double"] = DOUBLE;
	tipo_umap_str["iterator"] = ITERATOR;

	default_value_map[INT] = "0";
	default_value_map[DOUBLE] = "0.0";
	default_value_map[STRING] = "\"\\0\"";
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

void replace_all(std::string& data, std::string toSearch, std::string replaceStr)
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

void umap_label_add(string& new_label, int new_tipo, bool hasTamanho = false)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = new_tipo;
	new_var.ptrs = 0;
	new_var.isMat = 0;
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
		new_var.ptrs = 1;
		//cout << "size_label: " << size_label << " " << new_var.size_label << endl;
	}

	temp_umap[new_label] = new_var;
	//cout << "label: " << new_label << " size_label: " << temp_umap[new_label].size_label << endl;
}

void umap_label_add_iterator(string& new_label, int qtd_ptrs = 0)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = ITERATOR;
	new_var.isMat = 0;

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
	new_var.ptrs = qtd_ptrs;

	temp_umap[new_label] = new_var;
}

void umap_label_add_array(string& new_label, int points_to, int qtd_ptrs = 0)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = ARRAY;
	new_var.isMat = 0;
	new_var.pointsTo = points_to;

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
	new_var.ptrs = qtd_ptrs;

	temp_umap[new_label] = new_var;
}

void umap_label_add_matrix(string& new_label, int points_to, int qtd_ptrs = 0)
{
	new_label = label_generator();
	variavel new_var;
	new_var.tipo = ARRAY;
	new_var.pointsTo = points_to;
	new_var.isMat = 1;

	string size_label = label_generator();
	string start_label = label_generator();
	string end_label = label_generator();
	string step_label = label_generator();

	string start_col = label_generator();
	string step_col = label_generator();
	string end_col = label_generator();

	string row_size = label_generator();

	variavel size_var;
	size_var.tipo = INT;

	temp_umap[size_label] = size_var;
	temp_umap[start_label] = size_var;
	temp_umap[end_label] = size_var;
	temp_umap[step_label] = size_var;

	temp_umap[row_size] = size_var;
	temp_umap[start_col] = size_var;
	temp_umap[end_col] = size_var;
	temp_umap[step_col] = size_var;

	new_var.size_label = size_label;
	new_var.start_label = start_label;
	new_var.end_label = end_label;
	new_var.step_label = step_label;

	new_var.row_size = row_size;
	new_var.start_col = start_col;
	new_var.end_col = end_col;
	new_var.step_col = step_col;

	new_var.ptrs = qtd_ptrs;

	temp_umap[new_label] = new_var;
}


string search_variable(string var_name)
{
	for(int i = context_stack.size() - 2; i >= 0 ; i--)
	{
		auto lbl_umap = context_stack[i];
		//caso não encontre a variavel no contexto mais proximo, tentar no proximo
		if(lbl_umap.find(var_name) != lbl_umap.end() )
			return lbl_umap[var_name];
	}

	return "0";
}

string search_variable_cur_ctx(string var_name)
{
	int i = context_stack.size() - 1;
	auto lbl_umap = context_stack[i];
	//caso não encontre a variavel no contexto, retornar uma label invalida
	if(lbl_umap.find(var_name) != lbl_umap.end() )
		return lbl_umap[var_name];

	return "0";
}

string get_current_context_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0)
{
	auto& lbl_umap = context_stack.back();
	if(lbl_umap.find(user_label) == lbl_umap.end() )
	{
		string new_label = label_generator();
		variavel new_var;
		new_var.user_label = user_label;
		new_var.tipo = 0;
		new_var.fixed = fixed;
		new_var.ptrs = ptrs;
		new_var.pointsTo = pointsTo;

		lbl_umap[user_label] = new_label;
		temp_umap[new_label] = new_var;

		return new_label;
	}

	return lbl_umap[user_label];
}

string get_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0)
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

string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho = false)
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
	proc_temp_umap["tempPosRow"] = INT;
	proc_temp_umap["tempPosCol"] = INT;
	proc_temp_umap["posTemp"] = INT;
	proc_temp_umap["tmp"] = INT;
	proc_temp_umap["pEndTemp1"] = INT;
	proc_temp_umap["pEndTemp2"] = INT;
	proc_temp_umap["pEndTemp3"] = INT;
	proc_temp_umap["expTempLabel"] = INT;


	has_length.insert(pair<int, bool>(STRING, true));
	has_length.insert(pair<int, bool>(ITERATOR, true));
	has_length.insert(pair<int, bool>(ARRAY, true));
	has_length.insert(pair<int, bool>(MATRIX, true));
	has_length.insert(pair<int, bool>(DOUBLEARR, true));
	has_length.insert(pair<int, bool>(STRINGARR, true));
	has_length.insert(pair<int, bool>(ITERATORARR, true));
	has_length.insert(pair<int, bool>(BOOLEANARR, true));

	assoc_type[ARRAY] = INT;
	assoc_type[STRING] = STRING;
	assoc_type[INTARR] = INT;
	assoc_type[STRINGARR] = STRING;
	assoc_type[DOUBLEARR] = DOUBLE;
	assoc_type[ITERATORARR] = ITERATOR;
	assoc_type[ITERATOR] = INT;
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
	return string("CountStrLabelStart") + to_string(strLabelCounter);
}

string genCountStrLabelEnd()
{
	string str = string("CountStrLabelEnd") + to_string(strLabelCounter);
	return str;
}

string genSliceLabelStart()
{
	return string("SliceLabelStart") + to_string(sliceLabelCounter);
}

string genSliceLabelEnd()
{
	return string("SliceLabelEnd") + to_string(sliceLabelCounter);
}

string genSliceLabelCreate()
{
	return string("SliceLabelCreate") + to_string(sliceLabelCounter);
}

string genSliceLabelHigher()
{
	return string("SliceLabelLower") + to_string(sliceLabelCounter);
}

string genSliceLabelLower()
{
	return string("SliceLabelHigher") + to_string(sliceLabelCounter);
}

string genAfterSliceLabel()
{
	return string("AfterSliceLabel") + to_string(sliceLabelCounter);
}

void pushContext()
{
	if(ctxPushReseter)
	{
		ctxPushReseter = 0;
	}
	else
	{
		context_stack.push_back(unordered_map<string, string>());
	}
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

	traducao += "\tcountTempLabel = 0;\n";
	traducao += "\t" + labelStart + ":\n";
	traducao += "\texpTempLabel = buffer[countTempLabel] == \'\\0\';\n";
	traducao += "\tif(expTempLabel) goto " + genCountStrLabelEnd() + ";\n";
	traducao += "\tcountTempLabel = countTempLabel + 1;\n";
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
	string command2 = "\tsize_final_str = size_final_str + 1;\n";
	string command3 = "\tnew_label = (char*) malloc(size_final_str);\n";
	string command4 = "\tstrcpy(new_label, \"\");\n";
	string command5 = "\tstrcat(new_label, first_label);\n";
	string command6 = "\tstrcat(new_label, second_label);\n";
	string command7 = "\tmain_label = new_label;\n";
	matrix[ADD][STRING][STRING] = to_string(STRING) + command1 + command2 + command3 + command4 + command5 + command6 + command7;

	string command8 = string("\tsprintf(") + "convert_label, \"%lf\", second_label);\n";
	string command9 = string("\tsprintf(") + "convert_label, \"%lf\", first_label);\n";
	string command10 = string("\tsprintf(") + "convert_label, \"%d\", second_label);\n";
	string command11 = string("\tsprintf(") + "convert_label, \"%d\", first_label);\n";
	string command12 = command1 + command2 + command3 + command4 + command5 + command6 + command7;
	string command13 = command1 + command2 + command3 + command4 + command5 + command6 + command7;
	string command14 = countStringProc();
	string command15 = "\tsize_convert_str = countTempLabel;\n";

	replace_all(command12, "second_label", "convert_label");
	replace_all(command12, "size_second_str", "size_convert_str");
	replace_all(command13, "first_label", "convert_label");
	replace_all(command13, "size_first_str", "convert_label");

	matrix[ADD][STRING][DOUBLE] = to_string(STRING) + command8 + command14 + command15 + command12;
	matrix[ADD][DOUBLE][STRING] = to_string(STRING) + command9 + command14 + command15 + command13;
	matrix[ADD][STRING][INT] = to_string(STRING) + command10 + command14 + command15 + command12;
	matrix[ADD][INT][STRING] = to_string(STRING) + command11 + command14 + command15 + command13;

	for(int i = EQ; i <= LESS; i++)
	{
		string command1 = "\tnew_label = strcmp(first_label, second_label);\n";
		string command2 = "\tnew_label = new_label operator 0;\n";
		string command3 = "\tif(new_label) goto string_start;\n";
		string command4 = "\tmain_label = 0;\n";
		string command5 = "\tgoto string_end;\n";
		string command6 = "\tstring_start:\n";
		string command7 = "\tmain_label = 1;\n";
		string command8 = "\tstring_end:\n";
		matrix[i][STRING][STRING] = to_string(BOOLEAN) + command1 + command2 + command3 + command4 + command5 + command6 + command7 + command8;
	}
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

string double_to_string(string double_label, string str_label)
{
	string command1 = string("\t") + str_label + " = (char*) malloc(" + to_string(MAX_DOUBLE) + ");\n";
	string command2 = string("\tsprintf(") + str_label + ", \"%lf\", " + double_label + ");\n";
	return command1 + command2;
}

string int_to_string(string int_label, string str_label)
{
	string command1 = string("\t") + str_label + " = (char*) malloc(" + to_string(MAX_INT) + ");\n";
	string command2 = string("\tsprintf(") + str_label + ", \"%d\", " + int_label + ");\n";
	return command1 + command2;
}

string cmd_label_generator(string cmd_name = "CMD", int desloc = 0)
{
	string label_name = cmd_name + string("_");

	if(cmd_name == "IF")
	{
		label_name += to_string(ifLabelContador - desloc);
	}
	else if(cmd_name == "SWITCH")
	{
		label_name += to_string(switchLabelContador - desloc);
	}
	else if(cmd_name == "STRING")
	{
		label_name += to_string(strLabelCounter - desloc);
	}
	else
	{
		label_name += to_string(cmdLabelContador - desloc);
	}

	return label_name;
}

string cmd_label_iter_generator(int desloc = 0)
{
	string label_name = string("CMD_ITER_");
	label_name += to_string(cmdLabelContador - desloc);
	return label_name;
}

string cmd_label_end_generator(string cmd_name = "CMD", int desloc = 0)
{
	string label_end_name = cmd_name + string("_END_");

	if(cmd_name == "IF")
	{
		label_end_name += to_string(ifLabelContador + desloc);
	}
	else if(cmd_name == "SWITCH")
	{
		label_end_name += to_string(switchLabelContador + desloc);
	}
	else if(cmd_name == "STRING")
	{
		label_end_name += to_string(strLabelCounter + desloc);
	}
	else
	{
		label_end_name += to_string(cmdLabelContador + desloc);
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
		temp_umap[new_label].pointsTo = STRING;
		temp_umap[new_label].ptrs = 1;
	}
	else
	{
		umap_label_add(new_label, new_type, hasTamanho);
	}

	if(final_type == 0) //para casos onde a expressao retorna um tipo diferente do tipo convertido
	{
		atr_main.tipo = new_type;
		umap_label_add(atr_main.label, atr_main.tipo, hasTamanho);

		if(new_type == STRING)
		{
			temp_umap[atr_main.label].ptrs = 1;
			temp_umap[atr_main.label].pointsTo = STRING;
		}
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

		if(atr_1.tipo != STRING || atr_3.tipo != STRING)
		{
			string convert_label;
			umap_label_add(convert_label, STRING, hasTamanho);
			temp_umap[convert_label].ptrs = 1;
			temp_umap[convert_label].pointsTo = STRING;
			op_translate = string("\t") + convert_label + " = (char*) malloc(" + to_string(MAX_DOUBLE) + ");\n" + op_translate;
			replace_all(op_translate, "size_convert_str", temp_umap[convert_label].size_label);
			replace_all(op_translate, "convert_label", convert_label);
		}

		if(op >= EQ && op <= LESS)
		{
			replace_all(op_translate, "string_start", cmd_label_generator("STRING"));
			replace_all(op_translate, "string_end", cmd_label_end_generator("STRING"));
			strLabelCounter++;
		}
	}

	//cout << "main: " << atr_main.label << endl;

	replace_all(op_translate, "new_label", new_label);
	replace_all(op_translate, "first_label", atr_1.label);
	replace_all(op_translate, "second_label", atr_3.label);
	replace_all(op_translate, "main_label", atr_main.label);
	replace_all(op_translate, "operator", op_umap[op]);

	return op_translate;
}

string funct_label_generator()
{
	return string("funct_") + to_string(funct_counter++);
}

void emptying_queue(queue<int>& Q)
{
	while(!Q.empty())
	{
		//cout<<" "<<Q.front();
		Q.pop();
	}

	//cout << Q.size();

	//cout<<endl;
}

string declare_function_variables()
{
	string total = string("");

	for(auto it = temp_umap.begin(); it != temp_umap.end(); it++)
	{
		//cout << it -> first << endl;
		if(it->second.tipo == 0)
		{
			it->second.tipo = INT;
		}
		string tipo;
		if(it->second.tipo != ARRAY)
		{
			tipo = get_tipo(it->second.tipo, it->second.ptrs);
		}
		else
		{
			tipo = get_tipo(it->second.pointsTo, it->second.ptrs);
		}

		total += "\t" + tipo + " " + it->first + ";\n";
	}

	total += "\n";

	return total;
}

void removing_match_umap(unordered_map<string, variavel>& iterator_umap, unordered_map<string, variavel>& toEmpty_umap)
{
	for(auto it = iterator_umap.begin(); it != iterator_umap.end(); it++)
	{
		toEmpty_umap.erase(it->first);
	}
}

string free_variables()
{
	string total = string("");

	for(auto it = temp_umap.begin(); it != temp_umap.end(); it++)
	{
		if(it->second.ptrs > 0)
		{
			total += string("\t") + "free(" + it->first + ");\n";
			total += "\t" + it->first + " = NULL;\n";
		}
	}

	total += "\n";

	return total;
}

#endif
//IRMAO OLHA O TAMANHO DAS STRINGS VINDAS DE DOUBLE E DE INT