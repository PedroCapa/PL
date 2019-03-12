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
━*									{;}
Etiquetas:.*\n						{;}
PARTILHE" "*VIA:					{;}
(.|\n)								{ECHO;}
%%

int yywrap(){
	return 1;
}

int main(){
	yylex();
	return 1;
}