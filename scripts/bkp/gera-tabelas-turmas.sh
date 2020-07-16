#!/bin/bash

get_from_table() {
	pattern=$1
	table=$2

        if [ "$patternAA" = "AA" ] || [ "AA$pattern" = "AA-" ]; then
                echo "1"
        else
                echo "$(grep -n "$pattern" $table | head -1 | awk -F ":" '{ print $1 }')"
        fi
}

anonimize_mat() {
        if [ "$2AA" = "trueAA" ]; then
		matricula=$1
		a=$(echo $matricula | cut -c 2-3)
		t1=$(echo $matricula | cut -c 4-6)
		t2=$(echo $matricula | cut -c 7-9)
		prefix=$(echo $matricula | cut -c 1-4)
		seed1=$(expr $a + 1)
		seed2=$(expr $t1 + 1)
		seed=$(expr $seed1 \* $seed2)
		sufix1=$(expr $t2 + 1)
		sufix2=$(expr $sufix1 \* $seed)
        	sufix=$(printf %05d $(expr 1 + $sufix2 % 100000))
		echo $prefix$sufix
	else
		echo $1
	fi
}

dir_fonte=$1
dir_destino=$2
do_anonimize=$3

mkdir -p $dir_destino

cat $dir_fonte/resumo.csv | awk -F ";" '{ print $8 }' | sort | uniq > $dir_destino/horario.csv
cat $dir_fonte/resumo.csv | awk -F ";" '{ print $9 }' | sort | uniq > $dir_destino/sala.csv
cat $dir_fonte/resumo.csv | awk -F ";" '{ print $1";"$5";"$6";"$2 }' | tr -s ' ' | sort | uniq > $dir_destino/disciplina.csv
cat $dir_fonte/resumo.csv | awk -F ";" '{  print $3 }' | awk -F "," '{ print $1"\n"$2"\n"$3 }' | sort | uniq > $dir_destino/professor.csv

rm -f $dir_destino/turma.csv $dir_destino/turma_professor.csv
nlines=$(cat $dir_fonte/resumo.csv | wc -l)
if [ $nlines -ne 0 ]; then
	for i in $(seq 1 $nlines)
	do
        	line=$(head -$i $dir_fonte/resumo.csv | tail -1)
        	codigo=$(echo $line | awk -F ";" '{ print $1 }')
		nome=$(echo $line | awk -F ";" '{ print $2 }')
		professores=$(echo $line | awk -F ";" '{ print $3 }')
		turma=$(echo $line | awk -F ";" '{ print $4 }')
		creditos=$(echo $line | awk -F ";" '{ print $5 }')
		horas=$(echo $line | awk -F ";" '{ print $6 }')
		periodo=$(echo $line | awk -F ";" '{ print $7 }')
		horario_str=$(echo $line | awk -F ";" '{ print $8 }')
		horario=$(get_from_table "$horario_str" $dir_destino/horario.csv)
		sala_str=$(echo $line | awk -F ";" '{ print $9 }')
		sala=$(get_from_table "$sala_str" $dir_destino/sala.csv)
		codigo_disciplina=$(get_from_table "$codigo;$creditos;$horas;$nome" $dir_destino/disciplina.csv)
        	echo $codigo_disciplina";"$turma";"$periodo";"$horario";"$sala >> $dir_destino/turma.csv
		for j in `echo $professores | awk -F "," '{ print $1" "$2" "$3" "$4 }'`
		do
			echo "$i;$j" >> $dir_destino/turma_professor.csv
		done
	done
fi

rm -rf $dir_destino/aluno_disciplina.csv
max_nnotas=8
nlines=$(cat $dir_fonte/nota.csv | wc -l)
if [ $nlines -ne 0 ]; then
	for i in $(seq 1 $nlines)
	do
		line=$(head -$i $dir_fonte/nota.csv | tail -1)
        	codigo=$(echo $line | awk -F ";" '{ print $1 }')
		turma=$(echo $line | awk -F ";" '{ print $2 }')
		periodo=$(echo $line | awk -F ";" '{ print $3 }')
		matricula=$(echo $line | awk -F ";" '{ print $4 }')
		anonimo=$(anonimize_mat $matricula $do_anonimize)
		ncampos=$(echo $line | awk -F ";" '{ print NF }')
		notas=""
		nnotas=$(expr $max_nnotas - $(expr 17 - $ncampos))
		ultima=$(expr 5 + $nnotas)
		for j in $(seq 6 $(expr $max_nnotas + 5))
		do
			if [ "$j" -le "$ultima" ]; then
				notas=$notas";"$(echo $line | awk -F ";" -v index=$j '{ print $index }')
			else
				notas=$notas";"
			fi
		done
		parcial=$(echo $line | awk -F ";" '{ print $(NF-3) }')
		final=$(echo $line | awk -F ";" '{ print $(NF-2) }')
		media=$(echo $line | awk -F ";" '{ print $(NF-1) }')
#		obs=$(echo $line | awk -F ";" '{ print $NF }')
		codigo_disciplina=$(get_from_table "$codigo;$creditos;$horas" $dir_destino/disciplina.csv)
		codigo_turma=$(get_from_table "$codigo_disciplina;$turma;$periodo" $dir_destino/turma.csv)
		faltas=$(grep "^$codigo;$turma;$periodo;$matricula" $dir_fonte/frequencia.csv | tail -1 | awk -F ";" '{ print $5 }')
		situacao=$(grep "$matricula;$codigo;$periodo" $dir_fonte/disciplinas.csv | awk -F ";" '{ print $9 }')
		echo "situacao[$matricula;$codigo;$periodo]:[$situacao]"
		situacao_id=$(get_from_table "$situacao" $dir_destino/../discentes/situacao_disciplina.csv)
		echo "situacao_id[$situacao]:[$situacao_id]"
		echo $anonimo";"$codigo_turma";"$faltas$notas";"$parcial";"$final";"$media";"$situacao >> $dir_destino/aluno_disciplina.csv
	done
fi


