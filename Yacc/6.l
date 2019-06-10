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

%x TEXTO TEXTO_ALFA TEXTO_ESPACO
%x LISTA HIFENLISTA ESPACOLISTA
%x ELEMENTO
%x ID AATRIB ATRIB NULO RECOLHEVALOR
%option stack

%%

\n 												{;}
[^ \n]											{
													if(0<aIdentacao[niden]){
														niden--;
														yyless(0);
														printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}
													yyless(0);
													BEGIN ID;
												}
[ ]*/-											{	printf("(%d %d)",niden, yyleng);// Só deve vir para o initial quando pode ser definida uma nova identacao(quando termina em ':' a linha anterior)
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = ']';
														BEGIN HIFENLISTA;
														printf("[");
														return '[';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);
														//yy_pop_state();
														printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{yyless(0);
														yy_pop_state();
													}
												}

[ ]*											{
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = '}';
														BEGIN ID;
														printf("{");
														return '{';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);
														//yy_pop_state();
														printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														BEGIN ID;//yy_pop_state();
													}														
												}


<ID>-[ ]+										{
													BEGIN LISTA;//Identifica inicio de lista
												}		
<ID>[^\n-]*/:									{	// Identifica nome do objeto
													yylval.str = strdup(yytext);
													BEGIN ATRIB;
													printf("%s",yytext);
													return chave;
												}

<LISTA>.*:[ \n]					 				{//Caso seja uma estrutura
													yyless(0);BEGIN ESPACOLISTA;yy_push_state(ID);
												}
<LISTA>[\>|][ ]* 								{
													//Para o caso de ser texto
													BEGIN ESPACOLISTA;
													yy_push_state(TEXTO);
													int i = contaEspacos(yytext);
													printf("%c",yytext[i]);
													return yytext[i];
												}
<LISTA>[^:\n]*					 				{	
													yyless(0);
													yy_push_state(RECOLHEVALOR);
												}
<LISTA>\n 										{ BEGIN ESPACOLISTA; }


<ESPACOLISTA>[ ]+								{
													if(yyleng>aIdentacao[niden]){
														yylval.str = " ";
														printf(" ");
														BEGIN LISTA;
														return valor;
													}else if(yyleng<aIdentacao[niden]){
														BEGIN INITIAL;
														yyless(0);
													}else if(yyleng==aIdentacao[niden]){
														printf(",");
														BEGIN HIFENLISTA;
														return ',';
													}
												}
<ESPACOLISTA>[^ ]								{yyless(0);yy_pop_state();}

<HIFENLISTA>-[ ]+								{BEGIN LISTA;printf("$");}

<ATRIB>:										{
													BEGIN AATRIB;
													printf("%c",yytext[0]);
													return yytext[0];
												}

<AATRIB>[ ]*\n 									{BEGIN NULO;}
<AATRIB>[ ]* 									{
													BEGIN INITIAL;
													yy_push_state(RECOLHEVALOR);
												}
<AATRIB>[ ]+[\>|][ ]*\n 						{
													//Para o caso de ser texto
													BEGIN INITIAL;
													yy_push_state(TEXTO);
													int i = contaEspacos(yytext);
													//yyless(yyleng - 1);
													printf("%c",yytext[i]);
													return yytext[i];
												}

<NULO>[ ]*										{
													if(yyleng<=aIdentacao[niden]){
														yyless(0);
														BEGIN INITIAL;
														printf("nulo");
														return nulo;
													}else{
														yyless(0);
														BEGIN INITIAL;
													}
												}
<RECOLHEVALOR>[0-9]*[ ]*						{
													printf("%s",yytext);
													yylval.no=atoi(yytext);
													yy_pop_state();
													return inteiro;
												}
<RECOLHEVALOR>false[ ]*							{
													printf("%s",yytext);
													yylval.str=strdup(yytext);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>true[ ]* 							{
													printf("%s",yytext);
													yylval.str=strdup(yytext);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>.* 								{
													printf("?%s",yytext);
													yylval.str=strdup(yytext);
													yy_pop_state();
													return valor;
												}



<TEXTO>[ ]* 									{
													if(yyleng > aIdentacao[niden]){
														niden++;
														aIdentacao[niden]=yyleng;
														//Começar outro estado
														BEGIN TEXTO_ALFA;
													}
													else if(yyleng == aIdentacao[niden]){
														//Retornar lista vazia
														yy_pop_state();
														yylval.str = "";
														return valor;
													}
													else{
														//Retornar string vazia
														yy_pop_state();
														yylval.str = "";
														return valor;
													}
												}
<TEXTO_ALFA>.*									{
													//Enviar os caracteres para o yacc
													yylval.str = strdup(yytext);
													//Iniciar contagem dos espaços que estão a seguir
													BEGIN TEXTO_ESPACO;
													//return dos tipo
													printf("%s",yytext);
													return valor;
												}
<TEXTO_ESPACO>[ ]*								{
													if(yyleng > aIdentacao[niden]){
														//yyless da ultima identacao
														yyless(aIdentacao[niden]);
														BEGIN TEXTO_ALFA; 
													}
													else if(yyleng == aIdentacao[niden]){
														BEGIN TEXTO_ALFA;
													}
													else{
														niden--;
														yyless(0);
														yy_pop_state();
													}
												}
<TEXTO_ESPACO>[ ]+\n							{
													if(yyleng - 1 > aIdentacao[niden]){
														//yyless da ultima identacao
														yyless(aIdentacao[niden]);
														BEGIN TEXTO_ALFA; 
													}
													else{
														yylval.str = "\\n";
														printf("\\n");
														return valor;
													}
												}
<TEXTO_ESPACO>^\n 								{ 	// Para o caso de ser linha vazia APENAS Retornar O \n
													yylval.str = "\\n";
													printf("\\n");
													return valor;
												}

<*>(.|\n)	{;}

<<EOF>>											{
													if(0<aIdentacao[niden]){
														if(YY_START==TEXTO || YY_START==TEXTO_ALFA || YY_START==TEXTO_ESPACO){
															BEGIN INITIAL;
															niden--;
														}
														else{
															niden--;
															printf("%c",simbolo[niden+1]);
															return simbolo[niden+1];
														}
													}else{
														yyterminate();
													}
												}
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