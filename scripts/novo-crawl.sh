#!/bin/bash

function process_line() {
        $@
}

function process_turmas() {
	periodo=$1
	credencial=$2
	dir_destino=$3
	dir_scripts=$4
        linha=$5

	disciplina=$(echo $linha | awk -F ";" '{ print $1 }')
	turma=$(echo $linha | awk -F ";" '{ print $2 }')
	$dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaResumo\&codigo=$disciplina\&turma=$turma $dir_destino/turmas/$periodo/$periodo-$disciplina-$turma.html $periodo
	$dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoTurmaNotas\&codigo=$disciplina\&turma=$turma $dir_destino/turmas/$periodo/$periodo-$disciplina-$turma-notas.html $periodo
}

export -f process_line
export -f process_turmas

matriculas=$1
periodos=$2
login=$3
dir_destino=$4
dir_scripts=$5

mkdir -p $dir_destino/discentes

credencial=$dir_destino/credencial
touch $credencial
chmod 600 $credencial
cat $login | sed -e 's,$,\,CoordenacaoLogin,' > $credencial

for i in `cat $matriculas`
do
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoHistorico\&matricula=$i $dir_destino/discentes/$i-historico.html "qualquer-periodo"
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoAlunoCadastro\&matricula=$i $dir_destino/discentes/$i-cadastro.html "qualquer-periodo"
done

mkdir -p $dir_destino/turmas

for i in `cat $periodos`
do
	mkdir -p $dir_destino/turmas/$i
        $dir_scripts/crawler.sh $credencial https://pre.ufcg.edu.br:8443/ControleAcademicoOnline/Controlador\?command=CoordenacaoDisciplinasOfertadasListar $dir_destino/$i-turmas-ofertadas.html $i
        python $dir_scripts/../parsers/turmas-ofertadas.py $dir_destino/$i-turmas-ofertadas.html > $dir_destino/turmas.tmp
	cat $dir_destino/turmas.tmp | awk -v p=$i -v c=$credencial -v d=$dir_destino -v s=$dir_scripts '{ system("bash -c '\'' process_line process_turmas \""p"\" \""c"\" \""d"\" \""s"\" \""$0"\" '\'' ") }'
	rm $dir_destino/$i-turmas-ofertadas.html
done
rm $dir_destino/turmas.tmp
