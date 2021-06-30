#!/bin/bash

matriculas=$1
credenciais=$2
dir_destino=$3
dir_scripts=$4

dir_parsers=$dir_scripts/../parsers

mkdir -p $dir_destino
rm -f $dir_destino/cadastro.csv

for i in `cat $matriculas`
do
	echo "crawling $i"
	if [ ! -f $dir_destino/$i-cadastro.html ]; then
		$dir_scripts/crawler.sh $credenciais https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoCadastro\&matricula=$i $dir_destino/$i-cadastro.html $periodo
	fi
done

for i in `cat $matriculas`
do
	echo "extracting $i"
	python $dir_parsers/discente-cadastro.py $dir_destino/$i-cadastro.html >>  $dir_destino/cadastro.csv
done

cat $dir_destino/cadastro.csv |  awk -F ";" '{ print $1","$7","$3","$10 }' | awk -F "/" '{ print $1 $2 $3 }' | awk '{ print $1","; for(i=2; i<=NF; i++) print $i }' | tr '\n' ' ' | sed -e 's., .,.g' | sed -e 's. 1.#1.g' | tr '#' '\n' > $dir_destino/credenciais.csv

