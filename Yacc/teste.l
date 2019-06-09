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
	int abertas = 0;

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
%x ABRE_CHAVETA
%x FECHAR_CHAVETAS
%%



#.*											{;}

^[ \t]*										{	//Contar o numero de espaços no inicio da linha
												if(yyleng>aIdentacao[niden]){
													printf("1.niden++ %d\n", yyleng);
													niden++;
													aIdentacao[niden] = yyleng;
													yylval.num = yyleng;
													BEGIN ID;
													return ident;
												}else if(yyleng<aIdentacao[niden]){
													while(yyleng<aIdentacao[niden]){
														niden--;
														printf("1.niden--\n");
													}
													if(yyleng == aIdentacao[niden]){
														//Talvez BEGIN ID
														yylval.num = yyleng;
														return ident;
													}
												}
												else{
													printf("Estou a mandar Ident\n");
													BEGIN ID;
													yylval.num = yyleng;
													return ident;
												}
											}
^[ \t]+/-										{//Contar o numero de espaços no inicio da linha no caso de ser uma lista
												if(yyleng>aIdentacao[niden]){
													printf("2.niden++ %d\n", yyleng);
													niden++;
													aIdentacao[niden] = yyleng;
													yylval.num = niden;
												}else if(yyleng<aIdentacao[niden]){
													while(yyleng<aIdentacao[niden]){
														printf("2.niden--\n");
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
												printf("id->%s\n", yytext);
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS;
												return id;
											}

<TWO_POINTS>:[ ]*/\n						{	//Retorna os dois pontos de uma lista 
												printf("TWO_POINTS PARA NULO\n");
												BEGIN ABRE_CHAVETA; 
												return ':';
											}
<TWO_POINTS>:[ ]+[\>|]						{	//Retorna os dois pontos de um > ou |
												printf("TWO_POINTS PARA TEXTO PARAGRAFO\n");
												BEGIN TEXTO;
												yyless(yyleng - 1);
												return yytext[0];
											}
<TWO_POINTS>:[ ]*							{	//Retorna os dois pontos de um VALOR para remover os espaços
												printf("TWO_POINTS PARA VALOR\n");
												BEGIN VALOR; 
												return yytext[0];
											}

<ABRE_CHAVETA>\n[ ]*						{
												if(yyleng - 1 > aIdentacao[niden]){
													printf("ABRE_CHAVETA %d %d\n", yyleng, aIdentacao[niden]);
													abertas++;
													BEGIN INITIAL;
													yyless(0);
													return '{';
												}
												else if(yyleng - 1 == aIdentacao[niden]){
													yyless(0);
													BEGIN INITIAL;
													return NULO;
												}
												else{
													printf("RETRUN NULL\n");
													yyless(0);
													BEGIN FECHAR_CHAVETAS;
													return NULO;
												}
											}
<ABRE_CHAVETA>\n[ ]*-						{
												printf("Lista %d %d\n", yyleng, aIdentacao[niden]);
												BEGIN INITIAL;
												yyless(0);
											}


<TEXTO>.[ ]*\n								{	//Retorna o > ou |
												printf("texto\n");
												BEGIN TEXTO_INICIO;
												return yytext[0];
											}
<TEXTO_INICIO>[ ]+							{//Contar o numero de espaços no inicio da linha DE TEXTO
												if(yyleng <= aIdentacao[niden]){
													//printf("Identação errada no inicio do texto YAML\n");
												}
												else{
													printf("3.niden++ %d\n", yyleng);
													niden++;
													aIdentacao[niden] = yyleng;
													BEGIN TEXTO_LINHA;
												}
											}

<TEXTO_LINHA>.*								{
												printf("Linha->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TEXTO_MEIO; 
												return linha;
											}
<TEXTO_MEIO>[ ]+							{
												if(yyleng >= aIdentacao[niden]){
													printf("TEXTO_MEIO %d\n", yyleng);
													BEGIN TEXTO_LINHA;
												}
												else{
													while(yyleng < aIdentacao[niden])
														printf("3.niden--\n");
														niden--;
													//Começar a procura do ID
													BEGIN ID;
												}
											}
<TEXTO_MEIO>^\n 							{ 	// Para o caso de ser linha vazia
												printf("Linha vazia\n");
												yylval.str = "\\n"; 
												return linha;
												
											}
<TEXTO_MEIO>^[A-Za-z]+/:					{ 	// Para o caso de a Identação ser 0 
												printf("Id->%s FIZ NIDEN = 0\n", yytext);
												niden = 0;
												abertas = 0;
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS;
												return id;
											}


<ELEMENTO>[^:\n]*							{	//Retorna o elemento de uma lista que seja uma linha
												printf("ELEMENTO->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN INITIAL; 
												return line;
											}
<ELEMENTO>[A-Za-z]+/:[ ]					{	//Retorna o elemento de uma lista com chave valor
												printf("ELEMENTO->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS; 
												return chave;
											}


<VALOR>.*									{	//Retorna o valor de uma variavel
												printf("valor->%s\n", yytext); 
												yylval.str = strdup(yytext); 
												BEGIN FECHAR_CHAVETAS;
												return valor;
											}

<FECHAR_CHAVETAS>\n[ ]*						{
												if(yyleng - 1 < aIdentacao[niden]){
													printf("FECHAR_CHAVETAS %d %d %d\n", yyleng, aIdentacao[niden], niden);
													abertas--;
													niden--;
													yyless(0);
													return '}';
												}
												else{
													printf("BEGIN FECHA CHAV INITIAL\n");
													yyless(0);
													BEGIN INITIAL;
												}
											}

^[A-Za-z]+/:								{ 	// Para o caso de a Identação ser 0 
												printf("ID->%s NIDEN = 0\n", yytext);
												niden = 0;
												abertas = 0;
												yylval.str = strdup(yytext); 
												BEGIN TWO_POINTS; 
												return id;
											}
^\.\.\.										{yyterminate();}

<*>(.|\n)									{;}
%%

int yywrap(){
	return 1;
}