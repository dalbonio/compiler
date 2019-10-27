#ifndef VARIABLE_H
#define VARIABLE_H

unordered_map<string, string> var_umap;
unordered_map<string, variavel> temp_umap;
unordered_map<int, string> tipo_umap;
unordered_map<string, int> tipo_umap_str;
unordered_map<int, string> op_umap;
unordered_map<string, int> op_umap_str;
vector <unordered_map<string, string>> context_stack;

queue <string> multiple_atr_queue;
stack <pair<string, int>> multiple_atr_stack;

string matrix[QTD_OPERATORS + 1][QTD_TYPES + 1][QTD_TYPES + 1];

int tokenContador = 0;
int contadorLinha = 1;
int loopContador = 0;

#endif
