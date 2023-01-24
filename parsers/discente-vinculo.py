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
        print '\n\n' + 'O script em questão tem a função de exibir algumas informações sobre os vínculos anteriores dos alunos.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python aluno-vinculo_parse.py pagina-historico.html ou python aluno-vinculo_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Matrícula atual'
        print '- Matrícula do vínculo'
        print '- Curso no vínculo'
        print '- Situação do vínculo'
        print '- Período do vínculo' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python aluno-vinculo_parse.py historico-aluno.html ou python aluno-vinculo_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

header = ['matrícula atual', 'matrícula do vínculo', 'curso', 'situação', 'período de evasão']

# remove caractere de codificação desconhecida
def remove_caracter(text):
    retorno = ""
    for i in text:
        if i != 'ý':
            retorno += i
    return retorno

try:
    # Matrícula
    data = soup.find_all("div", class_="col-sm-6")
    matricula = data[0].text.split()[1].strip()

    # Selecionando todos os cabeçalhos de tabelas a fim de descobrir se existe
    #uma tabela de Outros vínculos.
    header_tabelas = soup.find_all("div", class_="panel-heading")

    # Selecionando todas as tabelas da página
    tables = soup.find_all("table")

    # Descobrindo se existe a tabela Outros vínculos
    for i in range(len(header_tabelas)):
        if "Outros v" in header_tabelas[i].h2.text:
            vinculos = tables[i-1].select("td")
            for i in range(0, len(vinculos), 4):
                matricula_vinculo = vinculos[i].text.strip()  
                curso_vinculo = remove_caracter(vinculos[i+1].text.strip())
                situacao_vinculo = remove_caracter(vinculos[i+2].text.strip())
                periodo_vinculo = vinculos[i+3].text.strip()
                print '%s;%s;%s;%s;%s' % (matricula, matricula_vinculo, curso_vinculo, 
                    situacao_vinculo, periodo_vinculo)

except Exception as e:
    print e