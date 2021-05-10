#!/bin/bash

matriculas=$1
credenciais=$2
periodo=$3
dir_destino=$4
dir_scripts=$5
tipo=$6

if [ $tipo"AA" = "AA" ]; then
	tipo="Curso"
fi 

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino

for i in `cat $matriculas`
do
	echo $i
	$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoHistorico\&matricula=$i $dir_destino/$i.html $periodo	
	python $dir_parsers/discente-disciplinas.py $dir_destino/$i.html | grep $periodo$ | grep $tipo | awk -F ";" '{ print $1";"$2 }' | sort >  $dir_destino/$i-$periodo.csv
done

