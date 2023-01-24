#!/bin/bash

matriculas=$1
grupo=$2
students=$3
map=$4

for i in `cat $matriculas`
do
        nome=`grep "^$i" $students | awk -F ";" '{ print $3 }'`
        email=`grep "^$i;" $map | awk -F ";" '{ print $2 }'`
        echo "$grupo,$email,$nome,MEMBER,USER"
done

