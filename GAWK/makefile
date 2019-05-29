CC=gcc

ex1:	ex1.gawk
	gawk -f ex1.gawk cartasetiopia.csv
ex2:	ex2.gawk
	mkdir -p Cartas
	gawk -f ex2.gawk cartasetiopia.csv
ex3:
	gawk -f ex3.gawk cartasetiopia.csv
ex4:
	gawk -f ex4.gawk cartasetiopia.csv
	dot -Tpng ex4.dot -o ex4.png
clean:
	rm -rf Cartas
	rm -f ex4.dot ex4.png