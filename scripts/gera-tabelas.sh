#!/bin/bash

function process_line() {
	$@
}

function get_from_table() {
	pattern=$1
	table=$2

	if [ "AA$pattern" = "AA" ] || [ "AA$pattern" = "AA-" ]; then
		echo "1"
	else
		resposta=$(echo "$(grep -n "$pattern" $table | head -1 | awk -F ":" '{ print $1 }')")
		if [ "AA$resposta" = "AA" ]; then
			echo "1"
		else
			echo $resposta
		fi
	fi
}

function get_cpf_from_matricula() {
	matricula=$1

	entrada=$(grep ";"$matricula $dir_fonte/cpf-mat-mapping.csv)
	echo $(echo $entrada | awk -F ";" '{ print $1 }')
}

function process_input_cadastro() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	dir_destino=$(echo $@ | awk -F ";" '{ print $2 }')
	periodo_atual=$(echo $@ | awk -F ";" '{ print $3 }')
	mat=$(echo $@ | awk -F ";" '{ print $4 }')
	cpf=$(echo $@ | awk -F ";" '{ print $5 }')
	echo $cpf";"$mat >> $dir_fonte/cpf-mat-mapping.csv
	nome=$(echo $@ | awk -F ";" '{ print $6 }')
	situacao_tipo_base=$(echo $@ | awk -F ";" '{ print $7 }' | awk '{ print $1 }')
	if [ "AA$situacao_tipo_base" = "AAInativo" ]; then
		semestre_situacao=$(echo $@ | awk -F ";" '{ print $7 }' | awk '{ print $NF }' | sed 's,)$,,')
	else
		semestre_situacao=$periodo_atual
	fi
	situacao_tipo=$(get_from_table "$situacao_tipo_base" $dir_destino/SituacaoDiscente.data)

	ingresso_tipo_base=$(echo $@ | awk -F ";" '{ print $8 }' | awk '{$NF=""; print $0}' | sed 's, $,,')
	ingresso_tipo=$(get_from_table "$ingresso_tipo_base" $dir_destino/Ingresso.data)

	semestre_ingresso=$(echo $@ | awk -F ";" '{ print $8 }' | awk '{ print $NF }')

	cota_tipo=$(echo $@ | awk -F ";" '{ print $9 }')
	cota=$(get_from_table "$cota_tipo" $dir_destino/Cota.data)

	nascimento=$(echo $@ | awk -F ";" '{ print $10 }' | awk -F "/" '{ print $3 }')

	tipo_escola=$(echo $@ | awk -F ";" '{ print $11 }')
	inst=$(get_from_table "$tipo_escola" $dir_destino/Escola.data)

	conclusao=$(echo $@ | awk -F ";" '{ print $12 }')

	email=$(echo $@ | awk -F ";" '{ print $13 }')

	tipo_genero=$(echo $@ | awk -F ";" '{ print $14 }')
	genero=$(get_from_table "$tipo_genero" $dir_destino/Genero.data)

	tipo_estado_civil=$(echo $@ | awk -F ";" '{ print $15 }')
	estado_civil=$(get_from_table "$tipo_estado_civil" $dir_destino/EstadoCivil.data)

	tipo_nacionalidade=$(echo $@ | awk -F ";" '{ print $16 }')
	nacionalidade=$(get_from_table "$tipo_nacionalidade" $dir_destino/Nacionalidade.data)

	tipo_pais_origem=$(echo $@ | awk -F ";" '{ print $17 }')
	pais_origem=$(get_from_table "$tipo_pais_origem" $dir_destino/Pais.data)

	tipo_naturalidade=$(echo $@ | awk -F ";" '{ print $18 }' | awk -F " - " '{ print $1";"$2 }')
	naturalidade=$(get_from_table "$tipo_naturalidade" $dir_destino/Naturalidade.data)

	tipo_cor=$(echo $@ | awk -F ";" '{ print $19 }')
	cor=$(get_from_table "$tipo_cor" $dir_destino/Cor.data)

	echo $cpf";"$nome";"$situacao_tipo";"$semestre_situacao";"$ingresso_tipo";"$semestre_ingresso";"$nascimento";"$cota";"$inst";"$conclusao";"$email";"$genero";"$estado_civil";"$nacionalidade";"$pais_origem";"$naturalidade";"$cor >> $dir_destino/Discente.data

	deficiencias=$(echo $@ | awk -F ";" '{ print $20 }' | sed -e 's, ,_,g')
	for j in $(echo $deficiencias | awk -F ",_" '{ for(k=1;k<=NF;k++) print $k }')
	do
		deficiencia=$(echo $j | sed -e 's,_, ,g')
		echo $cpf";"$(get_from_table "$deficiencia" $dir_destino/Deficiencia.data) >> $dir_destino/DiscenteDeficiencia.data
	done

	id_curso=$(get_from_table "$(echo "CINCIA DA COMPUTAO - D")" $dir_destino/Curso.data)

	if [ "AA$situacao_tipo_base" = "AAAtivo" ]; then
		id_situacao_vinculo=$(get_from_table "REGULAR" $dir_destino/SituacaoVinculo.data)
	else
		situacao_vinculo=$(echo $@ | awk -F ";" '{ print $7 }' | awk -F "(" '{ print $2 }' | awk '{ $NF=""; print $0 }' | sed -e 's, $,,')
		id_situacao_vinculo=$(get_from_table "$situacao_vinculo" $dir_destino/SituacaoVinculo.data)
	fi
	echo $cpf";"$mat";"$id_curso";"$id_situacao_vinculo";"$semestre_situacao >> $dir_destino/DiscenteVinculo.data
}

function process_input_vinculo() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	dir_destino=$(echo $@ | awk -F ";" '{ print $2 }')
	periodo_atual=$(echo $@ | awk -F ";" '{ print $3 }')
	mat=$(echo $@ | awk -F ";" '{ print $4 }')
	cpf=$(get_cpf_from_matricula $mat)
	mat_vinculo=$(echo $@ | awk -F ";" '{ print $5 }')
	id_curso=$(get_from_table "$(echo $@ | awk -F ";" '{ print $6 }')" $dir_destino/Curso.data)
	situacao_vinculo=$(echo $@ | awk -F ";" '{ print $7 }')
	id_situacao_vinculo=$(get_from_table "$situacao_vinculo" $dir_destino/SituacaoVinculo.data)
	periodo=$(echo $@ | awk -F ";" '{ print $8 }')
	if [ "AA$situacao_vinculo" = "AAAtivo" ]; then
		periodo=$periodo_atual
	fi
	echo $cpf";"$mat_vinculo";"$id_curso";"$id_situacao_vinculo";"$periodo >> $dir_destino/DiscenteVinculo.data
}

function process_input_disciplina() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	dir_destino=$(echo $@ | awk -F ";" '{ print $2 }')
	codigo=$(echo $@ | awk -F ";" '{ print $3 }')
	creditos=$(echo $@ | awk -F ";" '{ print $4 }')
	horas=$(echo $@ | awk -F ";" '{ print $5 }')
	nome=$(echo $@ | awk -F ";" '{ print $6 }')
        tipo_str=$(echo $@ | awk -F ";" '{ print $7 }')
        tipo=$(get_from_table "$tipo_str" $dir_destino/Tipo.data)
	echo $codigo";"$tipo";"$creditos";"$horas";"$nome >> $dir_destino/Disciplina.data
}

function process_input_turma_professor() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	dir_destino=$(echo $@ | awk -F ";" '{ print $2 }')
	codigo_turma=$(echo $@ | awk -F ";" '{ print $3 }')
	codigo=$(echo $@ | awk -F ";" '{ print $4 }')
	nome=$(echo $@ | awk -F ";" '{ print $5 }')
	professores=$(echo $@ | awk -F ";" '{ print $6 }')
	turma=$(echo $@ | awk -F ";" '{ print $7 }')
	creditos=$(echo $@ | awk -F ";" '{ print $8 }')
	horas=$(echo $@ | awk -F ";" '{ print $9 }')
	periodo=$(echo $@ | awk -F ";" '{ print $10 }')
	horario_str=$(echo $@ | awk -F ";" '{ print $11 }')
	horario=$(get_from_table "$horario_str" $dir_destino/Horario.data)
	sala_str=$(echo $@ | awk -F ";" '{ print $12 }')
	sala=$(get_from_table "$sala_str" $dir_destino/Sala.data)
	codigo_disciplina=$(get_from_table "$codigo;$creditos;$horas;$nome" $dir_destino/Disciplina.data)
	echo $codigo_disciplina";"$turma";"$periodo";"$horario";"$sala >> $dir_destino/Turma.data
	for j in $(echo $professores | awk -F "," '{ print $1" "$2" "$3" "$4 }')
	do
		echo "$codigo_turma;$j" >> $dir_destino/TurmaProfessor.data
	done
}

function process_input_aluno_disciplina() {
	dir_fonte=$(echo $@ | awk -F ";" '{ print $1 }')
	dir_destino=$(echo $@ | awk -F ";" '{ print $2 }')
	max_nnotas=8
	max_campos=17
	codigo=$(echo $@ | awk -F ";" '{ print $3 }')
	turma=$(echo $@ | awk -F ";" '{ print $4 }')
	periodo=$(echo $@ | awk -F ";" '{ print $5 }')
	mat=$(echo $@ | awk -F ";" '{ print $6 }')
	ncampos=$(expr $(echo $@ | awk -F ";" '{ print NF }') - 2)
	notas=""
	nnotas=$(expr $max_nnotas - $(expr $max_campos - $ncampos))
	ultima=$(expr 5 + $nnotas)
	for j in $(seq 6 $(expr $max_nnotas + 5))
	do
		if [ "$j" -le "$ultima" ]; then
			notas=$notas";"$(echo $line | awk -F ";" -v index=$j '{ print $index }')
		else
			notas=$notas";"
		fi
	done
	parcial=$(echo $@ | awk -F ";" '{ print $(NF-3) }')
	final=$(echo $@ | awk -F ";" '{ print $(NF-2) }')
	media=$(echo $@ | awk -F ";" '{ print $(NF-1) }')
	creditos=$(grep "$codigo;$turma;$periodo;$matricula" $dir_fonte/frequencia.csv | awk -F ";" '{ print $5 }')
	horas=$(grep "$codigo;$turma;$periodo;$matricula" $dir_fonte/frequencia.csv | awk -F ";" '{ print $6 }')
	codigo_disciplina=$(get_from_table "$codigo;$creditos;$horas" $dir_destino/Disciplina.data)
	codigo_turma=$(get_from_table "$codigo_disciplina;$turma;$periodo" $dir_destino/Turma.data)
	faltas=$(grep "^$codigo;$turma;$periodo;$matricula" $dir_fonte/frequencia.csv | tail -1 | awk -F ";" '{ print $5 }')
	situacao=$(grep "$matricula;$codigo;$periodo" $dir_fonte/disciplinas.csv | head -1 | awk -F ";" '{ print $9 }')
	situacao_id=$(get_from_table "$situacao" $dir_destino/SituacaoDisciplina.data)
	echo $mat";"$codigo_turma";"$faltas$notas";"$parcial";"$final";"$media";"$situacao_id >> $dir_destino/DiscenteDisciplina.data
}

function process_falta() {
	dir_destino=$(echo $@ | awk -F ";" '{ print $1 }')
	falta=$(echo $@ | awk -F ";" '{ print $2 }')
	codigo_disciplina=$(echo $@ | awk -F ";" '{ print $3 }')
	turma=$(echo $@ | awk -F ";" '{ print $4 }')
	periodo=$(echo $@ | awk -F ";" '{ print $5 }')
	matricula=$(echo $@ | awk -F ";" '{ print $6 }')
        creditos=$(echo $@ | awk -F ";" '{ print $7 }')
	horas=$(echo $@ | awk -F ";" '{ print $8 }')
	indice=$(echo $@ | awk -F ";" '{ print $9 }')
   	if [ "$falta" -eq "1" ]; then
		dia=$(expr $indice - 7)
		id_disciplina=$(get_from_table "$codigo_disciplina;$creditos;$horas" $dir_destino/Disciplina.data)
		id_turma=$(get_from_table "$id_disciplina;$turma;$periodo" $dir_destino/Turma.data)
		echo "$matricula;$id_turma;$dia"
	fi
}

function generate_headers() {
	echo "descricao" > $dir_destino/Cor.header
	echo "descricao" > $dir_destino/Cota.header
	echo "nome" > $dir_destino/Curso.header
	echo "descricao" > $dir_destino/Deficiencia.header
	echo "cpf;nome;id_situacao;semestre_situacao;id_ingresso;semestre_ingresso;ano_nascimento;id_cota;id_tipo_escola;ano_conclusao_ensino_medio;email;id_genero;id_estado_civil;id_nacionalidade;id_pais_origem;id_naturalidade;id_cor" > $dir_destino/Discente.header
	echo "cpf;id_deficiencia" > $dir_destino/DiscenteDeficiencia.header
	echo "matricula;id_turma;num_faltas;nota1;nota2;nota3;nota4;nota5;nota6;nota7;nota8;media_parcial;prova_final;media_final;id_situacao" > $dir_destino/DiscenteDisciplina.header
	echo "cpf;matricula;id_curso;id_situacao_vinculo;semestre_vinculo" > $dir_destino/DiscenteVinculo.header
	echo "codigo;creditos;horas;nome" > $dir_destino/Disciplina.header
	echo "descricao" > $dir_destino/Escola.header
	echo "descricao" > $dir_destino/EstadoCivil.header
	echo "matricula;id_turma;num_aula" > $dir_destino/Falta.header
	echo "descricao" > $dir_destino/Genero.header
	echo "descricao" > $dir_destino/Horario.header
	echo "descricao" > $dir_destino/Ingresso.header
	echo "municipio,estado" > $dir_destino/Naturalidade.header
	echo "descricao" > $dir_destino/Nacionalidade.header
	echo "nome" > $dir_destino/Pais.header
	echo "siape" > $dir_destino/Professor.header
	echo "nome" > $dir_destino/Sala.header
	echo "descricao" > $dir_destino/SituacaoDiscente.header
	echo "descricao" > $dir_destino/SituacaoDisciplina.header
	echo "descricao" > $dir_destino/SituacaoVinculo.header
	echo "descricao" > $dir_destino/Tipo.header
	echo "id_disciplina;turma;periodo;id_horario;id_sala" > $dir_destino/Turma.header
	echo "id_turma;siape" > $dir_destino/TurmaProfessor.header

	echo "Cor" > $dir_destino/autoincrement.list
        echo "Cota" >> $dir_destino/autoincrement.list
        echo "Curso" >> $dir_destino/autoincrement.list
        echo "Deficiencia" >> $dir_destino/autoincrement.list
        echo "Disciplina" >> $dir_destino/autoincrement.list
        echo "Escola" >> $dir_destino/autoincrement.list
        echo "EstadoCivil" >> $dir_destino/autoincrement.list
        echo "Genero" >> $dir_destino/autoincrement.list
        echo "Horario" >> $dir_destino/autoincrement.list
        echo "Ingresso" >> $dir_destino/autoincrement.list
        echo "Naturalidade" >> $dir_destino/autoincrement.list
        echo "Nacionalidade" >> $dir_destino/autoincrement.list
        echo "Pais" >> $dir_destino/autoincrement.list
        echo "Sala" >> $dir_destino/autoincrement.list
        echo "SituacaoDiscente" >> $dir_destino/autoincrement.list
        echo "SituacaoDisciplina" >> $dir_destino/autoincrement.list
        echo "SituacaoVinculo" >> $dir_destino/autoincrement.list
        echo "Tipo" >> $dir_destino/autoincrement.list
        echo "Turma" >> $dir_destino/autoincrement.list
}

export -f get_from_table
export -f get_cpf_from_matricula
export -f process_line
export -f process_input_cadastro
export -f process_input_vinculo
export -f process_input_disciplina
export -f process_input_turma_professor
export -f process_input_aluno_disciplina
export -f process_falta
export -f generate_headers

dir_fonte=$1
dir_destino=$2
periodo_atual=$3

mkdir -p $dir_destino
rm -f $dir_fonte/cpf-mat-mapping.csv

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $4 }' | awk '{ print $1 }' | sort | uniq > $dir_destino/SituacaoDiscente.data
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $4 }' | grep "Inativo" | awk -F "(" '{ print $2 }' | awk '{ $NF=""; print $0 }' | sed 's, $,,' | sort | uniq > $dir_fonte/situacao_vinculo.tmp
cat $dir_fonte/vinculo.csv | awk -F ";" '{ print $4 }' | sort | uniq >> $dir_fonte/situacao_vinculo.tmp
sort $dir_fonte/situacao_vinculo.tmp | uniq > $dir_destino/SituacaoVinculo.data
rm $dir_fonte/situacao_vinculo.tmp

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $5 }' | sort | uniq > $dir_fonte/ingresso.tmp
cat $dir_fonte/ingresso.tmp | awk '{$NF=""; print $0}' | sed 's, $,,' | sort | uniq > $dir_destino/Ingresso.data
rm $dir_fonte/ingresso.tmp

ed -s $dir_destino/Ingresso.data > /dev/null 2>&1 <<!
1
i
NÃO REGISTRADO
.
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $6 }' | sort | uniq > $dir_destino/Cota.data
ed -s $dir_destino/Cota.data > /dev/null 2>&1 <<!
1
/^$/s,,Não registrada,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $8 }' | sort | uniq > $dir_destino/Escola.data
ed -s $dir_destino/Escola.data > /dev/null 2>&1 <<!
1
/^$/s,,Não registrada,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $11 }' | sort | uniq > $dir_destino/Genero.data
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $12 }' | sort | uniq > $dir_destino/EstadoCivil.data
ed -s $dir_destino/EstadoCivil.data > /dev/null 2>&1 <<!
1
/^$/s,,Não registrado,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $13 }' | sort | uniq > $dir_destino/Nacionalidade.data
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $14 }' | sort | uniq > $dir_destino/Pais.data
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $15 }' | sort | uniq | awk -F " - " '{ print $1";"$2 }' > $dir_destino/Naturalidade.data
ed -s $dir_destino/Naturalidade.data > /dev/null 2>&1 <<!
1
/^$/s,,Não registrado;Não registrado,
w
q
!

cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $16 }' | sort | uniq > $dir_destino/Cor.data
cat $dir_fonte/cadastro.csv | awk -F ";" '{ print $17 }' | tr ',' '\n' | sed 's,^ ,,' | sort | uniq > $dir_destino/Deficiencia.data
cat $dir_fonte/vinculo.csv | awk -F ";" '{ print $3 }' | sort | uniq > $dir_destino/Curso.data

rm -f $dir_destino/Discente.data $dir_destino/DiscenteDeficiencia.data $dir_destino/DiscenteVinculo.data
cat $dir_fonte/cadastro.csv | awk -v f=$dir_fonte -v d=$dir_destino -v p=$periodo_atual '{ system("bash -c '\'' process_line process_input_cadastro \""f";"d";"p";"$0"\" '\'' ") }'
cat $dir_fonte/vinculo.csv | awk -v f=$dir_fonte -v d=$dir_destino -v p=$periodo_atual '{ system("bash -c '\'' process_line process_input_vinculo \""f";"d";"p";"$0"\" '\'' ") }'

rm -f $dir_destino/Disciplina.data
cat $dir_fonte/disciplinas.csv | awk -F ";" '{ print $2";"$4";"$5";"$6";"$7 }' | sort | uniq > $dir_fonte/disciplina.tmp
cat $dir_fonte/disciplina.tmp | awk -F ";" '{ print $5 }' | sort | uniq > $dir_destino/Tipo.data
cat $dir_fonte/disciplina.tmp | awk -v f=$dir_fonte -v d=$dir_destino '{ system("bash -c '\'' process_line process_input_disciplina \""f";"d";"$0"\" '\'' ") }'
rm $dir_fonte/disciplina.tmp

cat $dir_fonte/disciplinas.csv | awk -F ";" '{ print $9 }' | sort | uniq > $dir_destino/SituacaoDisciplina.data

# Fix data

ed -s $dir_destino/Naturalidade.data > /dev/null 2>&1 <<!
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
g/OLHO DGUA;PB/s,,OLHO D'ÁGUA;PB
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

ed -s $dir_destino/Cor.data > /dev/null 2>&1 <<!
g/Nýo declarada/s,,Não declarada
g/Indýgena/s,,Indígena
w
q
!

ed -s $dir_destino/Cota.data > /dev/null 2>&1 <<!
g/indgena/s,,indígena,g
g/pblica/s,,pública,g
g/mnim/s,,mínim,g
g/mdio/s,,médio,g
g/salrio/s,,salário,g
g/deficincia/s,,deficiência,g
w
q
!

ed -s $dir_destino/Deficiencia.data > /dev/null 2>&1 <<!
g/viso/s,,visão
g/Deficincia/s,,Deficiência
g/fsica/s,,física
g/Sndrome/s,,Síndrome
w
q
!

ed -s $dir_destino/Escola.data > /dev/null 2>&1 <<!
g/blica/s,,ública,g
w
q
!

ed -s $dir_destino/Genero.data > /dev/null 2>&1 <<!
g/Vivo/s,,Viúvo
w
q
!

ed -s $dir_destino/Tipo.data > /dev/null 2>&1 <<!
g/Obrigatria/s,,Obrigatória
w
q
!

cat $dir_fonte/resumo.csv | awk -F ";" '{ print $8 }' | sort | uniq > $dir_destino/Horario.data
cat $dir_fonte/resumo.csv | awk -F ";" '{ print $9 }' | sort | uniq > $dir_destino/Sala.data
cat $dir_fonte/resumo.csv | awk -F ";" '{ print $1";"$5";"$6";"$2 }' | tr -s ' ' | sort | uniq > $dir_destino/Disciplina.data

# Incluir uma disciplina vazia
ed -s $dir_destino/Disciplina.data > /dev/null 2>&1 <<!
1
i
0000000;0;0;DISCIPLINA NÃO ENCONTRADA
.
w
q
!

cat $dir_fonte/resumo.csv | awk -F ";" '{  print $3 }' | awk -F "," '{ print $1"\n"$2"\n"$3 }' | sort | uniq > $dir_destino/Professor.data

rm -f $dir_destino/Turma.data $dir_destino/TurmaProfessor.data
cat $dir_fonte/resumo.csv | awk -v f=$dir_fonte -v d=$dir_destino -v t=0 '{ t=t+1; system("bash -c '\'' process_line process_input_turma_professor \""f";"d";"t";"$0"\" '\'' ") }'

rm -f $dir_destino/DiscenteDisciplina.data
cat $dir_fonte/nota.csv | awk -v f=$dir_fonte -v d=$dir_destino '{ system("bash -c '\'' process_line process_input_aluno_disciplina \""f";"d";"$0"\" '\'' ") }'

cat $dir_fonte/frequencia.csv | awk -F ";" -v d=$dir_destino '{ for(i=8; i<=NF; i++) { system("bash -c '\'' process_falta \""d";"$i";"$1";"$2";"$3";"$4";"$5";"$6";"i"\" '\'' ")} }' > $dir_destino/Falta.data

generate_headers

