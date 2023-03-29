#!/bin/bash

periodo=$1
input=$2
output_dir=$3
mapping=$4

mkdir -p $output_dir

cat $input | grep ^1$periodo | awk -F ";" '{ print $1";"$3";"$7";"$10";"$2 }' | sed -e 's,/,,g' > $output_dir/tmp.out

cat $output_dir/tmp.out | awk -F ";" '{ print $1 }' > $output_dir/mat.out

cat $output_dir/tmp.out | awk -F ";" '{ print $2 }' > $output_dir/name.out
ed $output_dir/name.out <<! > /dev/null
g/ /s,,\,
w
q
!

cat $output_dir/tmp.out | awk -F ";" '{ print $2 }' | tr '[:upper:]' '[:lower:]' > $output_dir/email.out
ed $output_dir/email.out <<! > /dev/null
g/ /s,,\.,g
g/\.da\./s,,\.,g
g/\.do\./s,,\.,g
g/\.de\./s,,\.,g
g/\.das\./s,,\.,g
g/\.dos\./s,,\.,g
g/\.e\./s,,\.,g
g/\.d\'/s,,\.,g
g/$/s,,\@ccc\.ufcg\.edu\.br
w
q
!

cat $output_dir/tmp.out | awk -F ";" '{ print $3 }' > $output_dir/passwd.out

cat $output_dir/tmp.out | awk -F ";" '{ print ",/,"$4 }' > $output_dir/others.out

cat $output_dir/tmp.out | awk -F ";" '{ print $5 }' > $output_dir/cpf.out
for i in `cat $output_dir/cpf.out`
do
	grep ";$i;" $input | awk -F ";" '{ print $1 }' > $output_dir/tmp
	size=`cat $output_dir/tmp | wc -l | sed 's,/^ */,,'`
	if [ $size -ne 1 ]; then
		echo "CPF: $i" >> $output_dir/reingresso.dat
		cat $output_dir/tmp >> $output_dir/reingresso.dat
	fi
done
rm $output_dir/tmp $output_dir/cpf.out

paste -d ',' $output_dir/name.out $output_dir/email.out $output_dir/passwd.out $output_dir/others.out > $output_dir/tmp.out
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
paste -d ";" $output_dir/mat.out $output_dir/email.out > $output_dir/$periodo.mapping.csv 
rm -rf $output_dir/taken.list $output_dir/name.out $output_dir/mat.out $output_dir/email.out $output_dir/passwd.out $output_dir/others.out

for i in `cat $output_dir/$periodo.mapping.csv | awk -F ";" '{ print $2 }'`
do
	grep ";$i$" $mapping > /dev/null
	if [ $? == 0 ]; then
		echo $i >> $output_dir/$periodo.taken
	fi
done
