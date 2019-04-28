BEGIN					{FS="; +"; print "digraph graphname {\nrankdir=LR" > "ex4.dot";}
$4~/\`Carta (d|a|à)/	{
							size = split($4, titulo, "Carta d(a|e|o) ");
							if(size > 1){
								size = split(titulo[2],resto," (à|a|ao|aos|às) ");
								autor = resto[1];
								if(size > 1){
									recetor = resto[2];
								} else {
									recetor = "desconhecido";
								}

							} else {
								autor = "desconhecido";
								size = split(titulo[1],resto," (à|a|ao|aos|às) ");
								if(size > 1){
									recetor = resto[2];
								} else {
									recetor = "desconhecido";
								}
							}

							id=$1;
							sub(" +","",id);
							relacao[autor][recetor] = relacao[autor][recetor] id " ";
						}
END						{
							for(autor in relacao){
								for(recetor in relacao[autor]){
									print "\""autor"\"" " -> " "\""recetor"\"" " [ label=\"" relacao[autor][recetor] "\" ] " > "ex4.dot";
								}
							}
							print "}" > "ex4.dot";
						}