/*
a = 1\n\n
TK_ID = TK_NUM\n\n
E\n\n
COMANDO\n\n
*/

/*string check_not_declared(string var_label)
{
	if(var_umap.find(user_label) == var_umap.end())
	{
		string new_label = label_generator();
		//variavel new_var = new_label;
		var_umap[user_label] = new_label;
		return new_label;
	}
}*/

/*
operadores aritmeticos
string, string = string (+)
string, float = string (+)
string, int = string (+)

double, double = double
double, int = double
int, int = int

---
operadores relacionais
string, string = boolean (==, !=, >, <)

double, double = boolean
double, int = boolean
int, int = boolean

---
operadores logicos
boolean, boolean = boolean
*/

/*
| E '+' E
{
    $$.tipo = $1.tipo;
    $$.label = label_generator();
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.resultado = $1.resultado + $3.resultado;
    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";

}
| E '-' E
{
    $$.tipo = $1.tipo;
    $$.label = label_generator();
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.resultado = $1.resultado - $3.resultado;
    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";

}
| E '*' E
{
    $$.tipo = $1.tipo;
    $$.label = label_generator();
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.resultado = $1.resultado * $3.resultado;
    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";

}
| E '/' E
{
    $$.tipo = $1.tipo;
    $$.label = label_generator();
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.resultado = $1.resultado / $3.resultado;
    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";

}
*/
/*
    a = 2.0 > 1
    temp1 = 2.0
    temp2 = 1
    temp4 = (float) temp2
    temp3 = temp1 > temp4
    temp0 = temp3
*/
/*
| E '>' E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[MORE][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " > " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " > " + new_label + ";\n";
        }

    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " > " + $3.label + ";\n";
    }
}
| E '<' E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[LESS][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " < " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " < " + new_label + ";\n";
        }
    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " < " + $3.label + ";\n";
    }
}
| E TK_GEQ E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[GEQ][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " >= " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " >= " + new_label + ";\n";
        }
    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " >= " + $3.label + ";\n";
    }
}
| E TK_LEQ E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[MORE][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " <= " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " <= " + new_label + ";\n";
        }
    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " <= " + $3.label + ";\n";
    }
}
| E TK_EQ E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[EQ][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " == " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " == " + new_label + ";\n";
        }
    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " == " + $3.label + ";\n";
    }
}
| E TK_NEQ E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;
    $$.traducao = $1.traducao + $3.traducao;

    string new_label;
    int op_type = matrix[NEQ][$1.tipo][$3.tipo];

    if(op_type == -1)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    if($1.tipo != op_type || $3.tipo != op_type)
    {
        new_label = label_generator();
        variavel vv;
        vv.tipo = op_type;
        temp_umap[new_label] = vv;

        if($1.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $1.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + new_label + " != " + $3.label + ";\n";
        }
        else if($3.tipo != op_type)
        {
            $$.traducao += "\t" + new_label + " = " + "(" + tipo_umap[op_type] + ")" + " " + $3.label + ";\n";
            $$.traducao += "\t" + $$.label + " = " + $1.label + " != " + new_label + ";\n";
        }
    }
    else
    {
        $$.traducao += "\t" + $$.label + " = " + $1.label + " != " + $3.label + ";\n";
    }
}
*/