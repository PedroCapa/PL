%{
#include <stdio.h>
#include <string.h>
#include "createHTML.h"
#include <glib.h>

GTree * abreviaturas;

%}
 /* https://stackoverflow.com/a/9611844 */

letraM 		([A-Z]|Ç|À|Á|Ã|Â|Ä|È|É|Ẽ|Ê|Ë|Ì|Í|Ĩ|Î|Ï|Ò|Ó|Õ|Ô|Ö|Ù|Ú|Ũ|Û|Ü)  
letram 		([a-z]|ç|à|á|ã|â|ä|é|è|ẽ|ê|ë|í|ì|ĩ|î|ï|ó|ò|õ|ô|ö|ù|ú|ũ|û|ü)
palavraM 	{letraM}{letram}+
palavram 	{letram}+
sep 		(\ |-|\n)
%%

({palavraM}{sep}?({palavram}{sep})?)+\({letraM}+\)	{
					for(int i = 0; i < yyleng - 1; i++)
						if(yytext[i] == '\n' && yytext[i + 1] != '\0')
							yytext[i] = ' ';
					g_tree_insert(abreviaturas, strdup(strcat(yytext, "\n")), NULL);}


(.|\n)				{;}

%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){


	if(argc < 2){
		return 1;
	}

	abreviaturas = g_tree_new_full(mystrcmp,NULL,free,NULL);
	FILE * out = fopen("Abreviaturas", "w");
	yyin = fopen(argv[1],"r");


	printf("Inicio da filtragem\n");


	yylex();

	if(g_tree_nnodes(abreviaturas) > 0)
		g_tree_foreach(abreviaturas, insereAbv, out);
	printf("Fim da filtragem\n");

	return 0;
}