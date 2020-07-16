#!/bin/bash

periodos=$1
credencial=$2
dir_destino=$3
dir_scripts=$4

mkdir -p $dir_destino

for i in `cat $periodos`
do
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoDisciplinasOfertadasListar $dir_destino/$i-turmas-ofertadas.html $i
        python $dir_scripts/../parsers/turmas-ofertadas.py $dir_destino/$i-turmas-ofertadas.html > $dir_destino/turmas.tmp
        for j in $(seq 1 $(cat $dir_destino/turmas.tmp | wc -l))
        do
                linha=$(head -$j $dir_destino/turmas.tmp | tail -1)
                disciplina=$(echo $linha | awk -F ";" '{ print $1 }')
                turma=$(echo $linha | awk -F ";" '{ print $2 }')
                $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaResumo\&codigo=$disciplina\&turma=$turma $dir_destino/$i-$disciplina-$turma.html $i
                $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaNotas\&codigo=$disciplina\&turma=$turma $dir_destino/$i-$disciplina-$turma-notas.html $i

                pagina=1
                $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaFrequencia\&codigo=$disciplina\&turma=$turma\&p=$pagina $dir_destino/$i-$disciplina-$turma-frequencia-$pagina.html $i
                while :
                do
                        pagina_anterior=$pagina
                        pagina=$(expr $pagina + 1)
                        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaFrequencia\&codigo=$disciplina\&turma=$turma\&p=$pagina $dir_destino/$i-$disciplina-$turma-frequencia-$pagina.html $i
                        s=$(diff $dir_destino/$i-$disciplina-$turma-frequencia-$pagina.html $dir_destino/$i-$disciplina-$turma-frequencia-$pagina_anterior.html | wc -l)
                        if [ $s -eq 0 ]; then
                                rm $dir_destino/$i-$disciplina-$turma-frequencia-$pagina.html
                                break;
                        fi
                done
        done
	rm $dir_destino/$i-turmas-ofertadas.html
done
rm $dir_destino/turmas.tmp
