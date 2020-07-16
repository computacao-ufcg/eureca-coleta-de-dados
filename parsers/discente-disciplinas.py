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
        print '\n\n' 'O script em questão tem a função de exibir as disciplinas do histórico de um aluno.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python aluno-disciplinas_parse.py pagina-historico.html ou python aluno-disciplinas_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Código da disciplina'
        print '- Nome da disciplina'
        print '- Tipo da disciplina: (obrigatória ou optativa)'
        print '- Quantidade de créditos'
        print '- Carga horária da disciplina'
        print '- Média obtida na disciplina'
        print '- Situação na disciplina: (aprovado, em curso ou reprovado)'
        print '- Período em que foi cursada a disciplina' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python aluno-disciplinas_parse.py historico-aluno.html ou python aluno-disciplinas_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

# cabeçalho da resposta
header = ['codigo disciplina', 'nome disciplina', 'tipo', 'créditos', 'carga horária',
    'média', 'situação', 'período']

# função que retorna apenas o nome da disciplina dentre o nome da disciplina e o
#nome do professor, bem como a retirada de espaços em branco desnecessários.
def formata_nome_disciplina(attrs):
    info = attrs.split('\n')
    disc_name = info[1].strip()
    return disc_name

# função que retorna a média na disciplina sem espaços em branco desnecessários.
def formata_media_disciplina(attrs):
    return attrs.strip()

# remove caractere(s) de codificação desconhecida
def remove_caracter(text):
    retorno = ""
    for i in range(len(text)):
        if text[i] not in ['ï','¿','½','ý']:
            retorno += text[i]
    return retorno

try:
    # seleciona todas as disciplinas do histórico de um aluno
    discs = soup.select("#disciplinas table tbody tr td")

    # saída dos dados
    for i in range(0, len(discs), 8):
        aux = ''
        aux += discs[i].text + ';' + remove_caracter(formata_nome_disciplina(discs[i+1].text)) + ';'
        aux += remove_caracter(discs[i+2].text) + ';' + discs[i+3].text + ';' + discs[i+4].text + ';' 
        aux += formata_media_disciplina(discs[i+5].text) + ';' + discs[i+6].text + ';' + discs[i+7].text
        print aux

except Exception as e:
    print e