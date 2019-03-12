CC=gcc
LEX=lex.yy.c
CFLAGS=-W `pkg-config --cflags glib-2.0`

tp1:	TP1.l
	flex TP1.l
	$(CC) -o TP1 $(LEX)

criarHTML:	criarHTML.l
	flex criarHTML.l
	$(CC) $(CFLAGS) -o criarHTML $(LEX)

clean:
	rm $(LEX)
	rm TP1
	rm criarHTML