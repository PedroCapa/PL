BEGIN			{FS="; +"; print "digraph graphname {" > "ex4.dot";}
				{
					id=$1;
					sub(" +","",id);
					size = split($5, apelidos, ": +");
					for(i = 2; i < size;i++){
						print "\""apelidos[1]"\"" " -> " "\""apelidos[i]"\"" " [ label=\"" id "\" ] " > "ex4.dot";
					}
				}
END				{print "}" > "ex4.dot";
				

				}