%{
	#define _GNU_SOURCE        
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror();
	int conta = 0;
%}

%union{char* str;}
%token <str> est
%token <str> elem
%token <str> top
%token <str> linha
%type <str> Programa Conteudo Estrutura Texto Top Tex Est Lista

%%
Programa: Conteudo 						{printf("{\n%s\n}\n", $1);}
		;

Conteudo: Estrutura 					{asprintf(&$$, "%s", $1);}
		| Estrutura Conteudo			{asprintf(&$$, "%s,\n%s", $1, $2);}
		| Texto							{asprintf(&$$, "%s", $1);}
		| Texto Conteudo 				{asprintf(&$$, "%s,\n%s", $1, $2);}
		;

Estrutura: Est Lista 					{asprintf(&$$, "%s:[\n%s\n	]", $1, $2);}
		;

Est: est 								{asprintf(&$$, "	\"%s\"", $1);}
	;

Lista: elem Lista						{asprintf(&$$, "		-\"%s\",\n%s", $1, $2);}
	 | elem  							{asprintf(&$$, "		-\"%s\"", $1);}
	 ;

Texto: Top Tex 							{asprintf(&$$, "	\"%s\": \"%s\"", $1, $2);}
	 ;

Top: top								{asprintf(&$$, "%s", $1);}
	;

Tex: linha								{asprintf(&$$, "%s", $1);}
	| linha Tex 						{asprintf(&$$, "%s\\n%s", $1, $2);}
	;


%%
#include "lex.yy.c"

int yyerror(char * s){
	printf("%s\n", s);
}

int main(){
	yyparse();
	return 0;
}