#ifndef VARIABLE_H
#define VARIABLE_H

//maps all user variables to temporary variables
//unordered_map<string, string> var_umap;

//maps all temporary variables names to their "variable" struct
unordered_map<string, variavel> temp_umap;
//maps tipo integer to their respective string in intermediate code
unordered_map<int, string> tipo_umap;
//reverse from above
unordered_map<string, int> tipo_umap_str;
//maps operators to strings representing them
unordered_map<int, string> op_umap;
//reverse from above
unordered_map<string, int> op_umap_str;
//vector of maps to represent context stack
vector <unordered_map<string, string>> context_stack;
//map to connect variables like vectors or strings to their size temp variable
unordered_map<string, string> size_umap;
//maps all procedure temporary
unordered_map<string, int> proc_temp_umap;

queue <string> multiple_atr_queue;
stack <pair<string, int>> multiple_atr_stack;

//this maps have the purpose of making syntax check on types easier,
//like checking if certain type has length attribute, they work as a hash table
//the value in key-value pair has no actual use. All itens in these maps are
//inserted right here. This avoids "$1.type == STRING || $1.type == INT" f.i
unordered_map<int, bool> has_length;

string matrix[QTD_OPERATORS + 1][QTD_TYPES + 1][QTD_TYPES + 1];

int tokenContador = 0;
int contadorLinha = 1;
int cmdLabelContador = 0;
int strLabelCounter = 0;

stack <string> labels_if;
int ifLabelContador = 0;
string if_condition = "";

#endif
