#!/bin/bash

# Este script recebe como parametros tres arquivos, um diretorio e, opcionalmente, um flag que indica que e
# preciso anonimizar os campos sensiveis das tabelas a serem geradas. O primeiro arquivo tem a lista de matriculas
# (uma por linha) dos discentes cujos dados serao coletados. O segundo arquivo tem a lista de periodos (um por
# linha) no formato (AAAA.P, ex. 2020.1) cujos dados serao coletados. O terceiro arquivo tem a credencial da
# coordenacao para acesso ao SCAO. O formato desse arquivo e o seguinte: username,password,CoordenacaoLogin.
# O quarto parametro e o nome do diretorio onde os dados coletados serao armazenados. Se o quinto parametro
# nao for passado ou for passado com um valor diferente de true, os campos nao serao anonimizados.

print_sintax() {
	echo "Sintaxe: $0 matriculas periodos credencial dir_destino [true]"
	exit 1
}
 
if [ $# -ne 4 ] && [ $# -ne 5 ]; then 
	print_sintax
fi

matriculas=$1
periodos=$2
credencial=$3
dir_destino=$4
do_anonimize=$5

dir_scripts=$(dirname $0)

test -f $matriculas
if [ $? -ne 0 ]; then
	echo "O arquivo $matriculas nao existe."
	print_sintax
fi

test -f $periodos
if [ $? -ne 0 ]; then
        echo "O arquivo $periodos nao existe."
        print_sintax
fi

test -f $credencial
if [ $? -ne 0 ]; then
        echo "O arquivo $credencial nao existe."
        print_sintax
fi

# Crawling dados dos discentes
echo "Crawling $matriculas"
$dir_scripts/crawl-discentes.sh $matriculas $credencial $dir_destino/html/discentes $dir_scripts

# Crawling dados das turmas
echo "Crawling $periodos"
$dir_scripts/crawl-turmas.sh $periodos $credencial $dir_destino/html/turmas $dir_scripts

echo "Extraindo dados de discentes"
$dir_scripts/extrai-dados-discentes.sh $matriculas $dir_destino/html/discentes $dir_destino/tabelas $dir_scripts

echo "Extraindo dados de turmas"
$dir_scripts/extrai-dados-turmas.sh $dir_destino/html/turmas $dir_destino/tabelas $dir_scripts

echo "Gerando tabelas de discentes"
$dir_scripts/gera-tabelas-discentes.sh $dir_destino/tabelas $dir_destino/tabelas/discentes $do_anonimize

echo "Gerando tabelas de turmas"
$dir_scripts/gera-tabelas-turmas.sh $dir_destino/tabelas $dir_destino/tabelas/turmas $do_anonimize
