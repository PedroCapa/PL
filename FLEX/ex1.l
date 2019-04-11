%{
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include "createHTML.h"

GTree * tagTree;
GTree * idTree;   				//para limpar repetidos

FILE* out;

char * info;					// armazena id de um post
char * categoria;
char * titulo;
char * data;
char * texto;
char * tags;					//armazena tags de um post
%}

%x CATEGORIA
%x TITULO
%x TEXTO
%x TRANSICAO
%x DATA
%x DATE
%x TAGS
%x ID

%%
tag:								{BEGIN TAGS;}
^#ID:\{								{BEGIN ID;}
<ID>[^ ]*							{
										info = strdup((char*) yytext);	
										if(g_tree_lookup_extended(idTree,info,NULL,NULL)){
											g_tree_destroy(tagTree);
											tagTree = g_tree_new_full(mystrcmp,NULL,free,NULL);
											BEGIN INITIAL;

										}
										else{
											g_tree_insert(idTree,strdup(info),NULL);
											BEGIN CATEGORIA;
										}
									}


<TAGS>\{[^}]*						{tags = strdup((char*) yytext + 1);g_tree_insert(tagTree, tags, NULL);
									BEGIN INITIAL;}


<CATEGORIA>^[A-Za-z]+				{categoria = strdup((char*) yytext); BEGIN TITULO;}
<TITULO>^[^\n]*						{titulo = strdup((char*) yytext); BEGIN DATE;}

<DATE>^#DATE:" "[^\]]*				{BEGIN DATA;}
<DATA>.+							{
										fprintf(out, "<pub id=\"%s\">\n", info);
										fprintf(out, "	<title>%s</title>\n", titulo);
										fprintf(out, "	<author_date>%s</author_date>\n", yytext + 1);
										if(g_tree_nnodes(tagTree) > 0){
											fprintf(out, "	<tags>\n");
											g_tree_foreach(tagTree, travessia, out);
											fprintf(out, "	</tags>\n");
										}
										fprintf(out, "	<category>%s</category>\n	<text>\n", categoria);
										BEGIN TEXTO;
									}

<TEXTO>Etiquetas:.*\n				{;}

<TEXTO>"Partilhe este Artigo\n"		{;}

<TEXTO>\[.*							{;}

<TEXTO>\n{3,}						{;}

<TEXTO><\/pub>						{fprintf(out,"\n\t</text>\n</pub>\n\n");BEGIN INITIAL;
										limpa(&tagTree,info,categoria,titulo,data,texto,tags);}

<TEXTO>.*							{fprintf(out, "%s\n", yytext);}

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
	tagTree = g_tree_new_full(mystrcmp,NULL,free,NULL);
	idTree = g_tree_new_full(mystrcmp,NULL,free,NULL);
	yylex();

	printf("Fim da filtragem\n");

	g_tree_destroy(idTree);
	fclose(yyin);
	fclose(out);
	return 0;
}