#include <stdio.h>
#include <string.h>
#include <glib.h>


int mystrcmp(const void* s1, const void* s2, void *data){

	return strcmp(s1, s2);
}

void limpa(GTree * *tree, char * info, char * categoria, char * titulo, char * data, char * texto, char * tags){
	free(info);
	free(categoria);
	free(titulo);
	free(data);
	free(texto);
	g_tree_destroy(*tree);
	*tree = g_tree_new_full(mystrcmp,NULL,free,NULL);
}

gint travessia(gpointer key, gpointer value, gpointer out){


	fprintf((FILE *)out, "		<tag>%s</tag>\n", (char *)key);

	return 0;
}

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