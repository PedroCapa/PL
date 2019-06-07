tradutor: tradutor.l tradutor.y
	flex tradutor.l
	yacc -d -v tradutor.y
	gcc -o tradutor y.tab.c

teste: tradutor
	./tradutor < exemplo

clean:
	rm tradutor
	rm y.tab.h
	rm y.tab.c