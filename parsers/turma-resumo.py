# coding: utf-8
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
        print '\n\n' 'O script em questão tem a função de exibir o resumo de uma determinada turma.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python turma-resumo_parse.py turma-resumo.html ou python turma-resumo_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Código da disciplina'
        print '- Nome da disciplina'
        print '- Código(s) do(s) professor(es)'
        print '- Turma'
        print '- Créditos'
        print '- Carga horária'
        print '- Período'
        print '- Horários'
        print '- Sala' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python turma-resumo_parse.py turma-resumo.html ou python turma-resumo_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

header = ['codigo da disciplina', 'nome da disciplina', 'turma', 'créditos', 'carga horária', 'período',
    'horários', 'sala', 'código dos professores']

# função que seleciona apenas os códigos de disciplinas
def formata_codigos(lista):
    aux = []
    for i in lista:
        if i.isnumeric():
           aux.append(i)
    return ','.join(aux)

# remove caractere de codificação desconhecida
def remove_caracter(string):
    ret = ""
    for i in string:
        if i != 'ý':
            ret += i
    return ret

try:
    # código e nome da disciplina
    dados = soup.find_all("div", class_="col-sm-10 col-xs-9")
    codigo_disciplina = dados[0].text.split('-')[0].strip()
    nome_disciplina = remove_caracter(dados[0].text.split('-')[1].strip())

    # código(s) de professor(es)
    if dados[1].text == '\n':
        codigo_professores = ''
    else:
        codigo_professores = formata_codigos(dados[1].text.strip().split())

    # turma, créditos, carga horária e período
    dados2 = soup.find_all("div", class_="col-sm-1 col-xs-1")
    turma = dados2[0].text
    creditos = dados2[1].text.split('/')[0]
    carga_horaria = dados2[1].text.split('/')[1]
    periodo = dados2[2].text

    # horários e sala
    dados3 = soup.find_all("div", class_="col-sm-4 col-xs-6")[0].text.split()

    # verifica se a disciplina tem apenas um horário, nenhum ou dois horários
    if len(dados3) == 3:
        horarios = '%s-%s' % (dados3[0], dados3[1])
        sala = dados3[2]
    elif len(dados3) == 0:
        horarios = ''
        sala = ''
    else:
        horarios = '%s-%s,%s-%s' % (dados3[0], dados3[1], dados3[3], dados3[4])
        sala = dados3[2]

    print '%s;%s;%s;%s;%s;%s;%s;%s;%s' % (codigo_disciplina, nome_disciplina,
        codigo_professores, turma, creditos, carga_horaria, periodo, horarios, sala)

except Exception as e:
    print e
