%{
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	--------------------------------------------------------------------
	--------------------------------------------------------------------
	#include <ctype.h>
	--------------------------------------------------------------------
	--------------------------------------------------------------------


	int contaEspacos();

	int aIdentacao[20];
	char simbolo[20];
	int niden = 0;

	char* texto="";
%}

%x TEXTO TEXTO_ALFA TEXTO_ESPACO
%x ESTRUTURA
%x LISTA HIFENLISTA ESPACOLISTA
%x ELEMENTO
%x ID AATRIB ATRIB NULO RECOLHEVALOR
%option stack

%%

\n 												{;}
---------------------------------------------------------------------------
---------------------------------------------------------------------------
#.*												{;}
---------------------------------------------------------------------------
---------------------------------------------------------------------------
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

<LISTA>.*:[ \n]					 				{
													yyless(0);BEGIN ESPACOLISTA;yy_push_state(ID);
												}
<LISTA>[^:\n]*					 				{
													yylval.str = strdup(yytext);
													printf("%s",yytext);
													return linha;
												}
<LISTA>\n 										{ BEGIN ESPACOLISTA; }
<ESPACOLISTA>[ ]+								{
													if(yyleng>aIdentacao[niden]){
														yylval.str = " ";
														printf(" ");
														BEGIN LISTA;
														return linha;
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

<HIFENLISTA>-[ ]+								{BEGIN LISTA;}

<ATRIB>:										{
													BEGIN AATRIB;
													printf("%c",yytext[0]);
													return yytext[0];
												}

<AATRIB>[ ]*\n 									{BEGIN NULO;}
---------------------------------------------------------------------------
---------------------------------------------------------------------------
<AATRIB>[ ]+#.*\n 								{BEGIN NULO;}
---------------------------------------------------------------------------
---------------------------------------------------------------------------
<AATRIB>[ ]* 									{
													BEGIN RECOLHEVALOR;
												}
<AATRIB>[ ]+[\>|][ ]*\n 						{
													//Para o caso de ser texto
													BEGIN TEXTO;
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
---------------------------------------------------------------------------
---------------------------------------------------------------------------
<RECOLHEVALOR>[0-9]*[ ]+(#.*)					{
													printf("%s",yytext);
													int nums = contaNums(yytext);
													char* numero = strndup(yytext, nums);
													yylval.no=atoi(numero);
													BEGIN INITIAL;//yy_pop_state();
													return inteiro;
												}
<RECOLHEVALOR>false[ ]+(#.*)					{
													printf("%s",yytext);
													char * value = strndup(yytext, 5);
													yylval.str=strdup(value);
													BEGIN INITIAL;//yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>true[ ]+(#.*)						{
													printf("%s",yytext);
													char * value = strndup(yytext, 5);
													yylval.str=strdup(value);
													BEGIN INITIAL;//yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>([^\n ]*([ ]+[^\n#])?)*[ ]+#.*	{
													printf("%s",yytext);
													int contaNaoEspacos(yytext);
													char * value = strndup(yytext, 5);
													yylval.str=strdup(value);
													BEGIN INITIAL;//yy_pop_state();
													return valor;
												}
---------------------------------------------------------------------------
---------------------------------------------------------------------------
<RECOLHEVALOR>[0-9]*[ ]*						{
													printf("%s",yytext);
													yylval.no=atoi(yytext);
													BEGIN INITIAL;//yy_pop_state();
													return inteiro;
												}
<RECOLHEVALOR>false[ ]*							{
													printf("%s",yytext);
													yylval.str=strdup(yytext);
													BEGIN INITIAL;//yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>true[ ]* 							{
													printf("%s",yytext);
													yylval.str=strdup(yytext);
													BEGIN INITIAL;//yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>.* 								{
													printf("%s",yytext);
													yylval.str=strdup(yytext);
													BEGIN INITIAL;//yy_pop_state();
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
														BEGIN INITIAL;
														yylval.str = "";
														return linha;
													}
													else{
														//Retornar string vazia
														BEGIN INITIAL;
														yylval.str = "";
														return linha;
													}
												}
<TEXTO_ALFA>.*									{
													//Enviar os caracteres para o yacc
													yylval.str = strdup(yytext);
													//Iniciar contagem dos espaços que estão a seguir
													BEGIN TEXTO_ESPACO;
													//return dos tipo
													printf("%s",yytext);
													return linha;
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
														BEGIN INITIAL;
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
														printf("\\1n");
														return linha;
													}
												}
<TEXTO_ESPACO>^\n 								{ 	// Para o caso de ser linha vazia APENAS Retornar O \n
													yylval.str = "\\n";
													printf("\\2n");
													return linha;
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

int contaNums(char * str){
	int i = 0;
	while(isdigit(str[i])){
		i++;
	}
	return i;
}

int contaNaoEspacos(char * str){
	int i = 0;
	while(str[i] != ' '){
		i++;
	}
	return i;
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