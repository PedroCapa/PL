#include <stdio.h>
#include <string.h>
#include <glib.h>

FILE* out;

int mystrcmp(const void* s1, const void* s2){

	return strcmp(s1, s2);
}

void limpa(GTree * tree, char * info, char * categoria, char * titulo, char * data, char * texto, char * tags){
	free(info);
	free(categoria);
	free(titulo);
	free(data);
	free(texto);
	free(tags);
	g_tree_new(mystrcmp);
}

gint travessia(gpointer key, gpointer value, gpointer data){

	char* myKey = key;

	fprintf(out, "		<tag>%s</tag>\n", myKey);
	//g_tree_remove(tree, key);

	return 0;
}

void escreveFile(GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags){

	char filename[200];
	sprintf(filename, "%s.html", info);
	out = fopen(filename, "w");
	fprintf(out, "<pub id=\"%s\">\n", info);
	fprintf(out, "	<title>%s</title>\n", titulo);
	fprintf(out, "	<author_date>%s<author_date>\n", data);
	if(g_tree_nnodes(tree) > 0){
		fprintf(out, "	<tags>\n");
		g_tree_traverse(tree, travessia, G_IN_ORDER, NULL);
		fprintf(out, "	</tags>\n");
	}
	fprintf(out, "	<categoria>%s<categoria>\n", categoria);
	fprintf(out, "	<text>%s	</text>\n</pub>\n", texto);
	fclose(out);
}