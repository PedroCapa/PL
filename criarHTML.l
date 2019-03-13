%{
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include "createHTML.h"

GTree * tree;

char * info;
char * categoria;
char * titulo;
char * data;
char * texto;
char * tags;
%}

%x CATEGORIA
%x TITULO
%x TEXTO
%x TRANSICAO
%x DATA
%x TAGS
%x ID

%%
tag:								{BEGIN TAGS;}
^#ID:\{								{BEGIN ID;}
^#DATE:" "[^\]]*					{BEGIN DATA;}
<ID>[^ ]*							{info = strdup((char*) yytext); BEGIN CATEGORIA;}


<TAGS>\{[^}]*						{tags = strdup((char*) yytext + 1); g_tree_insert(tree, tags, NULL);
									BEGIN INITIAL;}

<CATEGORIA,TITULO,DATA>(.|\n)		{;}

<CATEGORIA>^[A-Za-z]+				{categoria = strdup((char*) yytext); BEGIN TITULO;}
<TITULO>^[^\n]*						{titulo = strdup((char*) yytext); BEGIN INITIAL;}

<DATA>^\[.*							{BEGIN TEXTO;}
<DATA>.+							{data = strdup((char*) yytext + 1);}

<TEXTO>^[^\<]+						{texto = strdup((char*) yytext);
									escreveFile(tree, info, categoria, titulo, data, texto, tags);}

(.|\n)								{;}
%%

int yywrap(){
	return 1;
}

int main(){

	tree = g_tree_new(mystrcmp);
	yylex();
	return 0;
}