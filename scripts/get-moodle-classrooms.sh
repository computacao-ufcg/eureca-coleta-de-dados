#!/bin/bash

periodo=$1
credenciais=$2
dir_destino=$3
dir_scripts=$4

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino/$periodo $dir_destino/moodle

if [ ! -f $dir_destino/turmas-$periodo.html ]; then
	$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoDisciplinasOfertadasListar $dir_destino/turmas-$periodo.html $periodo
        python $dir_scripts/../parsers/turmas-ofertadas.py $dir_destino/turmas-$periodo.html | tr ';' '-' > $dir_destino/turmas-$periodo.csv
fi

rm -f $dir_destino/turmas-resumo-$periodo.csv $dir_destino/moodle/*.csv

for i in `cat $dir_destino/turmas-$periodo.csv`
do
	disciplina=$(echo $i | awk -F "-" '{ print $1 }')
        turma=$(echo $i | awk -F "-" '{ print $2 }')
	if [ ! -f $dir_destino/$periodo/resumo-$disciplina-$turma.html ]; then
        	$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaResumo\&codigo=$disciplina\&turma=$turma $dir_destino/$periodo/resumo-$disciplina-$turma.html $periodo
	fi
	if [ ! -f $dir_destino/$periodo/alunos-$disciplina-$turma.html ]; then
		$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaNotas\&codigo=$disciplina\&turma=$turma $dir_destino/$periodo/alunos-$disciplina-$turma.html $periodo
	fi
	python $dir_parsers/turma-resumo.py $dir_destino/$periodo/resumo-$disciplina-$turma.html >> $dir_destino/turmas-resumo-$periodo.csv
	python $dir_parsers/turma-notas.py $dir_destino/$periodo/alunos-$disciplina-$turma.html | awk -F ";" '{ print $1 }' > $dir_destino/moodle/$periodo-$disciplina-$turma.csv
done

cat $dir_destino/turmas-resumo-$periodo.csv | awk -F ";" '{ print $1";"$4";"$2";"$3 }' > $dir_destino/moodle-turmas-$periodo.csv
