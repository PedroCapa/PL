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
%option stack

%%

\n 											{;}
[^ \n]											{
													if(0<aIdentacao[niden]){
														niden--;
														yyless(0);
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}
													yyless(0);
													yy_push_state(ID);
												}
[ ]*/-											{	// Só deve vir para o initial quando pode ser definida uma nova identacao(quando termina em ':' a linha anterior)
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = ']';
														yy_push_state(HIFENLISTA);
														//printf("[");
														return '[';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);yy_pop_state();
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														yy_push_state(ID);
													}
												}

[ ]*											{
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = '}';
														yy_push_state(ID);
														//printf("{");
														return '{';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);yy_pop_state();
														//printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														yy_push_state(ID);;
													}														
												}


<ID>-[ ]+										{
													BEGIN LISTA;//printf("%c",yytext[0]);//return yytext[0]; //Identifica inicio de lista
												}		

<LISTA>[^ \n]([^\n:]*:*[^ \n:])*\: 				{
													yyless(0);yy_push_state(ID);
												}
<LISTA>[^ \n]([^\n:]*:*[^ \n:])* 				{
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
<ESPACOLISTA>[^ ]								{yyless(0);yy_pop_state();}

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
													yy_pop_state();
													return valor;
												}
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
<AATRIB>[ ]+[\>|][ ]*\n 						{
													//Para o caso de ser texto
													//BEGIN TEXTO;
													//int i = contaEspacos(yytext);
													//yyless(yyleng - 1);
													//return yytext[i];
												}
<TEXTO>[ ]* 									{
													if(yyleng > aIdentacao[niden]){
														//acrescenta-se o niden
														//acrescenta-se o aIdentacao
														//Começar outro estado
													}
													else if(yyleng == aIdentacao[niden]){
														//Retornar lista vazia
													}
													else{
														//Retornar string vazia
														//BEGIN INITIAL ou pop de uma condição para fechar as chavetas
													}
												}
<TEXTO_ALFA>.*									{
													//Enviar os caracteres para o yacc
													//Iniciar contagem dos espaços que estão a seguir
													//return dos tipo
												}
<TEXTO_ESPACO>[ ]*								{
													if(yyleng > aIdentacao[niden]){
														//yyless da ultima identacao
														//BEGIN TEXTO_ALFA; 
													}
													else if(yyleng == aIdentacao[niden]){
														//BEGIN TEXTO_ALFA;
													}
													else{
														//Fazer Pop ou BEGIN INITIAL;
													}
												}
<TEXTO_ESPACO>^\n 								{ 	// Para o caso de ser linha vazia APENAS Retornar O \n
													yylval.str = "\\n"; 
													return linha;
												}
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
<ESTRUTURA>[ ]*\n 								{
													BEGIN INITIAL;
												}
<ESTRUTURA>[ ]*.* 								{
													//printf("%s",yytext);
													yylval.str=strdup(yytext);
													yy_pop_state();
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