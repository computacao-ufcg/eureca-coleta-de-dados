# coding: utf-8
import codecs
from bs4 import BeautifulSoup
import sys, os
import glob

# código de cores para o menu de ajuda do comando
RED = "\033[1;31m"  
RESET ="\033[0;0m"

if len(sys.argv) == 2:
    if sys.argv[1] == '--help' or sys.argv[1] == '-h':
        print '\n\n' 'O script em questão tem a função de exibir as turmas ofertadas no próximo período.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python turmas-ofertadas_parse.py turmas-ofertadas.html ou python turmas-ofertadas_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Código da disciplina'
        print '- Turma' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python turmas-ofertadas_parse.py turmas-ofertadas.html ou python turmas-ofertadas_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

try:
    dados = soup.find_all("td", class_="text-center")

    for i in range(0, len(dados), 3):
        codigo = dados[i].text
        turma = dados[i+1].input['value']
        print '%s;%s' % (codigo, turma)

except Exception as e:
    print e

