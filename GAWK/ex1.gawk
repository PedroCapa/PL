BEGIN			{FS=";        "}
				{split($2, data, ".");
				if($3){
					ano[$3][conta[$3]]=data[1];
					conta[$3]++;
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