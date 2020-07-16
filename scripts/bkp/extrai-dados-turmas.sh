#!/bin/bash

dir_fonte=$1
dir_destino=$2
dir_scripts=$3

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino

rm -rf $dir_destino/resumo.csv $dir_destino/nota.csv $dir_destino/frequencia.csv

for i in `ls $dir_fonte/*.html | grep -v notas | grep -v frequencia`
do
	dir=$(dirname $i)
	base=$(basename $i .html)
	periodo=$(echo $base | awk -F "-" '{ print $1 }')
	disciplina=$(echo $base | awk -F "-" '{ print $2 }')
	turma=$(echo $base | awk -F "-" '{ print $3 }')
	python $dir_parsers/turma-resumo.py $i >> $dir_destino/resumo.csv
	python $dir_parsers/turma-notas.py $dir/$base-notas.html | awk -v vd=$disciplina -v vt=$turma -v vp=$periodo '{ print vd";"vt";"vp";"$0 }' >> $dir_destino/nota.csv
	
	pagina=1
	while :
	do
		if [ $pagina -ne 1 ]; then
			output=frequencia_extra.tmp
		else
			output=frequencia_base.tmp
		fi
		python $dir_parsers/turma-frequencia.py $dir/$base-frequencia-$pagina.html | awk -v vd=$disciplina -v vt=$turma -v vp=$periodo '{ print vd";"vt";"vp";"$0 }' >> $dir_destino/$output
		pagina=$(expr $pagina + 1)
		test -f $dir/$base-frequencia-$pagina.html
		if [ $? -ne 0 ]; then
			break;
		fi
	done
done

rm -f $dir_destino/frequencia.csv
for i in $(seq 1 $(cat $dir_destino/frequencia_base.tmp | wc -l))
do
	linha=$(head -$i $dir_destino/frequencia_base.tmp | tail -1)
	disciplina=$(echo $linha | awk -F ";" '{ print $1 }')
	turma=$(echo $linha | awk -F ";" '{ print $2 }')
	periodo=$(echo $linha | awk -F ";" '{ print $3 }')
	matricula=$(echo $linha | awk -F ";" '{ print $4 }')
	extra_tmp=$(grep "$disciplina;$turma;$periodo;$matricula" $dir_destino/frequencia_extra.tmp | awk -F ";" '{for(i = 1; i<=NF; i++) if(i < 6) continue; else print(";"$i)}')
	extra=$(echo $extra_tmp | sed -e '/ /s,,,g')
	echo "$linha$extra" >> $dir_destino/frequencia.csv		 
done
rm $dir_destino/frequencia_base.tmp $dir_destino/frequencia_extra.tmp

