#include <stdio.h>
#include <string.h>
#include <glib.h>
#include <stdlib.h>

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

gint insereAbv(gpointer key, gpointer value, gpointer out){


	fprintf((FILE *)out, "%s", (char *)key);
	return 0;	
}

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