%{
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include "createHTML.h"

GTree * tree;

FILE* out;
char *title,*post;
%}

%x TEXT TITLE TAGS

%%

\<pub\ id=\"[^\"]*\"\>					{yytext[yyleng-2]='\0'; post=strdup((char*) yytext+9);char filename[200];sprintf(filename, "html/post/%s.html", post);
										out = fopen(filename,"w");BEGIN TITLE;}

<TITLE>\<title\>.*\<\/title\>			{yytext[yyleng-8]='\0'; title=strdup((char*) yytext+7);
										fprintf(out, "<html>\n<head><meta charset=\"UTF-8\">\n<title>%s</title>\n</head>\n<body>\n<h1>%s</h1>\n", title,title);}

<TITLE>\<tags\>							{BEGIN TAGS;fprintf(out, "tags:");}
<TITLE>\<text\>							{BEGIN TEXT;fprintf(out, "\n<br>\n");}


<TAGS>\<tag\>.*\<\/tag\>				{yytext[yyleng-6]='\0';
										char tag[(yyleng-11)];int i=5;
										for (; i < yyleng-6; i++)			//Retira / das tags e substitui por um hifen
										{
											if(yytext[i]=='/'){
												tag[i-5] = '-';
											}else{
												tag[i-5] = yytext[i];
											}
										}tag[i-5]=0;
										char tagLink[512];
										sprintf(tagLink,"  <dt><a href=\"../post/%s.html\">%s</a></dt>\n",post,title);
										char *tl = strdup(tagLink);
										GArray *array = (GArray *) g_tree_lookup(tree,tag);
										if(array == NULL){
											array = g_array_new(TRUE,TRUE,sizeof(char *));
											array = g_array_append_val(array,tl);
											g_tree_insert(tree,strdup(tag),array);
										}
										else{
											g_array_append_val(array,tl);
										}
										fprintf(out,"<a href=\"../tag/%s.html\">%s</a>; ",tag,tag);
										}

<TAGS>\<\/tags\>						{BEGIN TEXT;}

<TEXT>\n								{fprintf(out, "\n<br>\n");}
<TEXT>\<\/text\>						{fprintf(out, "</body>\n</html>");fclose(out);BEGIN INITIAL;free(title);free(post);}
<TEXT>.									{fprintf(out, "%s", yytext);}

<*>(.|\n)								{;}

%%

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){

	if(argc < 2){
		return 1;
	}

	yyin = fopen(argv[1],"r");

	tree = g_tree_new_full(mystrcmp,NULL,free,NULL);

	printf("Inicio da filtragem\n");


	yylex();

	fclose(yyin);
	printf("Fim da filtragem\n");

	g_tree_foreach(tree, criaTags, NULL);
	g_tree_destroy(tree);

	return 0;
}