BEGIN			{FS="; +"}
				{split($2, data, ".");
				if($3){
					local = $3;
					gsub("[^A-ZÇÀÁÃÂÄÈÉẼÊËÌÍĨÎÏÒÓÕÔÖÙÚŨÛÜa-zçàáãâäéèẽêëíìĩîïóòõôöùúũûü ,]", "", local);
					ano[local][conta[local]]=data[1];
					conta[local]++;
				} 
				else{
					ano["NIL"][conta["NIL"]]=data[1]; 
					conta["NIL"]++;
				}
					}
END				{for(i in conta){
					print i "------->" conta[i];
					for(x in ano[i])
					print ano[i][x];}
}