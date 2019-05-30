%{
	#include "y.tab.h"
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	char* texto="";
%}

%x TEXTO


%%
[A-Za-z]+:\n					{yylval.str = strdup(yytext);		yylval.str[yyleng - 2] = '\0';	 				return est;}

-[ ]*.*							{yylval.str = strdup(yytext + 2); 	 										 		return elem;}

[A-Za-z]+:[^A-Za-z0-9]+			{yylval.str = strdup(yytext);		int j = 0;
																	while(yytext[yyleng - j] != ':')
																		j++; 
																	yylval.str[yyleng - j] = '\0';	
																	BEGIN TEXTO; 	return top;

								}


[A-Za-z]+:[ ]+[A-Za-z0-9]+		{yylval.str = strdup(yytext);		
									return variavel;		
								}


<TEXTO>[^:\n]+					{
									yylval.str = strdup(yytext);	return linha;
								}

<TEXTO>[A-Za-z]+:.+				{yylval.str = strdup(yytext);		int j = 0;
																	while(yytext[yyleng - j] != ':')
																		j++; 
																	yylval.str[yyleng - j] = '\0';	
																	BEGIN TEXTO; 	return top;}

<TEXTO>[A-Za-z]+:				{yylval.str = strdup(yytext);		yylval.str[yyleng - 1] = '\0';	BEGIN INITIAL; 	return est;	}


^\#.+							{;}
(.|\n)							{;}
%%

int yywrap(){
	return 1;
}