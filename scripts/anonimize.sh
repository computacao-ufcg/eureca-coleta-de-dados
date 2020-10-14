#!/bin/bash

function process_line() {
        $@
}

function generate_cpf() {
        printf %011d $(expr 1 + $(openssl rand 4 | od -DAn) % 100000000000)
}

function anonimize_cpf() {
	p1=$(echo $1 | cut -c 1-3)
	p2=$(echo $1 | cut -c 4-6)
	p3=$(echo $1 | cut -c 7-9)
	p4=$(echo $1 | cut -c 10-11)
	echo $p4$p3$p1$p2
}

function anonimize_mat() {
        if [ "$1" = "113112447" ]; then
                echo "113108738"
                exit 0
        fi
	if [ "$1" = "115211093" ]; then
		echo "115218850"
		exit 0
	fi
        if [ "$1" = "115211312" ]; then
                echo "115261698"
                exit 0
        fi
	if [ "AA$2" = "AAtrue" ]; then
		matricula=$1
		a=$(echo $matricula | cut -c 2-3)
		t1=$(echo $matricula | cut -c 4-6)
		t2=$(echo $matricula | cut -c 7-9)
		prefix=$(echo $matricula | cut -c 1-4)
		seed1=$(expr $a + 1)
		seed2=$(expr $t1 + 1)
		seed=$(expr $seed1 \* $seed2)
		sufix1=$(expr $t2 + 1)
		sufix2=$(expr $sufix1 \* $seed)
        	sufix=$(printf %05d $(expr 1 + $sufix2 % 100000))
		echo $prefix$sufix
	else
		echo $1
	fi
}

function anonimize_nome() {
	if [ "AA$2" = "AAtrue" ]; then
		echo ""
	else
		echo $1
	fi
}

function anonimize_email() {
        if [ "AA$2" = "AAtrue" ]; then
                echo "anonimo@ccc.ufcg.edu.br"
        else
                echo $1
        fi
}

function anonimize_input_cadastro() {
        dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
        do_anonimize=$(echo $@ | awk -F ";" '{ print $2 }')
	mat=$(echo $@ | awk -F ";" '{ print $3 }')
        anonimo=$(anonimize_mat $mat $do_anonimize)
	cpf=$(echo $@ | awk -F ";" '{ print $4 }')
	if [ "AA$cpf" = "AA" ]; then
		cpf=$(generate_cpf)
	fi
	if [ "AA$do_anonimize" = "AAtrue" ]; then
		cpf=$(anonimize_cpf $cpf)
	fi
	nome=$(anonimize_nome "$(echo $@ | awk -F ";" '{ print $5 }')" $do_anonimize)	
	suffixA=$(echo $@ | awk -F ";" '{ for(i=6; i<=11; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g' | sed -e 's, $,,')
	suffixB=$(echo $@ | awk -F ";" '{ for(i=13; i<=NF; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g' | sed -e 's, $,,')
	email=$(anonimize_email "$(echo $@ | awk -F ";" '{ print $12 }')" $do_anonimize)
	echo "$anonimo;$cpf;$nome$suffixA;$email$suffixB" >> $dir_fonte/cadastro.csv
}

function anonimize_input_disciplinas() {
        dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
        do_anonimize=$(echo $@ | awk -F ";" '{ print $2 }')
	mat=$(echo $@ | awk -F ";" '{ print $3 }')
	anonimo=$(anonimize_mat $mat $do_anonimize)
        suffix=$(echo $@ | awk -F ";" '{ for(i=4; i<=NF; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g')
	echo "$anonimo$suffix" >> $dir_fonte/disciplinas.csv
}

function anonimize_input_nota() {
        dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
        do_anonimize=$(echo $@ | awk -F ";" '{ print $2 }')
	prefix=$(echo $@ | awk -F ";" '{ for(i=3; i<=5; i++) print $i";" }' | tr -s '\n' ' ' | sed -e '/; /s,,;,g')
	mat=$(echo $@ | awk -F ";" '{ print $6 }')
	anonimo=$(anonimize_mat $mat $do_anonimize)
	nome=$(anonimize_nome "$(echo $@ | awk -F ";" '{ print $7 }')" $do_anonimize)
	suffix=$(echo $@ | awk -F ";" '{ for(i=8; i<=NF; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g')
	echo "$prefix$anonimo;$nome$suffix" >> $dir_fonte/nota.csv
}

function anonimize_input_vinculo() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	do_anonimize=$(echo $@ | awk -F ";" '{ print $2 }')
	mat1=$(echo $@ | awk -F ";" '{ print $3 }')
	mat2=$(echo $@ | awk -F ";" '{ print $4 }')
	anonimo1=$(anonimize_mat $mat1 $do_anonimize)
	anonimo2=$(anonimize_mat $mat2 $do_anonimize)
	suffix=$(echo $@ | awk -F ";" '{ for(i=5; i<=NF; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g')
	echo "$anonimo1;$anonimo2$suffix" >> $dir_fonte/vinculo.csv 
}

function anonimize_input_frequencia() {
        dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
        do_anonimize=$(echo $@ | awk -F ";" '{ print $2 }')
	prefix=$(echo $@ | awk -F ";" '{ for(i=3; i<=5; i++) print $i";" }' | tr -s '\n' ' ' | sed -e '/; /s,,;,g')
        mat=$(echo $@ | awk -F ";" '{ print $6 }')
        anonimo=$(anonimize_mat $mat $do_anonimize)
        suffix=$(echo $@ | awk -F ";" '{ for(i=7; i<=NF; i++) print ";"$i }' | tr -s '\n' ' ' | sed -e '/ ;/s,,;,g')
        echo "$prefix$anonimo$suffix" >> $dir_fonte/frequencia.csv
}

export -f process_line
export -f generate_cpf
export -f anonimize_cpf
export -f anonimize_mat
export -f anonimize_nome
export -f anonimize_email
export -f anonimize_input_cadastro
export -f anonimize_input_disciplinas
export -f anonimize_input_nota
export -f anonimize_input_vinculo
export -f anonimize_input_frequencia

dir_fonte=$1
do_anonimize=$2

mv $dir_fonte/cadastro.csv $dir_fonte/cadastro.ori
cat $dir_fonte/cadastro.ori | sed -e "/\'/s,,,g" | awk -v f=$dir_fonte -v a=$do_anonimize '{ system("bash -c '\'' process_line anonimize_input_cadastro \""f";"a";"$0"\" '\'' ") }'

mv $dir_fonte/disciplinas.csv $dir_fonte/disciplinas.ori
cat $dir_fonte/disciplinas.ori | sed -e "/\'/s,,,g" | awk -v f=$dir_fonte -v a=$do_anonimize '{ system("bash -c '\'' process_line anonimize_input_disciplinas \""f";"a";"$0"\" '\'' ") }'

mv $dir_fonte/vinculo.csv $dir_fonte/vinculo.ori
cat $dir_fonte/vinculo.ori | sed -e "/\'/s,,,g" | awk -v f=$dir_fonte -v a=$do_anonimize '{ system("bash -c '\'' process_line anonimize_input_vinculo \""f";"a";"$0"\" '\'' ") }'

mv $dir_fonte/nota.csv $dir_fonte/nota.ori
cat $dir_fonte/nota.ori | sed -e "/\'/s,,,g" | awk -v f=$dir_fonte -v a=$do_anonimize '{ system("bash -c '\'' process_line anonimize_input_nota \""f";"a";"$0"\" '\'' ") }'

mv $dir_fonte/frequencia.csv $dir_fonte/frequencia.ori
cat $dir_fonte/frequencia.ori | awk -v f=$dir_fonte -v a=$do_anonimize '{ system("bash -c '\'' process_line anonimize_input_frequencia \""f";"a";"$0"\" '\'' ") }'

# Sanity checking
nreg=$(cat $dir_fonte/cadastro.csv | wc -l)
uniq_mat=$(cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $1 }' | sort | uniq | wc -l)

if [ $nreg -ne $uniq_mat ]; then
        echo "Failed: $nreg registros, $uniq_mat matriculas"
        exit 1
fi

