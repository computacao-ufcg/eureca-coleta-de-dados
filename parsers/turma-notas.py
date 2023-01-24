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
        print '\n\n' 'O script em questão tem a função de exibir as notas de alunos de uma determinada turma.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python turma-notas_parse.py turma-notas.html ou python turma-notas_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Matrícula do aluno'
        print '- Nome do aluno'
        print '- Nota do 1º estágio'
        print '- Nota do 2º estágio'
        print '- Nota do 3º estágio'
        print '- Média parcial'
        print '- Nota do exame final'
        print '- Média final'
        print '- Observações' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python turma-notas_parse.py turma-notas.html ou python turma-notas_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

# verifica se o aluno possui ou não observações na tabela de notas
def verifica_observacoes(observacao):
    if observacao.text == ' ':
        return ";Sem observações"
    else:
        return ';' + observacao.text.strip()

try:
    periodo = soup.find_all("div", class_="col-sm-2 col-xs-3")[-1].text
    codigo_disciplina = soup.find_all("div", class_="col-sm-10 col-xs-9")[0].text.split(' - ')[0]
    turma = soup.find_all("div", class_="col-sm-2 col-xs-3")[1].text

    # verifica o número de colunas que a tabela de notas possui
    n_columns = len(soup.select("thead tr th"))

    # informações de todos os alunos (não formatadas)
    alunos = soup.select("table td")

    # imprime várias linhas, onde cada uma representa as informações de notas de cada aluno
    # uma disciplina pode ter de 1 até 7 notas no semestre
    for i in range(0, len(alunos), n_columns):
        # junta todos os dados, separados por ';' até o penúltimo item de cada aluno
        output = ';'.join(map(lambda x: x.text, alunos[i+1 : (n_columns-1)+i]))
        output += verifica_observacoes(alunos[(n_columns - 1) + i])
        print output
        
except Exception as e:
    print e
    