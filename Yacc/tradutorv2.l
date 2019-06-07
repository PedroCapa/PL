%{
	#define _GNU_SOURCE
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	
	int yydebug=1;

	int contaEspacos();

	int aIdentacao[20];
	int niden = 0;

	char* texto="";
%}

%x TEXTO
%x ESTRUTURA
%x LISTA
%x ELEMENTO
%x ID


%%

#.*											{;}

^[ ]*											{
													if(yyleng>aIdentacao[niden]){
														niden++;
														aIdentacao[niden] = yyleng;
														yylval.num = niden;
														return identacao;
													}else if(yyleng<aIdentacao[niden]){
														while(yyleng<aIdentacao[niden]){
															niden--;
														}
														if(yyleng == aIdentacao[niden]){
															yylval.num = niden;
															return identacao;
														}
													}
													BEGIN ID;
												}
<ID>-[ ]+										{
													BEGIN ELEMENTO;return yytext[0]; //Identifica inicio de lista
												}		

<ID>[^:]*										{	// Identifica nome do objeto
													yylval.str = strdup(yytext);
													BEGIN ATRIB;
													return Id;
												}
<ATRIB>:										{BEGIN AATRIB; return yytext[0];}

<AATRIB>[ ]*/\n 								{BEGIN INITIAL;}
<AATRIB>[ ]*[|\>] 								{return yytext[yyleng-1];Begin TITULO;//Depois pode-se fazer egin para ir buscar os modificador a frente}
<AATRIB>[ ]*.* 									{yylval.str=strdup(yytext);BEGIN INITIAL; return Valor;}

<TITULO>[ ]*									{ nEspacos = yyleng;BEGIN T;}
<T>.*											{yylval.str = strdup(yytext);BEGIN TEXTO;return Linha;}
<TEXTO>.*										{
													if(nEspacos>yyleng){
													}
													yylval.str = strdup(yytext+nEspacos);return Linha;
												}

<ELEMENTO>/\n 									{BEGIN INITIAL;}
<ELEMENTO>.* 									{yylval.str = strdup(yytext);return valor;}

^[^: ][^:]*											{ 
													char* ret;
													while(0<aIdentacao[niden]){
														niden--;
														asprintf(&ret,"%s}",ret);
													}
													yylval.str = strdup(yytext);
													asprintf(&ret,"%s%d",ret,Id);
													return ret;
												}


\n/[ \n\t\r]								{yylval.num=0;return identacao;}
.											{;}

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

int main(){
	aIdentacao[0]=0;
	yylex();
	return 0;
}