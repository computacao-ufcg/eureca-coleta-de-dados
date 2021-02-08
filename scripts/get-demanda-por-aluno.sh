#!/bin/bash

matriculas=$1
dir_fonte=$2
dir_destino=$3
dir_data=$4

pagou() {
	for k in `cat $dir_data/$1.codigo`
        do
                grep $k $dir_fonte/$2.aprovadas > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                        echo true
                        break
                fi
        done
	echo false
}

tem_pre_requisito() {
	n=0
        for k in `cat $dir_data/$1.pre`
        do
		for l in `cat $dir_data/$k.codigo`
		do
			m=1      
                	grep $k $dir_fonte/$2.aprovadas > /dev/null 2>&1
			m=`expr $m \* $?`
		done
		n=`expr $n + $m`
        done 
        if [ $n -eq 0 ]; then
		echo true
	else
		echo false
	fi
}

mkdir -p $dir_destino

for h in 1 2 3 4 5 6 7 8 9
do
	for i in `cat $dir_data/p$h.obrig`
	do
		for j in `cat $matriculas`
		do
			p=`pagou $i $j`
			if [ "$p" = "false" ]; then
				tempre=`tem_pre_requisito $i $j`
				if [ "$tempre" = "true" ]; then
					echo $i,$h >> $dir_destino/$j.demanda
				fi
			fi
		done
	done
done
