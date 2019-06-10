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

#.*		{;}

\n 												{printf("IGNORA\n");}
[^ \n]											{
													if(0<aIdentacao[niden]){
														niden--;
														yyless(0);
														printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}
													yyless(0);
													printf("INITIAL caracteres\n");
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
														printf("Estou aqui no initial\n");
														yy_pop_state();
													}
												}

[ ]*											{
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														simbolo[niden] = '}';
														BEGIN ID;
														printf("{ No inicial %d\n", niden);
														return '{';
													}else if(yyleng<aIdentacao[niden]){
														niden--;
														yyless(0);
														//yy_pop_state();
														printf("%c",simbolo[niden+1]);
														return simbolo[niden+1];
													}else{
														printf("Estou no inicial com identacao %d\n", niden);
														BEGIN ID;//yy_pop_state();
													}														
												}


<ID>-[ ]+										{
													BEGIN LISTA;//Identifica inicio de lista
												}		
<ID>[^\n-]*/:									{	// Identifica nome do objeto
													yylval.str = strdup(yytext);
													BEGIN ATRIB;
													printf("%s Estou no ID\n",yytext);
													return chave;
												}

<LISTA>.*:[ \n]					 				{//Caso seja uma estrutura
													listaNula = 0;
													yyless(0);BEGIN ESPACOLISTA;yy_push_state(ID);
												}
<LISTA>[\>|]([ ]*|[ ]+#.*)						{
													//Para o caso de ser texto
													BEGIN ESPACOLISTA;
													yy_push_state(TEXTO);
													int i = contaEspacos(yytext);
													printf("%c",yytext[i]);
													listaNula = 0;
													return yytext[i];
												}
<LISTA>#.*\n									{
													BEGIN ESPACOLISTA;
													listaNula = 0;
													//Dá erro para um caso
													printf("LISTA COM COMENTARIO INICIO\n");
												}
<LISTA>([^\n ]*([ ]+[^\n#])?)*[ ]+#.*\n			{
													//Ter um comentario no meio da linha
													printf("LISTA COM COMENTARIO a meio\n");
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
<LISTA>\n 										{ BEGIN ESPACOLISTA; printf("€%d€",listaNula);}


<ESPACOLISTA>[ ]+								{
													if(listaNula==1){
														printf("nulo");
														listaNula = 0;
														yyless(0);
														return nulo;
													}
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
<ESPACOLISTA>[^ ]								{yyless(0); BEGIN INITIAL;}

<HIFENLISTA>-[ ]*								{BEGIN LISTA;listaNula=1;printf("$");}

<ATRIB>:										{
													BEGIN AATRIB;
													printf("%c\n",yytext[0]);
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


<RECOLHEVALOR>[0-9]*[ ]+(#.*)					{
													printf("%s RECOLHEVALOR",yytext);
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
													printf("%s ENCONTREI COMENTARIO\n",yytext);
													int inicio = contaCardinal(yytext);
													char * value = strndup(yytext, inicio - 1);
													yylval.str=strdup(value);
													BEGIN INITIAL;//yy_pop_state();
													return valor;
												}
<RECOLHEVALOR>[0-9]*[ ]*						{
													printf("%s RECOLHEVALOR numero\n",yytext);
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
													printf("%s TEXTO_ALFA\n",yytext);
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
														printf("Vou sair %d\n", niden);
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
<TEXTO_ESPACO>[^ \n]							{
													niden--;
													yyless(0);
													yy_pop_state();
												}

<*>(.|\n)	{;}

<<EOF>>											{
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
/*
int main(){
	yylex();
	return 0;
}*/