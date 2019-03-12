%{
#include <stdio.h>
#include <string.h>

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
^#TAG:								{printf("	<tags>\n");}
tag:								{BEGIN TAGS;}
^#ID:\{								{printf("	</tags>\n"); BEGIN ID;}
^#DATE:" "[^\]]*					{BEGIN DATA;}
<ID>[^ ]*							{titulo = strdup((char*) yytext); printf("<pub id=\"%s\">\n", titulo); BEGIN CATEGORIA;}


<TAGS>\{[^}]*						{tags = strdup((char*) yytext + 1); printf("		<tag>%s</tag>\n", tags); BEGIN INITIAL;}

<CATEGORIA,TITULO,DATA>(.|\n)		{;}

<CATEGORIA>^[A-Za-z]+				{categoria = strdup((char*) yytext); printf("	<category>%s</categoty>\n", categoria); BEGIN TITULO;}
<TITULO>^[^\n]*						{titulo = strdup((char*) yytext); printf("	<title>%s</title>\n", titulo); BEGIN INITIAL;}
<DATA>.+							{data = strdup((char*) yytext + 1); printf("	<author_date>%s</author_date>\n", data); BEGIN TEXTO;}

<TEXTO>^\[.*						{;}
<TEXTO>\<\/pub>						{printf("\n	    </text>\n</pub>\n");BEGIN INITIAL;}
<TEXTO>^[^<]+						{texto = strdup((char*) yytext); printf("	<text>\n%s", texto);}

Etiquetas:.*\n						{;}
(.|\n)								{;}
%%

int yywrap(){
	return 1;
}

int main(){
	
	printf("Inicio da filtragem\n");
	yylex();
	printf("Fim da filtragem\n");

	return 0;
}