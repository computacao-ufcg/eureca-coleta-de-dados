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
        print '\n\n' 'O script em questão tem a função de exibir as frequências de alunos de uma determinada turma.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python turma-frequencia_parse.py turma-frequencias.html ou python turma-frequencia_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Matrícula do aluno'
        print '- Número total de faltas'
        print '- Registro de cada uma das aulas da disciplina?: 0 (presença) ou 1 (falta)' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python turma-frequencia_parse.py turma-frequencia.html ou python turma-frequencia_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

header = ['matricula', 'total de faltas', 'presença/falta por aula registrada']

try:
    # descobrindo quantas colunas possui a tabela
    colunas = soup.select("thead tr th")

    # buscando todos os dados dos alunos
    alunos = soup.select("td")

    # verifica se a tabela de frequências não está vazia
    if len(alunos) != 0:
        for i in range(0, len(alunos), len(colunas)):
            matricula = alunos[i+1].text
            total_faltas = alunos[i+len(colunas)-2].text
            faltas = ';'.join(map(lambda x: str(0) if x.text == '' else str(1), alunos[i+3:i+len(colunas)-2]))
            print '%s;%s;%s' % (matricula, total_faltas, faltas)

except Exception as e:
    print e
    