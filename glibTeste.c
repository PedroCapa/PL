#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <glib.h>

int mystrcmp(const void* s1, const void* s2){

	return strcmp(s1, s2);
}

gint travessia(gpointer key, gpointer value, gpointer data){

	char* myKey = key;

	printf("%s\n", myKey);

	return 0;
}

int main(){

	char* a = "comida";
	char* b = "cinema";
	char* c = "asus";
	char* d = "Thibaut";

	GTree * tree = g_tree_new(mystrcmp);

	g_tree_insert(tree, a, NULL);
	g_tree_insert(tree, b, NULL);
	g_tree_insert(tree, c, NULL);
	g_tree_insert(tree, d, NULL);

	g_tree_traverse(tree, travessia, G_IN_ORDER, NULL);
}