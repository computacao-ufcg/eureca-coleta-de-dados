#!/bin/bash

matricula=$1
periodo=$2
input_dir=$3
output_dir=$4

mkdir -p $output_dir/$periodo
cat $input_dir/nota.csv | grep $matricula | grep $periodo | awk -F ";" '{ print $1 }' > $output_dir/$periodo/$matricula.dat

