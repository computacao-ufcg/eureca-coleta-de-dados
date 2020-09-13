#!/bin/bash

periodo=$1
input_dir=$2
output_dir=$3

cat $input_dir/cadastro.ori | grep ^1$periodo | awk -F ";" '{ print $3","$7 }' | sed -e 's,/,,g' > $output_dir/tmp.out
cat $output_dir/tmp.out | awk '{ print toupper(substr($1,1,1)) tolower(substr($1,2)) }' > $output_dir/first.out
cat $output_dir/tmp.out | awk -F "," '{ print $1 }' | awk '{ for(i=2; i<=NF; i++) print toupper(substr($i,1,1)) tolower(substr($i,2)); print "#" }' | tr '\n' ' ' | tr '#' '\n' | sed -e 's,^ ,,g' | sed -e 's, $,,g' > $output_dir/last.out
cat $output_dir/tmp.out | awk '{ for(i=1; i<=NF; i++) print toupper( substr( $i, 1, 1 ) ) substr( $i, 2 ) }' | awk '{ print $1","$2" "$3" "$4" "$5" "$6" "$7 }' | sed -e 's, *$,,' > $output_dir/first-last.out
cat $output_dir/tmp.out | awk -F "," '{ print $1 }' | awk '{ print tolower($1)"."tolower($NF)"@ccc.ufcg.edu.br" }' > $output_dir/email.out
cat $output_dir/tmp.out | awk -F "," '{ print $2 }' > $output_dir/passwd.out
cat $input_dir/cadastro.ori | grep ^1$periodo | awk -F ";" '{ print ",/,"$10 }' > $output_dir/others.out
paste -d ',' $output_dir/first.out $output_dir/last.out $output_dir/email.out $output_dir/passwd.out $output_dir/others.out > $output_dir/tmp.out
ed $output_dir/tmp.out <<! > /dev/null 2>&1
g/^,*$/d
g/Joao/s,,João,
g/Jose/s,,José,
g/ De /s,, de ,
g/,De /s,,\,de ,
g/ Da /s,, da ,
g/\,Da /s,,\,da ,
g/ Do /s,, do ,
g/\,Do /s,,\,do ,
g/ Dos /s,, dos ,
g/\,Dos /s,,\,dos ,
g/ Das /s,, das ,
g/\,Das /s,,\,das ,
1
i
First Name,Last Name,Email Address,Password,Password Hash Function,Org Unit Path,Recovery Email
.
w
q
!
mv $output_dir/tmp.out $output_dir/$periodo.csv
cat $output_dir/$periodo.csv | awk -F "," '{ print $1" "$2","$3 }' > $output_dir/$periodo.pub
rm $output_dir/first.out $output_dir/last.out $output_dir/email.out $output_dir/passwd.out $output_dir/others.out

