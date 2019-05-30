%{
	#include "y.tab.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	
	int yydebug=1;

	int contaEspacos();

	char* texto="";
%}

%x TEXTO
%x ESTRUTURA
%x LISTA


%%

<*>[A-Za-z]+:\n/\t+-							{	/*Encontra uma estrutura*/
													printf("estrutura->%s\n", yytext);
													yylval.str = strdup(yytext);
													yylval.str[yyleng - 2] = '\0';
													BEGIN ESTRUTURA;
													return est;
												}

<LISTA>[A-Za-z]+:[ ]+[A-Za-z0-9]+				{	/*Encontra um item */
													printf("item->%s\n", yytext);
													yylval.str = strdup(yytext);
													return item;
												}

<*>[A-Za-z]+:[ ]+[A-Za-z0-9]+					{	/*Encontra uma variavel*/
													printf("variavel->%s\n", yytext);
													yylval.str = strdup(yytext);
													return variavel;
												}

<*>[A-Za-z]+:.+									{	/*Encontra uma Lista*/
													printf("Lista->%s\n", yytext);
													yylval.str = strdup(yytext);
													int j = 0;
													while(yytext[yyleng - j] != ':')
														j++; 
													yylval.str[yyleng - j] = '\0';	
													BEGIN TEXTO; 	
													return top;
												}


<*>[A-Za-z]+:\n/\t*[^:]+:						{	/*Encontra uma Lista*/
													printf("obj->%s\n", yytext);
													yylval.str = strdup(yytext);
													yylval.str[yyleng - 2] = '\0';
													BEGIN LISTA;
													return obj;
												}


<ESTRUTURA>-[ ]*.*								{	/*Encontra um elemento da estrutura*/
													printf("elem->%s\n", yytext);
													int espacos = contaEspacos(yytext) + 1;
													espacos += contaEspacos(yytext + espacos);
													yylval.str = strdup(yytext + espacos);
													return elem;
												}

<TEXTO>[^:\n]+									{	/*Encontra uma linha do texto*/
													printf("Tambem entrei aqui\n");
													yylval.str = strdup(yytext);	
													return linha;
												}

^\#.+											{;}
(.|\n)											{;}
%%

int contaDoisPontos(char * str, int tam){
	int j = 0;
	for(; str[tam - 1] == ':'; tam--, j++);
	return j;

}

int contaEspacos(char * str){
	int i = 0;
	for(; str[i] == ' ' || str[i] == 9; i++);
	//printf("%d", i);
	return i;
}

int yywrap(){
	return 1;
}