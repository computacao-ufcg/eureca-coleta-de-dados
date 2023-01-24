#!/usr/bin/python
#coding: utf-8
import codecs
from bs4 import BeautifulSoup
import sys, os
import glob

# configurando encoding
reload(sys)
sys.setdefaultencoding('utf-8')

# código de cores para o menu de ajuda do comando
RED = "\033[1;31m"  
RESET ="\033[0;0m"

if len(sys.argv) == 2:
    if sys.argv[1] == '--help' or sys.argv[1] == '-h':
        print '\n\n' + 'O script em questão tem a função de exibir algumas informações do cadastro do aluno.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python aluno-cadastro_parse.py pagina-cadastro.html ou python aluno-cadastro_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Matrícula'
        print '- CPF'
        print '- Nome'
        print '- Situação do aluno'
        print '- Ingresso: (ano de entrada)'
        print '- Cota de ingresso (se houver, caso não haja é "-")'
        print '- Data de nascimento'
        print '- Tipo de instituição que concluiu o ensino médio: (Pública e/ou Privada)'
        print '- Ano de conclusão do ensino médio'
        print '- Email'
        print '- Gênero'
        print '- Estado civil'
        print '- Nacionalidade'
        print '- País de origem'
        print '- Naturalidade'
        print '- Cor'
        print '- Deficiências' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python aluno-cadastro_parse.py cadastro-aluno.html ou python aluno-cadastro_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html) , "html.parser")

header = ['matrícula', 'cpf', 'nome', 'situação', 'ingresso', 'cota', 'nascimento', 'tipo de instituição que concluiu o ensino médio',
    'ano de conclusão do ensino médio', 'email', 'gênero', 'estado civil', 'nacionalidade', 'país de origem',
    'naturalidade', 'cor', 'deficiências']

# verifica se o aluno possui ou não deficiências
def verifica_deficiencia(deficiencia):
    if deficiencia == "":
        return "Sem deficiências"
    else:
        return deficiencia

# remove caractere de codificação desconhecida
def remove_caracter(text):
    ret = ""
    for i in text:
        if i != 'ý':
            ret += i
    return ret

# verifica se o aluno possui dados de cota ou não
def possui_cota(aluno):
    if len(aluno) == 25:
        return True
    else:
        return False

# verifica se o aluno possui dados de cota e currículo ou não
def possui_cota_e_curriculo(aluno):
    if len(aluno) == 26:
        return True
    else:
        return False

try:
    aluno = soup.find_all("div", class_="col-sm-9 col-xs-7")

    # matrícula e nome
    tokens = aluno[0].text.strip().split('-')
    matricula, nome = tokens[0].strip(), tokens[1].strip()

    # situação e ingresso
    situacao, ingresso = aluno[2].text.strip(), aluno[3].text.strip()

    # valor padrão para cota, caso não tenha
    cota = ''

    if possui_cota(aluno):
        # cpf
        cpf = aluno[6].text.strip()

        # cota
        cota = aluno[4].text.strip()

        # nascimento e tipo de instituição que cursou o ensino médio
        nascimento, tipo_instituicao = aluno[5].text.strip(), aluno[9].text.strip()
        
        # ano de conclusão do ensino médio e e-mail
        ano_conclusao, email = aluno[8].text.strip(), aluno[15].text.strip()

        # sexo e estado civil
        genero, estado_civil = aluno[16].text.strip(), aluno[17].text.strip()
        
        # nacionalidade e país de origem
        nacionalidade, pais_origem = aluno[20].text.strip(), aluno[21].text.strip()

        # naturalidade e cor
        naturalidade, cor  = aluno[22].text.strip(), aluno[23].text.strip()

        # deficiências
        deficiencias = aluno[24].text.strip()

        # verifica se no cadastro existe informação do currículo, que corresponde
        ## a um ano com 4 dígitos.
        if len(aluno[2].text.strip()) == 4:
            situacao, ingresso = aluno[3].text.strip(), aluno[4].text.strip()
            cota = ''


    elif possui_cota_e_curriculo(aluno):
        # situação e ingresso
        situacao, ingresso = aluno[3].text.strip(), aluno[4].text.strip()

        # cota
        cota = aluno[5].text.strip()

        # cpf
        cpf = aluno[7].text.strip()

        # nascimento e tipo de instituição que cursou o ensino médio 
        nascimento, tipo_instituicao = aluno[6].text.strip(), aluno[10].text.strip()

        # ano de conclusão do ensino médio e e-mail
        ano_conclusao, email = aluno[9].text.strip(), aluno[16].text.strip()

        # sexo e estado civil
        genero, estado_civil = aluno[17].text.strip(), aluno[18].text.strip()

        # nacionalidade e país de origem
        nacionalidade, pais_origem = aluno[21].text.strip(), aluno[22].text.strip()

        # naturalidade e cor
        naturalidade, cor = aluno[23].text.strip(), aluno[24].text.strip()

        # deficiências
        deficiencias = aluno[25].text.strip()
 
    else:
        # cpf
        cpf = aluno[5].text.strip()

        # nascimento e tipo de instituição que cursou o ensino médio
        nascimento, tipo_instituicao = aluno[4].text.strip(), aluno[8].text.strip()

        # ano de conclusão do ensino médio e e-mail
        ano_conclusao, email = aluno[7].text.strip(), aluno[14].text.strip()

        # sexo e estado civil
        genero, estado_civil = aluno[15].text.strip(), aluno[16].text.strip()
        
        # nacionalidade e país de origem
        nacionalidade, pais_origem = aluno[19].text.strip(), aluno[20].text.strip()

        # naturalidade e cor
        naturalidade, cor = aluno[21].text.strip(), aluno[22].text.strip()

        # deficiências
        deficiencias = aluno[23].text.strip()

    output = '%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s' % (matricula, cpf, nome, situacao, ingresso, 
        remove_caracter(cota), nascimento, remove_caracter(tipo_instituicao), ano_conclusao, email, genero, 
        remove_caracter(estado_civil), remove_caracter(nacionalidade), pais_origem, remove_caracter(naturalidade), 
        remove_caracter(cor), remove_caracter(verifica_deficiencia(deficiencias)))

    print output

except Exception as e:
    print e 
