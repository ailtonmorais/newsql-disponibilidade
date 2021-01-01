<p align="center">
<br>Departamento de Computação (DComp-So)</br>
<br>Centro de Ciências e Gestão em Tecnologias (CCGT)</br>
<br>UNIVERSIDADE FEDERAL DE SÃO CARLOS - Campus Sorocaba</br><br></br>
<img src="./images/ufscar.png" width="166">
</p>

# NewSQL - Disponibilidade
<sub>Autores: Adriano Tomicha & Ailton Morais</sub>

<a id="indice"></a>
# Índice
* [Introdução](#introducao)    
	* [MySQL Cluster](#sobre-mysqlcluster)
	* [CockroachDB](#sobre-cockroachdb)
    * [Estudo de Caso](#caso)	
* [Visão Geral](#geral)
	* [Alta Disponibilidade](#disponibilidade)
    	* [MySQL Cluster](#disponibilidade-mysqlcluster)
    	* [CockroachDB](#disponibilidade-cockroachdb)
* [Resiliência a Falhas](#resiliencia)	
    * [MySQL Cluster](#resiliencia-mysqlcluster)
    * [CockroachDB](#resiliencia-cockroachdb)
* [Instalação](#instalacao)
	* [Docker](#instalacao-docker)
	* [MySQL Cluster](#instalacao-mysqlcluster)
	* [CockroachDB](#instalacao-cockroachdb)
* [Conclusão](#conclusao)
	* [Resumo](#resumo)
* [Glossário](#glossario)
* [Referências Bibliográficas](#referencias)

<a id="introducao"></a>
# Introdução

A proposta do tutorial é apresentar o passo a passo desde a instalação, configuração, casos de uso e testes que irão ajudar a entender a abordagem da **disponibilidade** do [MySQL Cluster](https://www.mysql.com/products/cluster/) & [CockroachDB](https://www.cockroachlabs.com/product/)

<a id="sobre-mysqlcluster"></a>
### MySQL Cluster

MySQL Cluster é o banco de dados distribuído que combina escalabilidade linear e alta disponibilidade. Foi projetado para aplicativos de missão crítica, fornece acesso em tempo real na memória com consistência transacional em conjuntos de dados particionados e distribuídos [(MySQL 2020a)](#MySQL-2020a).

O Cluster MySQL tem replicação entre clusters em vários locais geográficos integrados e uma arquitetura nada compartilhada com reconhecimento de localidade de dados torna a escolha perfeita para execução em hardware comum e em infraestrutura em nuvem distribuída globalmente [(MySQL 2020a)](#MySQL-2020a).

<a id="sobre-cockroachdb"></a>
### CockroachDB

CockroachDB é um banco de dados SQL distribuído construído em um armazenamento de chave-valor transacional e fortemente consistente. Ele é dimensionado horizontalmente, sobrevive a falhas de disco, máquina, rack e até mesmo de datacenter com interrupção de latência mínima e sem intervenção manual, suporta transações ACID fortemente consistentes e fornece uma API SQL familiar para estruturar, manipular e consultar dados [(Cockroach Labs 2020a)](#Cockroach-2020a).

<a id="caso"></a>
### Estudo de Caso

Neste tutorial será utilizado o Banco de Dados do Northwind que foi criado pela Microsoft para atender os seus produtos, mas ao longo do tempo se tornou uma amostra bastante utilizada em tutoriais de Banco de Dados não desenvolvidos pela Microsoft. Dentre as amostras do Banco de Dados Northwind podemos destacar:

* Suppliers
  
* Customers
  
* Employees
  
* Products
  
* Shippers
  
* Orders

No total o Banco de Dados Northwind contém 14 tabelas. O diagrama com o relacionamento entre as tabelas pode ser visto abaixo:

<p align="center">
<img src="./images/northwind-er-diagram.png" width="974">
<br>Figura 1: Diagram ER. Fonte: (YugabyteDB 2020a)</br>
</p>

<a id="geral"></a>
# Visão Geral

Os Bancos de Dados relacionais surguiram para necessidade de armazenamento de dados, mas na época não tinhamos as tecnologias Web e os diversos tipos de dispositivos que geram enorme quantidade de dados atualmente.

Com a evolução tecnológica e o astronômico crescimento dos dispositivos móveis conectados a internet abriu caminho para a era da Internet das Coisas e já estamos vivendo mudanças significativas na sociedade. Veja alguams declarações que demonstram tal potencial:

* A  Internet das Coisas será uma revolução muito maior que a internet e os celulares juntos! [(Krco, Srdjan, et al, 2013)](#Krco-2013);
  
* A Internet das Coisas representa uma nova inteligência para os negócios, É uma mudança de paradigma do consumo, uma revolução do comportamento humano, um caminho para um novo mundo onde tudo e todos estarão conectados e sem fronteiras. Um caminho para um mundo que ainda não imaginamos [(Dias, 2016)](#Dias-2016).

A partir destes desafios surgiram os novos sistemas de Banco de Dados nomeados como **NoSQL** (Not Only SQL). Estas soluções fornecem alta disponbilidade, escalabilidade e uma arquitetura distribuída com crescimento horizontal. Mesmo sendo capaz de manipular grandes quantidades de dados, os Banco de Dados NoSQL geralmente não possuem suporte para as propriedades ACID:

* **A**tomicity: Transação deve ser executado por completo ou não executada;

* **C**onsistency: Se o resultado final não for válido ou ocorrer falha, os dados devem ser o mesmo antes do inicio da transação;

* **I**solation: Um transação em andamente não deve sofrer interferência de outra transação concorrente;

* **D**urability: Garante os dados disponíveis em definitivo.

Para quebrar alguns paradgimas foi criado os sistemas de Banco de Dados **NewSQL** que combinam funcionalidades do modelo relacional e NoSQL. Segundo [Pavlo e Aslett, 2016](#Pavlo-2016) os sistemas **NewSQL** são soluções modernas que buscam prover o mesmo desempenho escalável dos Bancos de Dados **NoSQL** para cargas de trabalho **OLTP** com tı́pico suporte completo a todas as propriedades **ACID**, como encontrado nos Banco de Dados Relacionais.

Os sistemas de Banco de Dados NewSQL são adequados para aplicações que utilizavam o **SGBD** tradicional, mas que surgiu a necessidade de escalabilidade adicional e aprimoramento de desempenho (YUAN, et al, 2015)](#Yuan-2015).

Os sistemas de Banco de Dados NewSQL tem como característica a execução de transações de leitura e gravação que:

* São de curta duração;

* Atingue um pequeno subconjunto de dados;
  
* Não fazem varredura de tabela completa;

* Possuem consultas repetidas com diferentes entradas.

De acordo com [Pavlo e Aslett, 2016](#Pavlo-2016) pode existir uma caracterização mais restrita com a implementação de um sistema de Banco de Dados NewSQL que utiliza:

* Um esquema de controle de simultaneidade sem bloqueio;

* Uma arquitetura distribuída não compartilhada.

[STONEBRAKER e CATTEL, 2011](#STONEBRAKER-CATTEL-2011) definem as cinco principais características de um SGBD NewSQL abaixo:

1. SQL como o principal mecanismo de interação de aplicativos;

2. Suporte ACID para transações;
  
3. Um mecanismo de controle de simultaneidade não bloqueável, portanto as leituras em tempo real não entrarão em conflito com as escritas;

4. Uma arquitetura que oferece um desempenho por nó muito maior que o disponível nas soluções SGBDs tradicionais;

5. Uma arquitetura de escala, não compartilhada, capaz de funcionar em um grande número de nós sem sofrerem estrangulamentos.

Segundo [Pavlo e Aslett, 2016](#Pavlo-2016) as três categorias que melhor representam os sistemas de Banco de Dados NewSQL são:

1. Sistemas inovadores construídos a partir do zero usando uma nova arquitetura;

2. Middleware que re-implementam a mesma infra-estrutura que foi desenvolvida na década de 2000 pelo Google e outros;
   
3. Ofertas de banco de dados como serviço de provedores de computação em nuvem que também são baseadas em novas arquiteturas.

Certamente podemos considerar que os sistemas de Banco de Dados NewSQL conseguem resolver os principais problemas de escalabilidade, desempenho e disponibilidade que temos no sistema relacional tradicional. Segundo [KAUR, 2017](#Kaur-2017) o NewSQL deve ser considerado como uma alternativa ao NoSQL ou banco de dados relacional clássico para novos aplicativos OLTP.

<a id="disponibilidade"></a>
# Alta Disponibilidade

A alta disponibilidade não está relacionada somente ao tempo que um sistema está acessível, mas também ao tempo que o sistema precisa para responder às solicitações dos usuários. Geralmente além dos testes é necessário prover componentes redundantes para obter um nível de disponibilidade alta mesmo em caso de falhas em parte da infra-estrutura.

<a id="disponibilidade-mysqlcluster"></a>
## MySQL Cluster

Para garantir a alta disponibilidade o MySQL Cluster se apoia em (MySQL 2020b):

* **Replicação síncrona**: Os dados em cada nó de dados são replicados de forma síncrona para outro nó de dados;

* **Failover automático**: - O mecanismo de pulsação do MySQL Cluster detecta instantaneamente quaisquer falhas e faz failover automaticamente, normalmente em um segundo, para outros nós no cluster, sem interromper o serviço aos clientes;

* **Autocorreção**: Os nós com falha são capazes de se autocorrigir reiniciando automaticamente e ressincronizando com outros nós antes de reingressar no cluster, com total transparência do aplicativo;

* **Arquitetura de nada compartilhado**: Nenhum ponto único de falha, cada nó tem seu próprio disco e memória, portanto, o risco de uma falha causada por componentes compartilhados, como armazenamento, é eliminado;

* **Replicação geográfica**: A replicação geográfica permite que os nós sejam espelhados em data centers remotos para recuperação de desastres.

<a id="disponibilidade-cockroachdb"></a>
## CockroachDB

Para o CockroachDB escalar os serviços horizontalmente é fundamental, para tal devemos utilizar a replicação dos dados em diversos servidores. Em caso de falha de um desses servidores, podemos continuar com os serviços operacionais. Segue um resumo com os principais conceitos utilizados para garantir a disponibilidade (Cockroach Labs 2020b):

* **Consistência**: Usa a "consistência" tanto no sentido da semântica ACID (Atomicity, Consistency, Isolation, Durability) quanto no teorema CAP (Consistency, Availability, Partition Tolerance), embora menos formalmente do que qualquer definição. O objetivo é garantir os dados livres de anomalias;

* **Intervalo**: Armazena todos os dados do usuário (tabelas, índices, etc.) e quase todos os dados do sistema em um mapa gigante classificado de pares de chave-valor. Este keyspace é dividido em "intervalos", pedaços contíguos do keyspace, de forma que cada chave pode sempre ser encontrada em um único intervalo;

* **Consenso**: Quando um Intervalo recebe uma gravação, um quorum de nós contendo réplicas do intervalo confirma a gravação. Isso significa que seus dados são armazenados com segurança e a maioria dos nós concorda com o estado atual do banco de dados, mesmo se alguns dos nós estiverem offline. Quando uma gravação não chega a um consenso, o progresso de encaminhamento é interrompido para manter a consistência dentro do cluster;

* **Replicação**: Criação e distribuição de cópias de dados, bem como a garantia de que as cópias permaneçam consistentes. No entanto, existem vários tipos de replicação: a saber, síncrona e assíncrona. O CockroachDB usa a replicação síncrona que requer que todas as gravações se propaguem para um quorum de cópias dos dados antes de serem consideradas confirmadas;

* **Transações**: Conjunto de operações realizadas em seu banco de dados que atendem aos requisitos da semântica ACID. Este é um componente crucial para um sistema consistente confie no seu banco de dados;

* **Disponibilidade Multi-ativa**: O consenso de alta disponibilidade permite que cada nó no cluster controle leituras e gravações para um subconjunto dos dados armazenados (em uma base por intervalo).

<a id="resiliencia"></a>
# Resiliência a Falhas

A confiabiliade de um sistema gerenciador de Banco de Dados tem um relação direta com a resiliência a falhas e redundância dos dados. Segundo [Silberschatz, 2006](#Silberschatz-2006) a solução para o problema de confiabilidade é introduzir a redundância; ou seja, armazenamos informações extras que normalmente não são necessárias, mas que podem ser usadas no caso de falha de um disco, para recriar a informação perdida. Assim, mesmo que um disco falhe os dados não são perdidos [...]

<a id="resiliencia-mysqlcluster"></a>
## MySQL Cluster

No mínimo de três computadores para executar um cluster viável. No entanto, o número mínimo recomendado de computadores em um Mysql Cluster NDB é quatro: um para cada para executar o gerenciamento e os nós SQL, e dois computadores para servir como nós de dados. O objetivo dos dois nós de dados é fornecer redundância; o nó de gerenciamento deve ser executado em uma máquina separada para garantir serviços de arbitragem contínuos no caso de um dos nós de dados falhar [(MySQL 2020c)](#MySQL-2020c).

<p align="center">
<img src="./images/mysql_cluster_availability_v1.png" width="867">
<br>Figura 2: Sem um único ponto de falha, o MySQL Cluster oferece extrema resiliência a falhas. Fonte: (MySQL 2020b)</br>
</p>

<a id="resiliencia-cockroachdb"></a>
## CockroachDB

Quando você estiver pronto para executar o seu sistema em produção em uma única região, é importante implantar pelo menos 3 nós do CockroachDB para aproveitar as vantagens dos recursos de replicação, distribuição, rebalanceamento e resiliência automáticos [(Cockroach 2020c)](#Cockroach-2020c).

<p align="center">
<img src="./images/topology_basic_production_v1.png" width="960">
<br>Figura 3: Topologia Básica. Fonte: (Cockroach 2020c)</br>
</p>

<a id="referencias"></a>
# Referências Bibliográficas

<a id="MySQL-2020a"></a>
- MySQL. [MySQL CLUSTER, 2020a](https://www.mysql.com/products/cluster/mysql-cluster-datasheet.pdf). Acesso em 14 out 2020 às 19h20m.

<a id="MySQL-2020b"></a>
- MySQL. [MySQL CLUSTER, 2020b](https://www.mysql.com/products/cluster/availability.html). Acesso em 17 out 2020 às 11h00m.

<a id="MySQL-2020c"></a>
- MySQL. [Appendix A MySQL 5.7 FAQ: NDB Cluster, 2020c](https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/faqs-mysql-cluster.html). Acesso em 17 out 2020 às 18h15m.
  
<a id="Cockroach-2020a"></a>
- Cockroach Labs. [What is CockroachDB, 2020a](https://www.cockroachlabs.com/docs/stable/frequently-asked-questions.html). Acesso em 16 out 2020 às 17h30m.

<a id="Cockroach-2020b"></a>
- Cockroach Labs. [Architecture Overview, 2020b](https://www.cockroachlabs.com/docs/stable/architecture/overview.html). Acesso em 17 out 2020 às 15h30m.

<a id="Cockroach-2020c"></a>
- Cockroach Labs. [Architecture Overview, 2020c](https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/faqs-mysql-cluster.html). Acesso em 17 out 2020 às 18h35m.

<a id="YugabyteDB-2020a"></a>
- YugabyteDB. [YugabyteDB, 2020a](https://docs.yugabyte.com/latest/sample-data/northwind/). Acesso em 29 dez 2020 às 10h15m.
  
<a id="Krco-2013"></a>
- Krco, Srdjan, et al. [Comic book](https://iotcomicbook.files.wordpress.com/2013/10/iot_comic_book_special_br.pdf). The internet of things, 2012, p. 15. Acesso em 21 dez 2020 às 21h10m.
  
<a id="Dias-2016"></a>
- Dias, Renata Rapim de Freitas. Internet das Coisas sem Mistérios: Uma nova
inteligência para os negócios. São Paulo: Netpress Books, 2016.

<a id="[Pavlo-2016"></a>
- Pavlo, A. and Aslett. What’s really new with newsql? SIGMOD Rec., 45(2), 2016.

<a id="[Yuan-2015"></a>
- YUAN, L.-Y.; WU, L.; YOU, J.-H.; CHI, Y.  A demonstration of rubato db: A highly scalable
newsql database system for oltp and big data applications. In: ACM. Proceedings of the 2015
ACM SIGMOD International Conference on Management of Data. [S.l.], 2015. p. 907–912.

<a id="[Kaur-2017"></a>
- KAUR, K.; SACHDEVA, M.  Performance evaluation of newsql databases. In: IEEE. Inventive
Systems and Control (ICISC), 2017 International Conference on. [S.l.], 2017. p. 1–5.

<a id="STONEBRAKER-2011"></a>
- STONEBRAKER, Michael, CATTELL, [Rick. 10 Rules for Scalable Performance in ‘Simple Operation’ Datastores](https://doi.org/10.1145/1953122.1953144). Communications Of The Acm, v. 54, n. 6, p. 72-80, jun. 2011.

<a id="[Silberschatz-2006"></a>
- SILBERSCHATZ, A.; KORTH, H. F.; SUDARSHAN, S. Sistema de banco de dados. 5 ed. Rio de Janeiro: Elsevier, 2006. p. 300.