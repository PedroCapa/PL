%{
	#define _GNU_SOURCE        
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror();
%}

%union{char* str;int no;}
%token <str> chave
%token <str> valor
%token <str> linha
%type <str> Programa Estruturas Estrutura Lista Elemento Linhas

%%
Programa : Estruturas			{printf("{%s\n}\n",$1);}
		 ;

Estruturas : Estruturas Estrutura 				{asprintf(&$$,"%s,\n  %s",$1,$2);}
		   | Estrutura 							{asprintf(&$$,"\n  %s",$1);}
		   ;

Estrutura : chave ':' valor						{asprintf(&$$,"\"%s\":\"%s\"",$1,$3);}
		  | chave ':' '[' Lista ']'				{
		  											char* lista = "";
		  											for(int i=0; $4[i]!=0; i++){
		  												if($4[i]=='\n'){
		  													asprintf(&lista,"%s\n  ",lista);
		  												}else{
		  													asprintf(&lista,"%s%c",lista,$4[i]);
		  												}
		  											}
		  											asprintf(&$$,"\"%s\": [%s\n  ]",$1,lista);
		  										}
		  | chave ':' '{' Estruturas '}'			{
		  											char* est = "";
		  											for(int i=0; $4[i]!=0; i++){
		  												if($4[i]=='\n'){
		  													asprintf(&est,"%s\n  ",est);
		  												}else{
		  													asprintf(&est,"%s%c",est,$4[i]);
		  												}
		  											}
		  											asprintf(&$$,"\"%s\": {%s\n  }",$1,est);
		  										}
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
		  | chave ':' '>' Texto					{//Concatenar a chave com o texto}
		  | chave ':' '|' Paragrafo				{//Concatenar a chave com o texto}
		  ;

Texto: Texto linha									{	
														if($2[0] == '\\' && $2[1] == 'n')
															asprintf(&$$, "%s%s", $1, $2);
														else
															asprintf(&$$, "%s\\n%s", $1, $2);
													}
	 | linha 										{	$$ = $1;	}
	 ;

Paragrafo: Paragrafo linha							{	asprintf(&$$, "%s%s", $1, $2);	}
	 	 | linha 									{	$$ = $1;	}
	 	 ;
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
Lista : Lista ',' Elemento						{asprintf(&$$,"%s,\n  %s",$1,$3);}
	  | Elemento								{asprintf(&$$,"\n  %s",$1);}
	  ;

Elemento : Linhas								{asprintf(&$$,"\"%s\"",$1);}
		 | Estruturas							{asprintf(&$$,"{\n%s\n}",$1);}
		 ;

Linhas : Linhas linha							{asprintf(&$$,"%s%s",$1,$2);}
	   | linha									{asprintf(&$$,"%s",$1);}

%%
#include "lex.yy.c"

int yyerror(char * s){
	printf("%s\n", s);
}

int main(){
	aIdentacao[0]=0;
	yyparse();
	return 0;
}