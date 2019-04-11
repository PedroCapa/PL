/**
@file createHTML.c
Ficheiro com as funções auxiliares da GTree
*/
#include <stdio.h>
#include <string.h>
#include <glib.h>
#include <stdlib.h>
/**
\brief Função que compara dois valores que serão inseridos na GTree
@param s1 valor comparado
@param s2 valor comparado
@param data 
@returns a diferença de valor entre os dois valores
*/
int mystrcmp(const void* s1, const void* s2, void *data){

	return strcmp(s1, s2);
}
/**
\brief Função que limpa a memoria das variaveis usadas no programa do ex1 e do ex2
@param tree arvore que sera limpa
@param info string referente a info de uma noticia
@param categoria string referente a categoria de uma noticia
@param titulo string referente aao titulo de uma noticia
@param data string referente a data de uma noticia
@param texto string referente ao texto de uma noticia
@param tags string referente a ultima tag de uma noticia
*/
void limpa(GTree * *tree, char * info, char * categoria, char * titulo, char * data, char * texto, char * tags){
	free(info);
	free(categoria);
	free(titulo);
	free(data);
	free(texto);
	g_tree_destroy(*tree);
	*tree = g_tree_new_full(mystrcmp,NULL,free,NULL);
}
/**
\brief Função que escreve num ficheiro todas as tags que estao guardadas numa arvore
@param key valor da tag
@param value
@param out onde será redirecionado o output
@return 0 caso tenha escrito com sucesso
*/
gint travessia(gpointer key, gpointer value, gpointer out){


	fprintf((FILE *)out, "		<tag>%s</tag>\n", (char *)key);

	return 0;
}
/**
\brief Função que escreve num ficheiro todas as abreviaturas guardadas numa GTree
@param key string da abreviatura
@param value
@param out onde será redirecionado o output
@return 0 caso tenha escrito com sucesso
*/
gint insereAbv(gpointer key, gpointer value, gpointer out){


	fprintf((FILE *)out, "%s", (char *)key);
	return 0;	
}
/**
\brief Função que escreve num ficheiro todas as referencias de uma TAG
@param key valor da referencia
@param value
@param out onde será redirecionado o output
@return 0 caso tenha escrito com sucesso
*/
gint criaTags(gpointer key, gpointer value, gpointer out){


	char filename[200];
	sprintf(filename, "html/tag/%s.html", (char *)key);
	FILE *tagFILE = fopen(filename,"w");

	GArray *array = (GArray *) value;

	fprintf(tagFILE,"<html>\n<head><meta charset=\"UTF-8\">\n<title>%s</title></head>\n<body><dl>",(char *)key);
	for(int i = 0; i<array->len;i++){
		char *s = g_array_index(array,char *,i);
		fprintf(tagFILE,"%s",s);
		free(s);
	}
	fprintf(tagFILE,"</dl></body>\n</html>");
	g_array_free(array,TRUE);
	fclose(tagFILE);
	
	return 0;
}
/**
\brief Função que insere num ficheiro as variaveis usadas no programa do ex1 e do ex2
@param out onde será redirecionado o output
@param tree arvore que sera inserida
@param info string referente a info de uma noticia
@param categoria string referente a categoria de uma noticia
@param titulo string referente aao titulo de uma noticia
@param data string referente a data de uma noticia
@param texto string referente ao texto de uma noticia
@param tags string referente a ultima tag de uma noticia
*/
void escreveFile(FILE *out, GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags){
	fprintf(out, "<pub id=\"%s\">\n", info);
	fprintf(out, "	<title>%s</title>\n", titulo);
	fprintf(out, "	<author_date>%s<author_date>\n", data);
	if(g_tree_nnodes(tree) > 0){
		fprintf(out, "	<tags>\n");
		g_tree_foreach(tree, travessia, out);
		fprintf(out, "	</tags>\n");
	}
	fprintf(out, "	<categoria>%s<categoria>\n", categoria);
	fprintf(out, "	<text>\n%s	</text>\n</pub>\n\n", texto);
}