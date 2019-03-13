#include <glib.h>

int mystrcmp(const void* s1, const void* s2);

void limpa(GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags);

void escreveFile(GTree * tree, char * info, char * categoria, 
					char * titulo, char * data, char * texto, char * tags);


gint travessia(gpointer key, gpointer value, gpointer data);