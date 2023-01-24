#!/bin/bash

function generate_anonymized_registration() {
	registration=$1
	anonymization_table=$2
	anonymized_registration=`grep ^$registration $anonymization_table 2>/dev/null | awk -F ";" '{ print $2 }'`
	if [ -z $anonymized_registration ]; then
		stored_anonymized_registration="000000000"
		while [ ${stored_anonymized_registration:-"empty"} != "empty" ];
		do
			random_registration=`printf %09d $(expr 1 + $(openssl rand 4 | od -DAn) % 1000000000)`
			stored_anonymized_registration=`grep $random_registration$ $anonymization_table 2>/dev/null | awk -F ";" '{ print $2 }'`
		done
		echo "$registration;$random_registration" >> $anonymized_table
		echo $random_registration
	else
		echo $anonymized_registration
	fi
}

export -f generate_anonymized_registration

input_file=$1
anonymized_table=$2

# 1. registration
# 2. subjectCode
# 3. term
# 4. classId
# 5. credits
# 6. grade
# 7. status

echo "anonymized_registration;subjectCode;term;classId;credits;grade;status"
while read line
do
	registration=`echo $line | awk -F ";" '{ print $1 }'`
	anonymized_registration=$(generate_anonymized_registration $registration $anonymized_table)
	subjectCode=`echo $line | awk -F ";" '{ print $2 }'`
	term=`echo $line | awk -F ";" '{ print $3 }'`
	classId=`echo $line | awk -F ";" '{ print $4 }'`
	credits=`echo $line | awk -F ";" '{ print $5 }'`
	grade=`echo $line | awk -F ";" '{ print $6 }'`
	status=`echo $line | awk -F ";" '{ print $7 }'`
	echo "$anonymized_registration;$subjectCode;$term;$classId;$credits;$grade;$status"
done < $input_file

