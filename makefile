CC=gcc
LEX=lex.yy.c
CFLAGS= `pkg-config --cflags glib-2.0` `pkg-config --libs glib-2.0` -g

ex1:	ex1.l
	flex ex1.l
	$(CC) -o ex1.out $(LEX) createHTML.c $(CFLAGS)

criarHTML:	criarHTML.l
	flex criarHTML.l
	$(CC) -o criarHTML.out $(LEX) createHTML.c $(CFLAGS)

clean:
	rm $(LEX)
	rm *.out
	rm *.html