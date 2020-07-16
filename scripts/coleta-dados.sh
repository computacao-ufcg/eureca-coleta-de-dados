#!/bin/bash

# Este script recebe como parametros tres arquivos, um diretorio e, opcionalmente, uma flag que indica que
# eh preciso anonimizar os campos sensiveis das tabelas a serem geradas. O primeiro arquivo contém a lista
# de matriculas (uma por linha) dos discentes cujos dados serao coletados. O segundo arquivo contém a lista
# de periodos (um por linha) no formato (AAAA.P, ex. 2020.1) cujos dados serao coletados. O terceiro arquivo
# contém a credencial da coordenacao para acesso ao SCAO. O formato desse arquivo e o seguinte: 
# <usuario>,<senha>,CoordenacaoLogin
# O quarto parametro eh o nome do diretorio onde os dados coletados serao armazenados. Se o quinto parametro
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
if [ $# -eq 4 ]; then
	do_anonimize=false
else
	do_anonimize=$5
fi

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

periodo_atual=$(tail -1 $periodos)

# Crawling dos arquivos .html
echo "$(date): Crawling $matriculas e $periodos"
$dir_scripts/crawl.sh $matriculas $periodos $credencial $dir_destino/html $dir_scripts

echo "$(date): Extraindo dados dos arquivos .html"
$dir_scripts/extrai-dados.sh $dir_destino/html $dir_destino/input $dir_scripts

echo "$(date): Anononimzando os dados de entrada (se necessario) e gerando cpfs quando esse campo estiver vazio"
$dir_scripts/anonimize.sh $dir_destino/input $do_anonimize
if [ $? -ne 0 ]; then
	exit 1
fi

echo "$(date): Gerando tabelas"
$dir_scripts/gera-tabelas.sh $dir_destino/input $dir_destino/tabelas $periodo_atual

