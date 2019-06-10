%{
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>
	

	int contaEspacos();
	int contaNums();
	int contaCardinal();

	int aIdentacao[20];
	char simbolo[20];
	int niden = 0;
	int listaNula = 0;
	char* texto="";
%}

%x TEXTO TEXTO_ALFA TEXTO_ESPACO
%x LISTA HIFENLISTA ESPACOLISTA
%x ID AATRIB ATRIB NULO RECOLHEVALOR
%option stack

%%

#.*												{;/**Ignorar ocorrências de comentários nos inícios de linha*/}

\n 												{;}
[^ \n]											{//Quando o primeiro caracter de uma linha não é espaço ou \n, retirar todas as identações e passar para a SC ID
													if(0<aIdentacao[niden]){//Devia ter sido feito um ciclo
														niden--;
														yyless(0);
														return simbolo[niden+1];
													}
													yyless(0);
													BEGIN ID;
												}
[ ]*/-											{	//Caso em que aparece um elemento de uma lista
													// Se a identação diminuiu, retirar identação; se aumentou, iniciar nova lista;
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = ']';
														BEGIN HIFENLISTA;
														return '[';
													}else if(yyleng<aIdentacao[niden]){//Devia ter sido feito um ciclo
														niden--;
														yyless(0);
														return simbolo[niden+1];
													}else{yyless(0);
														yy_pop_state();
													}
												}

[ ]*											{  // Se a identação diminuiu, retirar identação; se aumentou, iniciar nova estrutura;
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = '}';
														BEGIN ID;
														return '{';
													}else if(yyleng<aIdentacao[niden]){//Devia ter sido feito um ciclo
														niden--;
														yyless(0);
														return simbolo[niden+1];
													}else{
														BEGIN ID;
													}														
												}


<ID>-[ ]+										{  //Identifica inicio de lista
													BEGIN LISTA;
												}		
<ID>[^\n-]*/:									{	// Identifica nome do objeto
													yylval.str = strdup(yytext);
													BEGIN ATRIB;
													return chave;
												}

<LISTA>.*:[ \n]					 				{//Caso seja uma estrutura
													listaNula = 0;
													yyless(0);
													BEGIN ESPACOLISTA;
													yy_push_state(ID);
												}
<LISTA>[\>|]([ ]*|[ ]+#.*)						{
													//Para o caso de ser texto
													BEGIN ESPACOLISTA;
													yy_push_state(TEXTO);
													listaNula = 0;
													return yytext[0];
												}
<LISTA>#.*\n									{
													BEGIN ESPACOLISTA;
													listaNula = 0;
												}
<LISTA>([^\n ]*([ ]+[^\n#])?)*[ ]+#.*\n			{
													//Ter um comentario no meio da linha
													listaNula = 0;
													int i = contaCardinal(yytext);
													char *str = strndup(yytext, i - 1);
													BEGIN ESPACOLISTA;
													yylval.str = str;
													return valor;
												}
<LISTA>[^:\n]*					 				{	
													yyless(0);
													listaNula = 0;
													yy_push_state(RECOLHEVALOR);
												}
<LISTA>\n 										{ BEGIN ESPACOLISTA;}


<ESPACOLISTA>[ ]+								{
													if(listaNula==1){
														listaNula = 0;
														yyless(0);
														return nulo;
													}
													if(yyleng>aIdentacao[niden]){
														yylval.str = " ";
														BEGIN LISTA;
														return valor;
													}else if(yyleng<aIdentacao[niden]){
														BEGIN INITIAL;
														yyless(0);
													}else if(yyleng==aIdentacao[niden]){
														BEGIN HIFENLISTA;
														return ',';
													}
												}
<ESPACOLISTA>[^ ]								{yyless(0); BEGIN INITIAL;}

<HIFENLISTA>-[ ]*								{	
													BEGIN LISTA;
													listaNula=1;
												}

<ATRIB>:										{
													BEGIN AATRIB;
													return yytext[0];
												}

<AATRIB>[ ]*\n 									{BEGIN NULO;}
<AATRIB>[ ]+#.*\n 								{BEGIN NULO;}
<AATRIB>[ ]* 									{
													BEGIN INITIAL;
													yy_push_state(RECOLHEVALOR);
												}
<AATRIB>[ ]+[\>|][ ]*\n 						{
													//Para o caso de ser texto
													BEGIN INITIAL;
													yy_push_state(TEXTO);
													int i = contaEspacos(yytext);
													return yytext[i];
												}

<NULO>[ ]*										{
													if(yyleng<=aIdentacao[niden]){
														yyless(0);
														BEGIN INITIAL;
														return nulo;
													}else{
														yyless(0);
														BEGIN INITIAL;
													}
												}


<RECOLHEVALOR>[0-9]*[ ]+(#.*)					{
													int nums = contaNums(yytext);
													char* numero = strndup(yytext, nums);
													yylval.no=atoi(numero);
													yy_pop_state();
													return inteiro;
												}
<RECOLHEVALOR>false[ ]+(#.*)					{
													char * value = strndup(yytext, 5);
													yylval.str=strdup(value);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>true[ ]+(#.*)						{
													char * value = strndup(yytext, 5);
													yylval.str=strdup(value);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>([^\n ]*([ ]+[^\n#])?)*[ ]+#.*	{
													int inicio = contaCardinal(yytext);
													char * value = strndup(yytext, inicio - 1);
													yylval.str=strdup(value);
													yy_pop_state();
													return valor;
												}
<RECOLHEVALOR>[0-9]*[ ]*						{	//Envia para o yacc o caso especial de ser um inteiro
													yylval.no=atoi(yytext);
													yy_pop_state();
													return inteiro;
												}
<RECOLHEVALOR>false[ ]*							{	//Envia para o yacc o caso especial false
													yylval.str=strdup(yytext);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>true[ ]* 							{	//Envia para o yacc o caso especial true
													yylval.str=strdup(yytext);
													yy_pop_state();
													return booleano;
												}
<RECOLHEVALOR>.* 								{	//Envia o valor de uma chave para o yacc
													yylval.str=strdup(yytext);
													yy_pop_state();
													return valor;
												}



<TEXTO>[ ]* 									{	// E invocado para contar o numero de espaços de um texto
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
													BEGIN TEXTO_ESPACO;
													return valor;
												}
<TEXTO_ESPACO>[ ]*								{	//Conta o número de espacos do texto e consoante o numero de espaços varia o proximo passo tomado
													if(yyleng > aIdentacao[niden]){
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
<TEXTO_ESPACO>[ ]+\n							{	//Caso no texto esteja uma linha em branco enviar os espaços a mais ou simplesmente o \\n
													if(yyleng - 1 > aIdentacao[niden]){
														yyless(aIdentacao[niden]);
														BEGIN TEXTO_ALFA; 
													}
													else{
														yylval.str = "\\n";
														return valor;
													}
												}
<TEXTO_ESPACO>^\n 								{ 	// Para o caso de ser linha vazia APENAS Retornar O \n
													yylval.str = "\\n";
													return valor;
												}
<TEXTO_ESPACO>[^ \n]							{	//Para o caso de a proxima estrutura ter identacao 0
													niden--;
													yyless(0);
													yy_pop_state();
												}

<*>(.|\n)	{;}

<<EOF>>											{	//No caso de chegar ao End of file envia os simbolo que tem que enviar. Quando não tiver mais nenhum simbolo acaba
													if(listaNula==1){
														listaNula = 0;
														return nulo;	
													}
													if(0<aIdentacao[niden]){
														if(YY_START==TEXTO || YY_START==TEXTO_ALFA || YY_START==TEXTO_ESPACO){
															BEGIN INITIAL;
															niden--;
														}
														else{
															niden--;
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
	return i;
}


int contaNums(char * str){
	int i = 0;
	while(isdigit(str[i])){
		i++;
	}
	return i;
}

int contaCardinal(char * str){
	int i = 0;
	while(str[i] != '#'){
		i++;
	}
	return i;
}

int yywrap(){
	return 1;
}