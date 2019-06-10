%{
	#define _GNU_SOURCE        
	#include <stdio.h>
	#include <string.h>

	int yylex();
	int yyerror();
%}

%union{char* str;int no;}
%token <str> chave
%token <str> valor booleano
%token <str> linha
%token <no> inteiro
%token nulo
%type <str> Programa Estruturas Estrutura Lista Elemento Linhas Valor Texto Paragrafo

%%
Programa : Estruturas			{printf("{%s\n}\n",$1);}
		 ;

Estruturas : Estruturas Estrutura 				{asprintf(&$$,"%s,\n  %s",$1,$2);}
		   | Estrutura 							{asprintf(&$$,"\n  %s",$1);}
		   ;

Estrutura : chave ':' Valor						{asprintf(&$$,"\"%s\": %s",$1,$3);}
		  | chave ':' '[' Lista ']'				{
		  											char* lista = "";
		  											for(int i=0; $4[i]!=0; i++){
		  												if($4[i]=='\n'){
		  													asprintf(&lista,"%s\n    ",lista);
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
		  ;

Valor : Linhas 									{
													if(strncmp($1,"\"", 1)!=0)
														asprintf(&$$,"\"%s\"",$1);
													else
														asprintf(&$$,"%s",$1);
												}
	  | nulo									{$$="null";}
	  | inteiro									{asprintf(&$$,"%d",$1);}
	  | booleano								{asprintf(&$$,"%s",$1);}
	  | '>' Texto								{asprintf(&$$,"\"%s\\n\"",$2);}
	  | '|' Paragrafo							{asprintf(&$$,"\"%s\"",$2);}
	  ;

Texto: Texto valor									{	
														if(strcmp($2,"\\n")==0)
															asprintf(&$$, "%s%s", $1, $2);
														else
															asprintf(&$$, "%s%s", $1, $2);
													}
	 | valor 										{	$$ = $1;	}
	 ;

Paragrafo: Paragrafo valor							{	
														if(strcmp($2,"\\n")==0)
															asprintf(&$$, "%s%s", $1, $2);
														else
															asprintf(&$$, "%s\\n%s", $1, $2);
													}
	 	 | valor 									{	$$ = $1;	}
	 	 ;

Lista : Lista ',' Elemento						{asprintf(&$$,"%s,\n%s",$1,$3);}
	  | Elemento								{asprintf(&$$,"\n%s",$1);}
	  ;

Elemento : Estruturas							{asprintf(&$$,"{%s\n}",$1);}
		 | Valor								{$$=$1;}
		 ;

Linhas : Linhas valor							{asprintf(&$$,"%s%s",$1,$2);}
	   | valor									{asprintf(&$$,"%s",$1);}

%%
#include "lex.yy.c"

int yyerror(char * s){
	printf("%s\n", s);
}

int main(){
	aIdentacao[0]=0;
	yy_push_state(INITIAL);
	yyparse();
	return 0;
}