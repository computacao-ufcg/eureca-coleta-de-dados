#!/bin/bash

# Este script recebe como parametros um código, três arquivos e um diretório. O primeiro parâmetro é o código
# do curso (ex. 14102100 é o código de Ciência da Computação). O segundo parâmetro é um arquivo que contém a
# lista de matriculas (uma por linha) dos discentes cujos dados serão coletados. O terceiro parâmetro é um
# arquivo que contém a lista de periodos (um por linha) no formato (AAAA.P, ex. 2020.1) cujos dados serão
# coletados. O quarto parâmetro é o arquivo que contém a credencial da coordenacao para acesso ao SCAO.
# O quinto parâmetro é o nome do diretório onde os dados coletados serão armazenados.

print_sintax() {
	echo "Sintaxe: $0 matriculas periodos credencial dir_destino [true]"
	exit 1
}
 
if [ $# -ne 4 ] && [ $# -ne 5 ]; then 
	print_sintax
fi

curso=$1
matriculas=$2
periodos=$3
credencial=$4
dir_destino=$5

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

echo "$(date): Crawling $matriculas e $periodos"
$dir_scripts/novo-crawl.sh $matriculas $periodos $credencial $dir_destino/html $dir_scripts

echo "$(date): Extraindo dados dos arquivos .html"
$dir_scripts/novo-extrai-dados.sh $curso $dir_destino/html $dir_destino/input $dir_scripts

echo "$(date): Processamento concluido; tabelas disponiveis em $dir_destino"
