#!/bin/bash

matriculas=$1
credencial=$2
dir_destino=$3
dir_scripts=$4

mkdir -p $dir_destino

for i in `cat $matriculas`
do
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoHistorico\&matricula=$i $dir_destino/$i-historico.html "qualquer-periodo"
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoCadastro\&matricula=$i $dir_destino/$i-cadastro.html "qualquer-periodo"
done

