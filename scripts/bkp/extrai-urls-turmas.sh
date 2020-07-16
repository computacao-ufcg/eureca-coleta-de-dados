#!/bin/bash

periodo=$1
dir_fonte=$2
dir_destino=$3

python /Users/fubica/Documents/fubica/ccc/src/report-matricula/src/parsers/turmas/turmas-ofertadas_parse.py $dir_fonte/turmas-$periodo.html | awk -F ";" '{ print "https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador?command=CoordenacaoTurmaResumo&codigo="$1"&turma="$2 }' > $dir_destino/url-turmas-$periodo.dat

