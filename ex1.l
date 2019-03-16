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

<DATA>.+							{
										fprintf(out, "<pub id=\"%s\">\n", info);
										fprintf(out, "	<title>%s</title>\n", titulo);
										fprintf(out, "	<author_date>%s</author_date>\n", yytext + 1);
										if(g_tree_nnodes(tree) > 0){
											fprintf(out, "	<tags>\n");
											g_tree_foreach(tree, travessia, out);
											fprintf(out, "	</tags>\n");
										}
										fprintf(out, "	<category>%s</category>\n	<text>", categoria);
										limpa(&tree,info,categoria,titulo,data,texto,tags);
										BEGIN TEXTO;
									}

<TEXTO>Etiquetas:.*\n				{;}

<TEXTO>"Partilhe este Artigo\n"		{;}

<TEXTO>\n{3,}						{;}

<TEXTO><\/pub>						{fprintf(out,"\n\t</text>\n%s\n\n",yytext);BEGIN INITIAL;}

<TEXTO>(.|\n)						{fprintf(out,"%s",yytext);}

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

	fclose(yyin);
	fclose(out);
	return 0;
}