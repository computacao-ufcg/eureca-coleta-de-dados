#!/usr/bin/python
#coding: utf-8
import codecs
from bs4 import BeautifulSoup
import sys, os
import glob

# código de cores para o menu de ajuda do comando
RED = "\033[1;31m"  
RESET ="\033[0;0m"

if len(sys.argv) == 2:
    if sys.argv[1] == '--help' or sys.argv[1] == '-h':
        print '\n\n' + 'O script em questão tem a função de exibir matrícula e forma de evasão de todos os alunos inativos do curso.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python alunos-inativos_parse.py pagina-alunos-inativos.html ou python alunos-inativos_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python alunos-inativos_parse.py pagina-alunos-inativos.html ou python alunos-inativos_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

try:
  # obtém todas as tags <td>
  alunos = soup.select("td")

  # filtra apenas matrícula e forma de evasão de todos os alunos
  for i in range(1, len(alunos), 4):
    print '%s;%s' % (alunos[i].text, alunos[i+2].text)
    
except Exception as e:
  print e