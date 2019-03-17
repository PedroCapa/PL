#include <glib.h>

int mystrcmp(const void* s1, const void* s2,void *data);

void limpa(GTree * *tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags);

void escreveFile(FILE *out, GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags);


gint travessia(gpointer key, gpointer value, gpointer data);
gint criaTags(gpointer key, gpointer value, gpointer data);