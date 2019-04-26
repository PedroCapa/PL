<<<<<<< HEAD
BEGIN			{FS="; +"}
				{split($2, data, ".");
				ano = data[1];
				if(ano != null){
					titulo[ano][$1] = $4;
					for(i=6;i<=NF;i++){
						resumo[ano][$1] = resumo[ano][$1] $i;
					}
				}
				}
END				{print "<html>\n	<head> Indice </head>\n	<body>\n		<ul>" > "Cartas/index.html";
								for (i in titulo){
									print "<html>\n	<head> " i " </head>\n	<body>" > "Cartas/" i ".html";
						 			for(j in titulo[i]){
										print "		<p>\n			<b>" titulo[i][j] "</b>\n		</p>\n" > "Cartas/" i ".html";
										print "		<p> " resumo[i][j] "		</p>" > "Cartas/" i ".html";
							 		}
							 		print "	</body>\n</html>" > "Cartas/" i ".html";
							 		print "			<li><a href= \"" i ".html\">" i"</a></li>"  > "Cartas/index.html";
							 	}
							 	print "\n</ul>	</body>\n</html>"  > "Cartas/index.html";}