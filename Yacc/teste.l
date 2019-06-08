%{
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	int yydebug=1;	
	int contaEspacos();
	int yywrap();
	int contaDoisPontos(char * str, int tam);

	int aIdentacao[20] = {0};
	int niden = 0;
	int nEspacos = 0;

	char* texto="";
%}

%x ID
%x ELEMENTO
%x TWO_POINTS
%x LISTA
%x IDENT_ELEMENTO
%x VALOR
%x TEXTO
%x TEXTO_INICIO
%x TEXTO_LINHA
%x TEXTO_MEIO


%%



#.*											{;}

^[ \t]*										{	//Contar o numero de espaços no inicio da linha
												if(yyleng>aIdentacao[niden]){
													niden++;
													aIdentacao[niden] = yyleng;
													yylval.num = niden;
													return ident;
												}else if(yyleng<aIdentacao[niden]){
													while(yyleng<aIdentacao[niden]){
														niden--;
													}
													if(yyleng == aIdentacao[niden]){
														yylval.num = niden;
														return ident;
													}
												}
												BEGIN ID;
											}
^[ \t]*/-										{//Contar o numero de espaços no inicio da linha no caso de ser uma lista
												if(yyleng>aIdentacao[niden]){
													niden++;
													aIdentacao[niden] = yyleng;
													yylval.num = niden;
													//printf("dsadssadsaasdsadadsad\n");
												}else if(yyleng<aIdentacao[niden]){
													while(yyleng<aIdentacao[niden]){
														niden--;
													}
												}
												BEGIN LISTA;
											}

<LISTA>\-									{	// Devolver o hifen do inicio de um ELEMENTO
												//printf("-"); 
												BEGIN IDENT_ELEMENTO; 
												return yytext[0];
											}

<IDENT_ELEMENTO>[ \t]+						{	//Identação de um ELEMENTO
												//printf("Elem\n"); 
												yylval.num = aIdentacao[niden]; 
												BEGIN ELEMENTO; 
												return ident;
											}

<ID>\-[ ]+									{	//Retorna o hifen
												//printf("-"); 
												BEGIN ELEMENTO; 
												return yytext[0];
											}
<ID>[^:\n]+/:								{	//Retorna o Id
												//printf("Id->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS;
												return id;
											}

<TWO_POINTS>:[ ]*\n							{	//Retorna os dois pontos de uma lista 
												//printf("TWO_POINTS\n");
												BEGIN INITIAL; 
												return yytext[0];
											}
<TWO_POINTS>:[ ]*							{	//Retorna os dois pontos de um VALOR para remover os espaços
												//printf("TWO_POINTS\n");
												BEGIN VALOR; 
												return yytext[0];
											}
<TWO_POINTS>:[ ]*/[/>|]						{	//Retorna os dois pontos de um > ou |
												//printf("TWO_POINTS\n");
												BEGIN TEXTO; 
												return yytext[0];
											}

<TEXTO>.[ ]*\n								{	//Retorna o > ou |
												//printf("texto\n");
												BEGIN TEXTO_INICIO;
												return yytext[0];
											}
<TEXTO_INICIO>[ ]+							{//Contar o numero de espaços no inicio da linha DE TEXTO
												if(yyleng <= aIdentacao[niden]){
													//printf("Identação errada no inicio do texto YAML\n");
												}
												else{
													niden++;
													aIdentacao[niden] = yyleng;
													BEGIN TEXTO_LINHA;
												}
											}

<TEXTO_LINHA>.*								{
												//printf("Linha->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TEXTO_MEIO; 
												return linha;
											}
<TEXTO_MEIO>[ ]+							{
												if(yyleng >= aIdentacao[niden]){
													BEGIN TEXTO_LINHA;
												}
												else{
													while(yyleng < aIdentacao[niden])
														niden--;
													//Começar a procura do ID
													BEGIN ID;
												}
											}
<TEXTO_MEIO>^\n 							{ 	// Para o caso de ser linha vazia
												//printf("Linha vazia\n");
												yylval.str = "\\n"; 
												return linha;
												
											}
<TEXTO_MEIO>^[A-Za-z]+/:					{ 	// Para o caso de a Identação ser 0 
												//printf("Id->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS; 
												return id;
											}


<ELEMENTO>[^:\n]*							{	//Retorna o elemento de uma lista que seja uma linha
												//printf("ELEMENTO->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN INITIAL; 
												return line;
											}
<ELEMENTO>[A-Za-z]+/:[ ]					{	//Retorna o elemento de uma lista com chave valor
												//printf("ELEMENTO->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS; 
												return chave;
											}

<VALOR>.*									{	//Retorna o valor de uma variavel
												//printf("valor->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN INITIAL; 
												return valor;
											}

^[A-Za-z]+/:								{ 	// Para o caso de a Identação ser 0 
												//printf("Id->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS; 
												return id;
											}


%%

int yywrap(){
	return 1;
}