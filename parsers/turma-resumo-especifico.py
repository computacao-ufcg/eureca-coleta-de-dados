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
        print 'sintaxe p/ execução: ' + RED + 'python turma-resumo-especifico.py turma-resumo.html ou python turma-resumo-especifico.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente (por linha):' + '\n'
        print '- Código da disciplina'
        print '- Número da turma'
        print '- Matrícula'
        print '- Código do curso'
        print '- Nome'
        print '- Situação'
        print '- Média final' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python turma-resumo-especifico.py turma-resumo.html ou python turma-resumo-especifico.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

try:
    # código e turma
    codigo_disc = soup.find_all("div", class_="col-sm-10 col-xs-9")[0].text.split()[0]
    turma = soup.find_all("div", class_="col-sm-1 col-xs-1")[0].text

    # informações dos alunos
    alunos = soup.select("table tbody td")

    for i in range(0, len(alunos), 7):
        matricula = alunos[i+1].text
        curso = alunos[i+2].text
        nome = alunos[i+3].text
        situacao = alunos[i+4].text
        media_final = alunos[i+5].text
        print '%s;%s;%s;%s;%s;%s;%s' %(codigo_disc, turma, matricula, curso, nome, situacao, media_final)

except Exception as e:
    print e
