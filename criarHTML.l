%{
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include "createHTML.h"

GTree * tree;

FILE* out;

char * info;
char * categoria;
char * titulo;
char * data;
char * texto;
char * tags;
int cont = 0;
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


<TAGS>\{[^}]*						{tags = strdup((char*) yytext + 1);g_tree_insert(tree, tags, NULL);
									BEGIN INITIAL;}


<CATEGORIA>^[A-Za-z]+				{categoria = strdup((char*) yytext); BEGIN TITULO;}
<TITULO>^[^\n]*						{titulo = strdup((char*) yytext); BEGIN INITIAL;}

<DATA>.+							{data = strdup((char*) yytext + 1);BEGIN TEXTO;}

<TEXTO>^[^\<]+						{texto = strdup((char*) yytext);
									escreveFile(out,tree, info, categoria, titulo, data, texto, tags);
									limpa(&tree,info,categoria,titulo,data,texto,tags); BEGIN INITIAL;}

<*>(.|\n)								{;}
%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){

	if(argc < 2){
		return 1;
	}

	char filename[200];
	sprintf(filename, "%s.norm", argv[1]);
	out = fopen(filename, "w");
	yyin = fopen(argv[1],"r");

	printf("Inicio da filtragem\n");
	tree = g_tree_new_full(mystrcmp,NULL,free,NULL);
	yylex();

	printf("Fim da filtragem\n");

	fclose(out);
	return 0;
}