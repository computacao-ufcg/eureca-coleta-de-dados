#!/bin/bash

matriculas=$1
grupo=$2
properties=$3
map=$4
dir_destino=$5
dir_scripts=$6

dir_parsers=../parsers

cp $dir_destino/$grupo.fixed.csv $dir_destino/novo-$grupo.csv

for i in `cat $matriculas`
do
	$dir_scripts/crawler.sh $properties https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoCadastro\&matricula=$i $dir_destino/$i-cadastro.html
	line=`python $dir_parsers/discente-cadastro.py $dir_destino/$i-cadastro.html`
	matricula=`echo $line | awk -F ";" '{ print $1 }'`
	email1=`echo $line | awk -F ";" '{ print $10 }'`
	email2=`grep $matricula $map | awk -F ";" '{ print $2 }'`
	nome=`echo $line | awk -F ";" '{ print $3 }'`
	if [ "AA"$email1 != "AA" ]; then
		echo "$grupo@ccc.ufcg.edu.br,"$email1","$nome",MEMBER,USER" >> $dir_destino/novo-$grupo.csv
	else
		if [ "AA"$email2 != "AA" ]; then
			echo "$grupo@ccc.ufcg.edu.br,"$email2","$nome",MEMBER,USER" >> $dir_destino/novo-$grupo.csv
		else
			echo "Sem e-mail para $matricula: [$email1][$email2]"
		fi
	fi
	rm $dir_destino/$i-cadastro.html
done