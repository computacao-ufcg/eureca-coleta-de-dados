#!/bin/bash

dir_base=$1
periodo=$2
prof_file=$3

rm -f /tmp/prof-alunos.list
for i in `cat $dir_base/turmas-$periodo.csv`
do
	codigo=`echo $i | awk -F '-' '{ print $1 }'`
	turma=`echo $i | awk -F '-' '{ print $2 }'`
	n_alunos=`cat $dir_base/moodle/$periodo-$codigo-$turma.csv | wc -l | sed 's., .,.'`
	professores=`cat $dir_base/moodle-turmas-$periodo.csv | grep $codigo";"$turma | awk -F ';' '{ print $4 }'`
	n_prof=`echo $professores | awk -F ',' '{ print NF }'`
	alunos_por_professor=`echo "scale=1; $n_alunos/$n_prof" | bc`
	echo $professores | awk -F ',' -v n=$alunos_por_professor '{ for(i=1; i<=NF; i++) print $i":"n }' >> /tmp/prof-alunos.list 
done

for i in `cat /tmp/prof-alunos.list | awk -F ':' '{ print $1 }' | sort | uniq`
do
	n_alunos=0
	for j in `cat /tmp/prof-alunos.list | grep "^$i" | awk -F ':' '{ print $2 }'`
	do
		n_alunos=`echo "scale=1; $n_alunos+$j" | bc`
	done
	line=`grep "^$i" $prof_file`
	if [ $? -eq 0 ]; then
		echo $n_alunos","`echo $line | awk -F ';' '{ print $2 }'`
	fi
done
rm /tmp/prof-alunos.list
