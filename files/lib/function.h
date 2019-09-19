#ifndef FUNCTION_H
#define FUNCTION_H

#include "define.h"
#include "header.h"

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

void yyerror(string);

string label_generator();
string declare_variables();
string get_id_label(string user_label);
void initialize_tipo_umap();
void initialize_matrix();
void replace_all(std::string & data, std::string toSearch, std::string replaceStr);
void umap_label_add(string& new_label, int new_tipo);
void replace_op(string& op_type, string new_label, string first_label, string second_label, string final_label, string op);
void initialize_op_umap();

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

#endif