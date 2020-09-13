#!/bin/bash

matriculas=$1
credenciais=$2
periodo=$3
dir_destino=$4
dir_scripts=$5

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino

for i in `cat $matriculas`
do
	if [ ! -f $dir_destino/$i.html ]; then
		$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoHistorico\&matricula=$i $dir_destino/$i.html $periodo
	fi	
	cra=$(python $dir_parsers/discente-historico.py $dir_destino/$i.html | awk -F ";" '{ print $8 }')
	echo $i";"$cra
done

