#include <stdio.h>
#include <string.h>
#include <glib.h>


void limpa(GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags){}

void escreveFile(GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags){

	char filename[200];
	sprintf(filename, "%s.html", info);
	FILE* out = fopen(filename, "w");
	fprintf(out, "<pub id=\"%s\">\n", info);
	fprintf(out, "	<title>%s</title>\n", titulo);
	fprintf(out, "	<author_date>%s<author_date>\n", data);
	fprintf(out, "	<categoria>%s<categoria>\n", categoria);
	fprintf(out, "	<text>%s	</text>\n</pub>\n", texto);
	fclose(out);
}