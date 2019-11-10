#ifndef HEADER_H
#define HEADER_H

#include <iostream>
#include <string>
#include <sstream>
#include <iterator>
#include <unordered_map>
#include <map>
#include <queue>
#include <stack>
#include <vector>

using namespace std;

struct variavel
{
	int tipo;
	int pointsTo;
	int fixed;
	int ptrs;
	int isMat;

	string user_label;
	string size_label;
	string start_label;
	string end_label;
	string step_label;

	string start_col;
	string step_col;
	string end_col;

	string row_size;
};

struct atributos
{
	string label;
	string traducao;
	int resultado;
	int tipo;
};

#endif
