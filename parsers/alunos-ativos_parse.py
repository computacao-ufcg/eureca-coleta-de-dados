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
        print '\n\n' + 'O script em questão tem a função de exibir todas as matrículas dos alunos ativos no curso.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python alunos-ativos_parse.py pagina-alunos-ativos.html ou python alunos-ativos_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python alunos-ativos_parse.py pagina-html.html ou python alunos-ativos_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

try:
    # obtém todas as tags <td>
    dados = soup.select("td.text-center")

    # filtra apenas matrícula e se o aluno é concluinte ou não (1 ou 0) de todos os registros
    for item in range(2, len(dados), 5):
        matricula = dados[item].text.strip()
        concluinte = dados[item+1].input.get('value')
        if concluinte == None:
            concluinte = 0
        print '%s;%s' % (matricula, concluinte)

except Exception as e:
    print e
