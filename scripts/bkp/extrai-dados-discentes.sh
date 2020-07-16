#!/bin/bash

matriculas=$1
dir_fonte=$2
dir_destino=$3
dir_scripts=$4

dir_parsers=$dir_scripts/../parsers

rm -f $dir_destino/cadastro.csv $dir_destino/historico.csv $dir_destino/disciplinas.csv $dir_destino/vinculo.csv

mkdir -p $dir_destino

for i in `cat $matriculas`
do
	python $dir_parsers/discente-cadastro.py $dir_fonte/$i-cadastro.html >> $dir_destino/cadastro.csv
	python $dir_parsers/discente-historico.py $dir_fonte/$i-historico.html >> $dir_destino/historico.csv
	python $dir_parsers/discente-disciplinas.py $dir_fonte/$i-historico.html > $dir_destino/disciplinas.tmp
	cat $dir_destino/disciplinas.tmp | awk -F ";" -v m=$i '{ print m";"$1";"$8";"$4";"$5";"$2";"$3";"$6";"$7 }' >> $dir_destino/disciplinas.csv
	python $dir_parsers/discente-vinculo.py $dir_fonte/$i-historico.html >> $dir_destino/vinculo.csv
done

