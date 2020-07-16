#!/bin/bash

anonimize_mat() {
        if [ "$2AA" = "AA" ]; then
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

anonimize_nome() {
        if [ "$2AA" = "AA" ]; then
                echo ""
        else
                echo $1
        fi
}

echo "Matrícula não anônima:" $(anonimize_mat 123456789 false)
echo "Matrícula anônima:" $(anonimize_mat 123456789)
echo "Nome não anônimo:" $(anonimize_nome "Francisco Vilar Brasileiro" false)
echo "Nome anônimo:" $(anonimize_nome "Francisco Vilar Brasileiro")

