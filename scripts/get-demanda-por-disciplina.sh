#!/bin/bash

matriculas=$1
dir_fonte=$2
dir_destino=$3
max=$4

get_cut() {
	t=`cat $1 | wc -l`
	if [ $t -gt $2 ]; then
		last_p=`head -$2 $1 | tail -1 | awk -F "," '{ print $2 }'`
		for i in `seq 1 $last_p`
		do
			grep ",$i$" $1 >> $1.tmp
		done
		echo `cat $1.tmp | wc -l`
		rm $1.tmp
	else
		echo $t
	fi
}

mkdir -p $dir_destino

for i in `cat $matriculas`
do
	if [ -f "$dir_fonte/$i.demanda" ]; then
		n=`get_cut $dir_fonte/$i.demanda $max`
		if [ $n -ne 0 ]; then 
			for j in `head -$n $dir_fonte/$i.demanda | awk -F "," '{ print $1 }'`
			do
				echo $i >> $dir_destino/$j.demanda
			done
		fi
	fi
done
