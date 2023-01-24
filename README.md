# pdc-coleta-de-dados

A coleta dos dados é feita através do script:

coleta-dados.sh matriculas periodos credencial dir_destino [true]

matriculas: arquivo contendo as matrículas de todos os discentes do curso (não tem como fazer crawler dessa informação, pois só é possível listar os alunos ativos e há um relatório com os egressos dos últimos 15 anos, mas eu consegui essa informação do nosso antigo sistema de egressos)

periodos: arquivo contendo os períodos que serão extraídos (ex. 2002.1 até 2020.1)

credencial: arquivo com as credenciais do coordenador no formato <login>,<senha>

dir_destino: é o diretório onde os dados serão armazenados; a hierarquia gerada é a seguinte. O diretório dir_destino/html contém as páginas que foram baixadas em dois subdiretórios. dir_destino/html/discente tem os dados dos discentes, enquanto que dir_destino/html/turmas/<periodo> tem os dados das turmas do período <periodo>. O diretório dir_destino/input tem os dados extraídos pelos parsers. Já o diretório dir_destino/tabelas tem os dados das tabelas a serem importadas.

true: é um parâmetro opcional que indica que os dados devem ser anonimizados.

O script coleta_dados.sh chama quatro outros scripts:

crawl.sh: faz o “crawling” das páginas html
extrai-dados.sh: faz o “scraping” dos dados das páginas html
anonimize.sh: faz a anonimização dos dados extraídos, se necessário, e gera CPFs “fake" (que é a chave primária do discente), caso o CPF não tenha sido registrado no controle acadêmico
gera-tabelas.sh: gera as tabelas a serem importadas

Só para ter uma ideia do tempo de processamento, para o curso de Ciência da Computação (2144 discentes e 37 períodos) os tempos foram os seguintes:
- crawl.sh: 3hs 19 min
- extrai-dados.sh: 13hs 45 min
- anonimize.sh: 4hs 38min
- gera-tabelas.sh: 29hs 11 min

Total: 50hs 53min

