%{
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	

	int contaEspacos();

	int aIdentacao[20];
	char simbolo[20];
	int niden = 0;

	char* texto="";
%}

%x TEXTO
%x ESTRUTURA
%x LISTA HIFENLISTA ESPACOLISTA
%x ELEMENTO
%x ID AATRIB ATRIB


%%
teste	{printf("%s\n",yytext);if(niden<3){yyless(0);niden++;}}

\n 											{;}
[^ \n]											{
													if(0<aIdentacao[niden]){
														niden--;
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}
													yyless(0);
													BEGIN ID;
												}
[ ]*/-											{	// Só deve vir para o initial quando pode ser definida uma nova identacao(quando termina em ':' a linha anterior)
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = ']';
														BEGIN HIFENLISTA;
														//printf("[");
														return '[';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														BEGIN ID;
													}
												}

[ ]*											{
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = '}';
														BEGIN ID;
														//printf("{");
														return '{';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														BEGIN ID;
													}														
												}


<ID>-[ ]+										{
													BEGIN LISTA;//printf("%c",yytext[0]);//return yytext[0]; //Identifica inicio de lista
												}		

<LISTA>[^ \n].* 								{
													yylval.str = strdup(yytext);
													//printf("%s",yytext);
													return linha;
												}
<LISTA>\n 										{ BEGIN ESPACOLISTA; }
<ESPACOLISTA>[ ]+								{
													if(yyleng>aIdentacao[niden]){
														yylval.str = " ";
														//printf(" ");
														BEGIN LISTA;
														return linha;
													}else if(yyleng<aIdentacao[niden]){
														BEGIN INITIAL;
														yyless(0);
													}else if(yyleng==aIdentacao[niden]){
														//printf(",");
														BEGIN HIFENLISTA;
														return ',';
													}
												}
<ESPACOLISTA>[^ ]								{yyless(0);BEGIN INITIAL;}

<HIFENLISTA>-[ ]+								{BEGIN LISTA;}

<ID>[^:-]*										{	// Identifica nome do objeto
													yylval.str = strdup(yytext);
													BEGIN ATRIB;
													//printf("%s",yytext);
													return chave;
												}
<ATRIB>:										{
													BEGIN AATRIB;
													//printf("%c",yytext[0]);
													return yytext[0];
												}

<AATRIB>[ ]*\n 									{BEGIN INITIAL;}
<AATRIB>[ ]*.* 									{
													//printf("%s",yytext);
													yylval.str=strdup(yytext);
													BEGIN INITIAL;
													return valor;
												}
<<EOF>>											{
													if(0<aIdentacao[niden]){
														niden--;
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														yyterminate();
													}
												}
(.|\n)										{;}
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
/*
int main(){
	yylex();
	return 0;
}*/