#!/bin/bash

dir_fonte=$1
dir_destino=$2
dir_scripts=$3

dir_parsers=$dir_scripts/../parsers

#mkdir -p $dir_destino

#rm -f $dir_destino/*.tmp 
#rm -f $dir_destino/students.data
#rm -f $dir_destino/classes.data
#rm -f $dir_destino/enrollments.data

ls $dir_fonte/discentes | grep cadastro | awk -F "-" '{ print $1 }' > $dir_destino/matriculas.tmp 

#for i in `cat $dir_destino/matriculas.tmp`
#do
#	python $dir_parsers/discente-cadastro.py $dir_fonte/discentes/$i-cadastro.html > $dir_destino/cadastro.tmp
#	python $dir_parsers/discente-historico.py $dir_fonte/discentes/$i-historico.html > $dir_destino/historico.tmp
#	paste -d ";" $dir_destino/cadastro.tmp $dir_destino/historico.tmp >> $dir_destino/students.data
#done

#for k in $(ls $dir_fonte/turmas)
#do
#	for i in $(ls $dir_fonte/turmas/$k/*.html | grep -v notas | grep -v frequencia)
#	do
#		dir=$(dirname $i)
#		base=$(basename $i .html)
#		periodo=$(echo $base | awk -F "-" '{ print $1 }')
#		disciplina=$(echo $base | awk -F "-" '{ print $2 }')
#		turma=$(echo $base | awk -F "-" '{ print $3 }')
#		python $dir_parsers/turma-resumo.py $i | awk -F ";" '{ print $1";"$7";"$4";"$3 }' >> $dir_destino/classes.data
#		python $dir_parsers/turma-notas.py $dir/$base-notas.html | awk -F ";" -v vd=$disciplina -v vt=$turma -v vp=$periodo '{ print $1"-"vd"-"vp";"vt }' >> $dir_destino/index.tmp
#	done
#done

rm -f $dir_destino/debug.tmp $dir_destino/debug.log

for i in `cat $dir_destino/matriculas.tmp`
do
        python $dir_parsers/discente-disciplinas.py $dir_fonte/discentes/$i-historico.html | grep ";Dispensa;" | awk -F ";" -v m=$i '{ print m";"$1";"$8";"$4";"$6";"$7 }' > $dir_destino/enrollments.tmp
	cat $dir_destino/enrollments.tmp >> $dir_destino/debug.tmp
	cat $dir_destino/enrollments.tmp | awk -F ";" '{ print $1";"$2";"$3 }' > $dir_destino/p1.tmp
	cat $dir_destino/enrollments.tmp | awk -F ";" '{ print $4";"$5";"$6 }' > $dir_destino/p3.tmp
	size=$(ls -l $dir_destino/p1.tmp | awk '{ print $5 }')
	if [ $size -ne 0 ]; then
		rm -f $dir_destino/p2.tmp
		cat $dir_destino/p1.tmp | awk -F ";" '{ print $1"-"$2"-"$3 }' > $dir_destino/keys.tmp
		for j in $(cat $dir_destino/keys.tmp)
		do
			grep "$j" $dir_destino/index.tmp > $dir_destino/class.tmp
			if [ $? -eq 0 ]; then
				class=$(cat $dir_destino/class.tmp | awk -F ";" '{ print $2 }' | tail -1)
				if [ "AA$class" = "AA" ]; then
					echo "$j sem turma" >> $dir_destino/debug.log
					echo "00" >> $dir_destino/p2.tmp
				else
					echo $class >> $dir_destino/p2.tmp
				fi
			else
				echo "$j sem match em index" >> $dir_destino/debug.log
				echo "00" >> $dir_destino/p2.tmp
			fi
		done
		echo "$j; $(wc -l $dir_destino/p1.tmp | tr '\n' ';') $(wc -l $dir_destino/p2.tmp)" >> $dir_destino/debug.log
		paste -d ";" $dir_destino/p1.tmp $dir_destino/p2.tmp $dir_destino/p3.tmp >> $dir_destino/enrollments.data
	fi
done

#rm -f $dir_destino/*.tmp
