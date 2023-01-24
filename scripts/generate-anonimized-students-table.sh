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

extract_status_and_year() {
	if [ $2 = "Inativo" ]; then
		status=`echo $* | awk -F "(" '{ print $2 }' | sed 's, *[0-9][0-9][0-9][0-9]\.[0-9]),,'`
		year=`echo $* | awk -F "(" '{ print $2 }' | sed 's,[A-Z3\/ ]*,,' | sed -e 's,-[A-Z ]*,,' | sed -e 's,)$,,'`
		echo $status";"$year
	else
		echo "ATIVO;$1"
	fi
}

extract_admission_and_year() {
	admission=`echo $* | sed -e 's, *[0-9][0-9][0-9][0-9]\.[0-9],,'`
	year=`echo $* | sed 's,[A-Z\/ ]*,,' | sed -e 's,-[A-Z ]*,,' | sed -e 's,)$,,'`
	echo $admission";"$year
}

extract_affirmative_policy() {
	if [ -z $1 ]; then
		echo "N/A"
	else
		case "$*" in
			"Candidato autodeclarado preto, pardo ou indgena que, independentemente da renda, tenha cursado integralmente o ensino mdio em escola pblica.") echo L6 ;;
			"Candidato autodeclarado preto, pardo ou indgena, com renda familiar bruta per capita igual ou inferior a 1,5 salrio mnimo que tenha cursado integralmente o ensino mdio em escola pblica.") echo L2 ;;
			"Candidato com deficincia autodeclarado preto, pardo ou indgena que, independentemente da renda, tenha cursado integralmente o ensino mdio em escola pblica.") echo L6 ;;
			"Candidato com deficincia autodeclarado preto, pardo ou indgena, com renda familiar bruta per capita igual ou inferior a 1,5 salrio mnimo que tenha cursado integralmente o ensino mdio em escola pblica.") echo L2 ;;
			"Candidato com deficincia com renda familiar bruta per capita igual ou inferior a 1,5 salrio mnimo que tenha cursado integralmente o ensino mdio em escola pblica.") echo L1 ;;
			"Candidato com deficincia que, independentemente da renda, tenha cursado integralmente o ensino mdio em escola pblica.") echo L5 ;;
			"Candidato com renda familiar bruta per capita igual ou inferior a 1,5 salrio mnimo que tenha cursado integralmente o ensino mdio em escola pblica.") echo L1 ;;
			"Candidato que, independentemente da renda, tenha cursado integralmente o ensino mdio em escola pblica.") echo L5 ;;
		esac
	fi
}

export -f generate_anonymized_registration
export -f extract_status_and_year
export -f extract_admission_and_year
export -f extract_affirmative_policy

input_file=$1
current_period=$2
anonymized_table=$3

# 1. registration
# 2. nationalId
# 3. name
# 4. statusStr
# 5. admissionStr
# 6. affirmativePolicy
# 7. birthDate
# 8. secondarySchool
# 9. secondarySchoolGraduationYear
# 10. email
# 11. gender
# 12. maritalStatus
# 13. nationality
# 14. country
# 15. placeOfBirth
# 16. race
# 17. disabilities
# 18. courseCode
# 19. curriculumCode
# 20. mandatoryHours
# 21. mandatoryCredits
# 22. optionalHours
# 23. optionalCredits
# 24. complementaryHours
# 25. complementaryCredits
# 26. gpa
# 27. mc
# 28. iea
# 29. completedTerms
# 30. suspendedTerms
# 31. institutionalEnrollments
# 32. mobilityTerms
# 33. enrolledCredits;
# 34. admissionGrade

echo "anonymized_registration;statusCode;statusYear;admissionCode;admissionYear;affirmativePolicy;birthDate;secondarySchool;secondarySchoolGraduationYear;gender;curriculumCode;mandatoryCredits;optionalCredits;complementaryCredits;gpa;completedTerms;suspendedTerms;institutionalEnrollments;mobilityTerms;enrolledCredits;admissionGrade"
while read line
do
	registration=`echo $line | awk -F ";" '{ print $1 }'`
	anonymized_registration=$(generate_anonymized_registration $registration $anonymized_table)
	statusCodeAndYear=$(extract_status_and_year $current_period `echo $line | awk -F ";" '{ print $4 }'`)
	admissionCodeAndYear=$(extract_admission_and_year `echo $line | awk -F ";" '{ print $5 }'`)
	affirmativePolicy=$(extract_affirmative_policy `echo $line | awk -F ";" '{ print $6 }'`)
	birthDate=`echo $line | awk -F ";" '{ print $7 }'`
	secondarySchool=`echo $line | awk -F ";" '{ print $8 }'`
	secondarySchoolGraduationYear=`echo $line | awk -F ";" '{ print $9 }'`
	gender=`echo $line | awk -F ";" '{ print $11 }'`
	curriculumCode=`echo $line | awk -F ";" '{ print $19 }'`
	mandatoryCredits=`echo $line | awk -F ";" '{ print $21 }'`
	optionalCredits=`echo $line | awk -F ";" '{ print $23 }'`
	complementaryCredits=`echo $line | awk -F ";" '{ print $25 }'`
	gpa=`echo $line | awk -F ";" '{ print $26 }'`
	completedTerms=`echo $line | awk -F ";" '{ print $29 }'`
	suspendedTerms=`echo $line | awk -F ";" '{ print $30 }'`
	institutionalEnrollments=`echo $line | awk -F ";" '{ print $31 }'`
	mobilityTerms=`echo $line | awk -F ";" '{ print $32 }'`
	enrolledCredits=`echo $line | awk -F ";" '{ print $33 }'`
	admissionGrade=`echo $line | awk -F ";" '{ print $34 }'`
	echo "$anonymized_registration;$statusCodeAndYear;$admissionCodeAndYear;$affirmativePolicy;$birthDate;$secondarySchool;$secondarySchoolGraduationYear;$gender;$curriculumCode;$mandatoryCredits;$optionalCredits;$complementaryCredits;$gpa;$completedTerms;$suspendedTerms;$institutionalEnrollments;$mobilityTerms;$enrolledCredits;$admissionGrade"
done < $input_file

