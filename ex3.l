%{
#include <stdio.h>
#include <string.h>

%}
 /* https://stackoverflow.com/a/9611844 */

letraM 		([A-Z]|Ç|À|Á|Ã|Â|Ä|È|É|Ẽ|Ê|Ë|Ì|Í|Ĩ|Î|Ï|Ò|Ó|Õ|Ô|Ö|Ù|Ú|Ũ|Û|Ü)  
letram 		([a-z]|ç|à|á|ã|â|ä|é|è|ẽ|ê|ë|í|ì|ĩ|î|ï|ó|ò|õ|ô|ö|ù|ú|ũ|û|ü)
palavraM 	{letraM}{letram}*
palavram 	{letram}+
sep 		(\ |-|\n)
%%

({palavraM}{sep}?({palavram}{sep})?)+\({letraM}+\)	{printf("%s\n",yytext);} /* Substituir '\n' por ' '*/


(.|\n)				{;}

%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){


	if(argc < 2){
		return 1;
	}

	yyin = fopen(argv[1],"r");

	printf("Inicio da filtragem\n");


	yylex();

	printf("Fim da filtragem\n");
	return 0;
}