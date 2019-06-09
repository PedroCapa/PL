tradutor: 6.l 6.y
	flex 6.l
	yacc -d -v 6.y
	gcc -o tradutor y.tab.c

teste: tradutor
	./tradutor < exemplo

clean:
	rm tradutor
	rm y.tab.h
	rm y.tab.c