/*
			| TK_ID TK_INCR
			{
				string new_label;
				string value;

				switch(temp_umap[var_umap[$1.traducao]].tipo)
				{
					case INT:
					{
						value = "1";
					}
					break;

					case DOUBLE:
					{
						value = "1.0";
					}
					break;
				}

				umap_label_add(new_label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				//$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label;
				$$.traducao = "\t" + new_label + " = " + value + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " + " + new_label + ";\n";
			}
			| TK_ID TK_DECR
			{
				string new_label;
				string value;

				switch(temp_umap[var_umap[$1.traducao]].tipo)
				{
					case INT:
					{
						value = "1";
					}
					break;

					case DOUBLE:
					{
						value = "1.0";
					}
					break;
				}

				umap_label_add(new_label, $1.tipo);
				$$.tipo = $1.tipo;
				$$.label = $1.label;

				//$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label;
				$$.traducao = "\t" + new_label + " = " + value + ";\n";
				$$.traducao += "\t" + $1.label + " = " + $1.label + " - " + new_label + ";\n";
			}*/

/*
a = 1 + 1
b = 2.0 - 2
c = 3 * 3.0
d = 4.0 / 4.0

e = 1 > 1
f = 2.0 < 2
g = 3 >= 3.0
h = 4.0 <= 4.0

i = true and true
j = false or false
k = not true

l = 1 eq 1.0
m = 2 neq 2
*/

/*
a = true + 5
a = false - 6.0
a = true eq 5
a = false neq 6.0
a = not 1
a = 1.0 and false
a = 2 or true

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

//$$.label = $1.label;

/*//no caso da variavel ja ter um tipo setado no codigo
if( temp_umap[$1.label].tipo != 0 && temp_umap[$1.label].tipo != $3.tipo )
{
    $$.tipo = $3.tipo;

    //criar uma temporaria nova pra guardar o antigo valor
    umap_label_add($$.label, $$.tipo);
    var_umap[$1.traducao] = $$.label;
}
else
{
    $$.tipo = $3.tipo;
    temp_umap[var_umap[$1.traducao]].tipo = $3.tipo;
    $$.label = $1.label;
}

$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n";*/
//$$.resultado = $1.resultado;

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
    int op_type = matrix[GREATER][$1.tipo][$3.tipo];

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
    int op_type = matrix[GREATER][$1.tipo][$3.tipo];

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

| E TK_AND E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;

    string op_type = matrix[AND][$1.tipo][$3.tipo];

    if(op_type == ERROR_VALUE)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " && " + $3.label + ";\n";
}
| E TK_OR E
{
    $$.label = label_generator();
    $$.resultado = 0;
    $$.tipo = BOOLEAN;
    variavel v;
    v.tipo = $$.tipo;
    temp_umap[$$.label] = v;

    string op_type = matrix[OR][$1.tipo][$3.tipo];

    if(op_type == ERROR_VALUE)
    {
        yyerror("\nA operação não pode ser executada para os tipos de variáveis selecionados.");
    }

    $$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " || " + $3.label + ";\n";
}

/*| E TK_OP_REL E
{

    $$.tipo = BOOLEAN;
    umap_label_add($$.label, $$.tipo);
    $$.traducao = $1.traducao + $3.traducao;
    $$.traducao += implicit_conversion_op($$, $1, $2, $3, BOOLEAN);
    //$$.resultado = 0;

}
| E TK_OP_LOG E
{
    $$.tipo = BOOLEAN;
    umap_label_add($$.label, $$.tipo);
    $$.traducao = $1.traducao + $3.traducao;
    $$.traducao += implicit_conversion_op($$, $1, $2, $3, BOOLEAN);
    //$$.resultado = 0;
}
| TK_NOT E
{
    if($1.tipo != BOOLEAN)
    {
        yyerror("\nO operador \"not\" não pode ser utilizado com variável do tipo " + tipo_umap[$2.tipo]);
    }

    $$.tipo = $2.tipo;
    umap_label_add($$.label, $$.tipo);
    $$.traducao = $2.traducao + "\t" + $$.label + " = " + "!" + "(" + $2.label + ");\n";
}
/*| E TK_FIM_LINHA
{
    $$.traducao = $1.traducao;
}
/*
loop(i = 3; i > 0; i--) do
a = i
end

i = 1;

LO
test = !(i > 0)
if(test)
goto LOEND
COMANDOS
CONT
goto LO

LO_END

/*
loop(true) do\n
a = 2\n
end

TK_LOOP(TK_BOOL) do\n
TK_ID = TK_NUM\n
end

TK_LOOP(E) do\n
TK_ID = TK_NUM\n
end

TK_LOOP(E) do\n
ATR\n
end

TK_LOOP(E) do\n
E\n
end

TK_LOOP(E) do TK_FIM_LINHA
COMANDOS
end
				/*

				int new_type = get_new_type($1, $2, $4);//matrix[op_umap_str[$2.traducao]][$1.tipo][$4.tipo][0] - '0';

				//no caso da variavel ja ter um tipo setado no codigo
				if(temp_umap[$1.label].tipo != new_type )
				{
					$$.tipo = new_type;

					//criar uma temporaria nova pra guardar o antigo valor
					umap_label_add($$.label, $$.tipo);
					var_umap[$1.traducao] = $$.label;
				}
				else
				{
					$$.tipo = $1.tipo;
					$$.label = $1.label;
				}
				
				$$.traducao = $4.traducao;
				$$.traducao += implicit_conversion_op($$, $1, $2, $4, 0);
%s newstate
START "/*"
END "*(/)"
SIMPLE [^*]
SPACE [ \t\n]
COMPLEX "*"[^/]
strcat(yytext, "\n"); return 0;
J_LINE (\n)+
{J_LINE}	                { contadorLinha += strlen(yytext); cout << contadorLinha << endl; yylval.traducao = yytext; return TK_FIM_LINHA; }
*/