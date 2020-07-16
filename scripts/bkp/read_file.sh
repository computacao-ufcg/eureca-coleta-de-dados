#!/bin/bash

function process_line() {
	echo "Running: $@"
	$@
}

get_from_table() {
        pattern=$1
        table=$2

        if [ "$patternAA" = "AA" ] || [ "AA$pattern" = "AA-" ]; then
                echo "1"
        else
                echo "$(grep -n "$pattern" $table | head -1 | awk -F ":" '{ print $1 }')"
        fi
}

function process_resumo() {
	my_dir_fonte=$1
	my_dir_destino=$2
	line=$3
	echo "destino[$my_dir_destino]"
	echo "line[$line]"
	echo "fonte[$my_dir_fonte]"
}

export -f process_line
export -f process_resumo

dir_fonte=$1
dir_destino=$2
input=$3

cat $input | awk -v fonte=$dir_fonte -v dest=$dir_destino '{ system("bash -c '\'' process_line process_resumo \""fonte"\" \""dest"\" \""$0"\" '\'' ") }'

