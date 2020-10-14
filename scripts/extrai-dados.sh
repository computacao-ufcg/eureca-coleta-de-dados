#!/bin/bash

function process_line() {
        $@
}

function process_frequencia() {
        dir_destino=$(echo $@ | awk -F ";" '{ print $1 }')
        disciplina=$(echo $@ | awk -F ";" '{ print $2 }')
        turma=$(echo $@ | awk -F ";" '{ print $3 }')
        periodo=$(echo $@ | awk -F ";" '{ print $4 }')
        matricula=$(echo $@ | awk -F ";" '{ print $5 }')
        faltas=$(echo $@ | awk -F ";" '{ print $6 }')
        aulas_p1=$(echo $@ | awk -F ";" '{ for(i=7; i<=NF; i++) print $i";" }' | tr -s '\n' ' ' | sed -e '/; /s,,;,g')
        aulas_outras=$(grep "$disciplina;$turma;$periodo;$matricula" $dir_destino/frequencia_extra.tmp | awk -F ";" '{for(i = 1; i<=NF; i++) if(i < 6) continue; else print($i";")}' | tr -s '\n' ' ' | sed -e '/; /s,,;,g')
        aulas=$(echo "$aulas_p1$aulas_outras" | sed -e '/;$/s,,,')
        creditos=$(grep "$disciplina;$periodo" $dir_destino/disciplinas.csv | head -1 | awk -F ";" '{ print $4 }')
        horas=$(grep "$disciplina;$periodo" $dir_destino/disciplinas.csv | head -1 | awk -F ";" '{ print $5 }')
        echo "$disciplina;$turma;$periodo;$matricula;$creditos;$horas;$faltas;$aulas" | sed -e '/;$/s,,,' >> $dir_destino/frequencia.csv
}

export -f process_line
export -f process_frequencia

dir_fonte=$1
dir_destino=$2
dir_scripts=$3

dir_parsers=$dir_scripts/../parsers

rm -f $dir_destino/cadastro.csv $dir_destino/historico.csv $dir_destino/disciplinas.csv $dir_destino/vinculo.csv

mkdir -p $dir_destino

ls $dir_fonte/discentes | grep cadastro | awk -F "-" '{ print $1 }' > $dir_destino/matriculas.dat 

for i in `cat $dir_destino/matriculas.dat`
do
	python $dir_parsers/discente-cadastro.py $dir_fonte/discentes/$i-cadastro.html >> $dir_destino/cadastro.csv
	python $dir_parsers/discente-historico.py $dir_fonte/discentes/$i-historico.html >> $dir_destino/historico.csv
	python $dir_parsers/discente-disciplinas.py $dir_fonte/discentes/$i-historico.html > $dir_destino/disciplinas.tmp
	cat $dir_destino/disciplinas.tmp | awk -F ";" -v m=$i '{ print m";"$1";"$8";"$4";"$5";"$2";"$3";"$6";"$7 }' >> $dir_destino/disciplinas.csv
	python $dir_parsers/discente-vinculo.py $dir_fonte/discentes/$i-historico.html >> $dir_destino/vinculo.csv
done

rm -f $dir_destino/matriculas.dat $dir_destino/disciplinas.tmp

rm -rf $dir_destino/resumo.csv $dir_destino/nota.csv $dir_destino/frequencia.csv

for k in $(ls $dir_fonte/turmas)
do
	for i in $(ls $dir_fonte/turmas/$k/*.html | grep -v notas | grep -v frequencia)
	do
		dir=$(dirname $i)
		base=$(basename $i .html)
		periodo=$(echo $base | awk -F "-" '{ print $1 }')
		disciplina=$(echo $base | awk -F "-" '{ print $2 }')
		turma=$(echo $base | awk -F "-" '{ print $3 }')
		python $dir_parsers/turma-resumo.py $i >> $dir_destino/resumo.csv
		python $dir_parsers/turma-notas.py $dir/$base-notas.html | awk -v vd=$disciplina -v vt=$turma -v vp=$periodo '{ print vd";"vt";"vp";"$0 }' >> $dir_destino/nota.csv
	
		pagina=1
		while :
		do
			if [ $pagina -ne 1 ]; then
				output=frequencia_extra.tmp
			else
				output=frequencia_base.tmp
			fi
			python $dir_parsers/turma-frequencia.py $dir/$base-frequencia-$pagina.html | awk -v vd=$disciplina -v vt=$turma -v vp=$periodo '{ print vd";"vt";"vp";"$0 }' | sed -e '/;$/s,,,' >> $dir_destino/$output
			pagina=$(expr $pagina + 1)
			test -f $dir/$base-frequencia-$pagina.html
			if [ $? -ne 0 ]; then
				break;
			fi
		done
	done
done

rm -f $dir_destino/frequencia.csv
cat $dir_destino/frequencia_base.tmp | awk -v d=$dir_destino '{ system("bash -c '\'' process_line process_frequencia \""d";"$0"\" '\'' ") }'
rm $dir_destino/frequencia_base.tmp $dir_destino/frequencia_extra.tmp

