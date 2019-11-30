void yyerror(string MSG);
/*
    imprime uma mensagem de erro
    interrompe a execução do parser
*/

string label_generator();
/*
    retorna uma label com o valor de contador de token
    incrementa o contador de token
*/

string get_tipo(int tipo, int qtd_ptr = 0);
/*
    retorna o tipo, considerando a quantidade de ponteiros
*/

string declare_variables();
/*
    retorna uma string com:
        comentários relacionando variaveis do codigo inicial com as temporarias
        declaracao das variaveis temporarias sem relacao com as variaveis do codigo inicial
        declaracao das variaveis temporarias com relacao com as variaveis do codigo inicial
*/

void initialize_tipo_umap();
/*
    inicializa o mapa tipo_umap (id inteiro dos tipos da linguagem, string dos tipos para o intermediario)
    inicializa o mapa tipo_umap_str (string dos tipos da linguagem, id inteiro dos tipos da linguagem)
    inicializa o mapa default_value_map (string dos tipos da linguagem, valor nulo dos tipos)
*/

void initialize_op_umap();
/*
    inicializa o mapa op_umap (id inteiro dos operadores da linguagem, string dos operadores para o intermediario)
    inicializa o mapa op_umap_str (string dos operadores da linguagem, id inteiro dos operadores da linguagem)
*/

void replace_all(std::string& data, std::string toSearch, std::string replaceStr);
/*
    substitui uma substring por outra substring numa string especificada
*/

void umap_label_add(string& new_label, int new_tipo, bool hasTamanho = false);
/*
*/

void umap_label_add_iterator(string& new_label, int qtd_ptrs = 0);
/*
*/

void umap_label_add_array(string& new_label, int points_to, int qtd_ptrs = 0);
/*
*/

void umap_label_add_matrix(string& new_label, int points_to, int qtd_ptrs = 0);
/*
*/

string search_variable(string var_name);
/*
*/

string search_variable_cur_ctx(string var_name);
/*
*/

string get_current_context_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0);
/*
*/

string get_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0);
/*
*/

string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho = false);
/*
*/

string add_iterator_in_current_context(string var_name);
/*
*/

void initialize_proc_temp_umap();
/*
*/

int get_new_type(atributos atr_1, atributos atr_2, atributos atr_3);
/*
*/

string genCountStrLabelStart();
string genCountStrLabelEnd();
string genSliceLabelStart();
string genSliceLabelEnd();
string genSliceLabelCreate();
string genSliceLabelHigher();
string genSliceLabelLower();
string genAfterSliceLabel();
void pushContext();
void endContext();
string countStringProc();
string outOfBoundsError();
void set_error_matrix();
void set_int_double_matrix();
void set_boolean_matrix();
void set_string_matrix();
void initialize_matrix();
string string_to_double(string str_label, string double_label);
string string_to_int(string str_label, string int_label);
string double_to_string(string double_label, string str_label);
string int_to_string(string int_label, string str_label);

string cmd_label_generator(string cmd_name = "CMD", int desloc = 0);
string cmd_label_iter_generator(int desloc = 0);
string cmd_label_end_generator(string cmd_name = "CMD", int desloc = 0);
string types_operations(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type);