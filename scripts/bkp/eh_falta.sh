#!/bin/bash

function eh_falta() {
   	if [ "$1" -eq "1" ]; then
		echo "$2;$3;$4"
	fi
}

export -f eh_falta

cat $1 | awk -F ";" '{ for(i=6; i<=NF; i++) { system("bash -c '\'' eh_falta "$i" "$4" "$1" "i" '\'' ")} }'

