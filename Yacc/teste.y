%{
	#define _GNU_SOURCE        
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror(char *s);
%}


%union{char *str; int num;}
%token <str> id
%token <num> ident
%token <str> linha
%token <str> line
%token <str> valor
%type <str> Programa Objetos Objeto Lista Elemento Texto Paragrafo
%%

Programa: Objetos         			{printf("{\n%s\n}\n", $1);}
		;

Objetos: Objetos Objeto 			{asprintf(&$$, "%s,\n%s", $1, $2);}
		| Objeto 					{asprintf(&$$, "%s", $1);}
		;

Objeto: ident id ':' Lista			{
	  									char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';
	  									asprintf(&$$, "%s\"%s\": [\n%s\n%s]", espacos, $2, $4, espacos);
	  								}
	  | ident id ':' valor			{
	  									char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';

	  									asprintf(&$$, "%s\"%s\": \"%s\"", espacos, $2, $4);
	  								}
	  | ident id ':' 				{
	  									char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';
	  									asprintf(&$$, "%s\"%s\": ", espacos, $2);} 				
	  | ident id ':' '>' Paragrafo  {
	  									char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';
	  									asprintf(&$$, "%s\"%s\": \"%s\"", espacos, $2, $5);
	  								}
	  | ident id ':' '|' Texto 		{
	  									char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';
	  									asprintf(&$$, "%s\"%s\": \"%s\"", espacos, $2, $5);
	  								}
	  | id ':' Lista 				{
	  									asprintf(&$$, "  \"%s\": [\n%s\n  ]", $1, $3);
	  								}
	  | id ':' valor 				{
	  									asprintf(&$$, "  \"%s\": \"%s\"", $1, $3);
	  								}
	  | id ':' 						{
	  									asprintf(&$$, "  \"%s\": ", $1);
	  								}
	  | id ':' '>' Paragrafo		{
	  									asprintf(&$$, "  \"%s\": \"%s\"", $1, $4);
	  								}
	  | id ':' '|' Texto 			{
	  									asprintf(&$$, "  \"%s\": \"%s\"", $1, $4);
	  								}
	  ;

Lista: Lista '-' Elemento			{
	 									asprintf(&$$, "%s,\n%s", $1, $3);
	 								}
	 | '-' Elemento					{
	 									asprintf(&$$, "%s", $2);
	 								}
	 ;

Elemento: ident line 				{
										char espacos[$1+3];
	  									espacos[$1+2] = '\0';
	  									for(int i = 0; i < $1+2; i++)
	  										espacos[i] = ' ';
										asprintf(&$$, "%s\"%s\"", espacos, $2);
									}
		;

Texto: Texto linha					{	asprintf(&$$, "%s\\n%s", $2, $1);	}
	 | linha 						{	$$ = $1;	}
	 ;

Paragrafo: Paragrafo linha			{	asprintf(&$$, "%s%s", $1, $2);	}
	 	 | linha 					{	$$ = $1;	}
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