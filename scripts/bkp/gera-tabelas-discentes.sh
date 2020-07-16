#!/bin/bash

get_from_table() {
	pattern=$1
	table=$2

        if [ "$patternAA" = "AA" ] || [ "AA$pattern" = "AA-" ]; then
                echo "1"
        else
                echo "$(grep -n "$pattern" $table | head -1 | awk -F ":" '{ print $1 }')"
        fi
}

get_cpf_from_matricula() {
	matricula=$1

	entrada=$(grep ";"$matricula $dir_destino/cpf-mat-mapping.csv)
	echo $(echo $entrada | awk -F ";" '{ print $1 }')
}

generate_cpf() {
        printf %011d $(expr 1 + $(openssl rand 4 | od -DAn) % 100000000000)
}

anonimize_mat() {
	if [ "$2AA" = "trueAA" ]; then
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
	if [ "$2AA" = "trueAA" ]; then
		echo ""
	else
		echo $1
	fi
}

PERIODO_ATUAL=2020.1
dir_fonte=$1
dir_destino=$2
do_anonimize=$3

mkdir -p $dir_destino

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $4 }' | awk '{ print $1 }' | sort | uniq > $dir_destino/situacao_aluno.csv
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $4 }' | grep "Inativo" | awk -F "(" '{ print $2 }' | awk '{ $NF=""; print $0 }' | sed 's, $,,' | sort | uniq > $dir_destino/situacao_vinculo.tmp
cat $dir_fonte/vinculo.csv | awk -F ";" '{ print $4 }' | sort | uniq >> $dir_destino/situacao_vinculo.tmp
sort $dir_destino/situacao_vinculo.tmp | uniq > $dir_destino/situacao_vinculo.csv
rm $dir_destino/situacao_vinculo.tmp

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $5 }' | sort | uniq > $dir_destino/ingresso.tmp
cat $dir_destino/ingresso.tmp | awk '{$NF=""; print $0}' | sed 's, $,,' | sort | uniq > $dir_destino/ingresso.csv
rm $dir_destino/ingresso.tmp
ed -s $dir_destino/ingresso.csv > /dev/null 2>&1 <<!
1
i
NÃO REGISTRADO
.
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $6 }' | sort | uniq > $dir_destino/cota.csv
ed -s $dir_destino/cota.csv > /dev/null 2>&1 <<!
1
/^$/s,,Não registrada,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $8 }' | sort | uniq > $dir_destino/escola.csv
ed -s $dir_destino/escola.csv > /dev/null 2>&1 <<!
1
/^$/s,,Não registrada,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $11 }' | sort | uniq > $dir_destino/genero.csv
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $12 }' | sort | uniq > $dir_destino/estado_civil.csv
ed -s $dir_destino/estado_civil.csv > /dev/null 2>&1 <<!
1
/^$/s,,Não registrado,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $13 }' | sort | uniq > $dir_destino/nacionalidade.csv
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $14 }' | sort | uniq > $dir_destino/pais.csv
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $15 }' | sort | uniq | awk -F " - " '{ print $1";"$2 }' > $dir_destino/municipio.csv
ed -s $dir_destino/municipio.csv > /dev/null 2>&1 <<!
1
/^$/s,,Não registrado,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $16 }' | sort | uniq > $dir_destino/cor.csv
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $17 }' | tr ',' '\n' | sed 's,^ ,,' | sort | uniq > $dir_destino/deficiencia.csv

rm -f $dir_destino/cpf-mat-mapping.csv $dir_destino/aluno.csv $dir_destino/aluno_deficiencias.csv $dir_destino/aluno_vinculos.csv

cat $dir_fonte/vinculo.csv | awk -F ";" '{ print $3 }' | sort | uniq > $dir_destino/cursos.csv

line=1

for i in $(cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $1 }')
do
	reg_cadastro=$(head -$line $dir_fonte/cadastro.csv | tail -1)
	reg_historico=$(head -$line $dir_fonte/historico.csv | tail -1)

 	if [ "AA$do_anonimize" = "AAtrue" ]; then
                cpf=$(generate_cpf)
        else
                cpf=$(echo $reg_cadastro | awk -F ";" '{ print $2 }')
		if [ "AA$cpf" = "AA" ]; then
			cpf=$(generate_cpf)
		fi
        fi
        echo $cpf";"$i >> $dir_destino/cpf-mat-mapping.csv

	nome=$(anonimize_nome "$(echo $reg_cadastro | awk -F ";" '{ print $3 }')" $do_anonimize)

	situacao_tipo_base=$(echo $reg_cadastro | awk -F ";" '{ print $4 }' | awk '{ print $1 }')
	if [ "$situacao_tipo_baseAA" = "InativoAA" ]; then
                semestre_situacao=$(echo $reg_cadastro | awk -F ";" '{ print $4 }' | awk '{ print $NF }' | sed 's,)$,,')
        else
                semestre_situacao=$PERIODO_ATUAL
	fi
	situacao_tipo=$(get_from_table "$situacao_tipo_base" $dir_destino/situacao_aluno.csv)

        ingresso_tipo_base=$(echo $reg_cadastro | awk -F ";" '{ print $5 }' | awk '{$NF=""; print $0}' | sed 's, $,,')
	ingresso_tipo=$(get_from_table "$ingresso_tipo_base" $dir_destino/ingresso.csv)

	semestre_ingresso=$(echo $reg_cadastro | awk -F ";" '{ print $5 }' | awk '{ print $NF }')        

	cota_tipo=$(echo $reg_cadastro | awk -F ";" '{ print $6 }')
	cota=$(get_from_table "$cota_tipo" $dir_destino/cota.csv)

	nascimento=$(echo $reg_cadastro | awk -F ";" '{ print $7 }' | awk -F "/" '{ print $3 }')

	tipo_escola=$(echo $reg_cadastro | awk -F ";" '{ print $8 }')
	inst=$(get_from_table "$tipo_escola" $dir_destino/escola.csv) 

	conclusao=$(echo $reg_cadastro | awk -F ";" '{ print $9 }')
	
	email=$(echo $reg_cadastro | awk -F ";" '{ print $10 }')

	tipo_genero=$(echo $reg_cadastro | awk -F ";" '{ print $11 }')
	genero=$(get_from_table "$tipo_genero" $dir_destino/genero.csv)

	tipo_estado_civil=$(echo $reg_cadastro | awk -F ";" '{ print $12 }')
	estado_civil=$(get_from_table "$tipo_estado_civil" $dir_destino/estado_civil.csv)

	tipo_nacionalidade=$(echo $reg_cadastro | awk -F ";" '{ print $13 }')
	nacionalidade=$(get_from_table "$tipo_nacionalidade" $dir_destino/nacionalidade.csv)

        tipo_pais_origem=$(echo $reg_cadastro | awk -F ";" '{ print $14 }')
        pais_origem=$(get_from_table "$tipo_pais_origem" $dir_destino/pais.csv)

        tipo_naturalidade=$(echo $reg_cadastro | awk -F ";" '{ print $15 }' | awk -F " - " '{ print $1";"$2 }')
        naturalidade=$(get_from_table "$tipo_naturalidade" $dir_destino/municipio.csv)

        tipo_cor=$(echo $reg_cadastro | awk -F ";" '{ print $16 }')
        cor=$(get_from_table "$tipo_cor" $dir_destino/cor.csv)

	echo $cpf";"$nome";"$situacao_tipo";"$semestre_situacao";"$ingresso_tipo";"$semestre_ingresso";"$nascimento";"$cota";"$inst";"$conclusao";"$email";"$genero";"$estado_civil";"$nacionalidade";"$pais_origem";"$naturalidade";"$cor >> $dir_destino/aluno.csv

	deficiencias=$(echo $reg_cadastro | awk -F ";" '{ print $17 }' | sed 's, ,_,g')
	for j in $(echo $deficiencias | awk -F ",_" '{ for(k=1;k<=NF;k++) print $k }')
	do
		deficiencia=$(echo $j | sed 's,_, ,g')
		echo $cpf";"$(get_from_table "$deficiencia" $dir_destino/deficiencia.csv) >> $dir_destino/aluno_deficiencias.csv
	done

        id_curso=$(get_from_table "$(echo "CINCIA DA COMPUTAO - D")" $dir_destino/cursos.csv)

	if [ "$situacao_tipo_baseAA" = "AtivoAA" ]; then
		id_situacao_vinculo=$(get_from_table "REGULAR" $dir_destino/situacao_vinculo.csv)
		echo $cpf";"$(anonimize_mat $i $do_anonimize)";"$id_curso";"$id_situacao_vinculo";"$semestre_situacao >> $dir_destino/aluno_vinculos.csv
	else
		situacao_vinculo=$(echo $reg_cadastro | awk -F ";" '{ print $4 }' | awk -F "(" '{ print $2 }' | awk '{ $NF=""; print $0 }' | sed 's, $,,')
		id_situacao_vinculo=$(get_from_table "$situacao_vinculo" $dir_destino/situacao_vinculo.csv)
		echo $cpf";"$(anonimize_mat $i $do_anonimize)";"$id_curso";"$id_situacao_vinculo";"$semestre_situacao >> $dir_destino/aluno_vinculos.csv
	fi
	line=$(expr $line + 1)
done

nlines=$(cat $dir_fonte/vinculo.csv | wc -l)
if [ $nlines -ne 0 ]; then
	for i in $(seq 1 $nlines)
	do
		line=$(head -$i $dir_fonte/vinculo.csv | tail -1)
		matricula=$(echo $line | awk -F ";" '{ print $1 }')
		cpf=$(get_cpf_from_matricula $matricula)
		matricula_vinculo=$(echo $line | awk -F ";" '{ print $2 }')
		id_curso=$(get_from_table "$(echo $line | awk -F ";" '{ print $3 }')" $dir_destino/cursos.csv)
        	id_situacao_vinculo=$(get_from_table "$(echo $line | awk -F ";" '{ print $4 }')" $dir_destino/situacao_vinculo.csv)
		periodo=$(echo $line | awk -F ";" '{ print $5 }')
		if [ "$periodoAA" = "AtivoAA" ]; then
			periodo=$PERIODO_ATUAL
		fi
		echo $cpf";"$(anonimize_mat $matricula_vinculo $do_anonimize)";"$id_curso";"$id_situacao_vinculo";"$periodo >> $dir_destino/aluno_vinculos.csv
	done
fi

# Sanity checking
nreg=$(cat $dir_destino/cpf-mat-mapping.csv | wc -l)
uniq_cpf=$(cat $dir_destino/cpf-mat-mapping.csv | awk -F ";" '{ print $1 }' | sort | uniq | wc -l)
uniq_mat=$(cat $dir_destino/cpf-mat-mapping.csv | awk -F ";" '{ print $2 }' | sort | uniq | wc -l)

if [ $nreg -ne $uniq_cpf ] || [ $nreg -ne $uniq_mat ]; then
        echo "Failed: $nreg registros, $uniq_cpf CPFs, $uniq_mat matriculas"
        exit 1
fi
rm $dir_destino/cpf-mat-mapping.csv

rm -f $dir_destino/disciplina.csv
cat $dir_fonte/disciplinas.csv | awk -F ";" '{ print $2";"$4";"$5";"$6";"$3 }' | sort | uniq > $dir_destino/disciplina.tmp
cat $dir_destino/disciplina.tmp | awk -F ";" '{ print $2 }' | sort | uniq > $dir_destino/tipo.csv

if [ "AA$do_anonimize" = "AAtrue" ]; then
	mv $dir_fonte/disciplinas.csv $dir_fonte/disciplinas.csv.ori
	nlines=$(cat $dir_fonte/disciplinas.csv.ori | wc -l)
	if [ $nlines -ne 0 ]; then
        	for i in $(seq 1 $nlines)
        	do
                	line=$(head -$i $dir_fonte/disciplinas.csv.ori | tail -1)
                	matricula=$(echo $line | awk -F ";" '{ print $1 }')
			echo $line | awk -F ";" -v mat=$(anonimize_mat $matricula $do_anonimize) '{ print mat";"$2";"$3";"$4";"$5";"$6";"$7";"$8";"$9 }' >> $dir_fonte/disciplinas.csv
        	done
	fi
#	rm $dir_fonte/disciplinas.csv.ori
fi

nlines=$(cat $dir_destino/disciplina.tmp | wc -l)
if [ $nlines -ne 0 ]; then
	for i in $(seq 1 $nlines)
	do
        	line=$(head -$i $dir_destino/disciplina.tmp | tail -1)
        	codigo=$(echo $line | awk -F ";" '{ print $1 }')
        	tipo_str=$(echo $line | awk -F ";" '{ print $2 }')
        	tipo=$(get_from_table "$tipo_str" $dir_destino/tipo.csv)
        	creditos=$(echo $line | awk -F ";" '{ print $3 }')
        	horas=$(echo $line | awk -F ";" '{ print $4 }')
        	nome=$(echo $line | awk -F ";" '{ print $5 }')
        	echo $codigo";"$tipo";"$creditos";"$horas";"$nome >> $dir_destino/disciplina.csv
	done
fi
rm $dir_destino/disciplina.tmp

cat $dir_fonte/disciplinas.csv | awk -F ";" '{ print $8 }' | sort | uniq > $dir_destino/situacao_disciplina.csv

# Fix data
ed -s $dir_destino/municipio.csv > /dev/null 2>&1 <<!
g/ALGODO DE JANDARA/s,,ALGODÃO DE JANDAÍRA
g/AU;RN/s,,AÇU;RN
g/BARO DE GRAJA;MA/s,,BARÃO DE GRAJAÚ;MA
g/BELM;P/g//s,,BELÉM;P
g/BODOC;PE/s,,BODOCÓ;PE
g/BOQUEIRO;PB/s,,BOQUEIRÃO;PB
g/BRASLIA;DF/s,,BRASÍLIA;DF
g/CACHOEIRA DOS NDIOS/s,,CACHOEIRA DOS ÍNDIOS;PB
g/CAIC;RN/s,,CAICÓ;RN
g/CANIND;CE/s,,CANINDÉ;CE
g/CARABAS;PB/s,,CARAÍBAS;PB
g/CATOL DO ROCHA;PB/s,,CATOLÉ DO ROCHA;PB
g/CONCEIO;PB/s,,CONCEIÇÃO;PB
g/CRATES;CE/s,,CRATEÚS;CE
g/CRICIMA;SC/s,,CRICIÚMA;SC
g/CUIT;PB/s,,CUITÉ;PB
g/ESPERANA;PB/s,,ESPERANÇA;PB
g/FLORIANPOLIS;SC/s,,FLORIANÓPOLIS;SC
g/FOZ DO IGUAU;PR/s,,FOZ DO IGUAÇU;PR
g/GOIS;GO/s,,GOIÁS;GO
g/GRAVAT;PE/s,,GRAVATÁ;PE
g/IC;CE/s,,ICÓ;CE
g/ING;PB/s,,INGÁ;PB
g/IREC;BA/s,,IRECÊ;BA
g/JABOATO DOS GUARARAPES;PE/s,,JABOATÃO DOS GUARARAPES;PE
g/JARDIM DO SERID;RN/s,,JARDIM DO SERIDÓ;RN
g/JI-PARAN;RO/s,,JI-PARANÁ;RO
g/JOO PESSOA;PB/s,,JOÃO PESSOA;PB
g/JUAREZ TVORA;PB/s,,JUAREZ TÁVORA;PB
g/LUS GOMES;RN/s,,LUÍS GOMES;RN
g/MACEI;AL/s,,MACEIÓ;AL
g/MARAB;PA/s,,MARABÁ;PA
g/MARIZPOLIS;PB/s,,MARIZÓPOLIS;PB
g/MOSSOR;RN/s,,MOSSORÓ;RN
g/NAZAR DA MATA;PE/s,,NAZARÉ DA MATA;PE
g/NITERI;RJ/s,,NITERÓI;RJ
g/NOVA IGUAU;RJ/s,,NOVA IGUAÇU;RJ
g/OLHO D'GUA;PB/s,,OLHO D'ÁGUA;PB
g/PALMEIRA DOS NDIOS;AL/s,,PALMEIRA DOS ÍNDIOS;AL
g/PIANC;PB/s,,PIANCÓ;PB
g/PICU;PB/s,,PICUÍ;PB
g/PONTA POR;MS/s,,PONTA PORÃ;MS
g/PONTA POR;MS/s,,POÇÃO;PE
g/REMGIO;PB/s,,REMÍGIO;PB
g/RONDONPOLIS;MT/s,,RONDONÓPOLIS;MT
g/SANTO ANDR;SP/s,,SANTO ANDRÉ;SP
g/SANTO ANTNIO DE LISBOA;PI/s,,SANTO ANTÔNIO DE LISBOA;PI
g/SAP;PB/s,,SAPÉ;PB
g/^SO /s,,SÃO 
g/GONALO;RJ/s,,GONÇALO;RJ
g/JOO DE MERITI;RJ/s,,JOÃO DE MERITI;RJ
g/JOS DO EGITO;PE/s,,JOSÉ DO EGITO;PE
g/LUS;MA/s,,LUÍS;MA
g/SEBASTIO DE LAGOA DE ROA;PB/s,,SEBASTIÃO DE LAGOA DE ROÇA;PB
g/SOLNEA;PB/s,,SOLÂNEA;PB
g/SUM;PB/s,,SUMÉ;PB
g/TOCANTNIA;TO/s,,TOCANTÍNIA;TO
g/TUCURU;PA/s,,TUCURUÍ;PA
g/UIRANA;PB/s,,UIRAÚNA;PB
g/VRZEA ALEGRE;CE/s,,VÁRZEA ALEGRE;CE
w
q
!

ed -s $dir_destino/cor.csv > /dev/null 2>&1 <<!
g/Nýo declarada/s,,Não declarada
g/Indýgena/s,,Indígena
w
q
!

ed -s $dir_destino/cota.csv > /dev/null 2>&1 <<!
g/indgena/s,,indígena,g
g/pblica/s,,pública,g
g/mnim/s,,mínim,g
g/mdio/s,,médio,g
g/salrio/s,,salário,g
g/deficincia/s,,deficiência,g
w
q
!

ed -s $dir_destino/deficiencia.csv > /dev/null 2>&1 <<!
g/viso/s,,visão
g/Deficincia/s,,Deficiência
g/fsica/s,,física
g/Sndrome/s,,Síndrome
w
q
!

ed -s $dir_destino/escola.csv > /dev/null 2>&1 <<!
g/blica/s,,ública
w
q
!

ed -s $dir_destino/genero.csv > /dev/null 2>&1 <<!
g/Vivo/s,,Viúvo
w
q
!

ed -s $dir_destino/tipo.csv > /dev/null 2>&1 <<!
g/Obrigatria/s,,Obrigatória
w
q
!

