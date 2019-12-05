void yyerror(string MSG);
/*
    imprime uma mensagem de erro
    interrompe a execução do parser
*/

string label_generator();
/*
    retorna uma label com o valor de tokenContador
    incrementa o tokenContador
*/

string get_tipo(int tipo, int qtd_ptr = 0);
/*
    retorna o tipo, considerando a quantidade de ponteiros
*/

string declare_variables();
/*
    retorna uma string com:
        comentários relacionando variaveis do codigo inicial com as temporarias
        declaracao das variaveis auxiliares sem relacao com as variaveis do codigo inicial
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
    gera uma label
    cria uma variavel usando o tipo do id especificado, com quantidade de ponteiros igual 0
    se for string
        gera labels que facilitam o uso de string (size, start, end, step)
        cria uma variavel para todos usando o tipo do id int
        adiciona no mapa temp_umap a relacao (labels de string, variavel)    
        adiciona na variavel as labels de string
        aumenta a quantidade de ponteiros da variavel inicial para 1
    adiciona no mapa temp_umap a relacao (label, variavel)
*/

void umap_label_add_iterator(string& new_label, int qtd_ptrs = 0);
/*
    gera uma label
    cria uma variavel usando o tipo de id ITERATOR, com quantidade de ponteiros igual a quantidade especificada
    gera labels que facilitam o uso de string (size, start, end, step)
    cria uma variavel para todos usando o tipo do id int
    adiciona no mapa temp_umap a relacao (labels de string, variavel)     
    adiciona na variavel as labels de string
    adiciona no mapa temp_umap a relacao (label, variavel)
*/

void umap_label_add_array(string& new_label, int points_to, int qtd_ptrs = 0);
/*
    gera uma label
    cria uma variavel usando o tipo de id ARRAY, com quantidade de ponteiros igual a quantidade especificada
    gera labels que facilitam o uso de string (size, start, end, step)
    cria uma variavel para todos usando o tipo do id int
    adiciona no mapa temp_umap a relacao (labels de string, variavel)     
    adiciona na variavel as labels de string
    adiciona o valor especificado de pointsto na variavel inicial
    adiciona no mapa temp_umap a relacao (label, variavel)
*/

void umap_label_add_matrix(string& new_label, int points_to, int qtd_ptrs = 0);
/*
    gera uma label
    cria uma variavel usando o tipo de id ARRAY, com quantidade de ponteiros igual a quantidade especificada e com o valor 1 simbolizando que é uma label de matriz
    gera labels que facilitam o uso de string (size, start, end, step)
    gera labels que facilitam o uso de matriz (row_size, start_col, end_col, step_col)
    cria uma variavel para todos usando o tipo do id int
    adiciona no mapa temp_umap a relacao (labels de string, variavel)     
    adiciona no mapa temp_umap a relacao (labels de matriz, variavel)     
    adiciona na variavel as labels de string
    adiciona na variavel as labels de matriz
    adiciona o valor especificado de pointsto na variavel inicial
    adiciona no mapa temp_umap a relacao (label, variavel)
*/

string search_variable(string var_name);
/*
    retorna o valor da label de usuário especificada nos contextos anteriores
    senao, retorna erro ("0")
*/

string search_variable_cur_ctx(string var_name);
/*
    retorna o valor da label de usuário especificada no contexto atual
    senao, retorna erro ("0")
*/

string get_current_context_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0);
/*
    busca a label do usuario usando search_variable
    se achar a label do usuario no contexto atual, retorna a label temporaria relacionada
    senao
        cria uma nova label
        cria uma variavel sem tipo
        adiciona no mapa do contexto atual (label usuario, nova label)
        adiciona em temp_umap (nova label, variavel)
*/

string get_id_label(string user_label, int fixed = 0, int ptrs = 0, int pointsTo = 0);
/*
    ::para global
    se achar a label do usuario nos contextos anteriores, retorna a label temporaria relacionada
    senao
        cria uma nova label
        cria uma variavel sem tipo
        adiciona no mapa do contexto atual (label usuario, nova label)
        adiciona em temp_umap (nova label, variavel)
*/

string add_variable_in_current_context(string var_name, int tipo, bool hasTamanho = false);
/*
    ::para atribuicao
    cria uma nova label
    usa umap_label_add para inicializar os mapas com a nova label
    no mapa do contexto atual, faz a relacao (label do usuario, nova label)
*/

string add_iterator_in_current_context(string var_name);
/*
    ::para atribuicao
    cria uma nova label
    usa umap_label_add_iterator para inicializar os mapas com a nova label
    no mapa do contexto atual, faz a relacao (label do usuario, nova label)
*/

void initialize_proc_temp_umap();
/*
    inicializa o mapa proc_temp_umap com as relacoes (labels auxiliares, id de tipo INT)
    inicializa o mapa has_length
    inicializa o mapa assoc_type com as relacoes (id dos tipos derivados, id dos tipos primitivos)
*/

int get_new_type(atributos atr_1, atributos atr_2, atributos atr_3);
/*
    retorna o id do tipo encontrado na matriz de operacoes com os atributos selecionados
*/

string genCountStrLabelStart();
/*
    retorna uma label de inicio da contagem do tamanho de string com o valor de strLabelCounter
*/

string genCountStrLabelEnd();
/*
    retorna uma label de fim da contagem do tamanho de string com o valor de strLabelCounter
*/

string genSliceLabelStart();
/*
    retorna uma label de inicio da operacao de slice com o valor de strLabelCounter
*/

string genSliceLabelEnd();
/*
    retorna uma label de fim da operacao de slice com o valor de strLabelCounter
*/

string genSliceLabelCreate();
/*
    retorna uma label de criacao da operacao de slice com o valor de strLabelCounter
*/

string genSliceLabelHigher();
/*
    retorna uma label para quando o slice tem um valor maior primeiro com o valor de strLabelCounter
*/

string genSliceLabelLower();
/*
    retorna uma label para quando o slice tem um valor menor primeiro com o valor de strLabelCounter
*/

string genAfterSliceLabel();
/*
    retorna uma label apos a operacao de slice com o valor de strLabelCounter
*/

void pushContext();
/*
    se ctxPushReseter não estiver setado com 1, para nao dar push em dois contextos e um deles ser inutil
    senao, dá push do mapa (string, string) num contexto mais atual
*/

void endContext();
/*
    dá pop no contexto atual
*/

string countStringProc();
/*
    faz a contagem do tamanho da string para o intermediario
    incrementa o contador de strLabelCounter
*/

string outOfBoundsError();
/*
    cria uma label de erro no intermediario
    dá goto para uma label de end of stream no intermediario
*/

void set_error_matrix();
/*
    inicializa a matriz com erro em todos os tipos de operacoes entre tipos
*/

void set_int_double_matrix();
/*
    muda o valor das operacoes aritmeticas entre int e double para um padrao que pode ser modificado posteriormente
    muda o valor das operacoes relacionais entre int e double para um padrao que pode ser modificado posteriormente
*/

void set_boolean_matrix();
/*
    muda o valor das operacoes logicas entre booleans para um padrao que pode ser modificado posteriormente
*/

void set_string_matrix();
/*
    muda o valor da concatenacao, operador ADD, entre string e string para um padrao que pode ser modificado posteriormente
    muda o valor da concatenacao, operador ADD, entre string e int para um padrao que pode ser modificado posteriormente
    muda o valor da concatenacao, operador ADD, entre string e double para um padrao que pode ser modificado posteriormente
*/

void initialize_matrix();
/*
    roda a funcao de inicializacao da matriz de erros
    roda a funcao de inicializacao da matriz de operacoes entre int e double
    roda a funcao de inicializacao da matriz de operacoes de boolean
    roda a funcao de inicializacao da matriz de operacoes de string
*/

string string_to_double(string str_label, string double_label);
/*
    retorna a conversao de string para double no intermediario
*/

string string_to_int(string str_label, string int_label);
/*
    retorna a conversao de string para int no intermediario
*/

string double_to_string(string double_label, string str_label);
/*
    retorna a conversao de double para string no intermediario
*/

string int_to_string(string int_label, string str_label);
/*
    retorna a conversao de int para string no intermediario
*/

string cmd_label_generator(string cmd_name = "CMD", int desloc = 0);
/*
    retorna a label de inicio correspondente a um comando
*/

string cmd_label_iter_generator(int desloc = 0);
/*
    retorna a label de inicio correspondente a um comando ITERATOR
*/

string cmd_label_end_generator(string cmd_name = "CMD", int desloc = 0);
/*
    retorna a label de fim correspondente a um comando
*/

string types_operations(atributos& atr_main, atributos atr_1, atributos atr_2, atributos atr_3, int final_type);
/*
    troca os padroes definidos pela matriz de operacoes e:
        realiza as operacoes aritmeticas
        realiza as operacoes logicas
        realiza as operacoes relacionais
*/

string funct_label_generator();
/*
    retorna a label da funcao usando o valor de functCounter
*/

void emptying_queue(queue<int>& Q);
/*
    esvazia a fila
*/

string declare_function_variables();
/*
    declara as variaveis usadas dentro do contexto da funcao
    os parametros são desconsiderados por logica aplicada na regra utilizadora dessa funcao
*/

void removing_match_umap(unordered_map<string, variavel>& iterator_umap, unordered_map<string, variavel>& toEmpty_umap);
/*
    esvazia o mapa toEmpty_umap para todas as chaves do iterator_umap
*/