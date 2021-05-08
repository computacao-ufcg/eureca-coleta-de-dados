#!/usr/bin/python
#coding: utf-8
import codecs
from bs4 import BeautifulSoup
import sys, os
import glob
import traceback

# código de cores para o menu de ajuda do comando
RED = "\033[1;31m"  
RESET ="\033[0;0m"

if len(sys.argv) == 2:
    if sys.argv[1] == '--help' or sys.argv[1] == '-h':
        print '\n\n' + 'O script em questão tem a função de exibir algumas informações do histórico do aluno.' + '\n'
        print 'sintaxe p/ execução: ' + RED + 'python aluno-historico_parse.py pagina-historico.html ou python aluno-historico_parse.py <options>' + RESET
        print 'options:' + '\n' + '* -h ou --help ==> exibe informações sobre o script.' + '\n'
        print 'Informações sobre os dados da saída padrão na ordem correspondente:' + '\n'
        print '- Currículo: ano ao qual o aluno foi matriculado'
        print '- Carga horária obrigatória integralizada'
        print '- Créditos obrigatórios integralizados'
        print '- Carga horária optativa integralizada'
        print '- Créditos optativos integralizados'
        print '- Carga horária complementar integralizada'
        print '- Créditos complementares integralizados'
        print '- CRA: Coeficiente de rendimento acadêmico'
        print '- MC: Média de conclusão'
        print '- IEA: Indíce de eficiência acadêmica'
        print '- Períodos integralizados'
        print '- Trancamentos totais'
        print '- Matrículas institucionais'
        print '- Mobilidade estudantil'
        print '- Créditos matriculados: (no período atual)'
        print '- Média geral no ENEM' + '\n\n'
        sys.exit()
    else:
        html = sys.argv[1]
else:
    print 'usage: python aluno-historico_parse.py historico-aluno.html ou python aluno-historico_parse.py <options>'
    print 'options: -h ou --help'
    sys.exit()

soup = BeautifulSoup(open(html), "html.parser")

header = ['curriculo', 'carga horária obrigatória integralizada',
    'créditos obrigatórios integralizados', 'carga horária optativa integralizada',
    'créditos optativos integralizados', 'carga horária complementar integralizada',
    'créditos complementares integralizados', 'cra', 'mc', 'iea', 'períodos integralizados',
    'trancamentos totais', 'matrículas institucionais', 'mobilidade estudantil',
    'créditos matriculados','média do enem']

# função que retira os múltiplos espaços entre a quantidade de horas e sua porcentagem 
# e deixa apenas um único espaço entre as duas strings. 
def formatter(attrs):
    ret = []
    attrs2 = attrs.split('\n')
    for i in range(len(attrs2)):
        aux = attrs2[i].strip()
        ret.append(aux)
    return ret[0]

# conta o número de <td>'s que possuem em cada tabela e retorna uma lista
def count_tds_per_table():
    # tabelas do historico [disciplinas, integr. curricular, ...]
    tables = soup.find_all("table")
    sizes = []
    for i in range(len(tables)):
        sizes.append(len(tables[i].select("td")))
    return sizes

# soma a quantidade de <td>'s de cada tabela até uma certa tabela para descobrir
# o indíce em que está a média do ENEM.
def acumulador(lista, limit):
    soma = 0
    for i in range(limit+1):
        soma += lista[i]
    return soma

try:
    # curriculo
    curriculo = soup.find_all("div", class_="col-sm-6")[5].text.split()[1]

    # para verificar se o aluno é reoptantante ou transferido
    ingresso = soup.find_all("div", class_="col-sm-6")[6].text.split()[1]

    # para verificar se o aluno é graduado ou graduando
    situacao = soup.find_all("div", class_="col-sm-6")[7].text.split()[1]

    # dados da integralização curricular
    dados = soup.select("#integralizacao table tbody tr td.text-center")
    ch_obrig_integr = formatter(dados[1].text.strip())
    creditos_obrig_integr = formatter(dados[3].text.strip())
    ch_opt_integr = formatter(dados[7].text.strip())
    creditos_opt_integr = formatter(dados[9].text.strip())
    ch_ativ_comp_integr = formatter(dados[13].text.strip())
    creditos_ativ_comp_integr = formatter(dados[15].text.strip())
    
    # cra, mc, iea
    aluno = soup.find_all("div", class_="col-md-2 col-sm-2")
    cra, mc, iea = aluno[0].text, aluno[1].text, aluno[2].text

    # pi = períodos integralizados, tt = trancamentos totais
    # mi = matrículas institucionais, me = mobilidade estudantil
    indices = soup.find_all("div", class_="col-md-1 col-sm-1 total")
    pi, tt, mi = indices[0].text, indices[1].text, indices[2].text
    me = indices[3].text

    # cm = créditos matriculados
    if situacao in ['GRADUADO', 'CANCELADO', 'CANCELAMENTO', 'TRANSFERIDO', 'CONCLUIDO']:
        cm = '0'
    else:
        cm = indices[4].text

    # média enem
    tags = soup.find_all("td")
    if ingresso in ['CONVENIO', 'JUDICIAL', 'REOPCAO', 'TRANSFERENCIA']:
        media_enem = '-'
    else:
        # base para descobrir qual tabela contém a nota do ENEM
        header_tabelas = soup.find_all("div", class_="panel-heading")
        flag = False
        for i in range(len(header_tabelas)):
            if header_tabelas[i].h2.text == "Notas de ingresso Vestibular/ENEM":
                tds_per_table = count_tds_per_table()
                index = acumulador(tds_per_table, i-1)
                media_enem = tags[index].text
                flag = True
        if not flag:
            media_enem = '-'

    # saída dos dados
    output = ''
    output += '%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s' % (curriculo,
        ch_obrig_integr, creditos_obrig_integr, ch_opt_integr, creditos_opt_integr,
        ch_ativ_comp_integr, creditos_ativ_comp_integr, cra, mc, iea, pi, tt, mi,
        me, cm, media_enem)

    print output

except Exception as e:
    print traceback.format_exc()
