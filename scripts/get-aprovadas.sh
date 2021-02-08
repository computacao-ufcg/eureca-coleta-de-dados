#!/bin/bash

matriculas=$1
credenciais=$2
dir_destino=$3
dir_scripts=$4

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino

for i in `cat $matriculas`
do
	echo $i
	$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoHistorico\&matricula=$i $dir_destino/$i.html	
	python $dir_parsers/discente-disciplinas.py $dir_destino/$i.html | grep -v "Em Curso" | grep -v "Trancado" | grep -v "Reprovado" | grep -v "Cancelado" | awk -F ";" '{ print $1 }' | sort >  $dir_destino/$i-aprovadas.csv
done

