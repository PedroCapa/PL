CC=gcc
LEX=lex.yy.c
CFLAGS= `pkg-config --cflags glib-2.0` `pkg-config --libs glib-2.0`

tp1:	TP1.l
	flex TP1.l
	$(CC) -o TP1.out $(LEX)

criarHTML:	criarHTML.l
	flex criarHTML.l
	$(CC) -o criarHTML.out $(LEX) $(CFLAGS)

clean:
	rm $(LEX)
	rm *.out