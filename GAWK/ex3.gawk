BEGIN			{FS="; +"}
				{size = split($5, apelidos, ": +");
				for(i = 1; i < size;i++){
					num[$1][i] = apelidos[i];
					}
				}
END				{
				
				for(i in num){
					for(j in num[i])
						print i "->" num[i][j]; 
				}

				}