%{
#include <stdio.h>
#include <string.h>

char * info;
%}

%x Categoria
%x TITULO
%x TEXTO

%%
^\[.*\n								{;}
^#.*\n								{;}
^\<.*\n								{;}
Etiquetas:.*\n						{;}
(.|\n)								{ECHO;}
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